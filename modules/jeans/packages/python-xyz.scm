;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages python-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python-build)
  #:use-module (guix build-system python)
  #:use-module (guix git-download)
  #:use-module (guix packages))

(define-public python-jieba
  (package
    (name "python-jieba")
    (version "0.42.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/fxsjy/jieba")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "028vmd6sj6wn9l1ilw7qfmlpyiysnlzdgdlhwxs6j4fvq0gyrwxk"))))
    (build-system python-build-system)
    ;; 上游 test/ 目录里的脚本依赖 ./extra_dict 大词典，并非可运行的单元测试套件。
    (arguments (list #:tests? #f))
    (native-inputs (list python-setuptools))
    (home-page "https://github.com/fxsjy/jieba")
    (synopsis "Chinese text segmentation library")
    (description
     "Jieba (\"结巴\") is a Chinese text segmentation module.  It supports
three segmentation modes: an accurate mode for text analysis, a full mode
that scans all possible words, and a search-engine mode that further splits
long words to improve recall.  Jieba also supports traditional Chinese
segmentation and custom dictionaries.")
    (license license:expat)))
