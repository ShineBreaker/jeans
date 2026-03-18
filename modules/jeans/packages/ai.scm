;;; Package Repository for GNU Guix
;;; Copyright © 2026 Franz Geffke <mail@gofranz.com>

(define-module (jeans packages ai)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (guix build-system cargo)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (nonguix build-system binary)
  #:use-module (nonguix licenses))

(define-public opencode
  (package
    (name "opencode")
    (version "1.2.27")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/anomalyco/opencode/releases/download/v"
             version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "1s39ks047pb8hi4z3pjqhb71zkvsic2jca3xa3zzfmsq2h5q5qvg"))))
    (build-system binary-build-system)
    (arguments
     (list
      #:strip-binaries? #f
      #:validate-runpath? #f
      #:patchelf-plan
      #~'(("opencode" ()))
      #:install-plan
      #~'(("opencode" "bin/opencode-unwrapped"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'create-wrapper
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (bin (string-append out "/bin"))
                     (unwrapped (string-append bin "/opencode-unwrapped"))
                     (wrapper (string-append bin "/opencode")))
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!~a
export DISABLE_AUTOUPDATER=1
export DISABLE_INSTALLATION_CHECKS=1
exec ~a \"$@\"
"
                            (search-input-file inputs "bin/bash")
                            unwrapped)))
                (chmod wrapper #o755)))))))
    (inputs
     (list bash-minimal))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/anomalyco/opencode")
    (synopsis "The open source coding agent.")
    (description
     "OpenCode is an AI-powered coding assistant that runs in your terminal.
It can understand your codebase, edit files, run commands, and handle workflows.
This package disables auto-updates.")
    (license license:expat)))
