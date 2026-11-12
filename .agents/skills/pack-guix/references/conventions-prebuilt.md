# jeans 通道打包约定 — 预编译二进制（AppImage/Electron/Tauri/patchelf/dlopen）

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## 预编译二进制包

预编译包的常见形态各不相同，按小节对号入座；先用 `patchelf --print-interpreter` 探测 linkage，再选处理路线。

### AppImage 包

**默认用 `7z x` 静态解压，永远不要执行 AppImage 自身的 `--appimage-extract`。** 原因：自解压需要执行构建树里的 AppImage runtime，而 jeans 的自动更新 CI（GitHub runner）不允许执行构建树中的任何可执行文件——AppImage 自解压、autotools `./configure` 乃至 chmod 755 的 shell 脚本全部 `execvp: Permission denied` （issue #32）。`7z` 只解析容器格式（ELF runtime + squashfs 段），全程只运行 store 里的程序，本地与 CI 行为一致。`p7zip` 加入 `native-inputs`。

`7z x` 把内容直接解到构建目录顶层（`usr/`、`*.desktop`、图标等），**没有** `squashfs-root/` 前缀——那是自解压模式才有的产物。`#:install-plan` 按顶层路径写：

```scheme
(native-inputs (list p7zip patchelf))
#:install-plan
#~'(("usr/" "lib/<pkg>/"))
```

**install-plan 陷阱**：AppImage 根部的 `.desktop` 和图标文件几乎都是指向 `usr/share/...` 的**相对符号链接**，按链接路径安装会得到悬空链接（waywallen-bin 实证）。需要这些文件时引用 `usr/` 内的真实文件，而非根部链接。

**计算值的 plan 参数必须 `#~(list ...)`，不能传宿主侧裸列表**：`#:install-plan` / `#:patchelf-plan` / `#:desktop-files` 等由构建期消费的列表，字面量写 `#~'(...)`（gexp 引用保数据态）；含宿主侧拼接的字符串时写 `#~(list (list "a" #$computed) ...)`。直接传宿主侧 quasiquote 列表（`` `(("a" ,(str ...))) ``）经 gexp 序列化后，内层列表在 builder 脚本里成为**待求值代码**——`("usr/share/" "share/")` 被当函数调用，构建报 `Wrong type to apply: "usr/share/"`（lazer 模板首版实证，2026-10-14）。另注意 `#:desktop-files` 的 DESKTOP/EXEC 是**输出内**相对路径（`share/applications/x.desktop`、`bin/x`），不是解包树路径。

解压后对所有 ELF 二进制和 `.so` 执行 `patchelf`（遍历全部，不只主入口）。

参照包：

- `modules/jeans/packages/games.scm` 的 `osu-lazer-appimage-package` —— osu!lazer 系 fork 的通用打包模板（`osu-lazer-bin` / `g0v0-bin` / `deltalazer-bin` 共用），7z 解包 + patchelf + wrap-program + 图标重命名防 profile 串台，已被自动更新 CI 构建验证多次。**模板生成包的 guix refresh 盲区**：`package-field-location` 把 version 字段定位到模板内的 `(version version)`，refresh 会下载新资产、宣布 `updating from X to Y`，然后**静默不落盘**（g0v0-bin 2026-11-12 实证）——跑完 refresh 必须核对 `git diff` 里是否真有版本行改动，缺了就在调用点手写回写（资产已入 store，`guix download <url>` 直接出 hash）。
- `modules/jeans/packages/desktop.scm` 的 `waywallen-bin` —— 复杂参照，Qt6 bundle 保留 AppRun 布局、QT_PLUGIN_PATH 补插件、插件发现桥接。

### tar.gz / .deb 等归档包

`gnu-build-system`，删除 `configure`/`build` 阶段，自定义 `install`。解包前先 `tar tzf` / `unzip -l` 列出顶层布局——多数归档有 `<name>-<version>/` 顶层目录，但有的直接散装在根部（ai-usagebar-bin 的 tar.gz、inso-bin 的 zip），install-plan 按实际布局写。

### 裸 ELF 可执行文件

`gnu-build-system`，`replace 'unpack` 阶段用 `copy-file` 直接复制原始二进制。安装到 `lib/<pkg>/`，然后从 `bin/` 创建 ld-linux wrapper。**裸 ELF 的陷阱**：即使 `readelf -d` 显示 NEEDED 为空，运行时仍可能通过 `dlopen` 加载 native addon（如 oh-my-pi 的 `pi_natives.linux-x64-modern.node`）。这些 addon 可能依赖 `libgcc_s.so.1`，因此 inputs 中需要包含 gcc 的 `lib` 子输出。

