#!/usr/bin/env python3
"""Merge `guix import crate` output into rust-crates.scm for a cargo-build-system
package whose inputs are looked up via `lookup-cargo-inputs`.

This is a re-implementation of the merge step that previously corrupted
rust-crates.scm.  Key fixes vs. the old script:

  1. Regex `rust-[a-z0-9.+-]+` matches variable names containing hyphens
     (e.g. rust-objc2-open-directory) AND plus signs (e.g.
     rust-wasip2-1.0.3+wasi-0.2.9, rust-toml-edit-0.25.11+spec-1.1.0).
     The old `rust-[\\w.+]+` stopped at the first hyphen, silently dropping
     those definitions and producing a wrong diff.

  2. The input-list replacement locates the `(list ...)` span by parenthesis
     depth counting instead of fragile string slicing, so it survives any
     indentation or inner structure.

  3. New crate-source definitions are copied verbatim from the import file
     (matched as whole `(define rust-... (crate-source ...))` blocks) rather
     than reconstructed, so formatting never drifts.

  4. A post-condition asserts that every variable in the new input list has a
     `(define ...)` somewhere in the merged file — the check that would have
     caught the previous corruption.

Usage:
    python3 merge_crate_inputs.py <package> <rust-crates.scm> <import.scm> [--dry-run]

<package>        the lookup-cargo-inputs key (e.g. git-credential-keepassxc)
<rust-crates.scm> target file (managed by guix import; this script edits in place)
<import.scm>     output of `guix import crate --lockfile ...` — a flat list of
                 `(define rust-... (crate-source ...))` blocks.  The set of
                 defines IS the new input list (every transitive dep appears).

BEFORE running this, verify the build will actually succeed:

  * MSRV — check the new Cargo.lock's highest rust-version / MSRV against the
    rust the package pins via `#:rust` and against what Guix ships
    (`guix show rust | grep version`).  A dependency bump can raise the
    Minimum Supported rust Version past what Guix has packaged (e.g.
    git-credential-keepassxc 0.14.3 pulled sysinfo-0.39.1 needing rustc 1.95,
    while Guix only had 1.93).  In that case the upgrade must be skipped —
    this script only rewrites definitions, it cannot conjure a newer rustc.

  * Build — after merging, run `blue build <package>` (or
    `guix build -L modules <package>`) and read the REAL exit status from the
    guix output, not the wrapper's: a "Compiling sysinfo v0.39.1 (requires
    Rust 1.95)" / "rustc X is not supported" line means failure even if the
    wrapper returns 0.

The script always asserts paren balance implicitly (guix parses the result)
and that every input variable has a definition; run with --dry-run first.
"""
import argparse
import os
import re
import sys
from pathlib import Path

# Matches a Guix rust-crate variable name: letters, digits, '.', '+', '-'.
# MUST include '+' (pre-release/metadata versions like 1.0.3+wasi-0.2.9) and
# '-' (crate names like objc2-open-directory).  [\w] alone is [A-Za-z0-9_].
VAR = r'rust-[a-z0-9.+-]+'

# A whole crate-source definition, captured verbatim (group 1 = full text,
# group 2 = var name).  Tolerates an optional `;; TODO REVIEW:` comment line
# that `guix import` emits for crates shipping bundled C sources.
DEF_RE = re.compile(
    r'(\(define (' + VAR + r')\n'
    r'  (?:;; [^\n]*\n  )?'
    r'\(crate-source "[^"]+" "[^"]+"\n'
    r'                "[^"]+"\)\))'
)


