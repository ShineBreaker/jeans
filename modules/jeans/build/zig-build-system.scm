;;; SPDX-FileCopyrightText: 2023 Ekaitz Zarraga <ekaitz@elenq.tech>
;;; SPDX-FileCopyrightText: 2024 Hilton Chain <hako@ultrarare.space>
;;; SPDX-FileCopyrightText: 2026 Raven Hallsby <raven@hallsby.com>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; Copied from GNU Guix's (guix build zig-build-system) with the changes from
;;; <https://codeberg.org/guix/guix/pulls/4087> applied: zig-extra-inputs
;;; support and the zig- prefix based install-path detection.  The channel
;;; carries its own copy because the build system lives in Guix proper, which a
;;; channel cannot patch.

;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2023 Ekaitz Zarraga <ekaitz@elenq.tech>
;;; Copyright © 2024 Hilton Chain <hako@ultrarare.space>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (jeans build zig-build-system)
  #:use-module ((guix build gnu-build-system) #:prefix gnu:)
  #:use-module (guix build utils)
  #:use-module (guix build zig-utils)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:export (%standard-phases
            zig-build
            zig-source-install-path))

(define (zig-source-install-path output)
  ;; XXX: We use the same trick other language-specific packages use and RELY
  ;; on the package-name prefix telling us that this is a Zig package.
  (if (string-contains output "zig-")
      (string-append output "/src/zig/" (strip-store-file-name output))
      output))

(define (zig-input-install-path input)
  ;; XXX: We use the same trick other language-specific packages use and RELY
  ;; on the package-name prefix telling us that this is a Zig package.
  (if (string-contains input "zig-")
      (zig-source-install-path
       ;; This dirname sequence assumes input is something like
       ;; /gnu/store/...-zig-xxx-u.v.w/src/zig/zig-xxx-u.v.w
       ;; However, if the input is a regular library, then things get tricky
       (dirname (dirname (dirname (canonicalize-path input)))))
      input))

(define (zig-arguments)
  (define version-major+minor
    (let* ((port (open-input-pipe "zig version"))
           (str  (read-line port)))
      (close-pipe port)
      (take (string-split str #\.) 2)))
  (define (version>=? a b-major b-minor)
    (let ((a-major (string->number (first a)))
          (a-minor (string->number (second a))))
      (or (> a-major b-major)
          (and (= a-major b-major)
               (>= a-minor b-minor)))))
  `(("parallel-jobs" .
     ,(lambda (jobs)
        (cond
         ((version>=? version-major+minor 0 11)
          (list (string-append "-j" (number->string jobs))))
         (else '()))))
    ("release-type" .
     ,(lambda (type)
        (cond
         ((version>=? version-major+minor 0 11)
          (list (string-append "--release=" type)))
         (else
          (list (string-append "-Drelease-" type))))))))

;; Notes on Zig package manager (`build.zig.zon')
;; 1. Dependency definition (name -> URL + hash)
;; - Dependency names are not necessarily consistent across packages.
;; - `zig fetch <url> --name=<name>' fetches <url> to Zig cache, computes its
;; hash, then overwrites dependency <name> with <url> and the computed hash.
;; 2. Dependency lookup
;; Lookup hash in Zig cache, fetch URL when missing.
;; 3. Recursive dependency is possible
;; `build.zig.zon' -> dependency (`build.zig.zon' -> next dependency).
;;
;; With our naming convention and different expectation on package sources,
;; we'll need to change dependency names and hashes for nearly every Zig
;; package.
;; - `rename-zig-dependencies' in `(guix build-system zig)' takes care of names.
;; - `unpack-dependencies' below is for hashes.  Ideally we can parse
;; `build.zig.zon' and only `zig fetch' required dependencies for current
;; package, this way recursive dependencies are resolved by fetching store paths
;; defined in dependency URLs.  However Zig package manager currently doesn't
;; support file URLs[0] so we are instead fetching all dependencies needed for
;; the build process and all of them are added to involved `build.zig.zon' as a
;; side effect.
;; [0]: https://github.com/ziglang/zig/pull/21931
(define* (unpack-dependencies #:key zig-extra-inputs #:allow-other-keys)
  "Unpack Zig dependencies from GUIX_ZIG_PACKAGE_PATH and zig-extra-inputs."
  (define zig-inputs
    (append-map
     (lambda (directory)
       (map (lambda (input-name)
              (cons input-name
                    (in-vicinity directory input-name)))
            (scandir directory (negate (cut member <> '("." ".."))))))
     (or (and=> (getenv "GUIX_ZIG_PACKAGE_PATH")
                (cut string-split <> #\:))
         '())))
  (define (strip-version input)
    (receive (name version) (package-name->name+version input)
      name))

  (define all-inputs (append (reverse zig-inputs) zig-extra-inputs))
  (format #t "all-inputs: ~s~%" all-inputs)

  ;; NOTE: This nested loop calling "zig fetch" is run N^2 times, once for each
  ;; build.zig.zon and once for each input in zig-inputs.  We have no mechanism
  ;; to skip zig-inputs that are not actually used by the build.zig.zon, so we
  ;; have to pay the "zig fetch" cost on EVERY input on EVERY build.zig.zon.
  ;; The "zig fetch" on large dependencies, like harfbuzz's sources, takes some
  ;; time.  Most Zig projects only have one build.zig.zon file, so this is not
  ;; usually a major issue.  However, for projects that have a large number of
  ;; build.zig.zons, this phase can become quite slow.  Some Zig projects have a
  ;; lot of build.zig.zon files because they have a lot of subprojects they
  ;; depend on, e.g., Ghostty.
  (for-each
   (lambda (build.zig.zon)
     (format #t "unpacking dependencies for ~s...~%" build.zig.zon)
     (with-directory-excursion (dirname build.zig.zon)
       (for-each
        (match-lambda
          ((input-name . input-path)
           (let ((call `("zig" "fetch"
                         ,(zig-input-install-path input-path)
                         ,(string-append "--save=" (strip-version input-name)))))
             ;; Cannot overwrite local sub-zon .path-s
             ;; FIXME: This is an INCREDIBLE HACK!
             ;; We read the build.zig.zon we are currently working on and
             ;; poorly check to see if it is pointing at a local dependency.
             ;; If it is, then we cannot change the pointer to an absolute path.
             ;; These are used in zig for subdirectories that contain other
             ;; build.zig.zon files, often for wrapping C libraries that are
             ;; used by the Zig program.
             (let* ((zon-local-path-matcher (string-append "\\." input-name
                                                           "\\s*=\\s*\\.\\{\\s*\\.path"))
                    (zon-local-path (string-match
                                     zon-local-path-matcher
                      (call-with-input-file (basename build.zig.zon) get-string-all))))
               (if zon-local-path
                   (format #t "~s is a local .path in this build.zig.zon. Skip replacement~%" input-name)
                 (begin
                   (format #t "~s is NOT a local .path!~%" input-name)
                   (format #t "running: ~s~%" call)
                   (apply invoke call)))))))
        all-inputs)))
   (find-files "." "^build\\.zig\\.zon$")))