**`.node` 与 `.so` 的 RPATH 规则**（2026-11-07 两次修）：`library-file?` 曾把 `.node` 误判成非库（`string-suffix?` 参数写反，恒为 #f），所有 Electron 包的 native addon 从来没拿到 Guix RPATH——qoder-cn 的 keytar 因此 `dlopen` 不到主程序没链的 `libsecret-1.so.0`。修复后 `.node` 与 `.so` 一视同仁走 library 分支；旧 RPATH 经 `kept-rpath-entries` 过滤：**保留 `$ORIGIN` 相对段与 `/gnu/store` 绝对段，丢弃构建机路径（`/home/runner`、`/usr/lib`）与空段并去重**。因此 `#:preserve-rpath? #t` 不再承担「保住 $ORIGIN」的职责，它现在只是额外前置一个裸 `$ORIGIN`；自包含子树仍可用 `#:patchelf-exclude`，但理由只剩 patchelf 变形风险（如 cindy-cn-bin 的 `libvips-cpp.so` 有 DT_INIT 失步），不再是为了保住 `$ORIGIN`。

完整模板见 `references/package-template.scm`。

### 自定位二进制：patchelf 和 wrapper 都不可用

判断标准：二进制在运行时用 `/proc/self/exe` 或自身文件名定位资源、甚至解包自己。任何改变 ELF 布局或文件名的处理都会破坏这条假设：

- **bun --compile 产物**：`patchelf` 写 interpreter/RPATH 会平移 ELF 内的 `.bun` 段，自解包随之损坏；Guix ld-linux wrapper 则让 `/proc/self/exe` 指向 wrapper 自身，触发循环解包（打包探索记录，仓库暂无此类包实例；nix-ld 侧基础设施已就位）。可行方案：**原样安装、不 patch**，依赖系统级 nix-ld 提供带回退搜索路径的 `/lib/ld-linux`（`jeans/services/nix-ld.scm` 的 `nix-ld-service-type`），运行库通过 `NIX_LD_LIBRARY_PATH` 提供。
- **wrap-program 会把真实二进制改名为 `.<name>-real`**：neomacs 在该命名下死循环。解法：真实 ELF 以本名安装到 `libexec/<pkg>/`，`bin/` 下手写 thin shell wrapper 启动它；exe 同目录数据（`neomacs.pdump`）和上游按 exe 路径探测的 `../share/<name>` 随之回正，仍不够时用上游提供的环境变量（如 `NEOMACS_RUNTIME_ROOT`）显式指路。完整分析见 `emacs-xyz.scm` 的 `neomacs-bin` 包前注释。
- **反例（能容忍 `.real` 命名）**：Tauri 的 resource/sidecar 解析以真实 exe 路径为基准，`wrap-program` 不影响（rayburst-bin，见下方 Tauri 小节）。动手前先读上游定位自身资源的代码，不要按包类型猜。

### patchelf page-shift 把 .dynamic 压成只读段（非 PIE 二进制启动即段错误）

deb/AppImage 里常带上游自编译的**非 PIE**辅助二进制（基址 0x400000 的 EXEC），其 PT_INTERP 空间按 `/lib64/ld-linux-x86-64.so.2`（27B）留。patchelf `--set-interpreter` 换 `/gnu/store` 长路径（~65B）放不下时触发 page-shift：映像下移、新建 RW PT_LOAD 装 interpreter/phdr/notes/.dynamic，**与原只读 PT_LOAD 地址重叠**；ld.so 按 phdr 顺序映射，后映射的 R 段把 .dynamic 页覆盖成不可写，glibc 2.41 的 ld 启动写 DT_DEBUG 即 SIGSEGV。

症状与判定（zcode 3.15.1 内嵌 ugrep/bfs/ripgrep 实证）：`--version` 即段错误 139；strace 里 execve 后只有两个 mmap、**无任何 openat** 就崩，si_addr 落在 .dynamic 内、`SEGV_ACCERR`（权限错误而非未映射）；`readelf -lW` 可见基址被下移（0x3fe000 而非 0x400000）且两个 LOAD 地址区间重叠。对比原始 deb 二进制（单 R LOAD 含 .dynamic）在标准 glibc 下正常——单段只读 ld 自己能处理，重叠覆盖才致命。patchelf 0.18.0（guix 1.5.0 所带）仍复现，非版本问题。

修复已进基座（`build/binary.scm` 的 `patch-one`）：executable 分支 `--set-interpreter` 后调 `repair-dynamic-load-permission`，解析 ELF64 phdr 给覆盖 PT_DYNAMIC 的只读 PT_LOAD 补 PF_W 位。正常二进制（.dynamic 本就在 RW 段）no-op；library 分支不设 interpreter 不触发；ELF32/畸形文件安全跳过。

### dlopen / CFFI 写死的动态加载

`readelf -d` 的 NEEDED 列表只是静态真相，两类运行时加载会让"NEEDED 为空 = 无依赖"的判断失效：

