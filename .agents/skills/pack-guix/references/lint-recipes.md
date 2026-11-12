# jeans lint-fix recipes — `guix lint` warning classes from the cron auto-fix workflow

Scope: concrete lint warnings observed in `~/Projects/Config/jeans` during
cron auto-fix sessions (especially the `jeans-issue-fixer` cron job), with
the exact patch hunks and re-check commands.
原 `jeans-channel-workflow` §3（已撤），2026-11-12 迁入本目录。

Authoritative baseline: Guix `9e068cc03bfacbbcd199f3618fcf360df3f368e0`.
Re-verify `guix lint -l` on the host before trusting these recipes — checker
names drift between Guix commits.

---

## Recipe 1: `wrap-program` package missing `bash-minimal` in inputs

**Checker:** `wrapper-inputs`
**Affected class:** Any `-bin` / Electron / .deb-wrap package using
`wrap-program` after patchelf. The most common silent failure introduced by
`scripts/check-updates/update_versions.py` since it only edits `version`
and `base32` and does NOT touch `inputs`.

### Before

```scheme
;; modules/jeans/packages/agent.scm, zcode@3.3.0
(arguments
 (list
  #:tests? #f
  #:validate-runpath? #f
  #:strip-binaries? #f
  ...
  (add-after 'install-icons 'wrap-program
    (lambda* (#:key inputs outputs #:allow-other-keys)
      ...
      (wrap-program (string-append out "/bin/zcode")
        `("LD_LIBRARY_PATH" prefix ...))))))
