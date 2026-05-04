# Contributing to homebrew-tools

Thank you for your interest in contributing to this Homebrew tap! This repository hosts Homebrew formulae for the [tenstorrent/tracy](https://github.com/tenstorrent/tracy) profiler fork.

---

## Repository layout

```
Formula/
  tracy.rb               # Stable formula — pinned tag + checksum
  tracy-experimental.rb  # HEAD-only formula — arbitrary branch via env
scripts/
  bump_tracy_formula.py  # Helper to update the stable pin (url + sha256)
```

---

## Development setup

1. **Fork and clone** this repository.
2. Tap your fork locally:
   ```bash
   brew tap tenstorrent/tools <path-to-your-clone>
   ```
3. Edit the formula you want to change under `Formula/`.
4. Validate syntax:
   ```bash
   brew audit --strict tenstorrent/tools/tracy
   ```
5. Run the formula test:
   ```bash
   brew test tenstorrent/tools/tracy
   ```

---

## Bumping the stable pin (`tracy.rb`)

Use the provided helper script to update the tarball URL and checksum automatically:

```bash
# By release tag
python3 scripts/bump_tracy_formula.py v0.13.3-tt.1

# By full commit SHA
python3 scripts/bump_tracy_formula.py --commit FULL_SHA_HERE
```

The script updates `Formula/tracy.rb` in-place. Review the diff, then open a pull request.

---

## Pull request guidelines

- Keep pull requests focused on a single change.
- If bumping the stable pin, include the tag/SHA and the upstream release notes link in the PR description.
- If modifying formula logic, verify the build succeeds locally before opening the PR:
  ```bash
  brew install --build-from-source tenstorrent/tools/tracy
  brew test tenstorrent/tools/tracy
  ```
- Run `brew style` and fix any reported issues:
  ```bash
  brew style --fix Formula/tracy.rb
  ```

---

## Reporting issues

Please open an issue on this repository if you encounter problems with the formulae. Include:
- macOS or Linux version and architecture.
- Output of `brew config`.
- Full output of the failing `brew install` / `brew reinstall` command.