- **裸 soname dlopen**：加载探测列表的第一项常是不带路径的裸 soname（fresh-editor-bin 的控制台鼠标支持 dlopen `libgpm.so.2`，`editor.scm` 包前注释）。RUNPATH 即可满足：把提供该库的包加进 inputs 并纳入 library path，不需要 symlink。
- **RUNPATH 失效场景（dlopen 由内嵌 runtime 发起）**：glibc 的 dlopen 只查*调用者*自己的 RUNPATH。宿主 ELF 内嵌另一个 runtime 并由它 dlopen 裸 soname 时（.NET single-file bundle：P/Invoke 走 libcoreclr 的 dlopen），打在宿主 ELF 上的 RPATH 完全不可见——库加载静默失败、上层功能无声降级。opentabletdriver-bin `hardware.scm` 包前注释：HidSharp 拿不到 libudev.so.1 时设备枚举恒为空，日志只说 "No tablets were detected"，不报库错误。解法是改走加载器自身的探测路径：.NET NativeLibrary 先试 `<assembly-dir>/<soname>`，把裸 soname symlink 进二进制同目录（libudev.so.1/libevdev.so.2/libnotify.so.4/libX11.so.6/libXrandr.so.2 实例）。soname 清单不要靠撞：grep 上游源码的 `DllImport` 常量一次枚举全（OTD 的 XScreen 走 libX11+libXrandr，而其 Wayland 路径是纯托管客户端零原生依赖，属"库清单取决于运行时分支"的变体）。strace 观察 dlopen 的 openat 搜索序列是判定调用链的最快手段。
- **写死上游发行版的 soname**：CFFI/FFI 的候选列表按打包者的发行版写死（lem-next 的 CFFI 写死 Ubuntu 的 `libncursesw.so.6.3`，而 Guix 的 ncurses 只提供 `libncursesw.so.6`）。解法：安装阶段在二进制同目录 `symlink` 一个别名指向 Guix 的实际库文件（`editor.scm` 的 `lem-next-bin` 实例），并把该目录放进 RUNPATH。**但 symlink 只解决「找不到库」，不解决符号版本**：ELF 若带 `.gnu.version_r` 需求（neomacs 要求 `libtinfo.so.6` 的 `NCURSES6_TINFO_5.0.19991023` 节点），替身库里却没有对应的 `.gnu.version_d` 定义，符号照样解析成功、加载器却每次启动都打印 `libtinfo.so.6: no version information available (required by ...)`。根治是提供真库：Guix 的 ncurses 没开 `--with-termlib`/`--with-versioned-syms`（Ubuntu 开了），`(inherit ncurses)` 补上这两个 flag（`emacs-xyz.scm` 的 `ncurses-tinfo-versioned`）即得带完整 `NCURSES6_TINFO_*` 节点的 `libtinfo.so.6`。诊断：`readelf -V` 对比二进制的 verneed 名与候选库的 version_d 节点。
- **升级后 NEEDED 会变，包内注释不是事实来源**：上游构建环境一变，依赖集合就可能增删——neomacs 0.0.16 移除了 GStreamer，0.0.18 又把它重新链进 NEEDED，而包定义与注释仍停在旧状态，症状是加载器直接拒绝启动（`libgstpbutils-1.0.so.0: cannot open shared object file`，`--version` 都过不去）；magpie-bin 0.1.1167 新增 `libfontconfig.so.1` 直接 NEEDED，hash 与构建全绿、装进系统即死。预编译包每次自动更新落地后，对 `bin/`、`libexec/` 下每个 ELF 重跑 `readelf -d | grep NEEDED`，与 inputs/RUNPATH 求差集；包前注释里的依赖清单同样要跟着改，它恰恰是最容易被信任的过期文档。**自动更新闸门已把这道检查自动化**：`test_updated_packages.py` 对更新产物里每个带 PT_INTERP 的 ELF 跑 `ld.so --list`（patchelf ELF 用自身 interp+RUNPATH；ld-linux/env wrapper 提取脚本里的 ld.so、`--library-path`、`LD_LIBRARY_PATH` 目录），直接缺失（stderr 致命错误）或传递缺失（`=> not found`）即判构建失败；无可用 ld.so 的自定位/nix-ld 包记 skipped 放行。注意该检查只看静态 NEEDED，dlopen/FFI 依赖不在其覆盖范围，仍按上条手动验证。
- **Electron safeStorage 是四层链，不是一条 NEEDED**（cindy-cn-bin 实证）：Linux 凭据存储链 = ①主二进制 dlopen `libsecret-1.so.0`（字符串里有 `Could not load libsecret-1.so.0:`，NEEDED 照不到）→ ②`--password-store=gnome-libsecret` 选定后端（auto-detect 在裸会话选不中，`basic`/`basic_text` 下 `isEncryptionAvailable()` 恒 false，应用层按不可用处理）→ ③会话里要有 `org.freedesktop.secrets` 持有者（gnome-keyring/kwallet/keepassxc 皆可；没有时 wrapper 兜底 `gnome-keyring-daemon --start --components=secrets`，用 gdbus `NameHasOwner` 判定避免抢占；KDE/Plasma 会话整体跳过让 Chromium 原生选 kwallet，用户显式传 `--password-store` 时也不覆盖——详见下文「Electron safeStorage 与 Secret Service 服务」小节）→ ④加密锁定的 keyring 需要解锁弹窗，daemon 向 `org.gnome.keyring.SystemPrompter` 发请求——无 prompter 时 libsecret 的 GTask 静默烂掉（`secret_service_real_prompt_async ... finalized without ever returning`），功能挂起而非报错。Guix 的 gcr 4.x 不带 prompter，`gcr-3` 的 `libexec/gcr-prompter` 后台拉起即认领两个 prompter 名。层①加 `libsecret` input 进 RPATH 即解；②③④在 wrapper exec 前注入（substitute `^exec -a ` 同款锚点）。诊断顺序：app.asar 里 grep 后端 flag/服务名 → 会话 `NameHasOwner` → stderr 找 `Could not load`/GTask。同类深坑：上游 JS 硬编码 `/usr/bin/python3`（remote-desktop 凭证 helper、viewer display）与 `/usr/bin/grim|hyprctl|wl-paste`（wayland 截屏/剪贴板）——strings 扫 `"/usr/bin/` 一遍能提前枚举这类失效面，asar 内字符串长度受限难以原地替换，功能降级时按已知限制记录。
- 断言"Guix 下无法加载"之前，先读上游的加载源码找探测顺序——多数 FFI 按列表依次尝试，前面失败会落到可满足的后续项。

