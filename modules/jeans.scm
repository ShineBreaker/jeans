;;; SPDX-FileCopyrightText: 2025 Hilton Chain <hako@ultrarare.space>
;;; SPDX-License-Identifier: GPL-3.0-or-later
;;;
;;; Based on Rosenthal by Hilton Chain
;;; Modified and adapted for the jeans channel by brokenshine <xchai404@gmail.com>

(define-module (jeans)
  )

(eval-when (eval load compile)
           (begin
             (define %public-modules
               '((gnu)
                 (guix utils)
                 (jeans packages fonts)
                 (jeans packages java)))

             (for-each (let ((i (module-public-interface (current-module))))
                         (lambda (m)
                           (module-use! i
                                        (resolve-interface m))))
                       %public-modules)))
