#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""网络类失败判定与重试归类的单元测试。

覆盖 2026-10 两次 CI 事故的根因：
- jdtls-bin（2026-10-14）：guix build 内 curl 报 "Could not resolve
  host"，旧模式表无 DNS 特征词，判定不可重试；
- aria2-next-bin（2026-10-13）：下载中断抛 ChunkedEncodingError，
  非 ConnectionError 子类，落入 hashing 的兜底 except 直接判死。
"""

import sys
import unittest
from unittest import mock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import requests

from common.hashing import get_base32_from_guix_download
from common.retry import RetryableError, is_retryable_command_failure


class TestRetryableCommandFailure(unittest.TestCase):
    def test_dns_failure_curl(self):
        # jdtls-bin 2026-10-14 CI 实际输出
        self.assertTrue(is_retryable_command_failure(
            "curl: (6) Could not resolve host: download.eclipse.org"))

    def test_dns_failure_glibc(self):
        self.assertTrue(is_retryable_command_failure(
            "fatal: unable to access 'https://example.com/': "
            "Temporary failure in name resolution"))

    def test_connection_reset(self):
        self.assertTrue(is_retryable_command_failure(
            "Failed to connect to 1.2.3.4 port 443: Connection reset by peer"))

    def test_http_5xx(self):
        self.assertTrue(is_retryable_command_failure("HTTP 502 Bad Gateway"))
        self.assertTrue(is_retryable_command_failure("The remote server returned: status 503"))

    def test_plain_build_failure_not_retryable(self):
        self.assertFalse(is_retryable_command_failure(
            "guix build: error: build of `/gnu/store/xxx-pkg-1.0.drv' failed"))

    def test_hash_mismatch_not_retryable(self):
        self.assertFalse(is_retryable_command_failure(
            "sha256 hash mismatch for /gnu/store/xxx"))

    def test_empty_output(self):
        self.assertFalse(is_retryable_command_failure(""))


class TestDownloadRetryClassification(unittest.TestCase):
    def test_chunked_encoding_error_is_retryable(self):
        # aria2-next-bin 2026-10-13 模式：下载中断不再落入兜底 except
        # 返回 None，而是转成 RetryableError 交给 with_retry 重试。
        with mock.patch("common.http.get",
                        side_effect=requests.exceptions.ChunkedEncodingError("Connection broken")):
            with self.assertRaises(RetryableError):
                get_base32_from_guix_download("https://example.com/big.tar.gz")

    def test_connection_error_is_retryable(self):
        with mock.patch("common.http.get",
                        side_effect=requests.exceptions.ConnectionError("refused")):
            with self.assertRaises(RetryableError):
                get_base32_from_guix_download("https://example.com/big.tar.gz")

    def test_404_is_not_retryable(self):
        resp = mock.Mock()
        resp.status_code = 404
        resp.raise_for_status.side_effect = requests.exceptions.HTTPError("404")
        with mock.patch("common.http.get", return_value=resp):
            self.assertIsNone(
                get_base32_from_guix_download("https://example.com/none"))


if __name__ == "__main__":
    unittest.main()