(native-inputs (list binutils patchelf tar xz))
(inputs `(("alsa-lib" ,alsa-lib)
          ("at-spi2-core" ,at-spi2-core)
          ("cups" ,cups)
          ...))
```

Lint output:

```
modules/jeans/packages/agent.scm:904:2: zcode@3.3.0: 使用 'wrap-program' 时应在 'inputs' 中包含 "bash-minimal"
```

### Fix

Insert one line in the quasiquote alist at alphabetical position (`at-spi2-core`
is before `bash-minimal`; `bash-minimal` comes before `cups`).

```diff
     (inputs `(("alsa-lib" ,alsa-lib)
               ("at-spi2-core" ,at-spi2-core)
+              ("bash-minimal" ,bash-minimal)
               ("cups" ,cups)
```

`bash-minimal` is already imported via `#:use-module (gnu packages bash)` in
`agent.scm` (line 13) — 13 packages in the same file use it. Pattern matches
the existing label conventions from AGENTS.md "input label 规范".

### Re-check

```bash
guix lint -c wrapper-inputs -L modules zcode
guix build -L modules -e '(@ (jeans packages agent) zcode)' --no-grafts
guix repl -L modules /dev/stdin <<< '(use-modules (jeans)) (display "OK\n")'
```

All three must exit 0. `wrapper-inputs` should report no warning.

---

## Recipe 2: description missing trailing period

**Checker:** `description`
**Affected class:** New or auto-updated packages where `(description "...")`
ends with a parenthetical like `(revert guix patch)` rather than a sentence.
Lint's sentence-terminator heuristic flags this even when the string's first
sentence ended with `.`.

### Variant A — single-string description

`opentabletdriver-udev-rules@0.6.7`:

```diff
-    (description "Open source, cross-platform, user-mode tablet driver")
+    (description "Open source, cross-platform, user-mode tablet driver.")
```

### Variant B — multi-line description with trailing parenthetical

`librewolf-nongnu@152.0.4-1` (multi-line `(description "...")` block ending
in `(revert guix patch)`):

```diff
        (description
         "LibreWolf is designed to increase protection against tracking and
    fingerprinting techniques, while also including a few security improvements.
    This is achieved through our privacy and security oriented settings and
    patches.  LibreWolf also aims to remove all the telemetry, data collection and
-   annoyances, as well as disabling anti-freedom features like DRM. (revert guix patch)")
+   annoyances, as well as disabling anti-freedom features like DRM. (revert guix patch).
+This package reverts the upstream Guix patch.")
```

Why not just add `.` inside the parenthetical (revert guix patch.)? Because the
parenthetical is meant to read as an inline parenthetical, not a sentence by
itself. Appending a real sentence after it reads better and lint is happy.

### Re-check

```bash
guix lint -c description -L modules <pkg>
```

---

## Recipe 3: `coreutils` → `coreutils-minimal` (DON'T apply for `-bin` packages)

**Checker:** `inputs-should-be-minimal`
**Affected class:** Wide.

`crush-bin@0.83.0` (and many other -bin packages) report this. Tempting to
auto-fix but **wrong**: the install phase uses
`(mkdir-p ...)` / `(copy-file ...)` / `(invoke "cp" ...)` / `find-files`
etc — operations that are coreutils itself, not GNU userland shell tools.
Replacing with `coreutils-minimal` would silently break install phase on
build dependencies like cp, install, find, mv.

**Verdict:** keep `coreutils` in `(inputs ...)` of -bin packages. Lint noise
must be accepted.

---

## Recipe 4: AGENTS.md drift — `source/channel.lock` does not exist

**Not a lint warning but a documented-path drift that catches new agents.**

`AGENTS.md` (project context, auto-injected) describes a layout including
`source/channel.lock`. The actual repository has only:

- `.guix-channel` (root, standard Guix channel manifest — declares
  `(name jeans)` + `nonguix` dependency + `directory "modules"`)
- No `source/` directory
- No `channel.lock` file

The blueprint (`blueprint.scm`) and `blue` CLI use `-L modules` + the
`.guix-channel` declaration. There is NO need to recreate `source/channel.lock`.

**If you ever search for it** during auto-fix, that's why it's missing —
don't add a fake `source/` directory to match AGENTS.md; correct fix would
be a future AGENTS.md cleanup (not in scope for a lint-fix cron run).

---

## Recipe 5: Text-level paren delta is misleading — what to verify instead

Counting `(` vs `)` as bytes in `browser.scm`:

```
text ( count: 398
text ) count: 392
text diff:    6
```

This 6-character delta is **HEAD state** (pre-existing in repo). Comparing
the byte count between current working tree and
`git show HEAD:<file>` confirmed identical 6 — meaning the
description-string edits I made did NOT introduce the delta. The `(` in
`'https://services.addons.mozilla.org/api/v4/...'` and
`(revert guix patch)` literals account for it.

### The only trustworthy verification chain

1. **`guix repl -L modules /dev/stdin` + `(use-modules (jeans))`** —
   must print the sentinel `OK` marker; this exercises every package file
   to compile + bind to its public interface.
2. **`guix build -L modules -e '(@ (jeans packages <file>) <pkg>)'`** —
   must return 0; this proves the specific patched package's derivation
   compiles. **Do not** rely on `guix build -n` alone — `-n` skips the
   real fixed-output validation.
3. **`guix lint -n -L modules <pkg>`** with a filter that drops the
   `substitute*` "line too long" noise, the `search-path %load-path`
   relative-path false positives, and the auto-generated-tar noise (see
   skill §5.2 for the exact filter regex).

All three green = real verification. Byte-counting `(`, `)` is not.

### Ad-hoc verification script template

For cron auto-fix, when the system asks for fresh passing verification
evidence, write a `/tmp/hermes-verify-*.sh` script that runs all three
above + a `git diff` self-check. Then delete the script + log after.
Keep the script under 60 lines. Example: see the 5-step template inline
in the SKILL.md §3.4.

---

## Quick-reference checker table (Guix 9e068cc baseline)

| Warning text (zh)                                  | Checker               | Auto-fix? | Notes                                                                   |
| -------------------------------------------------- | --------------------- | --------- | ----------------------------------------------------------------------- |
| 应在 'inputs' 中包含 "bash-minimal"                | `wrapper-inputs`      | ✅        | §Recipe 1                                                              |
| 输入标签与包名不匹配                               | `input-labels`        | ✅        | Use quasiquote alist `("foo:lib" ,foo "lib")` — AGENTS.md has the table |
| description should end with a period               | `description`         | ✅        | §Recipe 2                                                              |
| coreutils 可能应改 -minimal                         | `inputs-should-be-minimal` | ⚠ skip | §Recipe 3 — false positive for -bin packages                            |
| 第 N 行过长                                        | `formatting`          | ❌        | `substitute*` patterns legitimately long; cosmetic noise              |
| 解析为相对于当前目录                               | (carry-over)          | ❌        | `search-path` false-positive — skill §5.2                              |
| 自动生成的 tar 包 / 源文件名应包含包名            | `source-unstable-tarball` | ❌    | GitHub archive format is intentional; conflicts with §1.1 url-fetch     |
| 补丁文件名应以包名开头 / 补丁缺少注释              | `patch-file-names` / `patch-headers` | ⚠ manual | Cosmetic; rename + add header together, breaks referrer paths       |

**Cron policy:** Auto-fix only the ✅ rows; report the ⚠ rows but don't touch;
ignore ❌ entirely.

---

## Verification of this skill (2026-07-11)

These recipes were extracted from a real cron auto-fix session that touched
3 files (zcode / librewolf-nongnu / opentabletdriver-udev-rules) and
achieved lint green on all three before being deleted from the working
tree by the user. The 5-step verification chain (repl / lint / derivation
/ byte-diff / git diff self-check) was the working pattern.

## 3. Lint + verification

`guix lint -L modules <pkg>` is mandatory after any package modification per AGENTS.md. The repo's auto-update CI does NOT run lint — it only runs `guix build`. So lint regressions sneak in via auto-updates; spot-check lint on any package that appears in `report.json` with status `updated` before merging.

### 3.1 `guix lint` checker names — Guix 9e068cc baseline

The single combined `inputs` checker from older Guix was **split into 4** in 9e068cc. When debugging lint invocation failures, run `guix lint -l` once on the host to confirm the current name set; this list drifts between Guix commits. As of Guix `9e068cc03bfacbbcd199f3618fcf360df3f368e0`:

- `wrapper-inputs` — flags packages using `wrap-program` but missing `bash-minimal` in `inputs`. **Common in -bin packages** that do `wrap-program ... LD_LIBRARY_PATH prefix ...` after patchelf. (This was rolled into the old `inputs` checker; treat "wrapper-inputs" as the authoritative name now.)
- `input-labels` — label must match the package's actual `name` field. Use quasiquote alist `("foo:lib" ,foo "lib")`, not `(list foo `(,foo "lib"))` (the modern form generates bare `"foo"` label and trips lint). AGENTS.md has the full table.
- `inputs-should-be-minimal` — suggests `coreutils` → `coreutils-minimal`, etc. Usually **a false positive** for -bin packages that need full GNU coreutils at install time (cp / install / find). Don't blindly apply.
- `inputs-should-be-native` — only relevant for `native-inputs`. Less common.
- `description` — first-sentence-validity + **"description should end with a period"** (sentence-terminator check). Trailing `(revert guix patch)` and similar parentheticals without a final period trip this; fix is to append a final English sentence ending in `.`.
- `formatting` — line-length and formatting hygiene. Long `(substitute* "..." "..."  "..."` patterns with embedded `\n` legitimately exceed 89 chars; treat as unfixable noise.
- `source-unstable-tarball` / `source-file-name` — flags `archive/refs/tags/v<X>.tar.gz` from GitHub. Often a false positive for jeans since the CI auto-update script depends on the GitHub archive tarball URL format. Don't mask with `file-name` override without checking §1.1 first.
- `patch-file-names` / `patch-headers` — flags `Foo.patch` style. Cosmetic only.

**Cron rule of thumb:** when picking packages to lint-sweep during auto-fix, pick 1 representative from each category that lint complains about; the **wrapper-inputs** class is the highest-impact silent failure (introduced by any auto-update that adds `wrap-program` but forgets `bash-minimal`).

### 3.2 Text-level paren delta is a false signal, not a real mismatch

If you `git diff` or byte-count `(` vs `)` on a `.scm` file and get a non-zero delta, **do not panic**. The delta almost always comes from `(`, `)` characters inside string literals — URLs (`https://...`), `(revert guix patch)`, `substitute*` regex patterns (`\\(`), or `local-file` paths. Verify the real signal via:

1. `(use-modules (jeans))` in a fresh `guix repl -L modules /dev/stdin` — should print your sentinel string.
2. `guix build -L modules -e '(@ (jeans packages <file>) <pkg>)' --no-grafts` — must resolve to a derivation without throwing.
3. `guix lint -n -L modules <pkg>` — for the specific class of warning you changed.

All three green = real verification. The byte-delta alone is meaningless.

反过来，当 REPL 报 `Syntax error` 或 `package: missing field initializers (synopsis description license home-page)` 时，那是**真的**括号错了——后者特指多了一个 `)` 提前闭合 `package` 表单，往 `inputs` / `rpath` 列表插行时数错尾部括号就会触发（列表收尾的 `)` 和表单收尾的 `)` 是两个）。此时 `guix build -L modules <pkg>` 只会报 `未绑定变量` / `未知软件包`（模块加载失败 → 符号找不到），所以**报"未知软件包"时先跑一次 `guix repl -L modules` 拿真实错误**，别照着 §5.1 的 re-export 缺失去改 `%public-modules`。

### 3.3 Common lint-fix recipes (proven recipes)

Full transcripts (input/output, the exact patch hunks, and re-check commands) live in `references/lint-recipes.md`. Canonical classes:

- **Wrap-program + missing bash-minimal** → add one line to `inputs` after `at-spi2-core` (alphabetical insert), `("bash-minimal" ,bash-minimal)`. Re-run `guix lint -c wrapper-inputs -L modules <pkg>` to confirm.
- **Description trailing-period** → two valid fixes: add `.` at end of last quoted string in `(description "...")`; or append `.<sentence>.` after a trailing parenthetical.
- **coreutils → coreutils-minimal** → DON'T apply for binary wrappers; verify with `man <pkg>` what install-time tools are needed before subsituting.

### 3.4 Auto-fix session template

When cron auto-fix runs lint sweep, follow this exact 5-step flow:

```bash
# 1. Pull + status
git -C ~/Projects/Config/jeans pull --ff-only

# 2. Module load smoke
guix repl -L modules /dev/stdin <<< '(use-modules (jeans)) (display "OK\n")'

# 3. Lint 3-5 representative packages per category
guix lint -n -L modules <representative-1> <representative-2> ...

# 4. Apply minimal patches via `patch` tool with surrounding context
#    - keep alphabetical input order
#    - match §3.3 recipes

# 5. Re-run lint targeted at patched packages only
guix lint -n -L modules <pkg>  # each one you touched
```

Critical: **do not auto-push or auto-commit** GPG-signed fixes for jeans. The cron only generates patches; user owns the GPG signature + push. This matches the existing §4.1 commit-message guidance.

