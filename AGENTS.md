# AGENTS.md — jeans Guix Channel

## What This Repo Is

A personal [Guix channel](https://guix.gnu.org/manual/en/html_node/Channels.html) named **jeans** (Just Enough AI-geNerated Slops). It packages cutting-edge and close-source software for GNU Guix, with AI assistance. Hosted at `https://github.com/ShineBreaker/jeans.git` on the `main` branch, with Codeberg mirroring from GitHub.

The channel depends on [nonguix](https://gitlab.com/nonguix/nonguix) (declared in `.guix-channel`).

## Build Commands

```bash
# Build a single package
maak build <package-name>
# Equivalent to: guix build --load-path=./modules <package-name>

# Check all packages for upstream updates
maak upgrade
# Runs scripts/check-updates/update_versions.py via guix shell

# Direct guix build (alternative)
guix build -L modules <package-name>
```

## Repository Layout

```
modules/                          # Channel package directory (set in .guix-channel)
  jeans.scm                       # Top-level module: re-exports all submodules
  jeans/packages/                 # Package definitions by category
    browser.scm  desktop.scm  fonts.scm  games.scm
    hardware.scm  terminals.scm  theme.scm  tools.scm
    rust-crates.scm               # Rust crate sources — managed by guix import, DO NOT EDIT manually
  jeans/services/
    hardware.scm                  # Guix service definitions
  jeans/patches/
    WinApps.patch                 # Patches referenced by package definitions
scripts/check-updates/
  update_versions.py              # Automated version checker (GitHub API)
  config.json                     # Skip/pre-release config for the updater
  manifest.scm                    # guix shell manifest for the updater
maak.scm                          # Build task runner (maak tool)
```

## Key Conventions

### Package Naming
- All lowercase with hyphens (e.g. `osu-lazer-bin`, `font-maple-font-nf-cn`)
- Binary packages use `-bin` suffix when packaging prebuilt releases

### Commit Messages
Prefix style: `ADD:`, `FIX:`, `UPDATE:`, `DELETE:` — followed by a short description.

### Rust Packaging
Rust packages use a two-file pattern. See the project skill `guix-rust-packaging` for the full workflow:
- `rust-crates.scm` — `crate-source` definitions + `define-cargo-inputs` mapping. **Managed by `guix import crate --lockfile`, never edit manually.**
- Package file (e.g. `tools.scm`) — `package` definition referencing `(cargo-inputs '<name> #:module '(jeans packages rust-crates))`
- Always specify `#:rust rust-1.88` and `#:install-source? #f` for application crates.

### Prebuilt Binary Packages
- Use `patchelf` to set ELF interpreter (`ld-linux`) and RPATH for Guix store paths.
- Common pattern: `gnu-build-system` with deleted `configure`/`build` phases, custom `unpack` and `install`.
- Set `#:tests? #f` (no source → no tests).

### Git-Fetch Packages with Fixed Commits
- Version format: `0-unstable-YYYY-MM-DD` for rolling-commit packages.
- The update script uses a placeholder hash (`000...000`) for git-fetch packages; run `guix build` to get the correct hash.

## Update Workflow

1. Run `maak upgrade` — checks GitHub releases/tags/commits for all packages.
2. For url-fetch packages: auto-computes correct `base32` via `guix download`.
3. For git-fetch packages: sets placeholder hash; you **must** rebuild to get the real hash:
   ```bash
   guix build -L modules <package>   # will fail with hash mismatch, showing the correct hash
   # Replace placeholder in the .scm file, then rebuild
   ```
4. Config in `scripts/check-updates/config.json` controls pre-release checking and package skipping.

## Gotchas

- **Don't copy `rust-crates.scm` from other channels.** Version mismatches will cause `cargo build --offline` failures. Always use `guix import crate --lockfile`.
- **`player/` directory is empty.** It exists but contains nothing.
- **`licenses/misans.txt`** is referenced by `font-misans` as a local license file via `local-file` with a relative path (`../../../licenses/misans.txt`).
- The `nonguix` channel is a hard dependency — some packages import from `(nonguix ...)` modules (e.g. `hardware.scm` uses `nongnu packages dotnet`).
- `librewolf-nongnu` uses `trivial-build-system` to patch an inherited `librewolf` package — it modifies omni.ja, policies.json, and librewolf.cfg at build time via Python scripts.
