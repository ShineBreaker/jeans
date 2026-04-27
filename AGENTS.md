# AGENTS.md — jeans Guix Channel

## What This Repo Is

A personal [Guix channel](https://guix.gnu.org/manual/en/html_node/Channels.html) named **jeans** (Just Enough AI-geNerated Slops). It packages cutting-edge and close-source software for GNU Guix, with AI assistance. Hosted at `https://github.com/ShineBreaker/jeans.git` on the `main` branch, with Codeberg mirroring from GitHub.

The channel depends on [nonguix](https://gitlab.com/nonguix/nonguix) (declared in `.guix-channel`). Some packages import from `(nongnu ...)` modules (e.g. `hardware.scm` uses `nongnu packages dotnet`).

## Build Commands

```bash
# Build a single package
maak build <package-name>
# Equivalent to: guix build --load-path=./modules <package-name>
# Supports multiple: maak build pkg-a pkg-b

# Check all packages for upstream updates
maak upgrade
# Runs scripts/check-updates/update_versions.py via guix shell

# Direct guix build (alternative)
guix build -L modules <package-name>
```

## Repository Layout

```
modules/                          # Channel package directory (set in .guix-channel)
  jeans.scm                       # Top-level module: re-exports all submodules via %public-modules
  jeans/packages/                 # Package definitions by category
    browser.scm                   # librewolf-nongnu (trivial-build-system, omni.ja patching)
    desktop.scm                   # waypaper, niri-latest (cargo + custom phases)
    fonts.scm                     # Font packages (font-build-system, copy-build-system)
    games.scm                     # Binary game packages (-bin suffix, AppImage extraction)
    hardware.scm                  # opentabletdriver-udev-rules
    terminals.scm                 # kitty-full
    theme.scm                     # GTK/KDE theme packages
    tools.scm                     # Mixed: git-fetch, binary, Rust packages
    rust-crates.scm               # Rust crate sources — managed by guix import, DO NOT EDIT manually
  jeans/services/
    hardware.scm                  # Guix service definitions (opentabletdriver-service-type)
  jeans/patches/
    WinApps.patch                 # Patches referenced by package definitions via local-file
scripts/check-updates/
  update_versions.py              # Automated version checker (GitHub API)
  test_updated_packages.py        # Build tester for updated non-binary packages
  config.json                     # Skip/pre-release config for the updater
  manifest.scm                    # guix shell manifest: python + python-requests
maak.scm                          # Build task runner (maak tool)
```

## Commit Messages

Prefix style: `ADD:`, `FIX:`, `UPDATE:`, `FEATURE:`, `MIGRATE:` — followed by a short description. Auto-update CI uses `UPDATE: auto package update YYYY-MM-DD`.

## Package Patterns

### Rust Packaging (Two-File Pattern)

Rust packages use a two-file pattern:

1. **`rust-crates.scm`** — `crate-source` definitions + `define-cargo-inputs` mapping. **Managed by `guix import crate --lockfile`, never edit manually.** The update script skips this file entirely.
2. **Package file** (e.g. `desktop.scm`, `tools.scm`) — `package` definition referencing `(cargo-inputs '<name> #:module '(jeans packages rust-crates))`

Key Rust package arguments:

- Always specify `#:rust rust-1.88` (or current version) and `#:install-source? #f` for application crates.
- Use `#:cargo-install-paths ''(".")` when the crate root is the workspace root.
- Rust packages may need custom `unpack` phases to rewrite `Cargo.toml` entries (strip `git =`, `rev =` lines, replace with `version = "*"` for vendored deps).

### Prebuilt Binary Packages (`-bin` suffix)

- **AppImage packages**: Extract with `7z x`, then `patchelf` all ELF binaries + `.so` files. Use `copy-build-system` with `#:install-plan`.
- **tar.gz/deb binaries**: `gnu-build-system` with deleted `configure`/`build` phases, custom `install`.
- `patchelf` is required to set ELF interpreter (`ld-linux`) and RPATH for Guix store paths.
- Set `#:tests? #f` (no source → no tests).
- Set `#:validate-runpath? #f` when patchelf on all `.so` files is impractical (e.g. JavaFX SDK).
- Install binary to `lib/<pkg>/` and symlink from `bin/` so patchelf can find co-located `.so` files.
- Binary packages (`-bin`) are excluded from CI build testing — only source packages are build-tested.

### `trivial-build-system` Wrapping Pattern

`librewolf-nongnu` uses a distinctive pattern:

- `source #f` + `trivial-build-system` with `#:builder` — operates on an inherited package's store output.
- `(inherit librewolf)` wraps the upstream Guix package.
- `dereference!` helper replaces symlinks with real copies before patching (Guix store paths are read-only symlinks).
- `chmod` dance: `#o644` → patch → `#o444` (make writable, edit, make read-only).
- `omni.ja` patching via embedded Python scripts — unzips, modifies JS modules, rezips.

### Git-Fetch Packages with Fixed Commits

- Version format: `0-unstable-YYYY-MM-DD` for rolling-commit packages.
- The update script uses a placeholder hash (`000...000`) for git-fetch packages; you **must** rebuild to get the correct hash.
- Pinned-commit packages: `(let ((commit "...") (revision "0")) ...)` with `(git-version ...)`.

### Common Build Phase Patterns

- **`wrap-program`**: Always wrap to set `PATH`, `LD_LIBRARY_PATH`, `GI_TYPELIB_PATH`, `XDG_DATA_DIRS`, etc.
- **`substitute*`**: For patching `.desktop` files, configs, and source files.
- **`(,gcc "lib")`**: Syntax for selecting a sub-output of a package.
- **`properties` field**: `'((upstream-name . "osu"))` — used by the update script to map package name to GitHub repo name.
- **Private helper packages**: Use `define` (not `define-public`) for packages only used within the same file.

### Font Packages

- Use `font-build-system` for standard font archives.
- Use `copy-build-system` for single-file font downloads.
- Local license files use `(local-file "../../../licenses/<file>")` with relative paths.

### Service Definitions

Pattern: `define-record-type*` → `service-type` with extensions → convenience wrapper function.

Services extend:

- `udev-service-type` for udev rules
- `kernel-module-loader-service-type` for kernel modules

## Update Workflow

1. Run `maak upgrade` — the script scans all `.scm` files in `modules/jeans/packages/`, parses `define-public` blocks via regex, checks GitHub releases/tags/commits API.
2. **url-fetch packages**: Auto-computes correct `base32` via `guix download <url>`.
3. **git-fetch packages**: `git clone --depth=1` + `guix hash -rx <dir>` for hash computation. Sets placeholder hash for some; you must rebuild to get the real hash.
4. Version normalization: strips leading `v` from GitHub tags (Guix convention: no `v` prefix).
5. Config in `scripts/check-updates/config.json`:
   - `check_pre_release`: packages that check pre-release versions too.
   - `skip_packages`: packages to skip entirely.
   - `skip_files`: files to skip (e.g. `rust-crates.scm`).
6. Exit codes: 0 = no updates, 1 = updates applied, 2 = errors.
7. After update, `test_updated_packages.py` runs `guix build` for non-binary updated packages.

## CI Pipeline

The `auto-update.yml` workflow runs weekly (Monday 02:00 UTC) or on manual trigger:

1. Install Guix on Ubuntu runner
2. Run update script → detect changes
3. GPG-sign commits with workflow key
4. Build test updated non-binary packages
5. Push to GitHub → mirror to Codeberg
6. Create GitHub Issues for build failures (with deduplication)

## Gotchas

- **Don't copy `rust-crates.scm` from other channels.** Version mismatches will cause `cargo build --offline` failures. Always use `guix import crate --lockfile`.
- **`licenses/misans.txt`** is referenced by `font-misans` via `local-file` with relative path (`../../../licenses/misans.txt`) — path is relative to the `.scm` file, not the repo root.
- **The `nonguix` channel is a hard dependency** — declared in `.guix-channel` and required at build time.
- **File headers**: All `.scm` files use `SPDX-FileCopyrightText` and `SPDX-License-Identifier` headers. New files should include `BrokenShine <xchai404@gmail.com>` copyright.
- **`#:use-module ((guix licenses) #:prefix license:)`** is the standard import pattern for licenses — always prefix with `license:`.
- **`jeans.scm`** re-exports all submodules — when adding a new package file, add its module to `%public-modules` in `jeans.scm`.
