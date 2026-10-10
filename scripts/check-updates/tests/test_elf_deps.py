#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""ELF NEEDED 检查（check_elf_dependencies 系列）的单元回归测试。

不依赖真实 store 产物：手工构造 ELF64/PT_INTERP 与 wrapper 脚本，
subprocess.run 用桩替换以覆盖 missing / resolved / skipped 三分支。
"""

import struct
import subprocess
import sys
import tempfile
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent))

import test_updated_packages as tup


def make_elf64(path: Path, interp: str = "/lib64/ld-linux-x86-64.so.2") -> None:
    """写一个最小 ELF64 little-endian 头 + 单个 PT_INTERP program header。"""
    blob = interp.encode() + b"\x00"
    ehsize, phentsize, phoff = 64, 56, 64
    ident = b"\x7fELF" + bytes([2, 1, 1]) + bytes(9)  # 64-bit, LE, current
    hdr = struct.pack(
        "<16sHHIQQQIHHHHHH",
        ident, 2, 0x3E, 1, 0, phoff, 0, 0, ehsize, phentsize, 1, 64, 0, 0,
    )
    data_off = phoff + phentsize
    phdr = struct.pack(
        "<IIQQQQQQ",
        3, 4, data_off, 0, 0, len(blob), len(blob), 1,  # PT_INTERP
    )
    path.write_bytes(hdr + phdr + blob)


def fake_run(stdout: str, stderr: str, returncode: int):
    def _run(cmd, **kwargs):
        return subprocess.CompletedProcess(cmd, returncode, stdout, stderr)

    return _run


def find_store_ldso() -> str:
    """本机 store 里找一个真实存在的 ld.so，充当 PT_INTERP 桩。"""
    for cand in Path("/gnu/store").glob("*-glibc-*/lib/ld-linux-*.so.2"):
        return str(cand)
    raise RuntimeError("store 中找不到 glibc ld.so，本测试需要 Guix 环境")


def main() -> None:
    real_run = subprocess.run
    interp_target = find_store_ldso()

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)

        # _is_elf / _elf_interp
        make_elf64(tmp / "prog", "/custom/ld.so")
        assert tup._is_elf(tmp / "prog")
        assert not tup._is_elf(tmp / "missing")
        assert tup._elf_interp(tmp / "prog") == "/custom/ld.so"
        text = tmp / "plain.txt"
        text.write_text("not an elf")
        assert tup._elf_interp(text) is None

        # _scan_wrapper_scripts：--library-path 参数 + LD_LIBRARY_PATH 导出
        wrapper = tmp / "wrapped"
        wrapper.write_text(
            "#!/gnu/store/" + "a" * 32 + "-bash-5/bin/sh\n"
            'export LD_LIBRARY_PATH="/gnu/store/' + "b" * 32
            + '-nss-1/lib/nss:/gnu/store/' + "c" * 32
            + '-mesa-1/lib${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"\n'
            "exec /gnu/store/" + "d" * 32 + "-glibc-1/lib/ld-linux-x86-64.so.2"
            " --library-path /gnu/store/" + "e" * 32 + "-gtk-1/lib:"
            "/gnu/store/" + "f" * 32 + "-glib-1/lib /real/prog \"$@\"\n"
        )
        ldsos, lib_dirs = tup._scan_wrapper_scripts(tmp)
        assert ldsos == ["/gnu/store/" + "d" * 32 + "-glibc-1/lib/ld-linux-x86-64.so.2"], ldsos
        for frag in ("-nss-1/lib/nss", "-mesa-1/lib", "-gtk-1/lib", "-glib-1/lib"):
            assert any(frag in d for d in lib_dirs), f"{frag} 未提取: {lib_dirs}"
        assert not any("${" in d or "$LD" in d for d in lib_dirs), lib_dirs

        # check_elf_dependencies：missing 分支（stderr 致命错误）
        out1 = tmp / "out1"
        out1.mkdir()
        make_elf64(out1 / "prog", interp_target)
        subprocess.run = fake_run(
            "",
            f"{interp_target}: error while loading shared libraries: "
            "libgone.so.1: cannot open shared object file: No such file or directory",
            1,
        )
        r = tup.check_elf_dependencies([str(out1)])
        assert r["missing"] and "libgone.so.1" in r["missing"][0], r

        # resolved 分支（stdout 全解析）
        subprocess.run = fake_run(
            "libx.so.1 => /gnu/store/" + "a" * 32 + "-x-1/lib/libx.so.1\n", "", 0
        )
        r = tup.check_elf_dependencies([str(out1)])
        assert r["checked"] == 1 and not r["missing"] and not r["skipped"], r

        # 传递依赖 "=> not found" 分支
        subprocess.run = fake_run(
            "libdeep.so.2 => not found\n", "", 0
        )
        r = tup.check_elf_dependencies([str(out1)])
        assert r["missing"] and "libdeep.so.2" in r["missing"][0], r

        # skipped 分支：interp 不存在且无 wrapper ld.so
        out2 = tmp / "out2"
        out2.mkdir()
        make_elf64(out2 / "prog", "/nonexistent/ld.so")
        r = tup.check_elf_dependencies([str(out2)])
        assert r["checked"] == 0 and not r["missing"] and len(r["skipped"]) == 1, r

        # 无 interp 的 ELF（静态/未 patch）不计入任何一类
        out3 = tmp / "out3"
        out3.mkdir()
        no_interp = out3 / "static"
        no_interp.write_bytes(struct.pack(
            "<16sHHIQQQIHHHHHH",
            b"\x7fELF" + bytes([2, 1, 1]) + bytes(9),
            2, 0x3E, 1, 0, 0, 0, 0, 64, 56, 0, 64, 0, 0,
        ))
        r = tup.check_elf_dependencies([str(out3)])
        assert r == {"checked": 0, "skipped": [], "missing": []}, r

        subprocess.run = real_run

    print("ELF NEEDED 检查单元测试全部通过")


if __name__ == "__main__":
    main()
