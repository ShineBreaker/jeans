#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only
"""Regression checks for release-tag-prefix handling in the updater."""

import importlib.util
import json
from pathlib import Path


ROOT = Path(__file__).parents[2]
UPDATER_PATH = Path(__file__).with_name("update_versions.py")


def load_updater():
    spec = importlib.util.spec_from_file_location("jeans_update_versions", UPDATER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {UPDATER_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> None:
    updater = load_updater()
    package_file = ROOT / "modules/jeans/packages/agent.scm"
    config_file = ROOT / "scripts/check-updates/config.json"
    packages = {
        package["name"]: package
        for package in updater.parse_package_definitions(
            package_file.read_text(encoding="utf-8"), package_file
        )
    }
    configured_prefixes = json.loads(config_file.read_text(encoding="utf-8"))["tag_prefix"]

    cases = (
        ("open-interpreter-bin", "rust-v", "rust-v0.0.34", "0.0.34"),
        ("reasonix-bin", "v", "v1.17.17", "1.17.17"),
        ("reasonix-desktop-bin", "desktop-v", "desktop-v1.17.17", "1.17.17"),
    )
    for name, prefix, tag, version in cases:
        package = packages[name]
        actual_prefix = updater.package_tag_prefix(package, configured_prefixes)
        normalized = updater.normalize_tag_to_version(tag, actual_prefix)
        download_url = updater.construct_download_url_from_uri(
            package["uri_expr"], normalized
        )
        assert actual_prefix == prefix, (name, actual_prefix)
        assert normalized == version, (name, normalized)
        assert f"/{tag}/" in download_url, (name, download_url)

    print("release tag prefix regression checks passed")


if __name__ == "__main__":
    main()