### 所有预编译包的通用规则

- `patchelf` 用于设置 ELF 解释器（`ld-linux`）和 RPATH（指向 Guix store 路径）。
- 先探测 linkage 再动手：`patchelf --print-interpreter` 非零退出（找不到 `.interp` 段）说明是静态二进制（static-pie），直接复制安装即可，不做任何 interpreter/RPATH 处理。`agent.scm` 的 crush 在构建时探测、只在 dynamic 时 `--set-interpreter`；CodeWhale 已知 fully static，直接安装、连 patchelf 都不进 native-inputs。
- 探测结论只对该次 `--set-*` 有效，**每个设置型操作前要独立确认对象是动态 ELF**：reasonix-studio 2.22.0 的 Go sidecar（原为动态、注释写「libc only」）转静态后，旧代码「`.so` 跳过 interpreter + 无条件 `--set-rpath`」在 `--set-rpath` 处炸出 `cannot find section '.dynamic'`（issue #47）。修法是 phase 内以 `--print-interpreter` 退出码存 `dynamic?`，静态文件 interpreter 和 rpath 全跳过；`--set-rpath` 对静态 ELF 同样必炸，别只防 `--set-interpreter`。**上游升级可能翻转单个二进制的链接方式**——deb 里的 sidecar/子二进制升级后逐个 `file` 检查，别信包注释。
- 设置 `#:tests? #f`（无源码 → 无测试）。
- 设置 `#:validate-runpath? #f`（预编译二进制无法通过 Guix 的 runpath 校验）。
- 设置 `#:strip-binaries? #f`（预编译二进制不支持 Guix 的 strip，会导致损坏）。
- 二进制安装到 `lib/<pkg>/`，然后从 `bin/` 创建符号链接，使 patchelf 能找到同目录的 `.so` 文件。
- 自动更新 CI（guix refresh 主力 + Python 兜底）会对本次更新的所有包运行构建测试；预编译包同样需要验证解包、patchelf 和 wrapper 阶段。

### systemd 单元与 autostart：先判断有没有消费者，再决定装不装

预编译包的上游几乎都按发行版布局发 `share/systemd/user/*.service|*.socket` 和 `etc/xdg/autostart/*.desktop`。Guix 没有 systemd，这些文件装进 `$out` 之后没有任何东西会读它们——不是"装了暂时没用"，而是纯死文件，还会让人误以为功能已经配好（2026-11-10 msime-bin 首版实证：整棵 `usr/share/` 安装把三个用户单元带了进去）。

判定顺序：

1. **看单元在做什么**：常驻进程、socket 激活，还是一次性注册。
2. **找有没有替代拉起路径**：宿主自己 spawn、设置应用按需启动，或上游已经写了"没有 systemctl 就手动启动"的分支。msime 的上游就明说 `if shutil.which("systemctl") is None: print("... 可用 msime-linux-provider-session online|voice 手动启动")`——有这条就说明作者预期了非 systemd 系统。
3. **有用户价值且没有其他拉起点** → 在 `modules/jeans/home/services/` 写 home shepherd 服务（参照 `home-nosdshell-service-type` 与 `hardware.scm` 的 otd-daemon）；**纯参考或没人消费** → 不装。

安装侧：不要整棵 `("usr/" ...)` 或 `("usr/share/" ...)` 安装，逐目录列 `install-plan`（applications / doc / fcitx5 / ibus / icons / …），systemd 与 autostart 就不会跟进来。整包安装的上游（AppImage、`usr/` 全装）排除不掉时，至少在包前注释写明"这些 unit 无人消费，Guix 用 home service 代替"，别让下一个人以为它们在工作。

shepherd 侧的环境时序（2026-11-10 实证，与 `hardware.scm` 注释同源）：

