#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for release-tag-prefix handling in the updater."""

import json
import sys
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from common.scm import parse_package_definitions
from common.versions import (
    construct_download_url_from_uri,
    normalize_tag_to_version,
    package_tag_prefix,
)


ROOT = Path(__file__).resolve().parents[3]


def main() -> None:
    package_file = ROOT / "modules/jeans/packages/agent.scm"
    config_file = ROOT / "scripts/check-updates/config.json"
    packages = {
        package["name"]: package
        for package in parse_package_definitions(
            package_file.read_text(encoding="utf-8"), package_file
        )
    }
    configured_prefixes = json.loads(config_file.read_text(encoding="utf-8"))[
        "tag_prefix"
    ]

    cases = (
        ("reasonix-bin", "v", "v1.17.17", "1.17.17"),
        ("reasonix-studio-bin", "studio-v", "studio-v2.16.0", "2.16.0"),
    )
    for name, prefix, tag, version in cases:
        package = packages[name]
        actual_prefix = package_tag_prefix(package, configured_prefixes)
        normalized = normalize_tag_to_version(tag, actual_prefix)
        download_url = construct_download_url_from_uri(
            package["uri_expr"], normalized
        )
        assert actual_prefix == prefix, (name, actual_prefix)
        assert normalized == version, (name, normalized)
        assert f"/{tag}/" in download_url, (name, download_url)

    print("release tag prefix regression checks passed")


if __name__ == "__main__":
    main()
