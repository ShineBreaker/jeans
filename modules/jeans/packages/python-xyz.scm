;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

(define-module (jeans packages python-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix download)
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

;; cffi 在运行时 dlopen libwayland-client，故 wayland 进 inputs 而非
;; native-inputs；scanner 在构建期用 pkg-config 定位 wayland-protocols 的
;; 协议 XML 生成核心协议绑定。
(define-public python-pywayland
  (package
    (name "python-pywayland")
    (version "0.4.19")
    (source
     (origin
      (method url-fetch)
      (uri (pypi-uri "pywayland" version))
      (sha256
       (base32
        "17jlk1c8bylzvq2mhs4cqar50hdkx1gsb1fg7hrl0dfzn3spi14x"))))
    (build-system pyproject-build-system)
    ;; 测试套件需要真实 Wayland 会话（起 wayland-server socket）。
    (arguments (list #:tests? #f))
    (propagated-inputs (list python-cffi))
    (inputs (list wayland))
    (native-inputs (list pkg-config wayland-protocols python-setuptools))
    (home-page "https://github.com/flacjacket/pywayland")
    (synopsis "Python bindings for the Wayland protocol")
    (description
     "Pywayland provides Python bindings for the Wayland protocol, built
with cffi.  Core protocol bindings are generated at build time from the
protocol XML shipped in the source distribution.")
    (license license:expat)))