- Shepherd 在 **TTY 登录**时启动，环境里有 `XDG_RUNTIME_DIR`（elogind 设），但**没有** `WAYLAND_DISPLAY` / `DISPLAY`。
- `home-wayland-service-type` / `home-x11-service-type` 的 `start` 用 `setenv` 写进 Shepherd 自身；而 `make-forkexec-constructor` 的默认 `#:environment-variables` 在服务构造时就取好了，看不到这个变化。显式传 `#:environment-variables (environ)` 才会在 start thunk 里取值、拿到已经 setenv 的变量。
- 所以需要显示的常驻服务必须 `(requirement '(wayland-display))` 或 `(requirement '(x11-display))`；两种会话都要支持的包用"等 compositor socket 出现再 exec"的 wrapper（OTD 做法）。requirement 是 AND 语义，写不了"任一"，会话类型二选一时给用户一个配置字段（msime 的 `clipboard-requirement`）而不是猜。
- requirement 缺失不是静默失效：`guix home build` 在配置验证阶段直接报 `服务 'x' 需要 'y'，但没有任何服务提供该服务`。所以需要显示的服务默认必须关闭（`clipboard? #f` 之类），否则会连累整份 home 配置构建失败——这反而比运行期悄悄不启动好，错误信息足够让用户补上 wayland/x11 service 或把 requirement 置空。
- 只依赖 `XDG_RUNTIME_DIR` 的服务（socket provider、音频、网络）**不需要** requirement。

实例对照：`msime-bin`（三个 provider，包内不装 unit，`home-msime-service-type` 提供开关）；`sunshine-bin`（unit 随 AppImage payload 落在 `lib/sunshine/usr/share/sunshine/systemd/user/`，整包安装排不掉，注释声明用 home shepherd）；`opentabletdriver-bin`（`.deb` 里的 otd-daemon unit，`home-opentabletdriver-service-type` + wait-for-display wrapper）。


### Qt 预编译 bundle 缺插件

自包含 Qt bundle（AppImage 等）常缺个别 Qt 插件。典型案例：waywallen 的 AppImage 不含 `iconengines/libqsvgicon.so`，所有主题 SVG 图标渲染为空白。补法：把 Guix 对应 qt 包的插件目录（如 `qtsvg` 的 `lib/qt6/plugins`）**追加**到 wrapper 的 `QT_PLUGIN_PATH`（bundle 自带目录在前）。前提：wrapper 的 `LD_LIBRARY_PATH` 让 bundle 的 Qt 库排在 Guix Qt 之前，插件于是链接回 bundle 的 Qt，避免两套 Qt ABI 混用。

### 预编译包需要的 ffmpeg 版本 Guix 没有

Guix 只有 ffmpeg 8.x/6.x/5.x/4.x，没有 7.x。预编译包链接 7.x sonames（libavformat.so.61、libavcodec.so.61、libavutil.so.59、libswscale.so.8、libswresample.so.5）时，在同一包文件内写**私有 helper**（`define` 而非 `define-public`）：`(inherit ffmpeg)` 改 name/version/source，只保留 shared 输出，inputs 收缩到实际需要的（如仅 zlib）。**保留继承来的自定义 `configure` phase**——ffmpeg 用手写的 configure，不接受 gnu-build-system 默认 phase 注入的 `CONFIG_SHELL`/`--build=` 参数，替换掉就构建失败。参照 `desktop.scm` 的 `ffmpeg-7`（open-wallpaper-engine-bin 的依赖）。

### 插件宿主不读 XDG_DATA_DIRS

插件型宿主（daemon/编辑器）常只扫私有目录（如 `<exec>/../share/<name>` 和 `$XDG_DATA_HOME/<name>`），不读 `XDG_DATA_DIRS`——而 Guix profile 恰恰通过 `XDG_DATA_DIRS` 暴露 `share/` 树。桥接法：在 wrapper 里遍历 `XDG_DATA_DIRS`（shell 循环需临时 `IFS=:`），把含 `<name>/plugins/` 的目录去重后转成上游的插件 CLI 参数（如 `--plugin <dir>`）。使用前确认：flag 是否可重复、上游期望前缀目录还是插件目录本身。桥接后，插件包与宿主装进同一 profile 即可互相发现，无需用户手动 symlink。

### Electron 包的 Wayland/Ozone 参数

仓库有两个现成的 phase helper（`agent.scm`），新 Electron 包直接复用，不要各写各的：

- `prefer-electron-wayland-phase`：默认方案。`WAYLAND_DISPLAY` 存在且用户未自选平台时，向 wrapper 注入 `--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations`。
- `prefer-electron-wayland-hint-phase`：**argv 解析严格的上游**（自己的 parser 对未知 flag 直接退出，Paseo 实证）不能用注入方案，改为 export Electron 原生的 `ELECTRON_OZONE_PLATFORM_HINT=wayland`。注入后启动即报未知 flag 的包换这个。

生效条件（读 case 逻辑）：hint-phase 只在用户未设置 `ELECTRON_OZONE_PLATFORM_HINT` 时 export；wayland-phase 在未设置（默认 auto）或显式设为 wayland 时注入，设为其他值（如 x11）则不注入。两者都不覆盖用户指向其他平台的选择。

### Electron 内置终端的 CA 证书

