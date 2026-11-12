# jeans 通道打包约定 — Emacs 包

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## Emacs 包（emacs-build-system）

- **`install` 只装根目录 `.el`**：`%default-include` 为 `'("^[^/]*\\.el$" "^[^/]*\\.info$" "^doc/.*\\.info$")`，子目录（`test/`、`scripts/`、`lisp/`）里的 `.el` 不会被安装。上游把源码放在子目录时用 `#:lisp-directory`（`emacs-ghostel` 的 `#:lisp-directory "lisp"`），无需手写 `#:exclude`。
- **`patch-el-files` 递归扫描整棵源码树，会被测试夹具里的 `/bin/...` 字面量打断**：该阶段用 `(find-files (getcwd) "\\.el$")` 取**所有** `.el`（不只待安装的），把 `"/bin/xxx"`、`"/sbin/xxx"` 形式字面量替换为 store 路径，解析不到就 `(error "patch-el-files: unable to locate ...")` 中止构建（`guix/build/emacs-build-system.scm:137-148`，Guix 9e068cc0）。上游测试里的 `(let ((shell-file-name "/bin/sh"))` 这类夹具足以让构建失败，**且 `#:exclude` 管不到这个阶段**（它不接受该参数）。生产 `.el` 无此类字面量时（程序按 PATH 查找，上游常规做法）直接 `(delete 'patch-el-files)`；否则把提供该程序、且带 `bin/` 的包加进 `inputs`。实例：`emacs-dsh`（`emacs-xyz.scm`，2026-09-14）。
- **反向陷阱：`"/usr/bin/true"` 不会被误伤**。正则锚定在引号后紧跟 `s?bin/`，`"` 后是 `/usr/` 故不匹配；不要把 `/usr/bin/...` 与 `/bin/...` 混为一谈去排查。
- 完整换行工具包（无 pkg.el、无 Makefile、无 ELPA 发布）用 `#:tests? #f`：`check` 阶段只认 `buttercup`、`ert-runner` 或 `Makefile`，都没有时即使 `#:tests? #t` 也只打印 "test system not found"。要用上游 ERT 套件得显式给 `#:test-command`。
- **`#:test-command` 传裸列表会在 builder 里变成函数调用**：`(list #:test-command '("make" "test"))` 经 gexp 序列化后 builder 脚本里是 `#:test-command ("make" "test")`（无 quote），`primitive-load` 求值时报 `Wrong type to apply: "make"`（check 阶段还没开始就崩）。正确姿势是 `#~(list ...)` 让列表在 builder 侧求值，与 gnu/packages/emacs-xyz.scm:415（`#:test-command #~(list "make" "test")`）一致。另外 check 对 Makefile 自动探测的是 `make check`（guix/build/emacs-build-system.scm:226），上游 Makefile 只有 `test` 目标时必须显式给 `#:test-command`，且上游 test 若无 `--batch`（如 `emacs -Q -L . -l test.el`），headless 构建沙箱报 "standard input is not a tty"——把同一条命令加 `--batch` 复刻即可。实例：`emacs-minibuffer-frame`（`emacs-xyz.scm`，2026-09-17）。

