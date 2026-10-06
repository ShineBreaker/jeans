;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; jeans 预编译二进制包的 build-side 实现（基座；electron 层在其上扩展）。
;;;
;;; 配合 (jeans build-system binary) 使用。%standard-phases：
;;;
;;;   unpack → install → patchelf → wrap → desktop-files
;;;
;;; 其余阶段（set-paths、patch-shebangs 等）沿用 gnu-build-system。
;;;
;;; 参数语义：
;;;
;;; - #:unpack-method：无探测，必须显式声明。'gnu-unpack（默认；
;;;   'tar/'zip 为同义别名，走 gnu 默认解包）、'deb（ar x +
;;;   tar xzf data.tar.gz）、'deb-xz/'deb-zst（ar x + tar xf，自动识别压缩；
;;;   两符号同义，留两个名字只为向后兼容）、'bsdtar（bsdtar xf 解两层，
;;;   .deb 的 ar 层也由 bsdtar 直接读）、'appimage-7z（7z x 静态解包，
;;;   绝不执行 AppImage 自身的 --appimage-extract）、'file（单文件
;;;   copy-file，裸 ELF 用）、'none（跳过）。'bsdtar 需 native-inputs 带
;;;   libarchive（提供 bsdtar），'appimage-7z 需 p7zip（提供 7z）。
;;; - #:install-plan：(SRC DST) 二元组列表，copy-build-system 语义的简化子集
;;;   （不支持 #:include/#:exclude 过滤器）。SRC 尾随 "/" 表示装其内容，
;;;   DST 尾随 "/" 表示把 SRC basename 装进该目录。默认把构建目录内容装到
;;;   lib/<dir>/（<dir> 优先取 #:app-dir 去 "lib/" 前缀后的名字；未传时由
;;;   derivation 名去掉版本后缀得到，启发式，见 derivation-name->package-name；
;;;   要精确控制请显式传 #:install-plan）。
;;; - #:app-dir（默认 #f）：资源根在 lib/ 下的名字，如 "opencode-desktop"
;;;   （electron 层透传的 "lib/<app>" 形式也接受，在此去掉 "lib/" 前缀）。
;;;   非 #f 时 lib-dir = out/lib/<app>（RPATH 首项即真实资源根，如
;;;   lib/opencode-desktop 而非 lib/opencode-desktop-bin），且默认 install-plan
;;;   与 desktop 自动查找都按此目录；#f 时行为与以前完全一致。
;;; - #:patchelf?（默认 #t）：#f 则跳过整个 patchelf 阶段（静态链接、
;;;   自定位二进制用；后者另需 #:wrap? #f）。
;;; - #:patchelf-plan：((PATH [SPEC ...]) ...)，PATH 为输出内相对路径
;;;   （文件或目录，目录递归取 ELF；裸字符串视为无 SPEC 条目）。SPEC 省略时
;;;   RPATH 自动取自带 lib-dir + 所有 inputs 的 /lib；显式给出时只取所列
;;;   inputs（元素为 "name" 或 ("name" "/subdir")，沿用 nonguix 形状）。
;;;   逐文件先用 patchelf --print-interpreter 探测 dynamic，静态全跳过；
;;;   .so/.node 跳过 interpreter 只设 RPATH（设之前再用 --print-rpath 确认
;;;   有 .dynamic 段，静态 sidecar 不会炸）。
;;; - #:preserve-rpath?（默认 #f）：#t 时新 RPATH =
;;;   $ORIGIN:旧RPATH:计算值（prepend 保 $ORIGIN 且保留旧值）。
;;; - #:wrap?（默认 #t）/#:wrap-plan：((PROG SPEC ...) ...)，直通 wrap-program；
;;;   PROG 为输出内相对路径或绝对路径。
;;; - #:desktop-files：((DESKTOP [EXEC [ICON]]) ...)，只重写 [Desktop Entry]
;;;   组内的 Exec=/Icon= 为绝对路径（Action 组不动）；相对路径按输出内解析，
;;;   EXEC 省略时按 basename 自动到 bin/、lib/<pkg>/ 下找，找不到则告警保留原值。
;;;
;;; 不抽象清单（仍留各包自定义 phase，不进基座）：
;;;   - Tauri resource_dir / sidecar 布局（按 exe_dir 基准解析）；
;;;   - dotnet 内嵌 runtime 的裸 soname symlink（宿主 RPATH 对其 dlopen 不可见）；
;;;   - deb ABI 漂移 compat-symlink（必须建在 patch-elf 之后，通用顺序罩不住）。
;;;
;;; 三关默认全关：#:tests? #f、#:validate-runpath? #f、#:strip-binaries? #f。

