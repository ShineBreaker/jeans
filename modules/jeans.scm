;;; SPDX-FileCopyrightText: 2025 Hilton Chain <hako@ultrarare.space>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (jeans))

(eval-when (eval load compile)
           (begin
             (define %public-modules
               '((gnu)
                 (guix utils)
                 (jeans packages desktop)
                 (jeans packages fonts)
                 (jeans packages games)
                 (jeans packages hardware)
                 (jeans packages theme)
                 (jeans packages winapps)

                 (jeans services hardware)
                 (jeans home services hardware)))

             (for-each (let ((i (module-public-interface (current-module))))
                         (lambda (m)
                           (module-use! i
                                        (resolve-interface m))))
                       %public-modules)))
