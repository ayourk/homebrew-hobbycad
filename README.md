# homebrew-hobbycad

<!-- HobbyCAD-homebrew — README.md -->

Homebrew tap for [HobbyCAD](https://github.com/ayourk/hobbycad) dependencies
not available in Homebrew core.

## Installation

```
brew tap ayourk/hobbycad
```

## Available Formulas

### Custom Libraries (not in Homebrew core)

| Formula | Version | Description | License |
|---------|---------|-------------|---------|
| libslvs | 3.2p1 | SolveSpace constraint solver library, HobbyCAD series (snapshot 2026-09-08) | GPL 3.0 |
| openmesh | 11.0.0 | Half-edge polygon mesh data structure | BSD 3-Clause |
| lib3mf | 2.5.0p1 | 3D Manufacturing Format I/O, HobbyCAD build-system series | BSD 2-Clause |
| meshfix | 2.1 | Automatic mesh repair | GPL 3.0+ |

### Version-Pinned Libraries (matching the HobbyCAD PPA)

These formulas pin specific upstream versions to match the packages the
HobbyCAD PPA ships. They are **keg-only** and do not
conflict with the corresponding Homebrew core formulas.

| Formula | Pinned Version | PPA Version | License |
|---------|---------------|---------------------|---------|
| opencascade@8.0.1 | 8.0.1p1 (current) | 8.0.1+p1-1~ppa1 | LGPL 2.1 |
| libzip@1.7.3 | 1.7.3 | 1.7.3 | BSD 3-Clause |
| libgit2@1.7.2 | 1.7.2 | 1.7.2 | GPL 2.0 w/ exception |

> **Note:** Qt 6.4.2 is not pinned via Homebrew because building Qt from
> source takes 2+ hours. Install Qt 6.4.2 via the
> [Qt Online Installer](https://www.qt.io/download-qt-installer) instead,
> or use `brew install qt@6` (rolling latest) if exact version parity is
> not critical for your work.

## Install all HobbyCAD dependencies (pinned)

```bash
# Tap
brew tap ayourk/hobbycad

# Phase 0 — pinned to Ubuntu 24.04 versions (keg-only)
brew install ayourk/hobbycad/opencascade@8.0.1
brew install ayourk/hobbycad/libzip@1.7.3
brew install ayourk/hobbycad/libgit2@1.7.2

# Phase 0 — from Homebrew core (not pinned)
brew install cmake ninja nlohmann-json pybind11 libpng jpeg-turbo
# qt@6 only without a prebuilt Qt 6.4.2 (see the note above)

# Phase 1+ — custom libraries from this tap
brew install ayourk/hobbycad/libslvs
brew install ayourk/hobbycad/openmesh
brew install ayourk/hobbycad/lib3mf
brew install ayourk/hobbycad/meshfix
```

## Using pinned keg-only formulas with CMake

Because the pinned formulas are keg-only, CMake needs to be told where
to find them. Pass `CMAKE_PREFIX_PATH` with all three prefixes:

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_PREFIX_PATH="$(brew --prefix ayourk/hobbycad/opencascade@8.0.1);$(brew --prefix ayourk/hobbycad/libzip@1.7.3);$(brew --prefix ayourk/hobbycad/libgit2@1.7.2);$(brew --prefix qt@6)"
```

Or export the variable in your shell profile:

```bash
export CMAKE_PREFIX_PATH="$(brew --prefix ayourk/hobbycad/opencascade@8.0.1):$(brew --prefix ayourk/hobbycad/libzip@1.7.3):$(brew --prefix ayourk/hobbycad/libgit2@1.7.2):$(brew --prefix qt@6)"
```

## Source Archives

All custom-library formulas download source tarballs from the
[hobbycad-vcpkg](https://github.com/ayourk/hobbycad-vcpkg) release
assets, the same orig tarballs the Launchpad PPA and the vcpkg registry
build from. libslvs and opencascade@8.0.1 carry the HobbyCAD patch
series inside the tarball (the `+pN` in the file name), so the formulas
apply no patches of their own; the other custom libraries are git
snapshots taken on 2026-02-08 from the upstream repositories.

GitHub stores a release asset name with `~` replaced by `.`, so the
URLs spell the snapshot as `3.2.git.20260908` even though the PPA
version is `3.2.git~20260908`.

## Setup Notes

Before using these formulas, you must:

1. Create the `ayourk/hobbycad-vcpkg` repo and upload the source
   tarballs as release assets (see that repo's `sources/README.txt`).
2. Push the `ayourk/homebrew-hobbycad` repo so the patch URLs resolve.
3. Populate SHA256 hashes in the pinned formulas before committing.
   A `populate-sha256.sh` helper script is provided outside of version
   control (see `.gitignore`) — run it from the repo root to download
   the upstream tarballs and insert the hashes automatically.

All SHA-256 hashes for custom-library tarballs and patches are already
populated in the formula files.
