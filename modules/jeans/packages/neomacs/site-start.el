;;; site-start.el --- Guix integration shim for neomacs -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Installed by jeans' neomacs-bin into share/neomacs/lisp/, which is
;; always on neomacs' built-in load-path, so `site-run-file' (loaded
;; before early-init.el, skipped only by -Q) finds it without any
;; profile cooperation.
;;
;; Guix' own Emacs builds carry site-start.el + guix-emacs.el inside the
;; emacs package itself; that profile never shows up in the
;; EMACSLOADPATH roots a foreign binary sees, and neomacs has no
;; compiled-in site-lisp of its own.  Without this file every Guix
;; package's *-autoloads.el stays unloaded, so any init referencing an
;; autoloads-time symbol (e.g. telega-prefix-map) dies, and
;; TREE_SITTER_GRAMMAR_PATH is never wired into `treesit-extra-load-path'.
;;
;; Removal conditions:
;; * eln defvar below: upstream defines native-comp-eln-load-path
;;   unconditionally (the `unless (boundp ...)' turns this into a no-op).
;; * the whole file: neomacs runs Guix' site-start chain itself.

;;; Code:

;; neomacs 0.0.16 startup.el compiles `startup-redirect-eln-cache'
;; unconditionally but only defvars `native-comp-eln-load-path' in
;; native-comp builds, so configs calling the former die with
;; void-variable.  A one-element list keeps the cdr/push dance intact.
(unless (boundp 'native-comp-eln-load-path)
  (defvar native-comp-eln-load-path (list "eln-cache/")))

;; Same three lines as Guix' gnu/packages/emacs.scm site-start.el.
(when (require 'guix-emacs nil t)
  (guix-emacs-autoload-packages 'no-reload)
  (advice-add 'package-load-all-descriptors :after
              #'guix-emacs-load-package-descriptors))

;; The guix-emacs-c-source.el file is available from the 'doc' output.
(require 'guix-emacs-c-source nil t)

;;; site-start.el ends here