Guix 的 curl/git/python 编译期**不带默认 CA 路径**，全靠 `SSL_CERT_DIR`/`SSL_CERT_FILE` 环境变量；Electron 应用的 wrapper 若只设三件套（LD_LIBRARY_PATH/FONTCONFIG_FILE/XDG_DATA_DIRS），内置终端从无证书变量的 GUI 会话启动时 curl 返回 000、git 报 `certificate signer not trusted`、python 报 `unable to get local issuer certificate`（zcode 实证：`env -i` 后必现，从登录 shell 继承时表面正常，换启动路径就挂）。

修复已进基座（`build/electron.scm` 的 `wrap-electron-program`）：substitute `^exec -a ` 注入 `export SSL_CERT_DIR="${SSL_CERT_DIR:-<nss-certs>/etc/ssl/certs}"`，`${VAR:-默认}` 语义保留用户/桌面会话已设值（如 mihomo MITM 自签 CA）。electron 包 inputs 需补 `("nss-certs" ,nss-certs)`。

两个事实：① guix 1.5.0 **没有** `ca-certificate-bundle` 变量（`(gnu packages certs)` 只导出 mkcert/certdata2pem/le-certs/desec-certbot-hook），CA 包现名 **nss-certs**，在 `(gnu packages nss)`；② nss-certs 只产 `etc/ssl/certs` 目录（.pem + .0 hash 链接）、**没有合并的 ca-certificates.crt**，所以只注入目录型变量——文件型变量（SSL_CERT_FILE/CURL_CA_BUNDLE/GIT_SSL_CAINFO/NODE_EXTRA_CA_CERTS 等）指向不存在的文件比不设更糟。系统 `/etc/ssl/certs/ca-certificates.crt` 是 guix system etc-service 生成的 store 项，不是包，不能当 input。实测目录型 `SSL_CERT_DIR` 一项即让 curl/git/python/node 全部连通。

### Electron 主二进制被上游换成 launcher 脚本

上游可能把 Electron 主二进制改名、原入口换成 POSIX launcher 脚本（Paseo 0.9.2：`Paseo` 变成脚本、真 ELF 移到 `Paseo.bin`）。两处要跟着改，漏第一处构建直接失败（`patchelf: not an ELF executable`，Paseo 0.9.2 实证）：

- **patchelf 目标换成新 ELF 名**，并给新脚本打 store shebang（上游脚本带 `#!/bin/sh`）。脚本里的 sandbox 检测依赖宿主的 `readlink`/`unshare`/`stat`/`findmnt`/`grep`，这点和 bundle 的其它脚本一致，不用额外补 PATH。
- **`wrap-program` 的 `exec -a "${0##*/}"` 会破坏按 `$0` 定位自身的脚本**：脚本用 `readlink -f -- "$0"` 推出 `${launcher}.bin`，而裸 basename 会被 readlink 解析到调用者的 CWD 而非 store。在 `wrap-program`（及 wayland helper）之后 substitute wrapper 换回真实路径，保持在 `exec -a ` 前缀上（helper 的 `^exec -a ` 锚点仍有效）：`(("exec -a \"[^\"]*\" ") (string-append "exec -a \"" #$output "/lib/<pkg>/<launcher>\" "))`——正则用 `[^"]*` 而不是手写 `${0##*/}`，避开 `$`/`{`/`*` 的转义。

### Electron 子进程的 env 过滤 ⇒ RUNPATH 必须自足（nss /lib/nss 布局）

Chromium 的 `utilityProcess.fork` 用**过滤后的 env**（仅 HOME/PATH/LANG 等 9 个变量，**不含 LD_LIBRARY_PATH**）重新 exec `process.execPath`。wrapper 的 LD_LIBRARY_PATH 只覆盖 wrapper 直接启动的主进程；这类子进程重新 exec 同一二进制时只认 **RUNPATH**，缺库即 `libnss3.so cannot open`、退出 127（qoder-cn 0.5.6「Qoder Mobile 远程控制连接失败」实证：远程控制进程是 Node utility，fork 即死，主进程与 UI 毫无异常）。

而 Guix 的 nss 共享库不在顶层 `/lib`：`<nss>/lib` 只有 `nss/` 与 `pkgconfig/`，真库在 `<nss>/lib/nss/`（electron 层 wrapper 的 LD_LIBRARY_PATH 早已特判 `nss/lib/nss`，RUNPATH 侧一直缺失，两处不对称）。

修复在基座（`build/binary.scm` 的 `auto-lib-dirs`）：对 label 为 `nss` 的 input 追加 `/lib/nss` 子目录，全部 binary/electron 包的 RPATH 随之自足。单包临时方案：`#:patchelf-plan #~'(("lib/<pkg>" ("nss" "/lib/nss")))`。

