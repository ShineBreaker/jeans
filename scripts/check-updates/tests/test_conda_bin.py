#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for the conda-forge handler (ghostty-bin).

conda 文件名带不可推导的 h<hash>_<build> 后缀：必须从 anaconda API 取精确
basename，按版本 + build_number 选最新，并整段替换 URL。
"""

import sys
import tempfile
import types
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

ROOT = Path(__file__).resolve().parents[3]
TERMINALS = ROOT / "modules/jeans/packages/terminals.scm"
NEW_HASH = "e" * 52
NEW_BASENAME = "linux-64/ghostty-1.5.0-habc1234_1.conda"
NEW_URL = f"https://conda.anaconda.org/conda-forge/{NEW_BASENAME}"


def _import_handler():
    try:
        import requests  # noqa: F401
    except ImportError:
        fake = types.ModuleType("requests")
        fake.exceptions = types.SimpleNamespace(
            Timeout=Exception,
            ConnectionError=Exception,
            ChunkedEncodingError=Exception,
            HTTPError=Exception,
            RequestException=Exception,
        )
        sys.modules["requests"] = fake

    import handlers.conda_bin as handler

    return handler


class _Resp:
    def __init__(self, data) -> None:
        self._data = data
        self.status_code = 200

    def json(self):
        return self._data

    def raise_for_status(self) -> None:
        pass


def _write_copy():
    tmp = Path(tempfile.mkdtemp(prefix="jeans-conda-")) / "terminals.scm"
    tmp.write_text(TERMINALS.read_text(encoding="utf-8"), encoding="utf-8")
    return tmp


def _parse_package(text):
    from common.scm import parse_package_definitions

    packages = {
        package["name"]: package
        for package in parse_package_definitions(text, TERMINALS)
    }
    return packages["ghostty-bin"]


def _files(*entries):
    out = []
    for basename, version, build_number, subdir in entries:
        out.append(
            {
                "basename": basename,
                "version": version,
                "attrs": {"subdir": subdir, "build_number": build_number},
            }
        )
    return out


def check_update(handler):
    tmp = _write_copy()
    package = _parse_package(tmp.read_text(encoding="utf-8"))
    assert package["version"] == "1.4.0", package["version"]

    handler.http.get = lambda *_args, **_kwargs: _Resp(
        {
            "files": _files(
                # 同版本两个 build：必须选 build_number 大的。
                ("linux-64/ghostty-1.5.0-hdeadbee_0.conda", "1.5.0", 0, "linux-64"),
                (NEW_BASENAME, "1.5.0", 1, "linux-64"),
                ("linux-64/ghostty-1.4.0-hc0dcdef_0.conda", "1.4.0", 0, "linux-64"),
                # 其他平台/格式：必须忽略。
                ("osx-arm64/ghostty-9.9.9-hx_0.conda", "9.9.9", 0, "osx-arm64"),
                ("linux-64/ghostty-9.9.9-hy_0.tar.bz2", "9.9.9", 0, "linux-64"),
            )
        }
    )
    calls = []
    handler.get_base32_from_guix_download = (
        lambda url, **_kwargs: calls.append(url) or NEW_HASH
    )

    change = handler.update_conda_bin(package, {}, tmp)
    assert change is not None
    assert change["new_version"] == "1.5.0", change["new_version"]
    assert calls == [NEW_URL], calls
    assert change["extra_replacements"] == [
        (
            "https://conda.anaconda.org/conda-forge/linux-64/"
            "ghostty-1.4.0-hc0dcdef_0.conda",
            NEW_URL,
        )
    ], change["extra_replacements"]

    from common.changes import apply_pending_updates

    assert apply_pending_updates([change])
    result = tmp.read_text(encoding="utf-8")
    assert '(version "1.5.0")' in result
    assert f'(base32 "{NEW_HASH}")' in result
    assert NEW_URL in result
    assert "ghostty-1.4.0-hc0dcdef_0.conda" not in result
    print("ghostty-bin: 1.4.0 -> 1.5.0 checks passed")


def check_uptodate(handler):
    tmp = _write_copy()
    package = _parse_package(tmp.read_text(encoding="utf-8"))
    handler.http.get = lambda *_args, **_kwargs: _Resp(
        {
            "files": _files(
                ("linux-64/ghostty-1.4.0-hc0dcdef_0.conda", "1.4.0", 0, "linux-64")
            )
        }
    )
    assert handler.update_conda_bin(package, {}, tmp) is None
    print("ghostty-bin: uptodate checks passed")


def main() -> None:
    handler = _import_handler()
    check_update(handler)
    check_uptodate(handler)
    print("conda handler regression checks passed")


if __name__ == "__main__":
    main()
