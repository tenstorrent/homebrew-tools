class TracyExperimental < Formula
  desc "Tracy profiler GUI from tenstorrent/tracy (arbitrary branch via env)"
  homepage "https://github.com/wolfpld/tracy"

  TRACY_REPO = "https://github.com/tenstorrent/tracy.git".freeze

  # HEAD-only: Homebrew clones master for the revision stamp; install() replaces the tree with the tarball.
  # Use `head` (not `url` + `version "HEAD"`) so pkg_version stays aligned with `formula.prefix`
  # after `update_head_version` — otherwise bin.install can land in a different Cellar than the
  # empty_installation? check (metafiles-only top-level → bogus "Empty installation").
  head TRACY_REPO, branch: "master"

  license "BSD-3-Clause"

  conflicts_with "tracy", because: "both install a `tracy` binary"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "capstone"
  depends_on "freetype"
  depends_on "glfw"
  depends_on "tbb"

  on_linux do
    depends_on "dbus"
    depends_on "libxkbcommon"
  end

  def install
    branch = tracy_branch_from_env
    encoded = branch.gsub("/", "%2F")
    tarball_url = "https://github.com/tenstorrent/tracy/archive/refs/heads/#{encoded}.tar.gz"

    ohai "Replacing source with tarball: refs/heads/#{branch}"

    buildpath.children.each { |p| rm_rf p }

    curl = ENV.fetch("HOMEBREW_CURL_PATH", "curl")
    system curl, "-fL", tarball_url, "-o", "tracy-src.tgz"
    system "tar", "-xzf", "tracy-src.tgz", "--strip-components=1"

    unless File.exist?("profiler/CMakeLists.txt")
      odie <<~EOS
        profiler/CMakeLists.txt not found after fetching refs/heads/#{branch}.
        Homebrew strips most env vars before formulas run — use HOMEBREW_TRACY_BRANCH (same line as brew). Example:
          HOMEBREW_TRACY_BRANCH=your/feature-branch brew reinstall #{full_name} --build-from-source
        Without it, this formula defaults to branch "master", which may not include the CMake profiler on this fork.
      EOS
    end

    # Force Unix Makefiles (single-config) so install paths are predictable.
    # Default Darwin generator is often Xcode (multi-config); relying on that led to
    # "Empty installation". Avoid depends_on ninja so a broken ninja bottle cache
    # cannot block this formula (uses CLT make instead).
    # Do not use cmake --install for Homebrew: Tracy's install rules + CMake cache
    # often land artifacts outside the Cellar or install nothing brew counts, which
    # surfaces as "Empty installation". Copy the built executable explicitly.
    system "cmake", "-S", "profiler", "-B", "profiler/build",
                   "-G", "Unix Makefiles",
                   "-DCMAKE_BUILD_TYPE=Release",
                   "-DCMAKE_INSTALL_PREFIX=#{prefix}",
                   "-DCMAKE_INSTALL_BINDIR=bin",
                   "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", "--build", "profiler/build", "--parallel"

    # If your brew log still shows `cmake --install` after this line, the formula is stale — run `brew update`.
    ohai "Copying tracy-profiler from profiler/build into prefix (no cmake --install)"

    exe_rel = tracy_profiler_executable_relative_path
    listing = profiler_build_listing_for_odie
    odie <<~EOS unless exe_rel
      Could not find tracy-profiler under profiler/build after build.
      profiler/build (sample paths):
      #{listing}
    EOS

    # Relative path (cwd is buildpath); Hash key as Pathname has confused bin.install.
    bin.install exe_rel => "tracy-profiler"
    bin.install_symlink "tracy-profiler" => "tracy"

    odie "Install produced no #{bin}/tracy-profiler" unless (bin/"tracy-profiler").exist?
  end

  # Relative to buildpath (Homebrew cwd during install). Check flat output first;
  # "**/name" globs do not match build/name. Allow a future macOS .app bundle layout.
  def tracy_profiler_executable_relative_path
    Dir.chdir(buildpath) do
      candidates = ["profiler/build/tracy-profiler"]
      candidates.concat(Dir.glob("profiler/build/**/tracy-profiler"))
      candidates.concat(Dir.glob("profiler/build/**/*.app/Contents/MacOS/tracy-profiler"))
      candidates.concat(Dir.glob("profiler/build/**/*.app/Contents/MacOS/Tracy"))

      candidates.uniq.each do |rel|
        next unless File.exist?(rel)
        next if File.directory?(rel)

        return rel
      end
    end
    nil
  end

  def profiler_build_listing_for_odie
    Dir.chdir(buildpath) do
      found = Dir.glob("profiler/build/**/*", File::FNM_DOTMATCH).reject { |x| x.end_with?("/.", "/..") }
      sample = found.first(60)
      return "(profiler/build missing)" if sample.empty? && !File.directory?("profiler/build")

      sample.join("\n")
    end
  rescue StandardError
    "(could not list profiler/build)"
  end

  def tracy_branch_from_env
    # Homebrew filters env before install; use HOMEBREW_* names (see Formula Cookbook).
    v = ENV.fetch("HOMEBREW_TRACY_BRANCH", "").to_s.strip
    return v unless v.empty?

    "master"
  end

  def caveats
    <<~EOS
      Pick the Git branch with HOMEBREW_TRACY_BRANCH (same line as brew).

        HOMEBREW_TRACY_BRANCH=your/branch brew install #{full_name} --build-from-source

      If brew reports "installed but not linked", unlink the stable formula if needed, then:

        brew unlink tracy 2>/dev/null; brew link #{name} --overwrite

      If install fails after `Copying tracy-profiler…`, run `brew update` and reinstall:

        brew reinstall #{full_name} --build-from-source
    EOS
  end

  test do
    assert_match(/Tracy Profiler/, shell_output("#{bin}/tracy --help"))

    port = free_port
    pid = fork do
      exec "#{bin}/tracy", "-p", port.to_s
    end
    sleep 1
  ensure
    Process.kill("TERM", pid) if pid
    Process.wait(pid) if pid
  end
end
