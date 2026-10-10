# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""瞬时错误重试。"""
import re
import subprocess
import time
from typing import Any, Callable, Dict, Optional, TypeVar

import requests


class RetryableError(Exception):
    """可重试的瞬时错误。"""


T = TypeVar("T")
LAST_RETRIES: Dict[str, int] = {}


def is_retryable_http_error(error: requests.exceptions.HTTPError) -> bool:
    """是否为可重试 HTTP 错误（5xx）。"""
    status_code = error.response.status_code if error.response else None
    return status_code is not None and 500 <= status_code <= 599


def is_retryable_command_failure(text: str) -> bool:
    """根据命令输出文本判断是否是可重试的网络/超时/5xx错误。"""
    lower = text.lower()
    retry_patterns = [
        r"timeout",
        r"timed out",
        r"connection",
        r"network",
        r"temporar",
        r"http\s*5\d\d",
        r"status\s*5\d\d",
        r"\b5\d\d\b",
    ]
    return any(re.search(pattern, lower) for pattern in retry_patterns)


def with_retry(
    func: Callable[..., T], *args: Any, max_retries: int = 2, base_delay: int = 5, **kwargs: Any
) -> T:
    """重试执行函数：重试网络错误/HTTP 5xx/超时，指数退避。"""
    last_error: Optional[Exception] = None
    retries = 0

    for attempt in range(max_retries + 1):
        try:
            result = func(*args, **kwargs)
            LAST_RETRIES[func.__name__] = retries
            return result
        except RetryableError as e:
            last_error = e
        except requests.exceptions.Timeout as e:
            last_error = e
        except requests.exceptions.ConnectionError as e:
            last_error = e
        except requests.exceptions.HTTPError as e:
            if not is_retryable_http_error(e):
                LAST_RETRIES[func.__name__] = retries
                raise
            last_error = e
        except subprocess.TimeoutExpired as e:
            last_error = e

        if attempt < max_retries:
            delay = base_delay ** (attempt + 1)
            print(f"⏳ 重试 {attempt + 1}/{max_retries} (等待 {delay}s)...")
            time.sleep(delay)
            retries += 1
            continue

        LAST_RETRIES[func.__name__] = retries
        raise last_error if last_error else RetryableError("未知错误")

    LAST_RETRIES[func.__name__] = retries
    raise RetryableError("未知错误")
