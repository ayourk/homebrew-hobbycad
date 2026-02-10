# homebrew-hobbycad

Homebrew tap for [HobbyCAD](https://github.com/ayourk/hobbycad) dependencies
not available in Homebrew core.

## Installation

```
brew tap ayourk/hobbycad
```

## Available Formulas

| Formula | Version | Description | License |
|---------|---------|-------------|---------|
| libslvs | 3.2 | SolveSpace constraint solver library | GPL 3.0 |
| openmesh | 11.0.0 | Half-edge polygon mesh data structure | BSD 3-Clause |
| lib3mf | 2.4.1 | 3D Manufacturing Format I/O | BSD 2-Clause |
| meshfix | 2.1 | Automatic mesh repair | GPL 3.0+ |

## Install all HobbyCAD dependencies

```
brew install ayourk/hobbycad/libslvs
brew install ayourk/hobbycad/openmesh
brew install ayourk/hobbycad/lib3mf
brew install ayourk/hobbycad/meshfix
```

## Source Archives

All formulas download source tarballs from the
[hobbycad-vcpkg](https://github.com/ayourk/hobbycad-vcpkg) release
assets. These are git snapshots taken on 2026-02-08 from the upstream
repositories — the same tarballs used for the Launchpad PPA and vcpkg
registry builds.

## Setup Notes

Before using these formulas, you must:

1. Create the `ayourk/hobbycad-vcpkg` repo and upload the source
   tarballs as release assets (see that repo's `sources/README.txt`).
2. Push the `ayourk/homebrew-hobbycad` repo so the patch URLs resolve.

All SHA-256 hashes for tarballs and patches are already populated in
the formula files.
