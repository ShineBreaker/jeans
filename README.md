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

## How to use:

adding the following line to your channel:

```scheme
(channel
  (name 'jeans)
  (branch "main")
  (url "https://codeberg.org/BrokenShine/jeans.git")
  (introduction
    (make-channel-introduction
      "c99bf2e3f67d05b4bcb817037d96fa1340d2be23"
      (openpgp-fingerprint
        "6271 1D5E 9CCD EC69 07CA  DBF8 8637 1322 2257 1907"))))
```

## Available Packages

### (jeans packages desktop)

| Package           | Description                                                                        |
| ----------------- | ---------------------------------------------------------------------------------- |
| `zen-browser-bin` | Zen Browser - A privacy-focused, beautifully designed web browser based on Firefox |
| `waypaper`        | GUI wallpaper manager for Wayland and Xorg Linux systems                           |

### (jeans packages games)

| Package                 | Description                                             |
| ----------------------- | ------------------------------------------------------- |
| `osu-lazer-tachyon-bin` | osu!lazer - A free-to-win rhythm game (Tachyon release) |

### (jeans packages hardware)

| Package                       | Description                                                            |
| ----------------------------- | ---------------------------------------------------------------------- |
| `opentabletdriver-bin`        | Open source, cross-platform, user-mode tablet driver (prebuilt binary) |
| `opentabletdriver-udev-rules` | UDev rules for OpenTabletDriver                                        |
| `opentabletdriver`            | Alias for `opentabletdriver-bin`                                       |

### (jeans packages fonts)

| Package                 | Description                                                                                 |
| ----------------------- | ------------------------------------------------------------------------------------------- |
| `font-maple-font-nf-cn` | Maple Mono - An open source monospace font with round corner, ligatures and Nerd-Font icons |
| `font-misans`           | MiSans - A font family for Xiaomi HyperOS (non-free license)                                |
| `font-nerd-symbols`     | Nerd Fonts Symbols Only - Iconic font aggregator                                            |

### (jeans packages theme)

| Package                | Description                                                                         |
| ---------------------- | ----------------------------------------------------------------------------------- |
| `colloid-gtk-theme`    | Colloid GTK theme - A modern Material Design theme for GTK                          |
| `vimix-gtk-themes`     | Vimix GTK themes - Flat Material Design theme for GTK 3, GTK 2 and GNOME-Shell      |
| `vimix-kvantum-themes` | Vimix Kvantum themes for KDE Plasma                                                 |
| `orchis-kde-themes`    | Orchis Kvantum themes for KDE Plasma (includes aurorae, color-schemes, wallpapers)  |
| `colloid-kde-themes`   | Colloid Kvantum themes for KDE Plasma (includes aurorae, color-schemes, wallpapers) |

### (jeans packages winapps)

| Package   | Description                                                                                  |
| --------- | -------------------------------------------------------------------------------------------- |
| `winapps` | Run Windows applications on GNU/Linux seamlessly (Microsoft 365, Adobe Creative Cloud, etc.) |

## Usage Examples

Install a package:

```bash
guix install zen-browser-bin
```

or using the channel prefix:

```bash
guix install jeans:zen-browser-bin
```

Adding udev rules:

```scheme
(udev-rules-service 'opentabletdriver
                    opentabletdriver-udev-rules)
```

## Development

This repository includes a `justfile` for common tasks:

```bash
# Check for package updates
just upgrade

# Build a package
just build zen-browser-bin
```

## License

Packages in this channel are under various licenses. Please check individual package definitions for details.
