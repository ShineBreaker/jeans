;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans services nix-ld)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages gl)         ; mesa
  #:use-module (gnu packages xdisorg)     ; libdrm
  #:use-module (gnu packages linux)       ; eudev, libcap
  #:use-module (gnu packages video)       ; libva
  #:use-module (gnu packages vulkan)      ; vulkan-loader
  #:use-module (gnu packages gnome)       ; network-manager
  #:use-module (gnu packages crypto)      ; libxcrypt
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (guix gexp)
  #:use-module (guix packages)     ; package?
  #:use-module (guix records)
  #:use-module (ice-9 match)
  #:use-module (jeans packages nix-ld)
  #:export (nix-ld-configuration
            nix-ld-configuration?
            nix-ld-service-type
            %default-nix-ld-libraries
            %steam-runtime-libraries))

;;;
;;; Configuration record
;;;

(define-record-type* <nix-ld-configuration>
  nix-ld-configuration make-nix-ld-configuration
  nix-ld-configuration?
  (package     nix-ld-package                 ; <package>
               (default nix-ld))
  (glibc       nix-ld-glibc                   ; <package>
               (default glibc))
  (libraries   nix-ld-libraries               ; list of <package> or (<package> "lib")
               (default %default-nix-ld-libraries)))

;;;
;;; Default library list (方案 A: 纯 Guix 包)
;;;

(define %default-nix-ld-libraries
  (list glibc
        `(,gcc "lib")              ; libstdc++, libgcc_s
        zlib
        bzip2
        xz
        openssl
        curl
        expat
        ncurses
        ;; 可按需扩展...
        ))

;;;
;;; Activation: create /lib64/ld-linux-x86-64.so.2 symlink
;;;

(define (nix-ld-activation config)
  "Return a G-exp that creates the /lib64/ld-linux-x86-64.so.2 symlink."
  (let ((nix-ld-bin (file-append (nix-ld-package config) "/bin/nix-ld")))
    (with-imported-modules '((guix build utils))
      #~(begin
          (use-modules (guix build utils))
          (mkdir-p "/lib64")
          (let ((target "/lib64/ld-linux-x86-64.so.2"))
            (when (file-exists? target)
              (delete-file target))
            (symlink #$nix-ld-bin target))))))

;;;
;;; ETC profile.d script: set NIX_LD and NIX_LD_LIBRARY_PATH
;;;

(define (nix-ld-profile-script config)
  "Return a file-like object for /etc/profile.d/nix-ld.sh setting environment variables."
  (let ((glibc (nix-ld-glibc config))
        (libs  (nix-ld-libraries config)))
    (computed-file
     "nix-ld.sh"
     ;; Build the list of <file-append> objects inside a gexp so
     ;; that #$expander resolves them to real store paths.
     (with-imported-modules '((guix build utils))
       #~(call-with-output-file #$output
           (lambda (port)
             (let ((nix-ld-value
                    #$(file-append glibc "/lib/ld-linux-x86-64.so.2"))
                   (lib-paths
                    (list
                     #$@(map (match-lambda
                               ((? string? p) p)
                               ((? package? p) (file-append p "/lib"))
                               (((? package? p) "lib") (file-append p "/lib"))
                               (((? package? p) part) (file-append p "/" part)))
                             libs))))
               (display
                (string-append
                 "export NIX_LD=" nix-ld-value "\n"
                 "export NIX_LD_LIBRARY_PATH=" (string-join lib-paths ":")
                 "${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}\n")
                port))))))))

;;;
;;; Service type
;;;

(define nix-ld-service-type
  (service-type
   (name 'nix-ld)
   (description
    "Configure nix-ld to run pre-compiled (FHS) binaries on Guix System.
This creates the @file{/lib64/ld-linux-x86-64.so.2} symlink and sets
@code{NIX_LD} and @code{NIX_LD_LIBRARY_PATH} environment variables.")
   (extensions
    (list
     ;; 1. activation script: create /lib64 symlink
     (service-extension activation-service-type
                        nix-ld-activation)
     ;; 2. /etc/profile.d/nix-ld.sh: set environment variables
     (service-extension etc-profile-d-service-type
                        (lambda (config)
                          (list (nix-ld-profile-script config))))
     ;; 3. ensure nix-ld package is in system profile
     (service-extension profile-service-type
                        (lambda (config)
                          (list (nix-ld-package config))))))
   (default-value (nix-ld-configuration))))
