```

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

```

# jeans -- Just Enough AI-geNerated Slops.

### A Self-Using Guix Channel target to some cutting-edge softwares and some close-source software.

### AI-Assisted.

Primary repository: `https://github.com/ShineBreaker/jeans.git`

Mirror: `https://codeberg.org/BrokenShine/jeans.git`

## How to use:

adding the following line to your channel:

```scheme
                (channel
                  (name 'jeans)
                  (branch "main")
                  (url "https://github.com/ShineBreaker/jeans.git")
                  (introduction
                   (make-channel-introduction
                    "1e30ccbcaef375169d453d89d8186137bc32d9e8"
                    (openpgp-fingerprint
                     "6271 1D5E 9CCD EC69 07CA  DBF8 8637 1322 2257 1907"))))
```

If you prefer the mirror, `https://codeberg.org/BrokenShine/jeans.git` should track the same `main` branch.

## Available Packages

### (jeans packages browser)

| Package            | Description                                                                              |
| ------------------ | ---------------------------------------------------------------------------------------- |
| `librewolf-nongnu` | Custom version of Firefox, focused on privacy, security and freedom. (revert guix patch) |

### (jeans packages desktop)

| Package           | Description                                                                 |
| ----------------- | --------------------------------------------------------------------------- |
| `waypaper`        | GUI wallpaper manager for Wayland and Xorg Linux systems                    |
| `zen-browser-bin` | Experience tranquillity while browsing the web without people tracking you! |

### (jeans packages fonts)

| Package                  | Description                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `font-maple-font-nf-cn`  | Maple Mono - An open source monospace font with round corner, ligatures and Nerd-Font icons |
| `font-misans`            | MiSans - A font family for Xiaomi HyperOS (non-free license)                                |
| `font-nerd-symbols`      | Nerd Fonts Symbols Only - Iconic font aggregator                                            |
| `font-nerd-font-iosevka` | Nerd Fonts Symbols Only - Iconic font aggregator                                            |

### (jeans packages games)

| Package                     | Description                                                       |
| --------------------------- | ----------------------------------------------------------------- |
| `lr2oraja-endlessdream-bin` | Community fork of beatoraja BMS rhythm game with QoL improvements |
| `osu-lazer-bin`             | rhythm is just a _click_ away!                                    |

### (jeans packages hardware)

| Package                       | Description                     |
| ----------------------------- | ------------------------------- |
| `opentabletdriver-udev-rules` | UDev rules for OpenTabletDriver |

### (jeans packages terminals)

| Package      | Description                                                              |
| ------------ | ------------------------------------------------------------------------ |
| `kitty-full` | Fast, feature-rich, GPU-based terminal emulator. (with kitten utilities) |

### (jeans packages theme)

| Package                | Description                                                                         |
| ---------------------- | ----------------------------------------------------------------------------------- |
| `colloid-gtk-theme`    | Colloid GTK theme - A modern Material Design theme for GTK                          |
| `vimix-gtk-themes`     | Vimix GTK themes - Flat Material Design theme for GTK 3, GTK 2 and GNOME-Shell      |
| `vimix-kvantum-themes` | Vimix Kvantum themes for KDE Plasma                                                 |
| `orchis-kde-themes`    | Orchis Kvantum themes for KDE Plasma (includes aurorae, color-schemes, wallpapers)  |
| `colloid-kde-themes`   | Colloid Kvantum themes for KDE Plasma (includes aurorae, color-schemes, wallpapers) |

### (jeans packages tools)

| Package                    | Description                                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| `cc-switch-bin`            | All-in-One assistant for Claude Code, Codex & Gemini CLI                                     |
| `crush-bin`                | AI-powered coding assistant for the CLI                                                      |
| `git-credential-keepassxc` | Use KeePassXC as a command-line credential store                                             |
| `jdtls-bin`                | Java language server                                                                         |
| `motrix-next-bin`          | Full-featured download manager                                                               |
| `opencode-bin`             | The open source AI coding agent                                                              |
| `warp-terminal-bin`        | Rust-based terminal with AI and modern developer experience                                  |
| `winapps`                  | Run Windows applications on GNU/Linux seamlessly (Microsoft 365, Adobe Creative Cloud, etc.) |

## Usage Examples

Install a package:

```bash
guix install librewolf-nongnu
```

or using the channel prefix:

```bash
guix install jeans:librewolf-nongnu
```

## How to use OpenTabletDriver

- add `opentabletdriver-service-type` to your configuration
- install OpenTabletDriver in flatpak
- disable hid-uclogic & wacom kernel modules

## Development

This repository includes a `maak.scm` for common tasks:

```bash
# Check for package updates
maak upgrade

# Build a package
maak build librewolf-nongnu
```

## License

Packages in this channel are under various licenses. Please check individual package definitions for details.
