#!/usr/bin/env python3
"""
Guix包版本检查和更新工具
检查GitHub仓库是否有新版本，并自动更新version和base32
支持通过配置文件自定义检查行为
"""

import os
import re
import requests
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import time

# GitHub API配置
GITHUB_API_URL = "https://api.github.com/repos"
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")  # 可选，用于提高API限制

# 常量
NEW_BASE32 = "0000000000000000000000000000000000000000000000000000"
PACKAGES_DIR = Path(__file__).parent.parent.parent / "modules" / "jeans" / "packages"
CONFIG_FILE = Path(__file__).parent / "config.json"


def load_config(config_path: Path) -> Dict:
    """加载配置文件"""
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️  配置文件不存在: {config_path}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "notes": {}
        }
    except json.JSONDecodeError as e:
        print(f"⚠️  配置文件格式错误: {e}")
        print("   使用默认配置")
        return {
            "check_pre_release": [],
            "skip_packages": [],
            "notes": {}
        }


def find_scm_files(directory: Path) -> List[Path]:
    """查找所有的.scm文件"""
    return list(directory.glob("*.scm"))


def extract_github_repo(url: str) -> Optional[str]:
    """从URL中提取GitHub仓库路径 (owner/repo)"""
    # 匹配 github.com/owner/repo 或 github.com/owner/repo/
    patterns = [
        r"github\.com/([^/]+)/([^/]+?)(?:\.git|/|$)",
        r"api\.github\.com/repos/([^/]+)/([^/]+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return f"{match.group(1)}/{match.group(2)}"

    return None


def get_latest_github_release(repo: str, include_pre_release: bool = False) -> Optional[str]:
    """获取GitHub仓库的最新release版本

    Args:
        repo: GitHub仓库路径 (owner/repo)
        include_pre_release: 是否包含pre-release版本

    Returns:
        最新版本的tag名称，如果获取失败则返回None
    """
    headers = {}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"

    try:
        # 首先尝试获取最新的稳定版release
        url = f"{GITHUB_API_URL}/{repo}/releases/latest"
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        latest_release = data.get("tag_name")

        if not include_pre_release:
            return latest_release

        # 如果需要检查pre-release，获取所有release并找到最新的（包括pre-release）
        url_all = f"{GITHUB_API_URL}/{repo}/releases"
        response_all = requests.get(url_all, headers=headers, timeout=10)
        response_all.raise_for_status()
        releases = response_all.json()

        if not releases:
            return None

        # 获取最新的release（可能是pre-release）
        latest_all = releases[0].get("tag_name")

        # 如果最新的包含pre-release，返回它
        if releases[0].get("prerelease", False):
            print(f"     ℹ️  最新版本是pre-release: {latest_all}")

        return latest_all

    except requests.exceptions.RequestException as e:
        print(f"  ⚠️  无法获取GitHub release: {e}")
        return None


def parse_package_definitions(content: str, file_path: Path) -> List[Dict]:
    """解析.scm文件中的包定义"""
    packages = []

    # 使用正则表达式匹配 define-public 后面的包定义
    # 这个正则表达式需要匹配从 (define-public name 到下一个 define-public 或文件结尾

    # 首先找到所有 define-public 的位置
    pattern = r'\(define-public\s+(\S+)'
    matches = list(re.finditer(pattern, content))

    for i, match in enumerate(matches):
        package_name = match.group(1)
        start_pos = match.start()

        # 确定结束位置（下一个 define-public 或文件结尾）
        if i + 1 < len(matches):
            end_pos = matches[i + 1].start()
        else:
            end_pos = len(content)

        package_content = content[start_pos:end_pos]

        # 提取版本号
        version_match = re.search(r'\(version\s+"([^"]+)"', package_content)
        version = version_match.group(1) if version_match else None

        # 提取URI
        uri_match = re.search(r'\(uri\s+(?:\([^)]+\)|"(?:[^"]*)")', package_content)
        if uri_match:
            uri_text = uri_match.group(0)
            # 从uri中提取URL
            url_match = re.search(r'"([^"]+github\.com[^"]+)"', uri_text)
            if not url_match:
                url_match = re.search(r'"([^"]+gitlab\.com[^"]+)"', uri_text)
            url = url_match.group(1) if url_match else None
        else:
            url = None

        # 提取base32
        base32_match = re.search(r'\(base32\s+"([^"]+)"', package_content)
        base32 = base32_match.group(1) if base32_match else None

        # 提取下载方法
        method_match = re.search(r'\(method\s+(\S+)', package_content)
        method = method_match.group(1) if method_match else None

        packages.append({
            "name": package_name,
            "version": version,
            "url": url,
            "base32": base32,
            "method": method,
            "content": package_content,
            "start_pos": start_pos,
            "end_pos": end_pos
        })

    return packages


def compare_versions(current_version: str, new_version: str) -> bool:
    """比较两个版本，返回是否需要更新"""
    # 移除版本号前面的'v'前缀
    current = current_version.lstrip('v')
    new = new_version.lstrip('v')

    # 简单的字符串比较（对于语义化版本，可以改进）
    return current != new


def update_package_in_file(file_path: Path, package: Dict, new_version: str) -> bool:
    """更新文件中的包版本和base32"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 更新version
        old_version_pattern = rf'\(version\s+"{re.escape(package["version"])}"\)'
        new_version_str = f'(version "{new_version}")'
        content = re.sub(old_version_pattern, new_version_str, content)

        # 更新base32
        if package["base32"]:
            old_base32_pattern = rf'\(base32\s+"{re.escape(package["base32"])}"\)'
            new_base32_str = f'(base32 "{NEW_BASE32}")'
            content = re.sub(old_base32_pattern, new_base32_str, content)

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

        return True
    except Exception as e:
        print(f"  ❌ 更新文件失败: {e}")
        return False


def main():
    """主函数"""
    print("=" * 60)
    print("Guix 包版本检查和更新工具")
    print("=" * 60)
    print()

    # 加载配置文件
    config = load_config(CONFIG_FILE)
    check_pre_release_packages = set(config.get("check_pre_release", []))
    skip_packages = set(config.get("skip_packages", []))

    print(f"📋 配置:")
    print(f"   检查pre-release的包: {', '.join(check_pre_release_packages) or '无'}")
    print(f"   跳过检查的包: {', '.join(skip_packages) or '无'}")
    print()

    if not PACKAGES_DIR.exists():
        print(f"❌ 错误: 包目录不存在: {PACKAGES_DIR}")
        return 1

    scm_files = find_scm_files(PACKAGES_DIR)
    if not scm_files:
        print(f"⚠️  未找到.scm文件: {PACKAGES_DIR}")
        return 1

    print(f"📁 找到 {len(scm_files)} 个.scm文件")
    print()

    total_packages = 0
    updated_packages = 0
    skipped_packages = 0

    for scm_file in scm_files:
        print(f"📄 处理文件: {scm_file.relative_to(PACKAGES_DIR.parent)}")

        try:
            with open(scm_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"  ❌ 无法读取文件: {e}")
            continue

        packages = parse_package_definitions(content, scm_file)
        print(f"  找到 {len(packages)} 个包定义")

        for package in packages:
            total_packages += 1
            package_name = package['name']

            print(f"\n  📦 包名: {package_name}")
            print(f"     当前版本: {package['version']}")

            # 检查是否在跳过列表中
            if package_name in skip_packages:
                print(f"     ⏭️  在跳过列表中，已跳过")
                skipped_packages += 1
                continue

            if not package['url']:
                print(f"     ⚠️  无法提取URL，跳过")
                continue

            print(f"     URL: {package['url']}")

            # 提取GitHub仓库
            github_repo = extract_github_repo(package['url'])

            if github_repo:
                print(f"     GitHub仓库: {github_repo}")

                # 判断是否需要检查pre-release
                include_pre_release = package_name in check_pre_release_packages
                if include_pre_release:
                    print(f"     🔍 包含pre-release检查")

                # 获取最新release
                latest_release = get_latest_github_release(github_repo, include_pre_release)

                if latest_release:
                    print(f"     最新release: {latest_release}")

                    # 比较版本
                    if compare_versions(package['version'], latest_release):
                        print(f"     ✅ 发现新版本: {latest_release}")

                        # 更新文件
                        if update_package_in_file(scm_file, package, latest_release):
                            print(f"     ✓ 已更新: {package_name}")
                            updated_packages += 1
                        else:
                            print(f"     ❌ 更新失败")
                    else:
                        print(f"     ✓ 版本已是最新")
                else:
                    print(f"     ⚠️  无法获取最新release信息")
            else:
                print(f"     ⚠️  不是GitHub仓库，跳过检查")

        print()

    print("=" * 60)
    print(f"📊 总计: {total_packages} 个包")
    print(f"🔄 已更新: {updated_packages} 个包")
    print(f"✓ 保持最新: {total_packages - updated_packages - skipped_packages} 个包")
    print(f"⏭️  已跳过: {skipped_packages} 个包")
    print("=" * 60)

    if updated_packages > 0:
        print()
        print("⚠️  注意: 已将base32设置为占位符值")
        print("   请运行 'guix hash -x <url>' 或类似命令获取正确的hash")
        print("   并手动替换base32值")

    return 0


if __name__ == "__main__":
    exit(main())
