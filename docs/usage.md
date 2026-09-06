<!-- SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com> -->

<!-- SPDX-License-Identifier: GPL-3.0-only -->

## Usage

### Adding the Channel

Add the following to your `.config/guix/channels.scm`:

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

If you prefer the mirror, `https://codeberg.org/BrokenShine/jeans.git` tracks the same `main` branch.

Then run `guix pull`.

### Installing Packages

```bash
guix install librewolf-nongnu
```

Or using the channel prefix:

```bash
guix install jeans:librewolf-nongnu
```

### Running Pre-compiled Binaries (nix-ld)

See [nix-ld guide](nix-ld.md) for detailed instructions on running FHS binaries via the nix-ld service.

### OpenTabletDriver

1. Add `opentabletdriver-service-type` to your system configuration
2. Install OpenTabletDriver via flatpak
3. Disable `hid-uclogic` and `wacom` kernel modules

### Neomacs (Home Service)

`home-neomacs-service-type` installs Neomacs together with Emacs Lisp
extensions into your Guix Home profile.  The extensions live in an
internal profile whose aggregated search paths (`EMACSLOADPATH` etc.)
are set by a wrapper, so launching Neomacs from a shell or a desktop
file always finds them:

```scheme
(use-modules (gnu home)             ;for home-environment
             (gnu services)         ;for service
             (gnu packages)         ;for specifications->manifest
             (jeans home services neomacs))

(home-environment
  (services
   (list (service home-neomacs-service-type
                  (home-neomacs-configuration
                   (packages (specifications->manifest
                              '("emacs-avy" "emacs-magit"))))))))
```

Plain `(service home-neomacs-service-type)` installs Neomacs without
extensions.  Extensions byte-compiled by GNU Emacs load fine; note that
Neomacs' own daemon mode is still experimental upstream, so the service
deliberately ships no shepherd daemon (see the commentary in
`modules/jeans/home/services/neomacs.scm` for details).
