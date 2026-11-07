#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""workbuddy-cn 更新决策的回归检查（纯逻辑，不联网）。

三条必须成立的行为，错任一条都不会报错、只会静默钉错版本：

  1. 版本键按数字段比较：5.6.10 比 5.6.9 新（字符串比较会判反）。
  2. 同版本但字节变了 → repin。上游会原地重传同名文件，只比 version 的更新
     器会永久停在旧字节，构建随即 hash mismatch（flatpark #648 同款）。
  3. 清单版本低于当前 → none。CDN 边缘回吐旧清单时不能把包降级。
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.hashing import _sha256_to_guix_base32
from handlers.workbuddy_cn import (
    VERSION_RE,
    _decision,
    _pinned_base32,
    _version_key,
)


def _sha(byte: int) -> str:
    """构造一个确定性的 32 字节 sha256 hex。"""
    return (bytes([byte]) * 32).hex()


CURRENT = "5.6.2.40046327-c7b525f3"
CURRENT_B32 = _sha256_to_guix_base32(bytes([0x11]) * 32)

# 1. 数字段比较
assert _version_key("5.6.10.1-ff") > _version_key("5.6.9.99-ff"), \
    "数字段必须按整数比较"
assert _version_key(CURRENT) == _version_key(CURRENT)

# 2. 版本变高 → update
assert _decision(CURRENT, CURRENT_B32, "5.7.0.40000000-aabbccdd", "") == "update"

# 3. 同版本同字节 → 无事可做
assert _decision(CURRENT, CURRENT_B32, CURRENT, _sha(0x11)) == "none"

# 4. 同版本不同字节 → 重钉
assert _decision(CURRENT, CURRENT_B32, CURRENT, _sha(0x22)) == "repin"

# 5. 版本变低 → 拒绝降级
assert _decision(CURRENT, CURRENT_B32, "5.6.1.40000000-aabbccdd", _sha(0x33)) == "none"

# 6. 清单缺 hash 且版本相同 → 不动
assert _decision(CURRENT, CURRENT_B32, CURRENT, "") == "none"

# 7. 版本形状门禁：缺 commit 后缀的版本号不能进包定义
assert VERSION_RE.match(CURRENT)
assert not VERSION_RE.match("5.6.2.40046327")
assert not VERSION_RE.match("5.6.2.40046327-C7B525F3")
assert not VERSION_RE.match("v5.6.2.40046327-c7b525f3")

# 8. sha256 → base32 与 guix 编码一致（第 3、4 条判断的基础）
assert _pinned_base32(_sha(0x11)) == CURRENT_B32
assert _pinned_base32("zz") is None
assert _pinned_base32("") is None

print("workbuddy-cn updater checks passed")
