;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; LZSync —— mygo（Go 后端 + webview 前端）应用，三段全部从源码构建。
;;;
;;; Packing notes (kept out of the descriptions on purpose):
;;;
;;; - 上游仓库自带的 lzsync.scm 是两段式：先 `just package`（mygo build，依赖
;;;   宿主的 go/bun/cmake/gcc-13），再 `guix build -f lzsync.scm` 用 local-file
;;;   收产物。本定义改为单次 hermetic 源码构建，上游本地只需要 guix。
;;; - 三段依赖：
;;;   1. librealm-ffi.so ← realm-core 20.1.1 源码。cmake 默认会去
;;;      static.realm.io 下载预编译 OpenSSL（沙箱内必失败），用
;;;      REALM_USE_SYSTEM_OPENSSL=ON 改走 Guix 的 openssl；GCC 必须锁 13.3
;;;      （上游实测 GCC 16 与 glibc 的 isnan 宏冲突报 196 错）。
;;;   2. Go 后端 ← lzsync 源码 + mygo v0.6.3 + 13 个 Go 模块。mygo 的 git
;;;      checkout 一份两用：Go replace 目标，同时 packages/runtime/src 就是
;;;      mygo-runtime 的源码（Go module zip 会剪枝非 Go 文件，拿不到它）。
;;;   3. 前端 ← bun 打包。mygo 的 webview 只消费产出的静态文件树
;;;      （mygo://localhost/ Scheme），任何等价打包器均可；bun 的 HTML 入口
;;;      一次产出 JS/CSS/HTML/图标，不需要上游 buildCommand 里的 vite/tsc
;;;      （两者都不在 Guix，且 rolldown / tsgo 是预编译原生二进制）。
;;; - Go 依赖离线解析：go.work 的 replace 指令指向解压后的模块目录，
;;;   GOPROXY=off + 只读模式，不动上游 go.mod/go.sum。
;;; - 前端嵌入：mygo CLI 的做法是 `go build -overlay` 往主 package 塞一个
;;;   //go:embed all:mygo_frontend 的生成文件；这里直接落盘等价文件。
;;; - 运行时：mygo Linux 后端经 purego dlopen 裸 soname（libglib/libgtk-3/
;;;   libwebkit2gtk-4.1/…），wrapper 必须给 LD_LIBRARY_PATH；librealm-ffi.so
;;;   由 realmc 层经 LZSYNC_LIBREALM 指名加载。
;;; - 命名：不带 -bin（本次从源码构建）；不带 -se（LZSync 是原创项目，不是
;;;   上游软件的 fork）。

(define-module (jeans packages lzsync)
  #:use-module (srfi srfi-1)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((gnu packages commencement) #:select (gcc-toolchain-13))
  #:use-module (gnu packages base)         ; glibc
  #:use-module (gnu packages bash)         ; bash-minimal（wrap-program 的 shebang）
  #:use-module (gnu packages build-tools)  ; ninja
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages compression)  ; unzip
  #:use-module (gnu packages glib)         ; glib
  #:use-module (gnu packages gnome)        ; libsecret, glib-networking,
                                           ; gsettings-desktop-schemas, libsoup
  #:use-module (gnu packages golang)       ; go-1.27
  #:use-module (gnu packages gtk)          ; gtk+, cairo, gdk-pixbuf
  #:use-module (gnu packages tls)          ; openssl
  #:use-module (gnu packages webkit)       ; webkitgtk-for-gtk3
  #:use-module (jeans packages tools))     ; bun-bin

