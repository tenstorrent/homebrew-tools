# homebrew-tools

Homebrew tap with Tracy formulae from **[tenstorrent/tracy](https://github.com/tenstorrent/tracy)**.

## Overview

This tap provides two Homebrew formulae for the [Tracy](https://github.com/wolfpld/tracy) frame profiler built from the [Tenstorrent fork](https://github.com/tenstorrent/tracy):

| Formula | Source | Use case |
|---|---|---|
| `tracy` | Pinned release tag + checksum | Stable, reproducible installs |
| `tracy-experimental` | Arbitrary branch via `HOMEBREW_TRACY_BRANCH` | Testing unreleased branches |

Both formulae install a `tracy` binary (the profiler GUI) and **cannot be installed simultaneously**.

---

## Requirements

- **macOS** (Intel or Apple Silicon) or **Linux** (via [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux))
- [Homebrew](https://brew.sh) installed
- For `tracy-experimental --HEAD --build-from-source`: Xcode Command Line Tools on macOS (`xcode-select --install`) or equivalent build tools on Linux (`cmake`, `make`)

## Getting Started

For a normal install of the latest **stable** Tracy GUI:

```bash
brew tap tenstorrent/tools
brew update
brew install tenstorrent/tools/tracy
```

See the sections below for upgrades, clean installs, and building from a custom branch (`tracy-experimental`).

### Upgrade to the latest stable

```bash
brew update
brew upgrade tenstorrent/tools/tracy
```

### Clean install of the latest stable

If other versions of the Tracy GUI were installed, switch to the latest stable version:

```bash
brew uninstall tracy 2>/dev/null || true
brew uninstall tracy-experimental 2>/dev/null || true
brew update-reset
brew tap tenstorrent/tools
brew update
brew install tenstorrent/tools/tracy
```
---

## Tracy from a custom branch (`tracy-experimental`)

Builds the profiler GUI from **`archive/refs/heads/<branch>.tar.gz`** on **github.com/tenstorrent/tracy**.  
Stable **`tracy`** and **`tracy-experimental`** both install a `tracy` binary, so **do not** install both.

Set **`HOMEBREW_TRACY_BRANCH`** on the **same line** as `brew` so Homebrew keeps the variable (see [environment variables](https://docs.brew.sh/Formula-Cookbook#using-environment-variables)).

**Important:** That value must be a **real branch name** on **[tenstorrent/tracy](https://github.com/tenstorrent/tracy)**. Names such as `your/feature-branch` in examples are placeholders only — using them verbatim produces HTTP **404** from GitHub and the install will fail before `brew link`.

To list remote branches:

```bash
git ls-remote --heads https://github.com/tenstorrent/tracy.git
```

`tracy-experimental` is a **HEAD-only** formula, so Homebrew requires **`--HEAD`** on first install commands.

**`brew update-reset`** resets Homebrew core and all taps to match GitHub (discards local edits to taps). You may need to **`brew tap`** again afterward.

### Install from scratch (clean slate)

```bash
brew uninstall tracy 2>/dev/null || true
brew uninstall tracy-experimental 2>/dev/null || true
brew update-reset
brew tap tenstorrent/tools
# Replace with your branch (example below is a real branch on tenstorrent/tracy):
HOMEBREW_TRACY_BRANCH=your/feature-branch brew install --HEAD tenstorrent/tools/tracy-experimental --build-from-source
brew link tracy-experimental --overwrite
```

### Rebuild after tap updates (same branch)

```bash
brew update
HOMEBREW_TRACY_BRANCH=your/feature-branch brew reinstall tenstorrent/tools/tracy-experimental --build-from-source
```

---

## Platform Support

Both formulae support **macOS** (Intel and Apple Silicon) and **Linux** via [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux). On Linux, additional dependencies (`dbus`, `libxkbcommon`) are installed automatically.

> **Note:** The tap name used with Homebrew is `tenstorrent/tools`.

---

## Contributing

Bug reports and pull requests are welcome via [GitHub Issues](https://github.com/tenstorrent/homebrew-tools/issues) and [Pull Requests](https://github.com/tenstorrent/homebrew-tools/pulls). See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

To bump the stable `tracy` formula to a new release tag or commit, use the helper script:

```bash
./scripts/bump_tracy_formula.py v0.13.4-tt.0
```

---

## License

Copyright 2026 Tenstorrent USA, Inc.

The formulae and scripts in this repository are licensed under the [Apache License 2.0](LICENSE). See [LICENSE_understanding.txt](LICENSE_understanding.txt) for additional clarification on patents and related rights.

Tracy itself is licensed under the [BSD 3-Clause License](https://github.com/wolfpld/tracy/blob/master/LICENSE); see [NOTICE](NOTICE) for attribution.
