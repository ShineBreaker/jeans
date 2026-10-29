# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

"""NAR 序列化 + Guix base32 编码与 hash 计算 I/O。"""

import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from typing import Optional

import requests

import common.http as http
from common.retry import RetryableError, is_retryable_command_failure, is_retryable_http_error


# ── Guix/Nix base32 编码 + NAR 序列化（纯 Python，不依赖 guix 命令） ──────────

# Nix/Guix base32 字符表（排除 e/o/t/u，避免与数字混淆）
_BASE32_CHARS = "0123456789abcdfghijklmnpqrsvwxyz"


def _sha256_to_guix_base32(digest: bytes) -> str:
    """将 SHA256 digest (32 字节) 转为 Nix/Guix base32 字符串 (52 字符)。

    Nix base32 从最低位取 5 位一组，结果从右到左填充。
    """
    hash_size = len(digest)
    total_bits = hash_size * 8
    d = (total_bits + 4) // 5  # ceil(256/5) = 52

    result = [''] * d
    for i in range(d):
        digit = 0
        for j in range(5):
            bit = i * 5 + j
            byte_idx = bit // 8
            bit_in_byte = bit % 8
            if byte_idx < hash_size and (digest[byte_idx] >> bit_in_byte) & 1:
                digit |= 1 << j
        result[d - 1 - i] = _BASE32_CHARS[digit]
    return ''.join(result)


def _nar_str(data) -> bytes:
    """编码 NAR 字节串：8 字节 LE 长度前缀 + 数据 + 填充到 8 字节边界。"""
    if isinstance(data, str):
        data = data.encode('utf-8')
    n = len(data)
    pad = (8 - n % 8) % 8
    return n.to_bytes(8, 'little') + data + b'\x00' * pad


def _nar_entry(path: str) -> bytes:
    """递归序列化单个文件系统条目为 NAR 字节流。"""
    # 符号链接必须在 isdir 之前检查
    if os.path.islink(path):
        return (_nar_str("type") + _nar_str("symlink") +
                _nar_str("target") + _nar_str(os.readlink(path)))

    if os.path.isdir(path):
        parts = [_nar_str("type"), _nar_str("directory")]
        for name in sorted(os.listdir(path)):
            child = os.path.join(path, name)
            parts += [_nar_str("entry"), _nar_str("("),
                      _nar_str("name"), _nar_str(name),
                      _nar_str("node"), _nar_str("("),
                      _nar_entry(child),
                      _nar_str(")"), _nar_str(")")]
        return b''.join(parts)

    if os.path.isfile(path):
        with open(path, 'rb') as f:
            content = f.read()
        result = _nar_str("type") + _nar_str("regular")
        # NAR 中可执行文件带有 executable "" 标记
        if os.access(path, os.X_OK):
            result += _nar_str("executable") + _nar_str("")
        result += _nar_str("contents") + _nar_str(content)
        return result

    raise ValueError(f"不支持的文件类型: {path}")


def compute_nar_base32(path: str) -> str:
    """计算目录/文件的 NAR 序列化 SHA256 → Guix base32。等价于 guix hash -rx。"""
    nar = (_nar_str("nix-archive-1") + _nar_str("(") +
           _nar_entry(str(path)) + _nar_str(")"))
    return _sha256_to_guix_base32(hashlib.sha256(nar).digest())


def get_base32_from_guix_download(url: str, timeout: int = 120) -> Optional[str]:
    """下载文件并计算 SHA256 → Guix base32（纯 Python，不依赖 guix 命令）"""
    try:
        print(f"     🔽 正在下载并计算 base32...")
        response = http.get(url, timeout)
        if 500 <= response.status_code <= 599:
            raise RetryableError(f"HTTP {response.status_code}")
        response.raise_for_status()

        content = response.content
        content_length = response.headers.get("Content-Length")
        if content_length and len(content) != int(content_length):
            print(f"     ⚠️  下载不完整: 预期 {content_length} 字节, 实际 {len(content)} 字节")
            raise RetryableError(f"下载不完整")

        digest = hashlib.sha256(content).digest()
        base32 = _sha256_to_guix_base32(digest)

        if re.fullmatch(r"[0-9a-z]{52}", base32):
            return base32

        print(f"     ⚠️  base32 编码异常")
        return None
    except requests.exceptions.Timeout:
        raise RetryableError("下载超时")
    except requests.exceptions.ConnectionError:
        raise RetryableError("网络连接错误")
    except requests.exceptions.ChunkedEncodingError:
        # 大文件下载中途断连（aria2-next-bin 2026-10-13 实证）：
        # 非 ConnectionError 子类，不归入可重试会直接判死。
        raise RetryableError("下载中断（分块编码错误）")
    except requests.exceptions.HTTPError as e:
        if is_retryable_http_error(e):
            raise
        print(f"     ⚠️  下载失败: {e}")
        return None
    except RetryableError:
        raise
    except Exception as e:
        print(f"     ⚠️  计算下载 hash 出错: {e}")
        return None