;;; LZSync 的 Go 模块依赖。除 mygo 用 git checkout（见 lzsync 的 inputs）外，
;;; 全部取 proxy.golang.org 的模块 zip 为 origin，构建期解压到 deps/<label>
;;; 并由 go.work 的 replace 指令接管解析。字段：import-path / label / version / hash。
(define %go-module-deps
  '(("github.com/dustin/go-humanize" "go-humanize" "v1.1.0"
     "1vdax4dqw9zj79bdl2xzwgg23ndwx90fgf77yysfjc7z7dhzcymq")
    ("github.com/ebitengine/purego" "purego" "v0.11.1"
     "09hg2zq7fzwh1zdpc3jvv2r949dfvfp9d502a30x6zvmcwvh057k")
    ("github.com/google/uuid" "uuid" "v1.6.0"
     "1vd6725h6mpakfx39k6x1lagbnqy8h34ws2rw812gx0pf8vjzw6h")
    ("github.com/mattn/go-isatty" "go-isatty" "v0.0.24"
     "1f1lh8a658xxh8fy7zqrmxjdx1bxh5x4kqlnpzvlmbg0pb0gxksg")
    ("github.com/ncruces/go-strftime" "go-strftime" "v1.1.0"
     "021v33m8jbipi34hw474v6zqi0fv8fc7lchm00jgn17lrhz0jm3f")
    ("github.com/remyoudompheng/bigfft" "bigfft"
     "v0.0.0-20230129092748-24d4a6f8daec"
     "1613p2wh2yjngal0l3q03fwy9979y4gkzc6pgc7mvmc4qcr6rqcv")
    ("golang.org/x/net" "x-net" "v0.59.0"
     "00gnlfzzzxfd3l1309iskcpfiw67rbjqzb4868whvs7bzhqvzhqx")
    ("golang.org/x/sys" "x-sys" "v0.49.0"
     "0cbb1iv5r0adz5bs7hgci932hwgdm0v5rd6cwdn03mx03ichcfp7")
    ("golang.org/x/text" "x-text" "v0.43.0"
     "0qrqw6s9q1msjhmidq3mfw1aalp94wqx6f6n5y4y9qpn53v32ldp")
    ("modernc.org/libc" "libc" "v1.79.0"
     "0sdhg5jq4znl6kxxacnkkjnd60aar26lfayhyacgghf0j1sh4s17")
    ("modernc.org/mathutil" "mathutil" "v1.7.1"
     "0bmx82r0lcz8r07i6qsxvjfdpnzj49qf6w73pyc12yjmxccdmq2v")
    ("modernc.org/memory" "memory" "v1.12.1"
     "1b4h0yrkz2d8wr15vapmgzb3gn3fxasbivcizxsznxnr03qqhmg2")
    ("modernc.org/sqlite" "sqlite" "v1.61.0"
     "0mikxhl1r0yxfh25mbgs2xlibnjjmhdbr1wkjl4dk3n6qapvyi2a")))

