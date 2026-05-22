<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

# nix-ld: Run Pre-compiled Binaries

## What It Is

[nix-ld](https://github.com/Mic92/nix-ld) is a minimal ELF dynamic linker shim (only 62K) that lets pre-compiled binaries built for FHS (Filesystem Hierarchy Standard) systems — such as Zoom, Master PDF Editor, game clients — run directly on non-FHS systems.

It is widely used in the NixOS community. The jeans channel ports it to Guix System.

### How It Works

Pre-compiled binaries have absolute paths to the dynamic linker embedded in their ELF headers, e.g. `/lib64/ld-linux-x86-64.so.2`. Guix System doesn't have `/lib64/` — the dynamic linker lives at `/gnu/store/…-glibc-2.41/lib/ld-linux-x86-64.so.2`.

nix-ld solves this by:

1.  Placing a symlink at `/lib64/ld-linux-x86-64.so.2` pointing to the nix-ld binary itself
2.  When a pre-compiled binary starts, the kernel loads nix-ld instead of the real `ld-linux`
3.  nix-ld reads the `NIX_LD` (real ld-linux path) and `NIX_LD_LIBRARY_PATH` (library search path) environment variables, then hands control to the real dynamic linker

The whole process is completely transparent to the binary.

## Quick Start

### 1. Enable the service in your OS configuration

In your `operating-system` declaration:

```scheme
(use-modules (jeans services nix-ld))

(operating-system
  (services
   (cons* (service nix-ld-service-type)   ;; ← add this line
          %base-services)))
```

Reconfigure your system:

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

The service automatically:

| Action                                | Effect                                  |
| ------------------------------------- | --------------------------------------- |
| Creates `/lib64/ld-linux-x86-64.so.2` | symlink → nix-ld binary                 |
| Generates `/etc/profile.d/nix-ld.sh`  | Sets `NIX_LD` and `NIX_LD_LIBRARY_PATH` |
| Adds nix-ld to system profile         | Ensures the nix-ld binary is available  |

### 2. Run pre-compiled binaries

Log back in (so `/etc/profile.d/nix-ld.sh` takes effect), then simply run:

```bash
chmod +x some-fhs-binary
./some-fhs-binary
```

That's it.

## Custom Configuration

`nix-ld-service-type` accepts a `nix-ld-configuration` record with three configurable fields:

| Field       | Type                | Default   | Description                                   |
| ----------- | ------------------- | --------- | --------------------------------------------- |
| `package`   | `<package>`         | `nix-ld`  | The nix-ld package itself                     |
| `glibc`     | `<package>`         | `glibc`   | glibc providing the real dynamic linker       |
| `libraries` | `list of <package>` | See below | Libraries to include in `NIX_LD_LIBRARY_PATH` |

### Default Library List

The service adds the following libraries to `NIX_LD_LIBRARY_PATH` by default:

- `glibc` — libc, libm, libpthread, etc.
- `(gcc "lib")` — libstdc++, libgcc_s (needed for C++ programs)
- `zlib` — compression
- `bzip2` — bzip2 compression
- `xz` — xz/lzma compression
- `openssl` — TLS/SSL
- `curl` — HTTP client library
- `expat` — XML parsing
- `ncurses` — terminal UI

This covers the vast majority of pre-compiled binary dependencies. If you need extra libraries:

```scheme
(use-modules (jeans services nix-ld)
             (gnu packages gl)
             (gnu packages sdl)
             (gnu packages audio))

(service nix-ld-service-type
  (nix-ld-configuration
   (libraries
    (append
     %default-nix-ld-libraries    ;; keep defaults
     (list
      mesa                         ;; OpenGL
      `(,gcc "lib")                ;; libstdc++ (already in defaults, shown for syntax)
      sdl2                         ;; SDL2 game engine
      pulseaudio)))))              ;; audio
```

> **Note**: Elements in the `libraries` list can be:
>
> - A `<package>` object (uses its `lib` output)
> - A `(package "output")` tuple (uses the specified output)

## Package-only Install (No Service)

If you don't need the `/lib64/` symlink and auto environment setup, you can install the package alone:

```bash
guix install jeans:nix-ld
```

Then manually set environment variables:

```bash
export NIX_LD=/gnu/store/…-glibc-2.41/lib/ld-linux-x86-64.so.2
export NIX_LD_LIBRARY_PATH=/gnu/store/…-glibc-2.41/lib:\
/gnu/store/…-gcc-14.3.0-lib/lib:…
```

> In most cases you should use the **service** instead.

## Practical Use Cases

### Running Zoom

```bash
# Zoom is a typical FHS pre-compiled binary
# After enabling nix-ld service:
./zoom/zoom
```

### Running indie games

```bash
# Many indie games (e.g. from itch.io) are pre-compiled ELF
./game-binary
```

### Running Steam / Steam games

```bash
# After adding %steam-runtime-libraries to nix-ld-configuration
steam
```

### Running IDEs / toolchains

```bash
# Some closed-source IDEs only ship as pre-compiled binaries
./some-ide/bin/run
```

## Troubleshooting

### `No such file or directory` when running a binary

This usually means `/lib64/ld-linux-x86-64.so.2` doesn't exist. Check if the service is enabled:

```bash
ls -la /lib64/ld-linux-x86-64.so.2
```

If missing, reconfigure:

```bash
sudo guix system reconfigure /path/to/your-config.scm
```

### `error while loading shared libraries: libxxx.so`

A dynamic library is missing. Add the corresponding Guix package to the `libraries` field of `nix-ld-configuration`.

Use `ldd` to check what libraries a binary needs:

```bash
ldd ./your-binary 2>&1 | grep "not found"
```

### Binary doesn't work on non-x86_64

nix-ld and the `/lib64/ld-linux-x86-64.so.2` path are x86_64-specific. On aarch64, the path would be `/lib/ld-linux-aarch64.so.1`. Currently, jeans' nix-ld packaging is only tested on x86_64.

### Environment variables not set

Make sure you've logged back in, or manually source:

```bash
source /etc/profile.d/nix-ld.sh
```

Verify:

```bash
echo $NIX_LD
echo $NIX_LD_LIBRARY_PATH
```
