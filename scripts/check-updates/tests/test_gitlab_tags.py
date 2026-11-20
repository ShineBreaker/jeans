#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for the GitLab tags handler (libfprint/fprintd -next).

2026-11-20 实测：guix refresh 的 generic-git updater 能读到 GitLab 上游
版本，但改不了模块级 %xxx-version 变量，落盘静默为零。本文件锁住
「改 define + 改包块 base32」两处替换。
"""

import sys
import tempfile
import types
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

ROOT = Path(__file__).resolve().parents[3]
HARDWARE = ROOT / "modules/jeans/packages/hardware.scm"
NEW_HASH = "d" * 52


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

    import handlers.gitlab_tags as handler

    return handler


class _Resp:
    def __init__(self, data) -> None:
        self._data = data
        self.status_code = 200

    def json(self):
        return self._data

    def raise_for_status(self) -> None:
        pass


def _parse_package(text, name):
    from common.scm import parse_package_definitions

    packages = {
        package["name"]: package
        for package in parse_package_definitions(text, HARDWARE)
    }
    return packages[name]


def _write_copy(text):
    tmp = Path(tempfile.mkdtemp(prefix="jeans-gitlab-")) / "hardware.scm"
    tmp.write_text(text, encoding="utf-8")
    return tmp


def check_update(handler, pkg_name, var, real, old, new_version):
    text = HARDWARE.read_text(encoding="utf-8")
    assert f'(define {var} "{real}")' in text, var
    text = text.replace(f'(define {var} "{real}")', f'(define {var} "{old}")', 1)
    tmp = _write_copy(text)
    package = _parse_package(text, pkg_name)

    tags = [
        {"name": f"v{real}"},
        {"name": f"v{new_version}-rc1"},   # 非纯版本，必须忽略
        {"name": f"v{new_version}"},
    ]
    handler.http.get = lambda *_args, **_kwargs: _Resp(tags)
    handler.get_base32_for_git = lambda _url, _ref, **_kwargs: NEW_HASH

    change = handler.update_gitlab_package(package, {}, tmp)
    assert change is not None, pkg_name
    assert change["new_version"] == new_version, change["new_version"]

    from common.changes import apply_pending_updates

    assert apply_pending_updates([change])
    result = tmp.read_text(encoding="utf-8")
    assert f'(define {var} "{new_version}")' in result, var
    assert f'(base32 "{NEW_HASH}")' in result
    print(f"{pkg_name}: {old} -> {new_version} checks passed")


def check_uptodate(handler, pkg_name, var, real):
    text = HARDWARE.read_text(encoding="utf-8")
    tmp = _write_copy(text)
    package = _parse_package(text, pkg_name)
    handler.http.get = lambda *_args, **_kwargs: _Resp([{"name": f"v{real}"}])
    assert handler.update_gitlab_package(package, {}, tmp) is None
    print(f"{pkg_name}: uptodate checks passed")


def main() -> None:
    handler = _import_handler()
    check_update(handler, "libfprint-next", "%libfprint-version", "1.94.100", "1.94.99", "1.95.0")
    check_update(handler, "fprintd-next", "%fprintd-version", "1.94.5", "1.94.4", "1.95.0")
    check_uptodate(handler, "libfprint-next", "%libfprint-version", "1.94.100")
    print("gitlab tags handler regression checks passed")


if __name__ == "__main__":
    main()
