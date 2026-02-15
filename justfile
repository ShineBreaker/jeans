manifest := "./scripts/check-updates/manifest.scm"
script := "./scripts/check-updates/update_versions.py"
packages := "./modules/jeans/packages/"
# 检查包的更新
upgrade:
  guix shell --manifest={{manifest}} -- python3 {{script}}

build *args:
  guix build -f {{packages}}{{args}}.scm
