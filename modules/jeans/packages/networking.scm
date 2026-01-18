(define-module (jeans packages networking)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages debian)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses)
                #:prefix license:))

(define-public sparkle
  (package
    (name "sparkle")
    (version "1.6.16")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/xishang0128/sparkle/releases/download/"
             version "/sparkle-linux-" version "-amd64.deb"))
       (sha256
        (base32 "158k4v5b6qdnc8v18av1d00i54cang9r5fl8j1n0nm9ib300gpmd"))))
    (build-system trivial-build-system)
    (native-inputs (list binutils patchelf tar xz))
    (inputs (list alsa-lib
                  at-spi2-core
                  cairo
                  cups
                  dbus
                  expat
                  glib
                  gtk+
                  mesa
                  libdrm
                  libxkbcommon
                  nspr
                  nss
                  pango
                  libx11
                  libxcomposite
                  libxdamage
                  libxext
                  libxfixes
                  libxrandr
                  libxcb))
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils)
                       (srfi srfi-1))

          ;; 获取输入包路径
          (define alsa-lib-input #$(this-package-input "alsa-lib"))
          (define at-spi2-core-input #$(this-package-input "at-spi2-core"))
          (define cairo-input #$(this-package-input "cairo"))
          (define cups-input #$(this-package-input "cups"))
          (define dbus-input #$(this-package-input "dbus"))
          (define expat-input #$(this-package-input "expat"))
          (define glib-input #$(this-package-input "glib"))
          (define gtk+-input #$(this-package-input "gtk+"))
          (define mesa-input #$(this-package-input "mesa"))
          (define libdrm-input #$(this-package-input "libdrm"))
          (define libxkbcommon-input #$(this-package-input "libxkbcommon"))
          (define nspr-input #$(this-package-input "nspr"))
          (define nss-input #$(this-package-input "nss"))
          (define pango-input #$(this-package-input "pango"))
          (define libx11-input #$(this-package-input "libx11"))
          (define libxcomposite-input #$(this-package-input "libxcomposite"))
          (define libxdamage-input #$(this-package-input "libxdamage"))
          (define libxext-input #$(this-package-input "libxext"))
          (define libxfixes-input #$(this-package-input "libxfixes"))
          (define libxrandr-input #$(this-package-input "libxrandr"))
          (define libxcb-input #$(this-package-input "libxcb"))

          ;; 解压deb包 (deb实际上是ar归档)
          (invoke (search-input-file %build-inputs "bin/ar") "-x"
                  #$(package-source this-package))
          ;; 使用xz解压data.tar.xz
          (invoke (search-input-file %build-inputs "bin/xz") "-d"
                  "data.tar.xz")
          ;; 解压数据部分
          (invoke (search-input-file %build-inputs "bin/tar") "-xf" "data.tar"
                  "-C" ".")

          ;; 创建输出目录
          (mkdir-p (string-append #$output "/bin"))
          (mkdir-p (string-append #$output "/opt"))
          (mkdir-p (string-append #$output "/share"))

          ;; 复制opt目录
          (copy-recursively "opt"
                            (string-append #$output "/opt"))

          ;; 复制share目录
          (copy-recursively "usr/share"
                            (string-append #$output "/share"))

          ;; 设置可执行权限（如果文件存在）
          (let ((sparkle-service (string-append #$output
                                  "/opt/sparkle/resources/files/sparkle-service")))
            (when (file-exists? sparkle-service)
              (chmod sparkle-service #o755)))

          ;; 修改desktop文件
          (substitute* (string-append #$output
                                      "/share/applications/sparkle.desktop")
            (("/opt/sparkle/sparkle")
             "sparkle"))

          ;; 创建符号链接
          (symlink (string-append #$output "/opt/sparkle/sparkle")
                   (string-append #$output "/bin/sparkle"))

          ;; 使用patchelf修复二进制文件的rpath
          (let* ((binary (string-append #$output "/opt/sparkle/sparkle"))
                 (lib-dirs (list (string-append alsa-lib-input "/lib")
                                 (string-append at-spi2-core-input "/lib")
                                 (string-append cairo-input "/lib")
                                 (string-append cups-input "/lib")
                                 (string-append dbus-input "/lib")
                                 (string-append expat-input "/lib")
                                 (string-append glib-input "/lib")
                                 (string-append gtk+-input "/lib")
                                 (string-append mesa-input "/lib")
                                 (string-append libdrm-input "/lib")
                                 (string-append libxkbcommon-input "/lib")
                                 (string-append nspr-input "/lib")
                                 (string-append nss-input "/lib")
                                 (string-append pango-input "/lib")
                                 (string-append libx11-input "/lib")
                                 (string-append libxcomposite-input "/lib")
                                 (string-append libxdamage-input "/lib")
                                 (string-append libxext-input "/lib")
                                 (string-append libxfixes-input "/lib")
                                 (string-append libxrandr-input "/lib")
                                 (string-append libxcb-input "/lib")
                                 (string-append #$output "/opt/sparkle")))
                 (rpath (string-join lib-dirs ":")))
            ;; 设置rpath（直接覆盖原有的）
            (invoke (search-input-file %build-inputs "bin/patchelf")
                    "--set-rpath" rpath binary)))))
    (home-page "https://github.com/xishang0128/sparkle")
    (synopsis "Another Mihomo GUI")
    (description
     "Sparkle is a graphical user interface for Mihomo (Clash Meta),
an advanced network proxy tool.")
    (license license:gpl3+)))

sparkle