;; Zig doesn't make any difference between phases, so why should we?
(define* (build+install #:key
                        zig-build-flags
                        zig-build-target
                        ;; "safe", "fast" or "small", empty for a "debug" build.
                        zig-release-type
                        parallel-build?
                        skip-build?
                        outputs
                        install-source?
                        #:allow-other-keys)
  "Build and install given Zig package."

  (when (not skip-build?)
    (let* ((arguments (zig-arguments))
           (call `("zig" "build"
                   "--prefix"             ,(assoc-ref outputs "out")
                   "--prefix-lib-dir"     "lib"
                   "--prefix-exe-dir"     "bin"
                   "--prefix-include-dir" "include"
                   "--verbose"
                   ,(string-append "-Dtarget=" (zig-target zig-build-target))
                   ,@(if parallel-build?
                         ((assoc-ref arguments "parallel-jobs")
                          (parallel-job-count))
                         ((assoc-ref arguments "parallel-jobs")
                          1))
                   ,@(if zig-release-type
                         ((assoc-ref arguments "release-type")
                          zig-release-type)
                         '())
                   ,@zig-build-flags)))
      (format #t "running: ~s~%" call)
      (apply invoke call))))

(define* (install-source #:key
                         outputs
                         install-source?
                         #:allow-other-keys)
  "Install sources for given Zig package."
  (when install-source?
    (let ((source-install-path (zig-source-install-path (assoc-ref outputs "out"))))
      (mkdir-p source-install-path)
      (copy-recursively "." source-install-path))))

(define* (check #:key tests?
                test-target
                zig-test-flags
                target
                parallel-tests?
                #:allow-other-keys)
  "Run all the tests"
  (when (and tests? (not target))
    (let* ((arguments (zig-arguments))
           (call `("zig" "build" ,(or test-target "test") "--verbose"
                   ,@(if parallel-tests?
                       ((assoc-ref arguments "parallel-jobs")
                        (parallel-job-count))
                       ((assoc-ref arguments "parallel-jobs")
                        1))
                   ,@zig-test-flags)))
      (format #t "running: ~s~%" call)
      (apply invoke call))))

(define %standard-phases
  (modify-phases gnu:%standard-phases
    (delete 'bootstrap)
    (replace 'configure zig-configure)
    (add-after 'configure 'unpack-dependencies unpack-dependencies)
    (delete 'build)
    (add-after 'unpack-dependencies 'build+install build+install)
    (add-after 'build+install 'install-source install-source)
    (replace 'check check)
    (delete 'install)))


(define* (zig-build #:key inputs (phases %standard-phases)
                      #:allow-other-keys #:rest args)
  "Build the given Zig package, applying all of PHASES in order."
  (apply gnu:gnu-build #:inputs inputs #:phases phases args))
