               8 8888 8 8888888888            .8.          b.             8    d888888o.
               8 8888 8 8888                 .888.         888o.          8  .`8888:' `88.
               8 8888 8 8888                :88888.        Y88888o.       8  8.`8888.   Y8
               8 8888 8 8888               . `88888.       .`Y888888o.    8  `8.`8888.
               8 8888 8 888888888888      .8. `88888.      8o. `Y888888o. 8   `8.`8888.
               8 8888 8 8888             .8`8. `88888.     8`Y8o. `Y88888o8    `8.`8888.
    88.        8 8888 8 8888            .8' `8. `88888.    8   `Y8o. `Y8888     `8.`8888.
    `88.       8 888' 8 8888           .8'   `8. `88888.   8      `Y8o. `Y8 8b   `8.`8888.
      `88o.    8 88'  8 8888          .888888888. `88888.  8         `Y8o.` `8b.  ;8.`8888
        `Y888888 '    8 888888888888 .8'       `8. `88888. 8            `Yo  `Y8888P ,88P'

# jeans -- Just Enough AI-geNerated Slops.

**English** \| [**中文**](./README.zh-CN.md)

[**Packages**](docs/packages.md) \| [**Usage**](docs/usage.md) \| [**nix-ld**](docs/nix-ld.md)

### A Self-Using Guix Channel target to some cutting-edge softwares and some close-source software.

### AI-Assisted.

Primary repository: `https://github.com/ShineBreaker/jeans.git`

Mirror: `https://codeberg.org/BrokenShine/jeans.git`

---

## Table of Contents

- [Quick Start](#quick-start)
- [Available Packages](#available-packages)
- [Development](#development)
- [License](#license)

---

## Quick Start

- **Usage Guide** → [docs/usage.md](docs/usage.md) — Channel setup, package installation, and service configuration guide
- **nix-ld Guide** → [docs/nix-ld.md](docs/nix-ld.md) — Running pre-compiled binaries on Guix System
- **Package List** → [docs/packages.md](docs/packages.md)

## Development

This repository includes a `maak.scm` for common tasks:

```bash
# Check for package updates
maak upgrade

# Build a package
maak build librewolf-nongnu

# Import Rust crate sources
maak import-crate <crate-name>[@version]
```

## License

Packages in this channel are under various licenses. Please check individual package definitions for details.