def find_paren_span(text: str, open_pos: int) -> int:
    """Return index just past the ')' that closes the '(' at open_pos."""
    depth = 0
    i = open_pos
    while i < len(text):
        c = text[i]
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise ValueError("unbalanced parentheses starting at %d" % open_pos)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('package')
    ap.add_argument('target')
    ap.add_argument('import_file')
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()

    # 规范化目标文件路径，避免相对路径/符号链接越界写入。
    args.target = os.path.abspath(os.path.realpath(args.target))

    with open(args.import_file) as f:
        imp = f.read()
    with open(args.target) as f:
        scm = f.read()

    # 1. Parse the import file: var -> verbatim definition text.
    imported: dict[str, str] = {}
    for m in DEF_RE.finditer(imp):
        var = m.group(2)
        imported[var] = m.group(1)
    if not imported:
        print("ERROR: no crate-source definitions parsed from import file",
              file=sys.stderr)
        return 2
    print(f"[1] import defines parsed: {len(imported)}")

    # 2. Existing defines in the target.
    existing = set(re.findall(r'\(define (' + VAR + r')', scm))
    print(f"[2] target existing defines: {len(existing)}")

    # 3. New crate-source definitions to insert = imported but not yet defined.
    to_insert = sorted(v for v in imported if v not in existing)
    print(f"[3] new crate-source definitions to insert: {len(to_insert)}")
    for v in to_insert:
        print(f"      + {v}")

    # 4. The new input list IS the full set of imported defines.
    new_inputs = sorted(imported.keys())
    print(f"[4] new input list size: {len(new_inputs)}")

    # 5. Insert new definitions before ssss-separator (end-of-crates marker).
    sep = re.search(r'\(define ssss-separator', scm)
    if not sep:
        print("ERROR: ssss-separator not found", file=sys.stderr)
        return 2
    insert_at = sep.start()
    if to_insert:
        block = '\n\n'.join(imported[v] for v in to_insert)
        # Two blank lines before the separator, matching existing spacing.
        insertion = block + '\n\n\n'
        scm = scm[:insert_at] + insertion + scm[insert_at:]
        print(f"[5] inserted {len(to_insert)} definitions before ssss-separator")

    # 6. Replace the package's input list, located by the key + (list ...),
    #    bounded by parenthesis depth so any inner structure is safe.
    key = re.escape(args.package)
    head = re.search(r'\(' + key + r' =>\s*\(list', scm)
    if not head:
        print(f"ERROR: input list for {args.package} not found", file=sys.stderr)
        return 2
    list_open = scm.index('(', head.start() + len(args.package))
    list_close = find_paren_span(scm, list_open)

    # Reproduce the original two-level indentation:
    #   <list_indent>(list <first-var>
    #   <item_indent><second-var>
    # where list_indent aligns `(list` under the key's `(list` column and
    # item_indent = list_indent + 1 (guix import aligns continuation lines
    # one column past `(list`'s opening paren).  We derive both from the
    # column of the matched `(list` rather than sampling a variable line,
    # because the first variable shares its line with `(list` (ambiguous).
    list_kw_start = scm.rfind('(list', head.start(), head.end())
    line_start = scm.rfind('\n', 0, list_kw_start) + 1
    list_indent = scm[line_start:list_kw_start]
    item_indent = list_indent + ' '
    after_list_kw = list_kw_start + len('(list')

    lines = [item_indent + v for v in new_inputs]
    # First variable stays on the `(list` line (after a single space).
    new_body = ' ' + new_inputs[0] + '\n' + '\n'.join(lines[1:]) if lines else ''
    # list_close points just PAST the inner `(list ...)` closing paren.
    # Preserve that inner `)` (at list_close-1) so both the list and the
    # enclosing `(key => ...)` item stay balanced.
    scm = scm[:after_list_kw] + new_body + scm[list_close - 1:]
    print(f"[6] replaced input list for {args.package}")

    # 7. POST-CONDITION: every input variable must now have a definition.
    merged_defines = set(re.findall(r'\(define (' + VAR + r')', scm))
    unresolved = [v for v in new_inputs if v not in merged_defines]
    if unresolved:
        print("ERROR: input variables without a definition (merge incomplete):",
              file=sys.stderr)
        for v in unresolved:
            print(f"        ? {v}", file=sys.stderr)
        return 3
    print(f"[7] OK: all {len(new_inputs)} input variables have definitions")

    if args.dry_run:
        print("[dry-run] no write performed")
        return 0

    Path(args.target).write_text(scm)
    print("[done] target updated")
    return 0


if __name__ == '__main__':
    sys.exit(main())
