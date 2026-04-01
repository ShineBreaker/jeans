(define-module (jeans packages tools)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages python)
  #:use-module (gnu packages java)
  #:use-module (gnu packages rdesktop)
  #:use-module (gnu packages gtk)      ; yad
  #:use-module (gnu packages linux)    ; iproute
  #:use-module (gnu packages admin)    ; netcat-openbsd
  #:use-module (gnu packages gnome)    ; libnotify
  #:use-module (gnu packages ncurses)) ; dialog

(define-public winapps
  (package
    (name "winapps")
    (version "0-unstable-2026-03-16")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/winapps-org/winapps")
             (commit "d5ea5d5a0b8ef28decb1f21e10b8290757e00693")))
       (file-name (git-file-name name version))
       (sha256 (base32 "1640mqdvarqfyv646p6qrfiskggjwz6l8m0mask93xhnis1vi1ra"))
       (patches (list (local-file "WinApps.patch")))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (add-after 'unpack 'patch-paths
            (lambda _
              (substitute* '("bin/winapps" "setup.sh")
                (("@out@") #$output))
              (substitute* "install/inquirer.sh"
                (("#!/bin/bash") (string-append "#!" #$bash "/bin/bash")))))
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (src (string-append #$output "/src")))
                (mkdir-p bin)
                (mkdir-p src)
                (copy-recursively "." src)
                (install-file "bin/winapps" bin)
                (copy-file "setup.sh" (string-append bin "/winapps-setup"))
                (chmod (string-append bin "/winapps") #o755)
                (chmod (string-append bin "/winapps-setup") #o755)

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
                   (wrap-program (string-append bin "/" prog)
                     `("LIBVIRT_DEFAULT_URI" = ("qemu:///system"))
                     `("PATH" ":" prefix
                       ,(list bin
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
    (description "Run Windows applications (including Microsoft 365
     and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE,
     integrated seamlessly as if they were native to the OS.")
    (license license:agpl3+)))

(define-public jdtls-bin
  (package
    (name "jdtls-bin")
    (version "1.57.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
              "https://download.eclipse.org/jdtls/milestones/"
              version
              "/jdt-language-server-"
              version
              "-202602261110.tar.gz"))
        (sha256
          (base32 "07k008iypk0dv9c75dkdwpb85i95rp6rgp8kmifskgmvw4zskzzp"))))
    (build-system gnu-build-system)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (delete 'build)
            (replace 'unpack
              (lambda _
                (let ((srcdir (string-append "jdtls-" #$version)))
                  (mkdir srcdir)
                  (with-directory-excursion srcdir
                    (invoke "tar" "xzf" #$source))
                  (chdir srcdir))))
            (replace 'install
              (lambda _
                (let ((share (string-append #$output "/share/jdtls")))
                  (mkdir-p share)
                  (for-each
                    (lambda (dir)
                      (when (file-exists? dir)
                        (copy-recursively dir (string-append share "/" dir))))
                    '("bin" "plugins" "features"
                      "config_linux" "config_ss_linux"))
                  (chmod (string-append share "/bin/jdtls") #o755)
                  (wrap-program (string-append share "/bin/jdtls")
                    `("PATH" ":" prefix
                      ,(list (string-append #$openjdk "/bin")
                             (string-append #$python "/bin")))
                    `("JAVA_HOME" = (,(string-append #$openjdk))))
                  (mkdir-p (string-append #$output "/bin"))
                  (symlink (string-append share "/bin/jdtls")
                           (string-append #$output "/bin/jdtls"))))))))
    (inputs (list openjdk python bash))
    (synopsis "Java language server")
    (description "The Eclipse JDT Language Server is a Java language specific implementation of
the Language Server Protocol and can be used with any editor that supports the
protocol, to offer good support for the Java Language.")
    (home-page "https://github.com/eclipse/eclipse.jdt.ls")
    (license license:expat)))

winapps
