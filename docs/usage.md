<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

# Usage Guide

**English** | [**中文**](zh_CN/usage.md)

This document provides installation instructions and complete service usage guides for the jeans channel.

---

## Table of Contents

- [Adding the Channel](#adding-the-channel)
- [Installing Packages](#installing-packages)
- [System Services](#system-services)
  - [nix-ld](#nix-ld)
  - [OpenTabletDriver](#opentabletdriver)
  - [Sunshine](#sunshine)
  - [Waydroid](#waydroid)
- [Home Services (Guix Home)](#home-services-guix-home)
  - [Neomacs](#neomacs)
  - [OpenTabletDriver Daemon](#opentabletdriver-daemon)
  - [Sunshine Stream Host](#sunshine-stream-host)
  - [nosDshell](#nosdshell)
  - [MSIME Providers](#msime-providers)

---

## Adding the Channel

Add the following declaration to your `~/.config/guix/channels.scm`:

```scheme
(channel
  (name 'jeans)
  (branch "main")
  (url "https://github.com/ShineBreaker/jeans.git")
  (introduction
   (make-channel-introduction
    "35d1811c26daf2c132880fe304149b1363064a79"
    (openpgp-fingerprint
     "6271 1D5E 9CCD EC69 07CA  DBF8 8637 1322 2257 1907"))))
```

If you prefer Codeberg, `https://codeberg.org/BrokenShine/jeans.git` mirrors the same `main` branch.

Update channels with:

```bash
guix pull
```

---

## Installing Packages

Search and install packages directly:

```bash
guix install librewolf-nongnu
```

Or explicitly qualify by channel name to avoid collisions:

```bash
guix install jeans:librewolf-nongnu
```

See [docs/packages.md](packages.md) for the complete list of available packages.

---

## System Services

### nix-ld

`nix-ld-service-type` provides a minimal shim dynamic linker at `/lib64/ld-linux-x86-64.so.2` and configures environment variables via `/etc/profile.d/nix-ld.sh`. This allows precompiled binaries built for FHS (Filesystem Hierarchy Standard) distributions to execute directly on Guix System.

For comprehensive details and practical examples, see the [nix-ld guide](nix-ld.md).

#### Basic Configuration

Add `nix-ld-service-type` to your `operating-system` services:

```scheme
(use-modules (gnu services)
             (jeans services nix-ld))

(operating-system
  ;; ...
  (services
   (cons* (service nix-ld-service-type)
          %base-services)))
```

#### Configuration Record

`nix-ld-configuration` fields:

| Field       | Type                                          | Default                     | Description                                            |
| ----------- | --------------------------------------------- | --------------------------- | ------------------------------------------------------ |
| `package`   | `<package>`                                   | `nix-ld`                    | The nix-ld package.                                    |
| `glibc`     | `<package>`                                   | `glibc`                     | The glibc package providing the target dynamic linker. |
| `libraries` | list of `<package>` or `(<package> "output")` | `%default-nix-ld-libraries` | Shared libraries added to `NIX_LD_LIBRARY_PATH`.       |

#### Adding Custom Libraries

```scheme
(use-modules (gnu services)
             (gnu packages gl)
             (gnu packages sdl)
             (gnu packages audio)
             (jeans services nix-ld))

(service nix-ld-service-type
         (nix-ld-configuration
          (libraries
           (append %default-nix-ld-libraries
                   (list mesa sdl2 pulseaudio)))))
```

---

### OpenTabletDriver

`opentabletdriver-service-type` configures system-level prerequisites for drawing tablets:

- Installs udev rules granting user access to drawing tablet USB/hidraw nodes.
- Loads the `uinput` kernel module required for virtual input emulation.
- Blacklists conflicting kernel modules (`wacom` and `hid_uclogic`) in `/etc/modprobe.d/99-opentabletdriver.conf`.
- Installs `/etc/libinput/local-overrides.quirks` so libinput respects OpenTabletDriver.
- Adds `opentabletdriver-bin` to the system profile.

#### Basic Configuration

```scheme
(use-modules (gnu services)
             (jeans services hardware))

(operating-system
  ;; ...
  (services
   (cons* (service opentabletdriver-service-type)
          %desktop-services)))
```

Alternatively, use the helper procedure `(opentabletdriver-service)`:

```scheme
(cons* (opentabletdriver-service)
       %desktop-services)
```

#### Configuration Record

`opentabletdriver-configuration` fields:

| Field     | Type        | Default                       | Description                                   |
| --------- | ----------- | ----------------------------- | --------------------------------------------- |
| `package` | `<package>` | `opentabletdriver-udev-rules` | Package containing udev rules.                |
| `driver`  | `<package>` | `opentabletdriver-bin`        | Package providing driver binaries and quirks. |

#### Notes

- To run the background driver daemon for user sessions, combine this system service with `home-opentabletdriver-service-type` in your Guix Home configuration.

---

### Sunshine

`sunshine-service-type` configures system-level requirements for the Sunshine self-hosted game stream host (used with Moonlight clients):

- Installs udev rules granting the active user access to `/dev/uinput`, `/dev/uhid`, and virtual gamepad device nodes.
- Loads `uhid` and `uinput` kernel modules.
- Adds the `sunshine-bin` package to the system profile.
- Optionally grants `cap_sys_admin=ep` file capabilities on the real Sunshine binary for DRM/KMS screen capture without root privileges.

#### Basic Configuration

```scheme
(use-modules (gnu services)
             (gnu services avahi)
             (jeans services tools))

(operating-system
  ;; ...
  (services
   (cons* (service sunshine-service-type
                   (sunshine-configuration
                    (cap-sys-admin? #t)))
          ;; mDNS publication enables client auto-discovery
          (service avahi-service-type)
          %desktop-services)))
```

Alternatively, use the helper procedure `(sunshine-service #:cap-sys-admin? #t)`.

#### Configuration Record

`sunshine-configuration` fields:

| Field            | Type        | Default        | Description                                                                                   |
| ---------------- | ----------- | -------------- | --------------------------------------------------------------------------------------------- |
| `package`        | `<package>` | `sunshine-bin` | Package providing Sunshine binaries and udev rules.                                           |
| `cap-sys-admin?` | `boolean`   | `#f`           | Whether to assign `cap_sys_admin=ep` to `/lib/sunshine/usr/bin/sunshine` for KMS/DRM capture. |

#### Prerequisites

- **User groups**: The streaming user must belong to the `video` group (and `render` if present) for GPU hardware encoding access.
- **Firewall ports**: Sunshine listens on base port 47989 by default:
  - TCP: 47984, 47989, 47990, 48010
  - UDP: 47998, 47999, 48000, 48002, 48010
- **Web UI**: Access `https://localhost:47990` for first-run pairing and configuration.
- **User daemon**: Run `home-sunshine-service-type` in Guix Home so the daemon connects to your user display and GPU session.

---

### Waydroid

`waydroid-service-type` configures the Waydroid LXC-based Android container runtime on Guix System:

- Installs system-wide D-Bus policies and service activation files for `id.waydro.Container`.
- Runs the root container manager daemon (`waydroid container start`) as a Shepherd service.

#### Basic Configuration

```scheme
(use-modules (gnu services)
             (jeans services android))

(operating-system
  ;; ...
  (services
   (cons* (service waydroid-service-type)
          %desktop-services)))
```

#### Configuration Record

`waydroid-configuration` fields:

| Field        | Type        | Default    | Description                                                                                                        |
| ------------ | ----------- | ---------- | ------------------------------------------------------------------------------------------------------------------ |
| `waydroid`   | `<package>` | `waydroid` | The Waydroid package to use.                                                                                       |
| `autostart?` | `boolean`   | `#t`       | Whether to start the container daemon at system boot. When `#f`, the daemon starts on demand via D-Bus activation. |

#### First-Time Initialization

The container image must be downloaded manually before starting your first session:

```bash
sudo waydroid init
```

Once initialized, start an Android session inside a Wayland graphical environment:

```bash
waydroid session start
```

Or launch Android apps directly from your desktop launcher. Container logs are written to `/var/log/waydroid-container.log`.

---

## Home Services (Guix Home)

### Neomacs

`home-neomacs-service-type` installs Neomacs along with configured Emacs Lisp extensions into your Guix Home profile.

It builds an internal profile combining Neomacs and package extensions, then sets search paths (such as `EMACSLOADPATH`) through wrapper scripts for `neomacs` and `neomacsclient`. Desktop entries and launcher icons are repointed at the wrapper, ensuring extensions load whether Neomacs is invoked from a shell or a graphical menu.

#### Basic Configuration

```scheme
(use-modules (gnu home)
             (gnu services)
             (gnu packages)
             (jeans home services emacs-xyz))

(home-environment
  (services
   (list (service home-neomacs-service-type
                  (home-neomacs-configuration
                   (packages (specifications->manifest
                              '("emacs-avy"
                                "emacs-magit"))))))))
```

To install Neomacs without extra extensions, use `(service home-neomacs-service-type)`.

#### Configuration Record

`home-neomacs-configuration` fields:

| Field      | Type         | Default          | Description                                                                                              |
| ---------- | ------------ | ---------------- | -------------------------------------------------------------------------------------------------------- |
| `neomacs`  | `<package>`  | `neomacs-bin`    | The Neomacs package.                                                                                     |
| `packages` | `<manifest>` | `(manifest '())` | Manifest of Emacs Lisp packages to install. Extensions compiled with standard GNU Emacs load seamlessly. |

#### Notes

- Neomacs daemon mode is experimental upstream and not yet stable. This service intentionally does not register a Shepherd background daemon.

---

### OpenTabletDriver Daemon

`home-opentabletdriver-service-type` installs OpenTabletDriver into the home profile and manages `otd-daemon` as a user Shepherd service.

Because Shepherd starts at login before the Wayland compositor or X server is running, the service uses an intelligent display wrapper: it polls `$XDG_RUNTIME_DIR/wayland-*` or `/tmp/.X11-unix/X*` and exports `WAYLAND_DISPLAY` or `DISPLAY` before executing `otd-daemon`, preventing premature initialization failures.

#### Basic Configuration

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services hardware))

(home-environment
  (services
   (list (service home-opentabletdriver-service-type))))
```

#### Configuration Record

`home-opentabletdriver-configuration` fields:

| Field     | Type        | Default                | Description                                                              |
| --------- | ----------- | ---------------------- | ------------------------------------------------------------------------ |
| `package` | `<package>` | `opentabletdriver-bin` | The OpenTabletDriver package.                                            |
| `daemon?` | `boolean`   | `#t`                   | Whether to run `otd-daemon` as an auto-restarting user Shepherd service. |

#### Notes

- Always configure `opentabletdriver-service-type` on Guix System alongside this home service to ensure kernel modules and udev rules are active.

---

### Sunshine Stream Host

`home-sunshine-service-type` runs the Sunshine game streaming host as a user Shepherd service. Running under the user account ensures Sunshine has access to the user's Wayland socket, GPU render nodes, and local configuration directory (`~/.config/sunshine`).

#### Basic Configuration

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services tools))

(home-environment
  (services
   (list (service home-sunshine-service-type))))
```

#### Configuration Record

`home-sunshine-configuration` fields:

| Field         | Type        | Default        | Description                                                            |
| ------------- | ----------- | -------------- | ---------------------------------------------------------------------- |
| `package`     | `<package>` | `sunshine-bin` | Package providing Sunshine.                                            |
| `auto-start?` | `boolean`   | `#t`           | Whether to start the service automatically with the graphical session. |

#### Notes

- **Shepherd requirement**: Depends on the `wayland-display` Shepherd provision (provided by `home-wayland-service-type` from Guix upstream or Rosenthal's `home-graphical-session-service-type`).
- **System service**: Requires `sunshine-service-type` on the host Guix System for udev input permissions and kernel modules.
- Logs are saved to `$XDG_STATE_HOME/shepherd/sunshine.log` (typically `~/.local/state/shepherd/sunshine.log` or `~/.local/var/log/sunshine.log`).

---

### nosDshell

`home-nosdshell-service-type` runs nosDshell (a quickshell-based Wayland desktop shell) as a user Shepherd service.

The service inherits the live graphical environment variables and waits for `dbus` and `wayland-display` Shepherd provisions before launching.

#### Basic Configuration

```scheme
(use-modules (gnu home)
             (gnu services)
             (gnu home services desktop)
             (jeans home services desktop))

(home-environment
  (services
   (list (service home-wayland-service-type)
         (service home-nosdshell-service-type))))
```

#### Configuration Record

`home-nosdshell-configuration` fields:

| Field         | Type        | Default     | Description                                                 |
| ------------- | ----------- | ----------- | ----------------------------------------------------------- |
| `nosdshell`   | `<package>` | `nosdshell` | The nosdshell package.                                      |
| `auto-start?` | `boolean`   | `#t`        | Whether to start the shell when `wayland-display` is ready. |

---

### MSIME Providers

`home-msime-service-type` manages the backend provider daemons for MSIME (水杉输入法) as user Shepherd services:

- **Online candidates & translation** (`msime-online`): Provides cloud vocabulary lookup and translation features.
- **Voice input** (`msime-voice`): Provides speech-to-text input backend.
- **Clipboard history monitor** (`msime-clipboard`): Optional background monitor for clipboard history.

On standard distributions, these are started via systemd user socket activation. On Guix, this service starts them eagerly so their features remain available to IBus and Fcitx5 frontend input method engines.

#### Basic Configuration

```scheme
(use-modules (gnu home)
             (gnu services)
             (jeans home services desktop))

(home-environment
  (services
   (list (service home-msime-service-type
                  (home-msime-configuration
                   (online? #t)
                   (voice? #t)
                   (clipboard? #f))))))
```

#### Configuration Record

`home-msime-configuration` fields:

| Field                   | Type              | Default              | Description                                                                                                                                                                    |
| ----------------------- | ----------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `msime`                 | `<package>`       | `msime-bin`          | Package providing MSIME binaries and provider daemons.                                                                                                                         |
| `online?`               | `boolean`         | `#t`                 | Enable the online candidate and translation provider daemon.                                                                                                                   |
| `voice?`                | `boolean`         | `#t`                 | Enable the voice input provider daemon.                                                                                                                                        |
| `clipboard?`            | `boolean`         | `#f`                 | Enable the clipboard history monitor daemon.                                                                                                                                   |
| `clipboard-requirement` | `list of symbols` | `'(wayland-display)` | Shepherd provisions the clipboard monitor must wait for. Use `'(wayland-display)` for Wayland, `'(x11-display)` for X11, or `'()` if display environment is set up beforehand. |
| `auto-start?`           | `boolean`         | `#t`                 | Whether to start enabled providers when Shepherd starts.                                                                                                                       |

#### Notes

- The input method frontends (IBus engine or Fcitx5 addon) are loaded directly by IBus or Fcitx5 and do not require separate Shepherd service definitions.
