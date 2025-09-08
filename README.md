# homebrew-tools

Homebrew tap with Tracy formulae from **[tenstorrent/tracy](https://github.com/tenstorrent/tracy)**.

---

## 1. Stable Tracy (pinned release tag)

Latest **stable** build comes from `Formula/tracy.rb` (fixed version + checksum).

### Install from scratch

```bash
brew tap tenstorrent/tools
brew update
brew install tenstorrent/tools/tracy
```

### Upgrade to the latest stable

```bash
brew update
brew upgrade tenstorrent/tools/tracy
```

### Clean slate install

If other versions of tracy gui were tried switching to the latest stable version is required:

```bash
brew uninstall tracy 2>/dev/null || true
brew uninstall tracy-experimental 2>/dev/null || true
brew update-reset
brew tap tenstorrent/tools
brew update
brew install tenstorrent/tools/tracy
```
---

## 2. Tracy from a custom branch (`tracy-experimental`)

Builds the profiler GUI from **`archive/refs/heads/<branch>.tar.gz`** on **github.com/tenstorrent/tracy**.  
Stable **`tracy`** and **`tracy-experimental`** both install a `tracy` binary, so **do not** install both.

Set **`HOMEBREW_TRACY_BRANCH`** on the **same line** as `brew` so Homebrew keeps the variable (see [environment variables](https://docs.brew.sh/Formula-Cookbook#using-environment-variables)).

**`brew update-reset`** resets Homebrew core and all taps to match GitHub (discards local edits to taps). You may need to **`brew tap`** again afterward.

### Install from scratch (clean slate)

```bash
brew uninstall tracy 2>/dev/null || true
brew uninstall tracy-experimental 2>/dev/null || true
brew update-reset
brew tap tenstorrent/tools
HOMEBREW_TRACY_BRANCH=your/feature-branch brew install tenstorrent/tools/tracy-experimental --build-from-source
brew link tracy-experimental --overwrite
```

### Rebuild after tap updates (same branch)

```bash
brew update
HOMEBREW_TRACY_BRANCH=your/feature-branch brew reinstall tenstorrent/tools/tracy-experimental --build-from-source
```