验证必须**不带 wrapper env** 对产物全部 ELF 跑 `ld.so --list`：`env -i <glibc>/lib/ld-linux-x86-64.so.2 --list <elf> | grep "not found"` 须为空（qoder-cn 实测 19 个 ELF，含 resources 下的 .node；注意过滤条件要覆盖无扩展名与 `.so.N`，`*.so`/`*.node` 会漏 `chrome_crashpad_handler`/`libvulkan.so.1`）。带 wrapper 的 LD_LIBRARY_PATH 跑这个检查正好漏过 env 过滤型子进程——清空环境是唯一可信形态。

### Electron safeStorage 与 Secret Service 服务

Electron 的 safeStorage（Linux 凭据存储）两件事缺一不可：dlopen `libsecret-1.so.0`（keytar 原生模块，NEEDED 里看不见）+ **会话里有 org.freedesktop.secrets 服务**。niri 会话下自动探测失败会静默退到 `basic_text` 后端，`isEncryptionAvailable()` 返回 false，应用拒绝持久化凭据——症状是每次启动都要重新登录（qoder-cn 0.5.6 实证；宿主 Secret Service 本身健康，`gdbus call … NameHasOwner org.freedesktop.secrets` 返回 true 也不能说明 app 侧探测成功）。

解法（cindy-cn-bin 0.1.128 + qoder-cn 0.5.6 实证）：基座 phase `ensure-secret-service`（`build/electron.scm`，位于 `prefer-wayland-hint` 之后）substitute wrapper 的 `^exec -a ` 前缀，exec 前按序完成：

1. **输入即开关**：inputs 里能定位到 `bin/gdbus`、`bin/gnome-keyring-daemon`、`libexec/gcr-prompter` 三者才启用（包定义补 `gcr-3`、`gnome-keyring`、`("glib:bin" ,glib "bin")`）。**不要**为此加 build-system 关键字——关键字须逐层穿过 bag arguments 到 builder，而 builder 只显式转发自己 `#:key` 声明的键（`#:allow-other-keys` 只是不报错，不转发），多一个键就多一处注定漏水的 plumbing。
2. **KDE/Plasma 直接跳过**：`XDG_CURRENT_DESKTOP` 含 `KDE`/`Plasma` 时不动，Chromium 原生 detect 会选 kwallet 直连；注入 `gnome-libsecret` 反而把它换成 libsecret 路径（数据仍进 kwallet，但绕开了用户桌面的原生选择）。
3. 其余桌面 `gdbus call … NameHasOwner org.freedesktop.secrets` 探测：在位即沿用（kwallet 桥 / keepassxc / gnome-keyring 都算），缺席才 `gnome-keyring-daemon --start --components=secrets` 兜底，起来后再后台拉 `libexec/gcr-prompter`（占 `org.gnome.keyring.SystemPrompter` 名，负责解锁弹窗）。
4. **仅当**服务确认在位、且用户没自己传 `--password-store=` 时才 `set -- --password-store=gnome-libsecret "$@"`；否则一律留给 Chromium detect。

隔离验证：`dbus-run-session -- env XDG_RUNTIME_DIR=<空目录> HOME=<空目录> bash -c '<gnome-keyring-daemon> --start --components=secrets; sleep 0.3; gdbus call … NameHasOwner …'` 才会让 daemon 真注册（共享真实 `XDG_RUNTIME_DIR` 时它检测到 control socket 就打 `discover_other_daemon: 1` 早退，属预期，不是故障）。行为判定用 `bash -x <wrapper> --version 2>&1 | grep '^+ exec -a'`：KDE 会话无 flag、普通桌面有 owner 时前置 `--password-store=gnome-libsecret`、用户自传 `--password-store={{SECRET_demo}}` 时原样保留不覆盖。

lint 的 `glib:bin 可能应该是本地输入` / `nss-certs 可能不应该是输入` / `gcr-3 标签与包名不匹配` 三条 finding 与 cindy-cn-bin 同源，是通道既有模式。

### Chromium 150 的 generic 字体路径不采用 TTC 匹配（Electron 包字体怪障）

Chromium 150（Electron 43.8.4）对 **generic family**（sans-serif/monospace）的 fontconfig 匹配结果**拒绝采用 TTC 文件**，静默 fallback 到后续 sans 候选：用户 fontconfig 配置 `sans-serif → Sarasa Gothic SC`（位于 Sarasa-Regular.ttc 内，比例字形），界面拉丁字母实际渲染成 Iosevka Nerd Font（等宽），中文正常（fallback 到 Sarasa Mono SC）。同 env 系统 Chromium 156 渲染正常——版本相关的 Skia/fontconfig 交互差异。

实证边界（qoder-cn 0.5.6，CDP `CSS.getPlatformFontsForNode` + 字形宽度测量）：

- generic `sans-serif` → Iosevka NF（等宽，m/i=1.0）；**点名** `"Sarasa Gothic SC"` → Sarasa Gothic SC（比例）✓；fontconfig alias 指向**单 TTF**（DejaVu Sans）→ DejaVu Sans ✓。即 Chromium 读 alias，只是不采用 TTC。
- fontconfig 层无问题：`fc-match` 正确返回 TTC 内的比例 face；`FONTCONFIG_FILE=fontconfig-minimal` 也**不阻断**用户配置（fontconfig 硬编码追加加载 `~/.config/fontconfig/fonts.conf`，与主配置无关）。
- remedy 原型验证有效：fontTools 从 TTC 拆出目标 face 为单 TTF + conf `rejectfont *.ttc` + alias 指向拆出文件 → generic sans-serif 正确渲染 Sarasa Gothic SC 比例字形（m/i=3.7）。Iosevka Nerd Font **Propo** 不行——它是比例字形但等宽 advance。

