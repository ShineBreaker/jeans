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
