(define-module (jeans))

;; Re-export commonly-used modules.

(eval-when (eval load compile)
  (begin
    (define %public-modules
      '((gnu)
        (guix utils)
        (jeans packages fonts)
        (jeans packages shellutils)))

    (for-each (let ((i (module-public-interface (current-module))))
                (lambda (m)
                  (module-use! i (resolve-interface m))))
              %public-modules)))
