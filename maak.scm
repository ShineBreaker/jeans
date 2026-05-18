(define-module (maak)
  #:declarative? #t
  #:use-module (ice-9 getopt-long)
  #:use-module (maak maak))

;; Project variables
(define manifest "./scripts/check-updates/manifest.scm")
(define script "./scripts/check-updates/update_versions.py")
(define packages "./modules/jeans/packages/")

;; By default (no task given) run help.
(define (default)
  ($ '("maak --list")))

;; 检查包的更新 (Check for package updates)
(define (upgrade)
  (log-info "Checking package updates...")
  ($ (list (string-append "guix shell --manifest=" manifest " -- python3 " script))
     #:verbose? #t))

;; Build with guix. Pass package name(s) as extra CLI arguments.
;; Example: maak build my-package   =>  guix build --load-path=./modules my-package
;; Example: maak build pkg-a pkg-b  =>  guix build --load-path=./modules pkg-a pkg-b
(define (build)
  ;; (command-line) includes maak's internal flags (--resources, --tasks, --file, etc.).
  ;; Use getopt-long to extract only the non-option positional arguments (package names).
  (let* ((option-spec '((resources (value #t))
                        (file (value #t))
                        (list (value #f))
                        (tasks (value #t))))
         (options (getopt-long (command-line) option-spec))
         (rest-args (option-ref options '() '()))
         (args (string-join rest-args " ")))
    (if (null? rest-args)
        (log-error "No package name(s) provided. Usage: maak build <package> ...")
        (begin
          (log-info "Building with guix...")
          ($ (list (string-append "guix build --load-path=./modules " args))
             #:verbose? #t)))))

;; Import Rust crate sources from crates.io into rust-crates.scm.
;; Usage: maak import-crate <crate-name>[@version]
;;   maak import-crate nix-ld
;;   maak import-crate embedded-io@0.6.1
;; Uses guix import crate --lockfile=<path>/Cargo.lock <name> to generate
;; crate-source definitions and appends them before the ssss-separator.
(define (import-crate)
  "Import Rust crate sources from crates.io. Usage: maak import-crate <name>[@version]"
  (let* ((option-spec '((resources (value #t))
                        (file (value #t))
                        (list (value #f))
                        (tasks (value #t))))
         (options (getopt-long (command-line) option-spec))
         (rest-args (option-ref options '() '())))
    (if (null? rest-args)
        (log-error "No crate name provided. Usage: maak import-crate <name>[@version]")
        (let* ((crate-spec (car rest-args))
               (rust-crates (string-append packages "rust-crates.scm"))
               (lockfile-arg
                (if (file-exists? "./Cargo.lock")
                    (string-append " --lockfile=./Cargo.lock")
                    ""))
               ;; Import to a temp file first
               (tmp-file "/tmp/maak-crate-import.scm"))
          (log-info "Importing crate: ~a" crate-spec)
          ;; Generate crate-source definitions to temp file
          ($ (list (string-append "guix import crate" lockfile-arg
                                  " " crate-spec
                                  " > " tmp-file))
             #:verbose? #t)
          ;; Insert before the ssss-separator line in rust-crates.scm
          ;; awk: print the temp file contents, then print the separator line
          ($ (list (string-append "awk '/ssss-separator/{system(\"cat " tmp-file
                                  "\");print;next}1' " rust-crates
                                  " > " rust-crates ".tmp"))
             #:verbose? #t)
          ($ (list (string-append "mv " rust-crates ".tmp " rust-crates))
             #:verbose? #t)
          ;; Clean up temp file
          ($ (list (string-append "rm -f " tmp-file)))))))
