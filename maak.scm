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