def get_base32_for_git(url: str, ref: str, recursive: bool = False) -> Optional[str]:
    """通过 git clone + NAR 序列化计算 git-fetch 包的 base32 值（纯 Python，不依赖 guix 命令）

    recursive=True 时按 guix git-fetch 的 (recursive? #t) 语义物化子模块，
    并删除所有 .git 条目（含子模块 gitfile）——两步都与 guix 构建器
    （guix/build/git.scm）逐条对齐，否则 NAR hash 与 guix 实产不符。
    """
    tmpdir = tempfile.mkdtemp(prefix="guix-git-hash-")
    try:
        print(f"     🔽 正在克隆源码并计算 base32...")

        is_sha = bool(re.fullmatch(r'[0-9a-f]{40}', ref))

        if is_sha:
            clone_result = subprocess.run(
                ["git", "clone", "--filter=blob:none", url, tmpdir],
                capture_output=True,
                text=True,
                timeout=120,
            )
            if clone_result.returncode == 0:
                checkout_result = subprocess.run(
                    ["git", "checkout", ref],
                    cwd=tmpdir,
                    capture_output=True,
                    text=True,
                    timeout=30,
                )
                if checkout_result.returncode != 0:
                    print(f"     ⚠️  git checkout {ref[:12]} 失败: "
                          f"{checkout_result.stderr.strip()}")
                    return None
        else:
            clone_result = subprocess.run(
                ["git", "clone", "--depth=1", "-b", ref, url, tmpdir],
                capture_output=True,
                text=True,
                timeout=60,
            )

        if clone_result.returncode != 0:
            clone_err = clone_result.stderr.strip()
            if is_retryable_command_failure(clone_err):
                raise RetryableError(f"git clone 失败: {clone_err}")
            print(f"     ⚠️  git clone 失败: {clone_err}")
            return None

        # 与 guix git-fetch（guix/build/git.scm）逐条对齐：
        # 1) (recursive? #t) 的 origin 检出后跑 submodule update --init
        #    --recursive。漏了这步算出的 NAR hash 是不含子模块内容的树——
        #    linux-wallpaperengine 2026-10-29 实证（issue #64）：updater
        #    算出 0za2af3s...，guix 实产 108kg0d4...，bump 全被挡下。
        #    update=none 的子模块（quickjs 的 test262）git 与 guix 同样
        #    跳过，行为一致。
        if recursive:
            submodule_result = subprocess.run(
                ["git", "submodule", "update", "--init", "--recursive"],
                cwd=tmpdir,
                capture_output=True,
                text=True,
                timeout=600,
            )
            if submodule_result.returncode != 0:
                submodule_err = submodule_result.stderr.strip()
                if is_retryable_command_failure(submodule_err):
                    raise RetryableError(f"git submodule update 失败: {submodule_err}")
                print(f"     ⚠️  git submodule update 失败: {submodule_err}")
                return None

        # 2) 删除所有 .git 条目：顶层目录之外还有子模块里的 .git gitfile
        #    （guix 用 find-files "^\\.git$" 全删）。只删顶层时 gitfile
        #    留在 NAR 里——同一 commit 复刻实测：得 15ji3vp2...，仍与
        #    guix 的 108kg0d4... 差一批文件。无子模块的仓库等价于原行为。
        for root, dirs, files in os.walk(tmpdir):
            kept = []
            for name in dirs:
                if name == ".git":
                    shutil.rmtree(os.path.join(root, name), ignore_errors=True)
                else:
                    kept.append(name)
            dirs[:] = kept
            for name in files:
                if name == ".git":
                    try:
                        os.remove(os.path.join(root, name))
                    except OSError:
                        pass

        # 纯 Python NAR 序列化 + SHA256 + base32
        base32 = compute_nar_base32(tmpdir)

        if base32 and re.fullmatch(r"[0-9a-z]{52}", base32):
            return base32

        print(f"     ⚠️  NAR hash 计算异常")
        return None

    except subprocess.TimeoutExpired as e:
        cmd = " ".join(e.cmd) if isinstance(e.cmd, list) else str(e.cmd)
        raise RetryableError(f"命令超时: {cmd}")
    except FileNotFoundError as e:
        print(f"     ⚠️  未找到命令: {e}")
        return None
    except RetryableError:
        raise
    except Exception as e:
        print(f"     ⚠️  计算 git-fetch base32 出错: {e}")
        return None
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)
