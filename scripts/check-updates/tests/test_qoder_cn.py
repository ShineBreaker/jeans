#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""qoder-cn 更新决策的回归检查（纯逻辑，不联网）。

三条必须成立的行为，错任一条都不会报错、只会静默钉错版本：

  1. 版本键按数字段比较：0.5.10 比 0.5.9 新（字符串比较会判反）。
  2. 同版本但字节变了 → repin。上游用 CopyObject 原地重传同名文件，只比
     version 的更新器会永久停在旧字节，构建随即 hash mismatch。
  3. 清单版本低于当前 → none。CDN 边缘回吐旧清单时不能把包降级。

另加清单解析的边界：entries 只认 deb 条目、非 official 构建拒绝、地址必须
在静态域下。
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.hashing import _sha256_to_guix_base32
from common.retry import RetryableError
from handlers.qoder_cn import (
    VERSION_RE,
    _decision,
    _parse_manifest,
    _pinned_base32,
    _version_key,
)

# 与上游 0.5.6 清单同形的样本（https 域名保留原样，便于核对域校验）
MANIFEST = """version: 0.5.6
files:
  - url: https://static.qoder.com.cn/qoder-app/releases/0.5.6/Qoder-CN-linux-amd64.deb
    sha512: ciSNK0i8GLrspy92KIp7l+7aulFbZLvzfG9XFsc1CKfV9s1I9wowXu3a2aKJCnYb4IkPfkuMvk2dOXIpI6pNUg==
    sha256: 7a7d506372c722ae5d72099f0c404f00b1f949d9e3c3ebef4c74fdd8640204e9
    size: 292068368
  - url: https://static.qoder.com.cn/qoder-app/releases/0.5.6/Qoder-CN-linux-x86_64.rpm
    sha512: oAgKp1TNf0kW34BLkNaMX0UJWSJ5rN2pAYGwHWYXRzbFecX1ZRcF46f+JbWqlTtyuNXvtA7MgdhMWlq5Tu0kTQ==
    sha256: 6977044e07828511a76d8ef7ab830747fa2e97fff44154219988866d9b2b8e0f
    size: 254526700
path: Qoder-CN-linux-amd64.deb
sha512: ciSNK0i8GLrspy92KIp7l+7aulFbZLvzfG9XFsc1CKfV9s1I9wowXu3a2aKJCnYb4IkPfkuMvk2dOXIpI6pNUg==
releaseDate: 2026-11-06T05:53:50.337Z
releaseId: 0.5.6
commit: 3856ca15528e74a3b8f6d532043ded87a760bb61
buildKind: official
releaseNotes: {}
"""


def _sha(byte: int) -> str:
    """构造一个确定性的 32 字节 sha256 hex。"""
    return (bytes([byte]) * 32).hex()


CURRENT = "0.5.6"
CURRENT_B32 = _sha256_to_guix_base32(bytes([0x11]) * 32)

# 1. 数字段比较
assert _version_key("0.5.10") > _version_key("0.5.9"), "数字段必须按整数比较"
assert _version_key(CURRENT) == _version_key("0.5.6")

# 2. 版本变高 → update
assert _decision(CURRENT, CURRENT_B32, "0.6.0", "") == "update"

# 3. 同版本同字节 → 无事可做
assert _decision(CURRENT, CURRENT_B32, CURRENT, _sha(0x11)) == "none"

# 4. 同版本不同字节 → 重钉
assert _decision(CURRENT, CURRENT_B32, CURRENT, _sha(0x22)) == "repin"

# 5. 版本变低 → 拒绝降级
assert _decision(CURRENT, CURRENT_B32, "0.5.5", _sha(0x33)) == "none"

# 6. 清单缺 hash 且版本相同 → 不动
assert _decision(CURRENT, CURRENT_B32, CURRENT, "") == "none"

# 7. 版本形状门禁：只收纯数字段
assert VERSION_RE.match(CURRENT)
assert not VERSION_RE.match("v0.5.6")
assert not VERSION_RE.match("0.5.6-rc1")
assert not VERSION_RE.match("0")

# 8. sha256 → base32 与 guix 编码一致（第 3、4 条判断的基础）
assert _pinned_base32(_sha(0x11)) == CURRENT_B32
assert _pinned_base32("zz") is None
assert _pinned_base32("") is None

# 9. 清单解析：取 deb 条目（不是 rpm、不是顶层 path/sha512）
version, url, sha256 = _parse_manifest(MANIFEST)
assert version == "0.5.6", version
assert url.endswith("/0.5.6/Qoder-CN-linux-amd64.deb"), url
assert sha256 == "7a7d506372c722ae5d72099f0c404f00b1f949d9e3c3ebef4c74fdd8640204e9"

# 10. 非 official 构建拒绝
bad_kind = MANIFEST.replace("buildKind: official", "buildKind: beta")
try:
    _parse_manifest(bad_kind)
    raise AssertionError("非 official 构建必须被拒绝")
except RetryableError:
    pass

# 11. 静态域之外的地址拒绝
bad_host = MANIFEST.replace("https://static.qoder.com.cn/qoder-app",
                            "https://evil.example.com/qoder-app")
try:
    _parse_manifest(bad_host)
    raise AssertionError("静态域之外的地址必须被拒绝")
except RetryableError:
    pass

# 12. 缺 deb 条目拒绝
try:
    _parse_manifest(MANIFEST.replace("Qoder-CN-linux-amd64.deb", "Qoder-CN-linux-arm64.deb"))
    raise AssertionError("缺 deb 条目必须被拒绝")
except RetryableError:
    pass

print("qoder-cn updater checks passed")
