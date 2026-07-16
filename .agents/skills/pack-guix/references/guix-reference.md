# Guix 打包参考

通用 Guix 打包知识，作为 `guix` info 手册的精简索引。所有 Guix 包共享此结构：

```scheme
(define-public package-name
  (package
    (name "package-name")
    (version "1.0.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://example.com/package-" version ".tar.gz"))
       (sha256
        (base32 "hash-here"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #t
       #:configure-flags '("--enable-feature")))
    (native-inputs (list pkg-config))
    (inputs (list openssl zlib))
    (propagated-inputs (list python))
    (home-page "https://example.com")
    (synopsis "Short one-line description")
    (description "Longer multi-line description of the package.")
    (license license:expat)))
```

## 必填字段

- **name**：包名（字符串，kebab-case）
- **version**：版本（字符串）
- **source**：源码获取方式（origin 块）
- **build-system**：构建系统
- **synopsis**：单行描述（<80 字符）
- **description**：详细描述
- **license**：许可证（来自 `(guix licenses)`）
- **home-page**：项目 URL

## 源码获取方式

**URL 下载：**

```scheme
(source
 (origin
   (method url-fetch)
   (uri (string-append "https://example.com/" version ".tar.gz"))
   (sha256 (base32 "hash"))))
```

**Git 获取：**

```scheme
(source
 (origin
   (method git-fetch)
   (uri (git-reference
         (url "https://github.com/user/repo")
         (commit (string-append "v" version))))
   (file-name (git-file-name name version))
   (sha256 (base32 "hash"))))
```

**Crate URI（Rust）：**

```scheme
(source
 (origin
   (method url-fetch)
   (uri (crate-uri "package-name" version))
   (file-name (string-append name "-" version ".tar.gz"))
   (sha256 (base32 "hash"))))
```

## 获取源码 Hash

```bash
# URL
guix hash https://example.com/package-1.0.0.tar.gz

# 解压后的目录
guix hash -rx /path/to/source

# Git 仓库
guix hash -rx $(guix build --source package-name)
```

## 构建系统

### cargo-build-system（Rust）

```scheme
(build-system cargo-build-system)
(arguments
 `(#:install-source? #f
   #:cargo-test-flags
   '("--release" "--"
     "--skip=failing_test")))
(inputs (cargo-inputs 'package-name #:module '(jeans packages rust-crates)))
```

要点：

- 使用 `cargo-inputs` 并指定 `#:module '(jeans packages rust-crates)` 从 jeans 通道解析依赖
- 依赖定义在 `rust-crates.scm` 文件中

### gnu-build-system

用于 autotools 项目（`./configure && make && make install`）：

```scheme
(build-system gnu-build-system)
(arguments
 `(#:configure-flags
   '("--enable-shared" "--with-feature")
   #:make-flags '("CC=gcc")
   #:tests? #t
   #:phases
   (modify-phases %standard-phases
     (add-after 'unpack 'patch-source
       (lambda _
         (substitute* "src/main.c"
           (("/usr/bin") (which "bin"))))))))
