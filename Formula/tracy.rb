class Tracy < Formula
  desc "Real-time, nanosecond resolution frame profiler (Tenstorrent fork)"
  homepage "https://github.com/wolfpld/tracy"

  # Stable: pinned GitHub archive + checksum (bump via scripts/bump_tracy_formula.py).
  stable do
    url "https://github.com/tenstorrent/tracy/archive/refs/tags/v0.13.3-tt.0-test.tar.gz"
    sha256 "d19e9a4c9a1ac7d4fb76534ccb2a36ae8bd771a23092e81a72ffd02e2f769a25"
  end

  # Pin a single commit (edit locally or PR): set revision on head, e.g.
  #   head "https://github.com/tenstorrent/tracy.git", revision: "FULL_SHA_HERE"
  head "https://github.com/tenstorrent/tracy.git", branch: "master"

  license "BSD-3-Clause"

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
    system "cmake", "-S", "profiler", "-B", "profiler/build",
                   "-DCMAKE_BUILD_TYPE=Release",
                   "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", "--build", "profiler/build", "--parallel"
    bin.install "profiler/build/tracy-profiler"
    bin.install_symlink "tracy-profiler" => "tracy"
  end

  test do
    assert_match(/Tracy Profiler 0\.13\.3/, shell_output("#{bin}/tracy --help"))

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