;;; mygo CLI 生成的前端嵌入文件（cmd/mygo/embed.go 的 frontendGenSource）：
;;; 主 package 里放 mygo_frontend/<dist 内容>，再靠 //go:embed all: 整目录
;;; 收进 embed.FS 并交给 mygo.SetFrontend。
(define %mygo-frontend-gen-source
  "// Code generated for the Guix package. DO NOT EDIT.

package main

import (
	\"embed\"
	\"io/fs\"

	\"github.com/egoist/mygo\"
)

//go:embed all:mygo_frontend
var mygoFrontendFiles embed.FS

func init() {
	files, _ := fs.Sub(mygoFrontendFiles, \"mygo_frontend\")
	mygo.SetFrontend(files)
}
")

;;; librealm-ffi.so：Realm 数据库的 C API 动态库，LZSync 的 realmc 层经
;;; purego dlopen 它。私有定义——它是 LZSync 的实现细节，不作为通道对外库。
(define librealm-ffi
  (package
    (name "librealm-ffi")
    (version "20.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/realm/realm-core")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "16kk435j0xsapa87lfcqh97sxf2sjg0520sb258whxy59y28f50h"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'check)
          (replace 'build
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((gcc (assoc-ref inputs "gcc")))
                (setenv "CC" (string-append gcc "/bin/gcc"))
                (setenv "CXX" (string-append gcc "/bin/g++")))
              (invoke "cmake" "-S" "." "-B" "build" "-G" "Ninja"
                      "-DCMAKE_BUILD_TYPE=Release"
                      "-DREALM_ENABLE_SYNC=OFF"
                      "-DREALM_NO_TESTS=ON"
                      ;; 默认走 static.realm.io 的预编译 OpenSSL，
                      ;; 沙箱内下载必失败；改认系统 OpenSSL。
                      "-DREALM_USE_SYSTEM_OPENSSL=ON"
                      "-DREALM_USE_SYSTEM_OPENSSL_PATHS=OFF"
                      (string-append "-DOPENSSL_ROOT_DIR="
                                     (assoc-ref inputs "openssl")))
              (invoke "cmake" "--build" "build" "--target" "RealmFFI"
                      "--parallel" (number->string (parallel-job-count)))))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                (install-file
                 "build/src/realm/object-store/c_api/librealm-ffi.so"
                 (string-append out "/lib"))
                (mkdir-p (string-append out "/include/realm"))
                (install-file "src/realm.h" (string-append out "/include"))
                (install-file "src/realm/error_codes.h"
                              (string-append out "/include/realm"))))))))
    (native-inputs
     `(("gcc" ,gcc-toolchain-13) ("cmake" ,cmake) ("ninja" ,ninja)))
    (inputs (list openssl))
    (home-page "https://realm.io")
    (synopsis "Realm database C API library")
    (description
     "This package provides the C API of Realm Core, a mobile-first object
database with a lightweight, embeddable core.  LZSync loads it at run time
through its @code{realmc} binding layer.")
    (license license:asl2.0)))

(define-public lzsync
  (package
    (name "lzsync")
    (version "1.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ShineBreaker/LZSync")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1dylhxpnp0ci4f8gd6ihg3r11qgg7d14j8q4mmdqy0qdkdcgagky"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:validate-runpath? #f            ; Go 工具链自决 linkage，非 Guix RPATH
      #:tests? #f                       ; Go 测试要 realmc 原生库与夹具，另行手工验证
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-1))         ; first/second/third/fourth
      #:phases
      #~(modify-phases %standard-phases
          (delete 'bootstrap)             ; 非 autotools 项目
          (delete 'configure)
          (add-after 'unpack 'unpack-go-modules
            (lambda* (#:key inputs #:allow-other-keys)
              (mkdir-p "deps")
              (for-each
                (lambda (m)
                  (invoke "unzip" "-q" "-o" (assoc-ref inputs (second m))
                          "-d" "deps-stage")
                  (rename-file (string-append "deps-stage/" (first m) "@"
                                              (third m))
                               (string-append "deps/" (second m))))
                ;; 加 quote：否则列表字面量在 builder 里被当作函数调用
                '#$%go-module-deps)
              ;; mygo 的 checkout 一份两用：Go replace 目标 + mygo-runtime 源码。
              (mkdir-p "deps/github.com/egoist")
              (copy-recursively (assoc-ref inputs "mygo")
                                "deps/github.com/egoist/mygo")))
          (add-after 'unpack-go-modules 'write-go-work
            (lambda _
              ;; replace 指令把依赖指向解压后的本地目录，GOPROXY=off 即可
              ;; 完全离线解析；不动上游 go.mod/go.sum。
              (call-with-output-file "go.work"
                (lambda (port)
                  (display "go 1.27.1\n\nuse .\n\n" port)
                  (for-each
                    (lambda (m)
                      (display (string-append "replace " (first m)
                                              " => ./deps/" (second m) "\n")
                               port))
                    ;; 加 quote：否则列表字面量在 builder 里被当作函数调用
                '#$%go-module-deps)
                  (display (string-append
                            "replace github.com/egoist/mygo"
                            " => ./deps/github.com/egoist/mygo\n")
                           port)))))
          (add-after 'write-go-work 'build-frontend
            (lambda _
              ;; mygo 只消费前端产出的静态文件树，bun 的 HTML 入口一次产出
              ;; JS/CSS/HTML/图标。mygo-runtime 直接以 TS 源码参与打包——它的
              ;; build.ts 只做 Bun.build + tsc 产 .d.ts，运行时不需要声明文件。
              (mkdir-p "node_modules/mygo-runtime")
              (copy-recursively
               "deps/github.com/egoist/mygo/packages/runtime/src"
               "node_modules/mygo-runtime/src")
              (call-with-output-file
                "node_modules/mygo-runtime/package.json"
                (lambda (port)
                  (display (string-append
                            "{\"name\":\"mygo-runtime\","
                            "\"version\":\"0.6.3\","
                            "\"type\":\"module\","
                            "\"exports\":{\".\":\"./src/index.ts\"}}\n")
                           port)))
              (invoke "bun" "build" "./index.html" "--outdir=dist"
                      "--target=browser")
              (unless (file-exists? "dist/index.html")
                (error "frontend build produced no dist/index.html"))))
          (replace 'build
            (lambda _
              (copy-recursively "dist" "mygo_frontend")
              (call-with-output-file "mygo_frontend_gen.go"
                (lambda (port)
                  (display #$%mygo-frontend-gen-source port)))
              ;; 沙箱里 HOME 是只读的 /homeless-shelter，Go 的默认 cache /
              ;; module 目录都建不起来；GOPROXY=off + go.work 的 replace 已让
              ;; 依赖全部本地化，不会再触网。
              (let ((build (getcwd)))
                (setenv "GOCACHE" (string-append build "/go-build"))
                (setenv "GOPATH" (string-append build "/gopath"))
                (setenv "GOPROXY" "off")
                (setenv "GOSUMDB" "off"))
              ;; 依赖集合全为纯 Go（modernc.org/sqlite 等），mygo 的 GTK/WebKit
              ;; 绑定走 purego 运行时 dlopen，无需 cgo。
              ;; -ldflags 与 mygo CLI 的 packageFlags 等价：Linux 可执行文件
              ;; 自身不带元数据，App.Name()/Version()/Identifier() 全凭这三项
              ;; （缺失时回退到 exe basename，配置目录会变成 ~/.config/.lzsync-real）。
              (invoke "go" "build"
                      "-ldflags"
                      (string-append
                       "-X github.com/egoist/mygo.packageName=LZSync"
                       " -X github.com/egoist/mygo.packageVersion="
                       #$version
                       " -X github.com/egoist/mygo.packageIdentifier="
                       "io.github.shinebreaker.lzsync")
                      "-o" "lzsync" ".")))
          (delete 'check)
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (libdir (string-append out "/lib/lzsync"))
                     (share (string-append out "/share"))
                     (lzsync (string-append bin "/lzsync"))
                     (lib-dirs
                      (map (lambda (label) (assoc-ref inputs label))
                           '("glib" "gtk+" "cairo" "gdk-pixbuf"
                             "webkitgtk-for-gtk3" "libsoup" "libsecret")))
                     (share-dirs
                      (map (lambda (label) (assoc-ref inputs label))
                           '("glib" "gtk+" "gsettings-desktop-schemas"))))
                (mkdir-p bin)
                (mkdir-p libdir)
                (install-file "lzsync" bin)
                (chmod lzsync #o555)
                ;; realm-core 的 C API 库，realmc 层经 LZSYNC_LIBREALM 指名
                (install-file
                 (string-append (assoc-ref inputs "librealm-ffi")
                                "/lib/librealm-ffi.so")
                 libdir)
                (mkdir-p (string-append share
                                        "/icons/hicolor/1024x1024/apps"))
                ;; install-file 会把文件装进目录，目标名要精确时用 copy-file
                (copy-file "resources/icon.png"
                           (string-append
                            share "/icons/hicolor/1024x1024/apps/lzsync.png"))
                (mkdir-p (string-append share "/applications"))
                (call-with-output-file
                  (string-append share "/applications/lzsync.desktop")
                  (lambda (port)
                    (display
                     (string-append
                      "[Desktop Entry]\n"
                      "Type=Application\n"
                      "Name=LZSync\n"
                      "Comment=同步多个 osu!lazer fork 的数据：曲库、收藏夹、皮肤、成绩\n"
                      "Exec=" lzsync "\n"
                      "Icon=lzsync\n"
                      "Categories=Utility;Game;\n"
                      "Terminal=false\n")
                     port)))
                ;; mygo 的 Linux 后端经 purego dlopen 裸 soname，LD_LIBRARY_PATH
                ;; 是唯一定位途径；GIO/GTK3 模块同样只扫私有目录。
                (wrap-program lzsync
                  `("LZSYNC_LIBREALM" ":" =
                    (,(string-append libdir "/librealm-ffi.so")))
                  `("LD_LIBRARY_PATH" ":" prefix
                    ,(cons libdir
                           (search-path-as-list '("lib") lib-dirs)))
                  `("XDG_DATA_DIRS" ":" prefix
                    ,(search-path-as-list '("share") share-dirs))
                  `("GIO_EXTRA_MODULES" ":" prefix
                    ,(search-path-as-list '("lib/gio/modules")
                                          (list (assoc-ref inputs
                                                           "glib-networking"))))
                  `("GUIX_GTK3_PATH" ":" prefix
                    ,(search-path-as-list '("lib/gtk-3.0")
                                          (list (assoc-ref inputs
                                                           "gtk+")))))))))))
    (native-inputs
     (list go-1.27 cmake-minimal ninja unzip bun-bin))
    (inputs
     (append
      (list (list "bash-minimal" bash-minimal))
      (map (lambda (m)
              (list (second m)
                    (origin
                      (method url-fetch)
                      (uri (string-append
                            "https://proxy.golang.org/"
                            (first m) "/@v/" (third m) ".zip"))
                      (sha256 (base32 (fourth m))))))
            %go-module-deps)
       `(
       ("mygo"
        ,(origin
           (method git-fetch)
           (uri (git-reference
                 (url "https://github.com/egoist/mygo")
                 (commit (string-append "v" "0.6.3"))))
           (file-name (git-file-name "mygo" "0.6.3"))
           (sha256
            (base32 "0zqy063s6pwagyd20bi7l0rf6mwgz5r7c0gp6wm1kvc4v6v8mlhs"))))
       ("librealm-ffi" ,librealm-ffi)
       ("glib" ,glib)
       ("gtk+" ,gtk+)
       ("cairo" ,cairo)
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("webkitgtk-for-gtk3" ,webkitgtk-for-gtk3)
       ("libsoup" ,libsoup)
       ("libsecret" ,libsecret)
       ("glib-networking" ,glib-networking)
       ("gsettings-desktop-schemas" ,gsettings-desktop-schemas))))
    (home-page "https://github.com/ShineBreaker/LZSync")
    (synopsis "Sync beatmaps and settings across several osu! clients")
    (description
     "LZSync keeps the beatmap library, collections, skins, local scores, key
bindings and ruleset settings of several osu! clients on one machine in
step.  It collects them into a local SQLite hub and deploys them back to
every client, storing each file once in a content-addressed store that the
clients reference through hard or symbolic links.  Before every write it
checks that the game is closed and keeps a timestamped backup of the
client's database.")
    ;; GitHub release tag（v*）即版本锚点，release-tag-prefix 让 refresh 只认
    ;; 这一系列 tag。
    (properties `((release-tag-prefix . "^v")))
    (license license:expat)
    (supported-systems '("x86_64-linux"))))
