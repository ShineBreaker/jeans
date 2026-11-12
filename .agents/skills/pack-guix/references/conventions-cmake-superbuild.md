# jeans 通道打包约定 — CMake superbuild / vendored 依赖栈

<!-- 2026-11-12 由 references/jeans-conventions.md 按主题拆分；内容为整段原样搬迁 -->

## CMake superbuild  vendored 依赖栈（aria2-next）

上游用 CMake superbuild 把整条依赖栈 vendored 进 third_party/（aria2-next 3.x：
boost/curl/expat/ffmpeg/gpac/libssh2/libtorrent/nghttp2/openssl/sqlite/zlib），
全静态构建、无需网络。cmake-build-system + `-DARIA2_SUPERBUILD=ON` 即可，但 Guix
沙箱有两处必改（snippet，aria2-next 3.1.0 实证）：

1. **沙箱无 /bin/sh**：ffmpeg 的 configure 做 sanity check 时生成一个 `#!/bin/sh`
   测试脚本并执行它；Guix 构建沙箱**没有 /bin/sh**（实测 exec status 127，**不是**
   noexec 挂载问题）。把该 shebang 指向 store 的 sh——与 Guix 官方 ffmpeg 包
   （video.scm:1962）同一修复：
   ```scheme
   (substitute* "third_party/ffmpeg/configure"
     (("#!/bin/sh") (string-append "#!" #$(file-append bash-minimal "/bin/sh"))))
   ```
   native-inputs 需含 bash-minimal。诊断手法：写一个 trivial-build-system 探针
   包，在 builder 里 `system* "/bin/sh" "-c" "true"` 看返回 127 即证实。
2. **lib64 陷阱**：64 位 GNUInstallDirs 默认把 CMake 依赖装进 lib64，而内层项目
   按 `lib/lib*.a` 硬搜索（OpenSSL 已 --libdir=lib）→ sqlite/zlib 等装到 lib64
   后找不到。在 superbuild 的外部 CMake 参数里强制 `-DCMAKE_INSTALL_LIBDIR=lib`。

另：superbuild 常跳过内层 install（`INSTALL_COMMAND ""`），snippet 重新接回
`INSTALL_COMMAND ${CMAKE_COMMAND} --install <BINARY_DIR> --prefix
${CMAKE_INSTALL_PREFIX}`，内层 GNUInstallDirs 规则才装出 bin。产物链接形态与
release ELF 一致（仅 libstdc++/libm/libgcc_s/libc 动态，余全静态）——升级时按
预编译包同一标准做 `ld.so --list` 加载器级 NEEDED 复查。

