(define-module (jeans packages winapps)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages rdesktop)
  #:use-module (gnu packages gtk)      ; yad
  #:use-module (gnu packages linux)    ; iproute
  #:use-module (gnu packages admin)    ; netcat-openbsd
  #:use-module (gnu packages gnome)    ; libnotify
  #:use-module (gnu packages ncurses)) ; dialog

(define-public winapps
  (package
    (name "winapps")
    (version "0-unstable-2026-02-14")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/winapps-org/winapps")
             ;; 如果你在打包本地文件，可以改用 local-file
             (commit "860710bb26e5afb040dd83b312a5a7afeee2d0bb"))) ; 请填入具体的 commit ID
       (file-name (git-file-name name version))
       (sha256 (base32 "0hvh5n6i5fhdrkbm399nad4hll6z0aalwwmyyc9wpwc21s1pqlsf"))
       ;; 引入你提供的 setup.patch
       (patches (list (local-file "WinApps.patch")))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f ; 该项目没有自动测试环节
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (add-after 'unpack 'patch-paths
            (lambda _
              ;; 替代 Nix 的 substituteAllInPlace [cite: 6]
              (substitute* '("bin/winapps" "setup.sh")
                (("@out@") #$output))
              ;; 修复 bash 路径 (类似 patchShebangs [cite: 6])
              (substitute* "install/inquirer.sh"
                (("#!/bin/bash") (string-append "#!" #$bash "/bin/bash")))))
          (replace 'install
            (lambda _
              ;; 对应 Nix 的 installPhase [cite: 7]
              (let ((bin (string-append #$output "/bin"))
                    (src (string-append #$output "/src")))
                (mkdir-p bin)
                (mkdir-p src)
                (copy-recursively "." src)
                (install-file "bin/winapps" bin)
                (copy-file "setup.sh" (string-append bin "/winapps-setup"))
                (chmod (string-append bin "/winapps") #o755)
                (chmod (string-append bin "/winapps-setup") #o755)

                ;; 替代 Nix 中的 writeShellScriptBin "xfreerdp3"
                (call-with-output-file (string-append bin "/xfreerdp3")
                  (lambda (port)
                    (format port "#!~a/bin/bash~%exec ~a/bin/xfreerdp \"$@\"~%"
                            #$bash #$freerdp-3)))
                (chmod (string-append bin "/xfreerdp3") #o755))))
          (add-after 'install 'wrap-programs
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (for-each
                 (lambda (prog)
                   ;; 对应 Nix 的 wrapProgram [cite: 8]
                   (wrap-program (string-append bin "/" prog)
                     `("LIBVIRT_DEFAULT_URI" = ("qemu:///system"))
                     `("PATH" ":" prefix
                       ,(list bin ; 将刚才创建的 xfreerdp3 加入 PATH
                              (string-append #$bash "/bin")
                              (string-append #$freerdp-3 "/bin")
                              (string-append #$libnotify "/bin")
                              (string-append #$dialog "/bin")
                              (string-append #$netcat-openbsd "/bin")
                              (string-append #$iproute "/bin")))))
                 '("winapps" "winapps-setup"))))))))
    (inputs
     (list bash freerdp-3 dialog libnotify netcat-openbsd iproute))
    (home-page "https://github.com/winapps-org/winapps")
    (synopsis "Run Windows applications on GNU/Linux")
    (description "Run Windows applications (including Microsoft 365 and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE, integrated seamlessly as if they were native to the OS. Wayland is currently unsupported.")
    (license license:agpl3+)))