```

**标准阶段：**

1. `unpack` - 解压源码
2. `patch-source-shebangs` - 修复脚本解释器
3. `configure` - 运行 ./configure
4. `build` - 运行 make
5. `check` - 运行 make check
6. `install` - 运行 make install
7. `patch-shebangs` - 修复已安装脚本

### python-build-system / pyproject-build-system

```scheme
;; Legacy
(build-system python-build-system)
(arguments `(#:tests? #f #:python ,python-3))

;; Modern
(build-system pyproject-build-system)
(native-inputs (list python-setuptools python-wheel))
```

### cmake-build-system

```scheme
(build-system cmake-build-system)
(arguments
 `(#:tests? #f
   #:configure-flags
   '("-DUSE_SYSTEM_LIBS=ON" "-DBUILD_TESTS=OFF")))
```

## 输入类型与依赖

### native-inputs

**构建时**需要的工具（运行时不需要）：pkg-config、编译器（gcc/rust/clang）、构建工具（cmake/autoconf）、测试框架。

```scheme
(native-inputs (list pkg-config cmake python-pytest))
```

### inputs

运行时依赖：库（openssl、zlib）、程序调用的可执行文件、共享库。

```scheme
(inputs (list openssl curl libffi))
```

### propagated-inputs

必须对使用此包的用户可见的依赖：你导入的 Python 模块、头文件需要的头文件、库链接的库。

```scheme
(propagated-inputs (list python-requests python-numpy))
```

### cargo-inputs

Rust 包使用 jeans 通道的依赖：

```scheme
(inputs (cargo-inputs 'package-name #:module '(jeans packages rust-crates)))
```

## 阶段与修改

### 标准阶段操作

```scheme
(arguments
 `(#:phases
   (modify-phases %standard-phases
     ;; 删除阶段
     (delete 'configure)

     ;; 替换阶段
     (replace 'install
       (lambda* (#:key outputs #:allow-other-keys)
         (let ((out (assoc-ref outputs "out")))
           (install-file "binary" (string-append out "/bin")))))

     ;; 在已有阶段之前添加
     (add-before 'build 'set-environment
       (lambda _
         (setenv "CC" "gcc")))

     ;; 在已有阶段之后添加
     (add-after 'unpack 'patch-source
       (lambda _
         (substitute* "setup.py"
           (("/usr") (assoc-ref %outputs "out"))))))))
```

### 常见阶段修改

**修补 Shebangs：**

```scheme
(add-after 'unpack 'patch-shebangs
  (lambda _
    (substitute* "script.sh"
      (("/bin/bash") (which "bash"))
      (("/usr/bin/env") (which "env")))))
```

**跳过测试：**

```scheme
(arguments `(#:tests? #f))  ; 禁用所有测试

;; 或跳过特定测试:
(arguments
 `(#:cargo-test-flags
   '("--release" "--"
     "--skip=test_network"
     "--skip=test_timing")))
```

**自定义安装：**

```scheme
(add-after 'build 'install
  (lambda* (#:key outputs #:allow-other-keys)
    (let* ((out (assoc-ref outputs "out"))
           (bin (string-append out "/bin"))
           (lib (string-append out "/lib")))
      (mkdir-p bin)
      (copy-file "target/release/binary" (string-append bin "/binary"))
      (chmod (string-append bin "/binary") #o755))))
```

## 常见工作流

### 打包 Rust 应用

```bash
# 1. 准备环境
guix shell rust rust:cargo cargo-audit cargo-license

# 2. 生成 lockfile 并检查依赖
cd /path/to/source
cargo generate-lockfile
cargo audit          # 检查安全问题
cargo license        # 验证许可证

# 3. 导入包模板
guix import crate package-name > modules/jeans/packages/target.scm

# 4. 导入依赖（-f = --lockfile, -i = 插入到文件）
guix import -i modules/jeans/packages/rust-crates.scm \
      crate -f /path/to/Cargo.lock package-name

# 5. 编辑包定义
# - 设置正确的版本
# - 添加 home-page、synopsis、description
# - 按需配置 arguments

# 6. 构建
guix build -L modules package-name

# 7. 测试
guix shell -L modules package-name -- package-name --version
```

### 打包 Python 应用

```bash
# 1. 从 PyPI 导入
guix import pypi package-name > modules/jeans/packages/python-target.scm

# 2. 编辑并构建
guix build -L modules python-package-name
```

### 去除捆绑依赖

当包捆绑了库时：

```scheme
(source
 (origin
   ...
   (snippet
    #~(begin
        (use-modules (guix build utils))
        ;; 删除捆绑的库
        (delete-file-recursively "vendor/libffi")
        (delete-file-recursively "vendor/openssl")
        ;; 修补以使用系统库
        (substitute* "build.rs"
          (("vendor/") ""))))))
```

## 最佳实践

### 安全与许可证

```bash
cargo audit              # Rust 安全漏洞
cargo license            # 验证可接受的许可证
```

在包定义中：

```scheme
(license license:expat)                        ; MIT
(license license:asl2.0)                       ; Apache 2.0
(license (list license:expat license:asl2.0))  ; 双重许可
```

### 跨平台编译

```scheme
#:phases
#~(modify-phases %standard-phases
    #$@(if (%current-target-system)
           ;; 跨编译
           #~((add-before 'build 'set-cross-env
                (lambda _
                  (setenv "TARGET" #$(%current-target-system)))))
           ;; 原生构建
           #~()))
```

### 文件命名与组织

包文件按类别组织，使用 kebab-case：

- **按领域**：`browser.scm`、`desktop.scm`、`fonts.scm`、`games.scm`、`tools.scm`
- **按语言**（绑定/库）：`python-xyz.scm`
- **特殊文件**：`rust-crates.scm`（自动管理）

优先将包添加到已有类别文件中；仅在没有已有类别匹配时才创建新文件。

### 模块组织

**包文件头：**

```scheme
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages category)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cargo)
  #:use-module (gnu packages rust))
```

**导入组织：**

1. License 模块（带 prefix）
2. Guix 核心模块
3. 构建系统模块
4. 包模块（按字母顺序）

### 测试与验证

**所有新包和修改过的包必须通过以下完整验证流程：**

```bash
# 1. 构建包
guix build -L modules package-name

# 2. Lint 检查（必须！）
#    检查 synopsis/description 格式、许可证一致性、home-page 可达性等
guix lint -L modules package-name

# 3. 在隔离环境中试用
guix shell -L modules package-name -- package-name --help

# 4. 验证依赖
guix graph package-name | dot -Tpng > graph.png
```

**Lint 是强制性步骤**，不是可选的。每个包在首次打包或修改后都必须通过 `guix lint` 检查，修复所有报告的问题后再提交。

## 快速参考

### 常用命令

```bash
# 导入包模板
guix import crate PACKAGE > modules/jeans/packages/file.scm
guix import pypi PACKAGE > modules/jeans/packages/file.scm

# 构建包
guix build -L modules PACKAGE

# 本地安装
guix package -L modules -i PACKAGE

# 带包进入 shell
guix shell -L modules PACKAGE

# Lint 检查（打包后必须运行）
guix lint -L modules PACKAGE

# 显示包信息
guix show PACKAGE

# 检查依赖
guix graph PACKAGE

# 获取源码 hash
guix hash FILE
guix hash -rx DIRECTORY
```

### jeans 文件位置

- **包定义**：`modules/jeans/packages/*.scm`
- **Rust crates**：`modules/jeans/packages/rust-crates.scm`
- **服务定义**：`modules/jeans/services/*.scm`
- **补丁**：`modules/jeans/patches/`
- **许可证文件**：`licenses/`

### 获取帮助

```bash
# 手册
info guix

# 包文档
guix show PACKAGE

# 在线资源
# - Guix 手册: https://guix.gnu.org/manual/
# - Guix Cookbook: https://guix.gnu.org/cookbook/
# - 邮件列表: help-guix@gnu.org
```