**这不是 jeans 包装缺陷**（wrapper 的 fontconfig 设置正确），修复归属用户 fontconfig 配置层（拆 TTC 单 face，或 alias 改指单 TTF 比例字体）。排查同类「Electron 包拉丁变等宽/怪字体」按此链条走：CDP `getPlatformFontsForNode` 读实际 face → `fc-match` 对照 fontconfig 层 → TTC/单 TTF 判定。

### Debian .deb 的 ABI 漂移适配（mysql-workbench classic-bin 模式）

Ubuntu/Debian 构建的预编译 .deb 与 Guix 同名库之间有四类系统性 ABI 漂移，逐类判定（全部实证于 `databases.scm` 的 mysql-workbench-community-classic-bin，8.0.47 ubuntu24.04 deb）：

- **soname 落后/领先**（Debian 保留上游旧 soname：`libzip.so.4`、`libsasl2.so.2`；Guix 是 `.so.5`/`.so.3`）→ 在包的 lib 目录建兼容 symlink（`databases.scm:631` compat-symlinks phase）。先决条件：`nm -D` 核对消费方 undefined 符号在目标库全部存在且无版本化节点要求。
- **版本化符号引用 vs 无版本定义库**（deb 引用 `@LIBXML2_2.4.30`、`@NCURSES6_TINFO_*`，Guix 的 libxml2.so.16/libncursesw 无这些 verdef 节点）→ glibc 对**完全没有 `.gnu.version_d` 的提供方**宽容匹配任意版本引用，只打印无害的 `no version information available`（bundled mysql CLI 实证跑通，`databases.scm:631` 的 libtinfo.so.6→libncursesw.so.6 symlink）。但注意方向相反的陷阱：若提供方**有** verdef 而缺所需节点（Guix libxml2.so.16 恰有部分版本化符号）则硬失败——所以 libxml2 不能 symlink 到 Guix 版，必须私有构建未版本化的 `libxml2-legacy` 2.12.9（`databases.scm:247`）拿到干净的 `.so.2`。
- **ABI 代际选择不同**（Guix libjpeg-turbo 一律 6b ABI = `libjpeg.so.62`，Debian 用 v8 ABI = `libjpeg.so.8`）→ 私有构建 `-DWITH_JPEG8=ON`（`databases.scm:278`），无法用 symlink 跨 ABI（结构体布局不同）。
- **Guix 完全没有的依赖**（捆绑 libgdal 需要 `libLerc.so.4`，Guix 无 lerc 包）→ 私有 helper（`databases.scm:216`）。

判定工具链：全 ELF `readelf -d` 求 NEEDED 并集 → `guix build` 后 `find … -type f | xargs ldd | grep "not found"` 必须为空；符号级用 `nm -D <deb ELF> | grep " U <prefix>"` 对照 `nm -D <guix lib>`。另外两个 deb 专属要点：compat symlink 必须建在 patch-elf **之后**（`find-files` 会遍历到指向只读 store 项的 symlink，patchelf 改写会失败，`databases.scm:598`）；deb 里未被任何 NEEDED/dlopen 引用、且自带重型依赖（如 GTK2）的辅助二进制可不装（iodbcadm-gtk，`databases.scm:575`），比拖整条 GTK2 闭包干净。

### Tauri 应用（prebuilt .deb）

Tauri 预编译包的两个解析规则（motrix-next-bin 实证，4.0.0 改名 rayburst-bin 后结构不变）：

- **resource_dir()** = `exe_dir/../lib/<identifier>/`：资源树（配置、数据库、bootstrap 数据）必须装到 `lib/<identifier>/`，缺任一数据文件会在启动时崩溃。
- **shell-plugin sidecar 按 `exe_dir` + basename 解析**（不在 resource dir）：替换 sidecar（如用独立 Guix 包替换 bundled 引擎）时，新二进制必须放在主 ELF 同目录。注意 `wrap-program` 会把真实二进制改名为 `.<name>-real`，`/proc/self/exe` 随之指向它——sidecar 与 resource 解析都以这个真实路径为基准。
- **sidecar 的 basename 可能与独立包撞名**：上游 bundled 引擎叫 `aria2-next`，与独立的 `aria2-next-bin` 同 basename。两包同装一个 profile 时 Guix 报 collision warning 并选先到者（实测：`warning: collision encountered` 后 `choosing ...aria2-next-bin-2.8.2/bin/aria2-next`，profile 构建成功，非错误）。**无需为此改包装结构**：sidecar 从包自身 `exe_dir` 解析，不经 profile 的 `bin/`，程序始终用自带引擎（rayburst-bin 4.0.0 实证）。