(define-module (jeans build binary)
  #:use-module ((guix build gnu-build-system) #:prefix gnu:)
  #:use-module (guix build utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-1)
  #:export (%standard-phases
            binary-build
            derivation-name->package-name
            normalize-app-dir))

(define (derivation-name->package-name name)
  "去掉 derivation 名 NAME 末尾的 \"-VERSION\"（\"crush-bin-0.97.1\" →
\"crush-bin\"）。版本按 Guix 惯例以数字开头；找不到这种后缀时原样返回。
这是启发式：名字本身以 \"-数字\" 结尾的包请显式传 #:install-plan。"
  (let ((len (string-length name)))
    (let loop ((i (- len 2)))
      (cond ((< i 0) name)
            ((and (char=? (string-ref name i) #\-)
                  (char-numeric? (string-ref name (+ i 1))))
             (substring name 0 i))
            (else (loop (- i 1)))))))

(define (normalize-app-dir app-dir)
  "#f 原样返回；\"lib/<app>\" 去掉 \"lib/\" 前缀；其它非空字符串原样；其它值报错
(base 的 lib-dir 只认裸名，electron 透传的 \"lib/<app>\" 在此归一)。"
  (cond ((not app-dir) #f)
        ((and (string? app-dir) (string-prefix? "lib/" app-dir))
         (let ((rest (substring app-dir 4)))
           (if (string-null? rest)
               (error "binary-build: #:app-dir 不能是 \"lib/\" 本身" app-dir)
               rest)))
        ((and (string? app-dir) (not (string-null? app-dir)))
         app-dir)
        (else (error "binary-build: #:app-dir 须为非空字符串或 #f" app-dir))))

(define (strip-keys args keys)
  "去掉 ARGS（key/value 交错列表）中出现在 KEYS 里的条目。"
  (let loop ((args args) (acc '()))
    (match args
      (() (reverse acc))
      ((k v rest ...)
       (if (memq k keys)
           (loop rest acc)
           (loop rest (cons v (cons k acc)))))
      (odd (error "strip-keys: 参数不是偶数个" odd)))))

(define (remove-deb-control-files)
  "删掉 .deb 解包后的控制文件，只留 payload（默认 install-plan 才干净）。"
  (for-each (lambda (f)
              (when (file-exists? f)
                (delete-file f)))
            (append (find-files "." "data\\.tar\\..*")
                    (find-files "." "control\\.tar\\..*")
                    (find-files "." "debian-binary"))))

(define (first-data-tar)
  (match (find-files "." "data\\.tar\\..*")
    ((data _ ...) data)
    (() (error "unpack: .deb 里没有 data.tar.*，换 'deb-xz/'deb-zst/'bsdtar 试试"))))

(define (first-subdirectory dir)
  "DIR 下第一个子目录名，没有则 #f（gnu unpack 同款行为）。"
  (match (filter (lambda (base)
                    (file-is-directory? (string-append dir "/" base)))
                  (directory-entries dir))
    ((first _ ...) first)
    (() #f)))

(define (gnu-unpack-source source)
  "gnu 默认解包（zip/tarball/单文件 + 自动进单顶层目录），
从 guix/build/gnu-build-system.scm 的 unpack 照搬（该过程未导出）。"
  (if (file-is-directory? source)
      (begin
        (mkdir "source")
        (chdir "source")
        (copy-recursively source "." #:keep-mtime? #t)
        (for-each (lambda (f)
                    (false-if-exception (make-file-writable f)))
                  (find-files ".")))
      (begin
        (cond ((string-suffix? ".zip" source)
               (invoke "unzip" source))
              ((tarball? source)
               (invoke "tar" "xvf" source))
              (else
               (let ((name (strip-store-file-name source))
                     (command (compressor source)))
                 (copy-file source name)
                 (when command
                   (invoke command "--decompress" name)))))
        (let ((subdir (first-subdirectory ".")))
          (when subdir
            (chdir subdir))))))

(define* (unpack #:key source unpack-method #:allow-other-keys)
  "按 #:unpack-method 把 SOURCE 解到构建目录（'none 跳过）。"
  (case unpack-method
    ((gnu-unpack tar zip)
     (gnu-unpack-source source))
    ((deb)
     (invoke "ar" "x" source)
     (unless (file-exists? "data.tar.gz")
       (error "unpack: 'deb 要求 data.tar.gz，当前包请用 'deb-xz/'deb-zst/'bsdtar"))
     (invoke "tar" "xzf" "data.tar.gz")
     (remove-deb-control-files))
    ((deb-xz)
     (invoke "ar" "x" source)
     (invoke "tar" "xf" (first-data-tar))
     (remove-deb-control-files))
    ((deb-zst)
     (invoke "ar" "x" source)
     (invoke "tar" "xf" (first-data-tar))
     (remove-deb-control-files))
    ((bsdtar)
     (invoke "bsdtar" "xf" source)
     (for-each (lambda (data) (invoke "bsdtar" "xf" data))
               (find-files "." "data\\.tar\\..*"))
     (remove-deb-control-files))
    ((appimage-7z)
     (let ((appimage (strip-store-file-name source)))
       (copy-file source appimage)
       (invoke "7z" "x" appimage)
       (delete-file appimage)))
    ((file)
     ;; 裸 ELF 单文件：store 里无执行位，补上（本方法即为可执行 payload 而设）。
     (let ((base (strip-store-file-name source)))
       (copy-file source base)
       (chmod base #o755)))
    ((none)
     #t)
    (else
     (error "unpack: 未知的 #:unpack-method" unpack-method)))
  #t)

(define (install-path source target)
  "装单个文件/链接/目录到绝对路径 TARGET（链接原样复制，不跟随）。"
  (mkdir-p (dirname target))
  (case (stat:type (lstat source))
    ((symlink) (symlink (readlink source) target))
    ((directory) (copy-recursively source target))
    (else (copy-file source target))))

(define (directory-entries dir)
  "DIR 下顶层条目名（不含 . 和 ..，不递归）。"
  (scandir dir (lambda (entry)
                 (not (member entry '("." ".."))))))

(define (install-content source-dir target-dir)
  "装 SOURCE-DIR 的内容进绝对路径 TARGET-DIR。"
  (mkdir-p target-dir)
  (for-each (lambda (base)
              (install-path (string-append source-dir "/" base)
                            (string-append target-dir "/" base)))
            (directory-entries source-dir)))

(define* (install #:key (install-plan #f) (package-name #f) outputs
                   #:allow-other-keys)
  "按 #:install-plan 把构建目录内容 copy 到输出（(SRC DST) 二元组列表）。
install-plan 省略时现算默认 plan：当前目录顶层逐项装进 lib/<pkg>/。"
  (let ((out (assoc-ref outputs "out"))
        (plan (or install-plan
                    (if package-name
                        (default-install-plan package-name)
                        (error "install: 无 #:install-plan 时需要 #:package-name")))))
    (for-each
     (match-lambda
       ((source target)
        (let ((destination (string-append out "/" target)))
          (if (string-suffix? "/" source)
              (let ((source-dir (substring source 0 (- (string-length source) 1))))
                (when (string=? source-dir "/")
                  (error "install: SRC 不能是根目录" source))
                (unless (and (file-exists? source-dir)
                             (file-is-directory? source-dir))
                  (error "install: 尾随 \"/\" 的 SRC 必须是目录" source))
                (install-content (if (string=? source-dir "") "." source-dir)
                                 destination))
              (begin
                (unless (file-exists? source)
                  (error "install: SRC 不存在" source))
                (install-path source
                              (if (string-suffix? "/" target)
                                  (string-append destination (basename source))
                                  destination))))))
       (entry (error "install: 非法的 install-plan 条目（应为 (SRC DST)）" entry)))
     plan)
    #t))

(define (default-install-plan short)
  "默认 plan：在 install 时现算（unpack 之后），当前目录顶层逐项装进
lib/<SHORT>/，跳过 gnu-build 每阶段落盘的环境快照 environment-variables
（nonguix 同款过滤）。"
  (map (lambda (base)
         (list base (string-append "lib/" short "/")))
       (remove (lambda (base)
                 (string=? base "environment-variables"))
               (directory-entries "."))))

(define (library-file? file)
  "是否 .so/.node（只设 RPATH，不碰 interpreter）。"
  (let ((base (basename file)))
    (or (string-contains base ".so")
        (string-suffix? base ".node"))))

(define (resolve-rpath-input inputs spec)
  "把 patchelf-plan 的 RPATH 元素（\"name\" 或 (\"name\" \"/subdir\")）解成绝对目录。"
  (match spec
    ((name subdir)
     (let ((dir (assoc-ref inputs name)))
       (unless dir
         (error "patchelf: plan 引用的 input 不存在" name))
       (string-append dir subdir)))
    ((? string? name)
     (let ((dir (assoc-ref inputs name)))
       (unless dir
         (error "patchelf: plan 引用的 input 不存在" name))
       (string-append dir "/lib")))
    (_ (error "patchelf: 非法的 RPATH 元素（应为 NAME 或 (NAME SUBDIR)）" spec))))

(define (plan-entry-files out path)
  "patchelf-plan 的 PATH（输出内相对路径）展开成绝对文件列表；目录递归取 ELF。"
  (let ((abs (string-append out "/" path)))
    (cond ((not (file-exists? abs))
           (error "patchelf: plan 的路径不存在" path))
          ((file-is-directory? abs)
           (find-files abs
                       (lambda (file stat)
                         (and (eq? 'regular (stat:type stat))
                              (elf-file? file)))))
          (else (list abs)))))

(define (current-rpath patchelf-bin file)
  "读 FILE 现有的 RPATH（单行；preserve-rpath? 用）。"
  (let ((port (open-pipe* OPEN_READ patchelf-bin "--print-rpath" file)))
    (let ((line (read-line port)))
      (close-pipe port)
      (if (eof-object? line) "" line))))

(define (patch-one patchelf-bin interpreter rpath preserve-rpath? file)
  "给单个 FILE 打 interpreter/RPATH：先探测 dynamic，静态全跳过。"
  (format #t "patching ~a ...~%" file)
  ;; 输出文件常是只读的（store copy 保留 444/555 模式），先加写权限；
  ;; daemon 会在构建后把整个输出统一改回只读。
  (make-file-writable file)
  (cond ((library-file? file)
         (if (zero? (system* patchelf-bin "--print-rpath" file))
             (begin
               (invoke patchelf-bin "--set-rpath"
                       (if preserve-rpath?
                           (string-join
                            (filter (lambda (s) (> (string-length s) 0))
                                    (list "$ORIGIN" (current-rpath patchelf-bin file) rpath))
                            ":")
                           rpath)
                       file)
               (display " done\n"))
             (format #t "  跳过（无 .dynamic 段）~%")))
        ((zero? (system* patchelf-bin "--print-interpreter" file))
         (when interpreter
           (invoke patchelf-bin "--set-interpreter" interpreter file))
         (invoke patchelf-bin "--set-rpath"
                 (if preserve-rpath?
                     (string-join
                      (filter (lambda (s) (> (string-length s) 0))
                              (list "$ORIGIN" (current-rpath patchelf-bin file) rpath))
                      ":")
                     rpath)
                 file)
         (display " done\n"))
        (else
         (format #t "  跳过（静态链接或非 ELF）~%"))))

(define* (patchelf #:key inputs outputs
                   (patchelf? #t)
                   (patchelf-plan '())
                   (preserve-rpath? #f)
                   (lib-dir #f)
                   (package-name #f)
                   #:allow-other-keys)
  "给 patchelf-plan 内的 ELF 打 interpreter/RPATH（默认全 inputs 的 /lib）。"
  (if (not patchelf?)
      #t
      (let* ((out (assoc-ref outputs "out"))
             (lib-dir (or lib-dir
                          (and package-name (string-append out "/lib/" package-name))))
             (patchelf-bin (let ((dir (assoc-ref inputs "patchelf")))
                             (if dir
                                 (string-append dir "/bin/patchelf")
                                 "patchelf")))
             (glibc-dir (or (assoc-ref inputs "glibc") (assoc-ref inputs "libc")))
             (interpreter (and glibc-dir
                               (match (find-files glibc-dir "ld-linux.*\\.so")
                                 ((ld _ ...) ld)
                                 (() #f))))
             (auto-lib-dirs
              (delete-duplicates
               (filter-map (lambda (entry)
                             (and (pair? entry)
                                  (let ((lib (string-append (cdr entry) "/lib")))
                                    (and (file-exists? lib) lib))))
                           inputs)
               string=?))
             (targets
              (if (null? patchelf-plan)
                  (if (and lib-dir
                           (file-exists? lib-dir)
                           (file-is-directory? lib-dir))
                      (map (lambda (file) (cons file '()))
                           (find-files lib-dir
                                       (lambda (file stat)
                                         (and (eq? 'regular (stat:type stat))
                                              (elf-file? file)))))
                      (begin
                        (format (current-error-port)
                                "warning: patchelf: 没有 patchelf-plan 且 ~a 不存在，无事可做~%"
                                (or lib-dir "(无 lib-dir)"))
                        '()))
                  (append-map
                   (match-lambda
                     ((? string? path)
                      (map (lambda (file) (cons file '()))
                           (plan-entry-files out path)))
                     ((path specs ...)
                      (map (lambda (file) (cons file specs))
                           (plan-entry-files out path)))
                     (entry (error "patchelf: 非法的 patchelf-plan 条目" entry)))
                   patchelf-plan))))
        (unless interpreter
          (format (current-error-port)
                  "warning: patchelf: 找不到 glibc ld-linux，只设 RPATH 不设 interpreter~%"))
        (for-each
         (match-lambda
           ((file . specs)
            (let ((rpath (string-join
                          (delete-duplicates
                           (append (if (and lib-dir
                                         (file-exists? lib-dir)
                                         (file-is-directory? lib-dir))
                                       (list lib-dir)
                                       '())
                                   (if (null? specs)
                                       auto-lib-dirs
                                       (map (lambda (spec)
                                              (resolve-rpath-input inputs spec))
                                            specs)))
                           string=?)
                          ":")))
              (patch-one patchelf-bin interpreter rpath preserve-rpath? file))))
         targets)
        #t)))

(define* (wrap #:key outputs
               (wrap? #t)
               (wrap-plan '())
               #:allow-other-keys)
  "按 #:wrap-plan 直通 wrap-program。"
  (if (or (not wrap?) (null? wrap-plan))
      #t
      (let ((out (assoc-ref outputs "out")))
        (for-each
         (match-lambda
           ((prog specs ...)
            (let ((abs (if (string-prefix? "/" prog)
                           prog
                           (string-append out "/" prog))))
              (unless (file-exists? abs)
                (error "wrap: 目标不存在" prog))
              (apply wrap-program abs specs)))
           (entry (error "wrap: 非法的 wrap-plan 条目（应为 (PROG SPEC ...)）" entry)))
         wrap-plan)
        #t)))

(define (resolve-out out path)
  "输出内相对路径转绝对；绝对路径原样。"
  (if (string-prefix? "/" path)
      path
      (string-append out "/" path)))

(define (resolve-prog out package-name base)
  "按 basename 在输出内找可执行文件：bin/ 优先，其次 lib/<pkg>/。"
  (let ((in-bin (string-append out "/bin/" base)))
    (cond ((file-exists? in-bin)
           in-bin)
          ((and package-name
                (file-exists? (string-append out "/lib/" package-name "/" base)))
           (string-append out "/lib/" package-name "/" base))
          (else #f))))

(define (split-exec-body body)
  "把 Exec= 去掉键名后的部分拆成 (命令 . 参数)。"
  (let ((idx (or (string-index body #\space)
                 (string-index body #\tab))))
    (if idx
        (cons (substring body 0 idx) (substring body idx))
        (cons body ""))))

(define (fix-exec-line out package-name desktop line explicit-exec)
  "重写单行 Exec=（参数部分原样保留）；自动模式找不到目标则告警保留原行。"
  (let* ((body (substring line 5))
         (parts (split-exec-body body))
         (old (car parts))
         (rest (cdr parts)))
    (cond (explicit-exec
           (string-append "Exec=" explicit-exec rest))
          ((resolve-prog out package-name (basename old))
           => (lambda (target)
                (string-append "Exec=" target rest)))
          (else
           (format (current-error-port)
                   "warning: desktop-files: ~a 的 Exec 目标 ~a 找不到，保持原样~%"
                   desktop old)
           line))))

(define (fix-desktop-file out package-name desktop exec icon)
  "重写单个 .desktop：只动 [Desktop Entry] 组内的 Exec=/Icon=。"
  (let ((abs (resolve-out out desktop)))
    (unless (file-exists? abs)
      (error "desktop-files: 文件不存在" desktop))
    (make-file-writable abs)
    (let ((explicit-exec (and exec (resolve-out out exec)))
          (explicit-icon (and icon (if (string-contains icon "/")
                                       (resolve-out out icon)
                                       icon)))
          (in-main #t))
      (define (fix-line line)
        (cond ((and (> (string-length line) 0)
                    (char=? (string-ref line 0) #\[))
               (set! in-main (string=? line "[Desktop Entry]"))
               line)
              ((and in-main (string-prefix? "Exec=" line))
               (fix-exec-line out package-name desktop line explicit-exec))
              ((and in-main explicit-icon (string-prefix? "Icon=" line))
               (string-append "Icon=" explicit-icon))
              (else line)))
      (let* ((text (call-with-input-file abs
                                          (lambda (port) (read-delimited "" port))))
             (fixed (string-join (map fix-line (string-split text #\newline))
                                 "\n")))
        (call-with-output-file abs
          (lambda (port)
            (display fixed port)
            (unless (string-suffix? "\n" fixed)
              (newline port)))))
      #t)))

(define* (desktop-files #:key outputs
                        (desktop-files '())
                        (package-name #f)
                        #:allow-other-keys)
  "按 #:desktop-files 重写 .desktop 的 Exec=/Icon=（简单版）。"
  (if (null? desktop-files)
      #t
      (let ((out (assoc-ref outputs "out")))
        (for-each
         (match-lambda
           ((desktop)
            (fix-desktop-file out package-name desktop #f #f))
           ((desktop exec)
            (fix-desktop-file out package-name desktop exec #f))
           ((desktop exec icon)
            (fix-desktop-file out package-name desktop exec icon))
           (entry (error "desktop-files: 非法条目（应为 (DESKTOP [EXEC [ICON]])）" entry)))
         desktop-files)
        #t)))

(define %standard-phases
  (modify-phases gnu:%standard-phases
    (delete 'bootstrap)
    (delete 'configure)
    (delete 'build)
    (delete 'check)
    (replace 'unpack unpack)
    (replace 'install install)
    (add-after 'install 'patchelf patchelf)
    (add-after 'patchelf 'wrap wrap)
    (add-after 'wrap 'desktop-files desktop-files)))

(define* (binary-build #:key source system outputs inputs
                       (package-name #f)
                       (app-dir #f)
                       (unpack-method 'gnu-unpack)
                       (install-plan #f)
                       (patchelf? #t)
                       (patchelf-plan '())
                       (preserve-rpath? #f)
                       (wrap? #t)
                       (wrap-plan '())
                       (desktop-files '())
                       (phases %standard-phases)
                       #:allow-other-keys #:rest args)
  "跑完 PHASES；资源目录名 DIR 取 #:app-dir（去 \"lib/\" 前缀）优先，
否则按 derivation 全名去版本后缀（见模块注释）；默认 install-plan、
lib-dir（RPATH 首项）与 desktop 自动查找都按 DIR 落盘。
PACKAGE-NAME 为 host 传来的 derivation 全名。"
  (let* ((out (assoc-ref outputs "out"))
         (dir (or (normalize-app-dir app-dir)
                  (and package-name
                       (derivation-name->package-name package-name))
                  (and install-plan "package")
                  (error "binary-build: 无 #:install-plan 时必须传 #:package-name 或 #:app-dir")))
         ;; Guile 的 #:rest 会吞下已命名 key（实测），apply 转发时重复 key
         ;; 行为未定义：显式覆盖的值必须先从 rest 里剥掉（只留外来 key）。
         (rest (strip-keys args '(#:source #:system #:outputs #:inputs #:phases
                                     #:package-name #:app-dir #:unpack-method #:install-plan
                                     #:patchelf? #:patchelf-plan #:preserve-rpath?
                                     #:lib-dir #:wrap? #:wrap-plan #:desktop-files))))
    (apply gnu:gnu-build
           #:source source
           #:system system
           #:outputs outputs
           #:inputs inputs
           #:phases phases
           #:unpack-method unpack-method
           ;; install-plan 原样透传（#f 表示用 install 阶段现算的默认 plan）。
           #:install-plan install-plan
           #:patchelf? patchelf?
           #:patchelf-plan patchelf-plan
           #:preserve-rpath? preserve-rpath?
           #:lib-dir (string-append out "/lib/" dir)
           #:package-name dir
           ;; 原值透传给 phases（electron 的 wrap-electron 等读 "lib/<app>" 形式）。
           #:app-dir app-dir
           #:wrap? wrap?
           #:wrap-plan wrap-plan
           #:desktop-files desktop-files
           rest)))
