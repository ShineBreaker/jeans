;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;; SPDX-FileCopyrightText: Christopher Rodriguez <yewscion@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; Database tools.
;;;
;;; mysql-workbench-community, mysql-connector-cpp and vsqlite++ were
;;; imported from the yewscion Guix channel
;;; <https://git.sr.ht/~yewscion/yewscion-guix-channel/> (cdr255/utils.scm,
;;; by Christopher Rodriguez) and are maintained here.
;;;
;;; Upstream version lines: MySQL stopped publishing 8.0.x source tags on
;;; GitHub in favour of the Electron-based "26.x" binary-only line that
;;; mysql-workbench-community-bin packages.  The 8.0.x line below is the
;;; last line whose sources are published as a git tag.

(define-module (jeans packages databases)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)            ; alsa-lib
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)             ; glibc
  #:use-module (gnu packages bash)             ; bash-minimal
  #:use-module (gnu packages boost)
  #:use-module (gnu packages bootstrap)        ; glibc-dynamic-linker
  #:use-module (gnu packages compression)      ; unzip, libzip, zlib
  #:use-module (gnu packages cups)
  #:use-module (gnu packages crypto)           ; keyutils
  #:use-module (gnu packages databases)        ; mysql, unixodbc
  #:use-module (gnu packages elf)              ; patchelf
  #:use-module (gnu packages fontutils)        ; fontconfig
  #:use-module (gnu packages gcc)              ; gcc "lib"
  #:use-module (gnu packages geo)              ; gdal, proj
  #:use-module (gnu packages gl)               ; mesa
  #:use-module (gnu packages glib)             ; glibmm, libsigc++, dbus
  #:use-module (gnu packages gnome)            ; libglade, libsecret
  #:use-module (gnu packages gtk)              ; gtk+, gtkmm-3, at-spi2-core
  #:use-module (gnu packages java)             ; antlr4
  #:use-module (gnu packages linux)            ; eudev
  #:use-module (gnu packages nss)              ; nss
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages python)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages ssh)              ; libssh
  #:use-module (gnu packages swig)
  #:use-module (gnu packages tls)              ; openssl
  #:use-module (gnu packages web)              ; rapidjson
  #:use-module (gnu packages xml)              ; libxml2, expat
  #:use-module (gnu packages xdisorg)          ; pixman, libxkbcommon
  #:use-module (gnu packages xorg)             ; libx11, libxcb, ...
  #:use-module (jeans packages agent)          ; electron phase helpers
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:))

;;; MySQL Connector/C++ 1.1.x (JDBC-style API).  Workbench 8.0.x builds
;;; against this legacy line; the 8.x/9.x connector tags on the same
;;; repository are an incompatible rewrite and cannot be used here.
;;; Imported from the yewscion Guix channel at 1.1.8; bumped to 1.1.13
;;; (final 1.1.x tag) because 1.1.8 predates the my_bool-to-bool switch
;;; in libmysqlclient 8.0+/9.x headers and no longer compiles against
;;; them, while 1.1.13 maps my_bool to bool when
;;; LIBMYSQL_VERSION_ID >= 80000.
(define mysql-connector-cpp
  (package
    (name "mysql-connector-cpp")
    (version "1.1.13")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mysql/mysql-connector-cpp.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1j3ilncgxyqa5w1qy7b11sqi172arjsc6dk1n9zy5vn47x3sjbz1"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags #~(list
                            "-DCMAKE_ENABLE_C++11=true"
                            (string-append
                             "-DMySQL_INCLUDE_DIRS="
                             #$(this-package-input "mysql")
                             "/include/mysql")
                            (string-append
                             "-DMySQL_LIBRARIES="
                             #$(this-package-input "mysql")
                             "/lib"))))
    (inputs `(("boost" ,boost)
              ("mysql" ,mysql)
              ("openssl" ,openssl)
              ("zlib" ,zlib)
              ("zstd:lib" ,zstd "lib")))
    (home-page "https://dev.mysql.com/doc/connector-cpp/en/")
    (synopsis "MySQL database connector for C++")
    (description
     "MySQL Connector/C++ is a database connectivity driver that allows
C++ applications to connect to MySQL servers using a JDBC-like API.")
    (license license:gpl2)))

;;; Imported from the yewscion Guix channel.
(define vsqlite++
  (let* ((revision "1")
         (commit "1bc5a9851195b9c67fd48cc82a4ccba378e63534"))
    (package
      (name "vsqlite++")
      (version (git-version "0.3.13" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/vinzenz/vsqlite--.git")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1b0s14axvqg3maqv28br5c72sbid4ilxi5j8vcxj10klr2fvyag1"))))
      (build-system gnu-build-system)
      (native-inputs `(("autoconf" ,autoconf)
                       ("automake" ,automake)
                       ("libtool" ,libtool)))
      (inputs `(("boost" ,boost)
                ("sqlite" ,sqlite)))
      (home-page "https://github.com/vinzenz/vsqlite--")
      (synopsis "Well designed C++ wrapper around SQLite")
      (description
       "VSQLite++ is a C++ wrapper around the SQLite library, providing a
thin, well designed and type-safe interface following the exception-based
error handling idiom of the C++ standard library.")
      (license license:gpl3))))

;;; ANTLR 4 C++ runtime, pinned to the ANTLR version Workbench 8.0.47
;;; generates its parsers with (upstream hardcodes antlr-4.13.2 in its
;;; CMake logic; generated parsers require a matching runtime).  Guix
;;; only packages the 4.10.1 Java tool, not this runtime, hence the
;;; private package (upstream yewscion referenced a
;;; java-antlr4-runtime-cpp that does not exist in Guix).
(define antlr4-runtime-cpp
  (package
    (name "antlr4-runtime-cpp")
    (version "4.13.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/antlr/antlr4.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1dpmqjq5z0r0543jfsbl9rwjrv459dxj378vs6qhy52hw4pm270g"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags #~(list "-DANTLR_BUILD_CPP_TESTS=OFF")
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'configure 'chdir
            (lambda _
              (chdir "runtime/Cpp"))))))
    (native-inputs `(("pkg-config" ,pkg-config)))
    (inputs `(("util-linux:lib" ,util-linux "lib")))
    (home-page "https://github.com/antlr/antlr4")
    (synopsis "ANTLR v4 C++ runtime library")
    (description
     "This package provides the C++ runtime support library for parsers
generated by the ANTLR v4 tool.")
    (license license:bsd-3)))

;;; The ANTLR tool jar used at build time to regenerate Workbench's
;;; parsers.  Workbench's CMake looks it up by its versioned upstream
;;; file name (antlr-4.13.2-complete.jar), which the Guix antlr4 package
;;; does not provide, so install the official jar under that name.
(define antlr4-jar-4.13.2
  (package
    (name "antlr4-jar")
    (version "4.13.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://www.antlr.org/download/antlr-" version "-complete.jar"))
       (sha256
        (base32
         "0xjdvwjm3f3ag85hkf651lc20nn3kqzgdbvj8r22fhx636hxzqpa"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan #~'(("antlr-4.13.2-complete.jar" "share/java/"))))
    (home-page "https://www.antlr.org/download.html")
    (synopsis "ANTLR 4 tool jar")
    (description
     "This package provides the complete ANTLR 4 tool jar used to
generate parsers at build time.")
    (license license:bsd-3)))

;;; MySQL Workbench (community source line, 8.0.x): the classic GTKmm
;;; application.  Imported from the yewscion Guix channel (based on
;;; 8.0.33); changes here: pinned to 8.0.47, the final source release of
;;; the 8.0.x line, unixODBC is taken from Guix proper instead of a
;;; pinned 2.3.11, icedtea-7 and java-antlr4-runtime-cpp were dropped (a
;;; private antlr4-runtime-cpp package and the official antlr-4.13.2 jar
;;; replace the latter), the connector was bumped to 1.1.13 for
;;; libmysqlclient 9.x header compatibility, and link-time libraries
;;; moved to inputs.
(define-public mysql-workbench-community
  (package
    (name "mysql-workbench-community")
    (version "8.0.47")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mysql/mysql-workbench.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0r26dl0d81b0cdpzbbc9w4gaw9z19dl27vh6i7cmy82nayyhb2xg"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f                         ; no test target upstream
      #:phases
      #~(modify-phases %standard-phases
          ;; The SWIG flags for cairo.i hardcode -I/usr/include (FHS
          ;; assumption); point them at Guix's cairo headers instead.
          (add-after 'unpack 'patch-sources
            (lambda _
              (substitute* "library/forms/swig/CMakeLists.txt"
                (("-I/usr/include")
                 (string-append "-I"
                                #$(this-package-input "cairo")
                                "/include")))
              ;; libmysqlclient 9.x added MYSQL_TYPE_VECTOR to
              ;; enum_field_types; handle it like the other binary
              ;; column types so -Werror=switch stays happy.  Note:
              ;; substitute* is line-based, so the pattern must be a
              ;; single line (both BLOB groups get the new case).
              (substitute* "plugins/migration/copytable/copytable.cpp"
                (("      case MYSQL_TYPE_BLOB:")
                 "      case MYSQL_TYPE_VECTOR:\n      case MYSQL_TYPE_BLOB:"))
              ;; The install rules reference the commercial-only
              ;; sharedmimeinfo/mime files by name; the community tree
              ;; ships the same files under the community name.
              (substitute* "CMakeLists.txt"
                (("mysql-workbench-commercial.sharedmimeinfo")
                 "mysql-workbench-community.sharedmimeinfo")
                (("mysql-workbench-commercial.mime")
                 "mysql-workbench-community.mime"))
              ;; The launcher wrapper locates libproj.so (for gdal's
              ;; dlopen) through ldconfig(8), which does not exist on
              ;; Guix; point PROJSO at the store path directly.  The
              ;; trailing awk fragment is commented out rather than
              ;; matched (substitute* patterns are EREs, and the
              ;; braces there are not worth escaping).
              (substitute* "frontend/linux/workbench/mysql-workbench.in"
                (("  TMPLOC=`ldconfig -p \\| grep libproj..so \\| awk")
                 (string-append
                  "  TMPLOC="
                  #$(this-package-input "proj") "/lib/libproj.so #")))
              ;; wbprivate uses libzip directly but never links it
              ;; (upstream builds with linkers that tolerate unresolved
              ;; shared-library symbols); make the dependency explicit.
              (substitute* "backend/wbprivate/CMakeLists.txt"
                (("    Rapidjson::Rapidjson")
                 "    Rapidjson::Rapidjson\n    ${LIBZIP_LIBRARIES}")))))
      #:configure-flags #~(list
                           "-DCMAKE_CXX_STANDARD=11"
                           ;; openjdk (native-input, for the ANTLR jar)
                           ;; ships its own libzip.so inside lib/, which
                           ;; shadows the real libzip in LIBRARY_PATH
                           ;; because native inputs are searched first.
                           ;; Put the real libzip ahead of it via -L, and
                           ;; append libzip/libmysqlclient/libodbc at the
                           ;; end of every link line (wbprivate uses
                           ;; libzip and wbcopytables uses the others
                           ;; without declaring them through the CMake
                           ;; variables upstream expects).
                           (string-append
                            "-DCMAKE_EXE_LINKER_FLAGS=-L"
                            #$(this-package-input "libzip") "/lib")
                           (string-append
                            "-DCMAKE_SHARED_LINKER_FLAGS=-L"
                            #$(this-package-input "libzip") "/lib")
                           ;; The internal libraries (libgrt, libwbbase,
                           ;; libmforms, ...) live side by side under
                           ;; lib/mysql-workbench and depend on each other,
                           ;; and the plugin modules under modules/ and
                           ;; plugins/ are dlopened by their siblings; give
                           ;; every installed binary RPATH entries for all
                           ;; three directories.
                           (string-append
                            "-DCMAKE_INSTALL_RPATH=" #$output
                            "/lib/mysql-workbench;" #$output
                            "/lib/mysql-workbench/modules;" #$output
                            "/lib/mysql-workbench/plugins")
                           "-DCMAKE_CXX_STANDARD_LIBRARIES=-lzip -lmysqlclient -lodbc"
                           (string-append
                            "-DWITH_ANTLR_JAR="
                            #$(this-package-native-input "antlr4-jar")
                            "/share/java/antlr-4.13.2-complete.jar")
                           (string-append
                            "-DMySQL_INCLUDE_DIRS="
                            #$(this-package-input "mysql")
                            "/include/mysql")
                           (string-append
                            "-DMySQL_LIBRARIES="
                            #$(this-package-input "mysql")
                            "/lib")
                           (string-append
                            "-DMySQLCppConn_INCLUDE_DIRS="
                            #$(this-package-input "mysql-connector-cpp")
                            "/include")
                           (string-append
                            "-DMySQLCppConn_LIBRARIES="
                            #$(this-package-input "mysql-connector-cpp")
                            "/lib")
                           (string-append
                            "-DUNIXODBC_INCLUDE_PATH="
                            #$(this-package-input "unixodbc")
                            "/include")
                           (string-append
                            "-DUNIXODBC_INCLUDE_DIRS="
                            #$(this-package-input "unixodbc")
                            "/include")
                           (string-append
                            "-DUNIXODBC_LIBRARIES="
                            #$(this-package-input "unixodbc")
                            "/lib"))))
    (native-inputs `(("antlr4-jar" ,antlr4-jar-4.13.2)
                     ("openjdk" ,openjdk)
                     ("pkg-config" ,pkg-config)
                     ("swig" ,swig)))
    (inputs `(("antlr4-runtime-cpp" ,antlr4-runtime-cpp)
              ("boost" ,boost)
              ("cairo" ,cairo)
              ("gdal" ,gdal)
              ("glibmm" ,glibmm)
              ("gtk+" ,gtk+)
              ("gtkmm" ,gtkmm-3)
              ("libglade" ,libglade)
              ("libsecret" ,libsecret)
              ("libsigc++" ,libsigc++)
              ("libssh" ,libssh)
              ("libxml2" ,libxml2)
              ("libzip" ,libzip)
              ("mysql" ,mysql)
              ("mysql-connector-cpp" ,mysql-connector-cpp)
              ("openssl" ,openssl)
              ("pango" ,pango)
              ("pcre" ,pcre)
              ("pixman" ,pixman)
              ("proj" ,proj)
              ("python" ,python)
              ("rapidjson" ,rapidjson)
              ("sqlite" ,sqlite)
              ("unixodbc" ,unixodbc)
              ("vsqlite++" ,vsqlite++)))
    (home-page "https://www.mysql.com/products/workbench/")
    (synopsis
     "Visual tool for MySQL database design, administration and development")
    (description
     "MySQL Workbench is a unified visual tool for database architects,
developers and DBAs.  It provides data modeling, SQL development and
comprehensive administration tools for server configuration, user
administration and backup.")
    (license license:gpl2)))

;;; MySQL Workbench binary line (26.x): Oracle rewrote the application on
;;; Electron; the rewritten sources are not published as release tags, only
;;; prebuilt archives are distributed from cdn.mysql.com.  The archive is a
;;; plain directory tree (no top-level folder) with the Electron runtime at
;;; the root and a self-contained MySQL Shell under
;;; resources/app/shell (mysqlsh itself, secret-store helpers and a private
;;; copy of libssl/libcrypto/libssh/libpython/abseil/protobuf all under
;;; shell/lib/mysqlsh, resolved via $ORIGIN-relative RPATH entries).
;;; mysqlsh and its helpers stay internal to the GUI package, matching
;;; upstream's own desktop archive layout.
(define-public mysql-workbench-community-bin
  (package
    (name "mysql-workbench-community-bin")
    (version "26.7.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-"
             version "-linux-glibc2.28-x86_64.zip"))
       (sha256
        (base32
         "0jik1nb07zvmiq38mxh1pwfw3pihzw8zvvzw97kwxyjwn8wx8jwl"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-26))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              (invoke "unzip" #$source)))
          (replace 'install
            (lambda _
              (copy-recursively "." (string-append #$output
                                                   "/lib/mysql-workbench"))
              #t))
          (add-after 'install 'disable-electron-updater
            #$(disable-electron-updater-phase "mysql-workbench"))
          (add-after 'disable-electron-updater 'patch-elf
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (append
                              (list (string-append #$output
                                                   "/lib/mysql-workbench")
                                    (string-append
                                     #$output "/lib/mysql-workbench"
                                     "/resources/app/shell/lib/mysqlsh"))
                              ;; Bundled libraries must win over the
                              ;; same-soname Guix libraries (libssl,
                              ;; libcrypto, ...): $ORIGIN entries come
                              ;; first and cover every nesting depth.
                              '("$ORIGIN"
                                "$ORIGIN/.."
                                "$ORIGIN/../mysqlsh"
                                "$ORIGIN/../../mysqlsh"
                                "$ORIGIN/../lib/mysqlsh"
                                "$ORIGIN/../../lib/mysqlsh")
                              (map (lambda (input)
                                     (string-append (cdr input) "/lib"))
                                   inputs))
                             ":")))
                (define (patch-elf file)
                  (when (elf-file? file)
                    (unless (string-contains (basename file) ".so")
                      (invoke "patchelf" "--set-interpreter" ld.so file))
                    (invoke "patchelf" "--set-rpath" rpath file)))
                (for-each patch-elf
                          (find-files (string-append #$output
                                                     "/lib/mysql-workbench"))))))
          (add-after 'patch-elf 'install-bin
            (lambda _
              (let* ((bin (string-append #$output "/bin"))
                     (exe (string-append #$output
                                         "/lib/mysql-workbench/mysql-workbench")))
                (mkdir-p bin)
                (symlink exe (string-append bin "/mysql-workbench")))))
          (add-after 'install-bin 'install-desktop
            (lambda _
              (let ((apps (string-append #$output "/share/applications")))
                (mkdir-p apps)
                (make-desktop-entry-file
                 (string-append apps "/mysql-workbench.desktop")
                 #:name "MySQL Workbench"
                 #:type "Application"
                 #:comment #$(package-synopsis this-package)
                 #:exec (string-append #$output "/bin/mysql-workbench %U")
                 #:icon "mysql-workbench"
                 #:categories '("Development")
                 #:startup-w-m-class "MySQL Workbench"))))
          (add-after 'install-desktop 'install-icons
            (lambda _
              (let ((icons (string-append #$output
                                         "/share/icons/hicolor/128x128/apps")))
                (mkdir-p icons)
                (copy-file "resources/app/images/app-icon.png"
                           (string-append icons "/mysql-workbench.png")))))
          (add-after 'install-icons 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (lib (string-append out "/lib/mysql-workbench"))
                     (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                     (nss-lib (string-append (assoc-ref inputs "nss")
                                             "/lib/nss")))
                (wrap-program (string-append out "/bin/mysql-workbench")
                  `("LD_LIBRARY_PATH" prefix
                    (,lib ,mesa-lib ,nss-lib))
                  `("FONTCONFIG_FILE" =
                    (,(string-append #$(this-package-input "fontconfig-minimal")
                                     "/etc/fonts/fonts.conf")))
                  `("XDG_DATA_DIRS" prefix
                    (,(string-append out "/share")))))))
          (add-after 'wrap-program 'prefer-wayland
            #$(prefer-electron-wayland-phase "mysql-workbench")))))
    (native-inputs (list patchelf unzip))
    (inputs `(("alsa-lib" ,alsa-lib)
              ("at-spi2-core" ,at-spi2-core)
              ("bash-minimal" ,bash-minimal)
              ("cups" ,cups)
              ("dbus" ,dbus)
              ("eudev" ,eudev)
              ("expat" ,expat)
              ("fontconfig-minimal" ,fontconfig)
              ("gcc:lib" ,gcc "lib")
              ("glibc" ,glibc)
              ("glib" ,glib)
              ("gtk+" ,gtk+)
              ;; The bundled kerberos libraries under shell/lib/mysqlsh
              ;; need libkeyutils.so.1, which is not bundled.
              ("keyutils" ,keyutils)
              ("libx11" ,libx11)
              ("libxcb" ,libxcb)
              ("libxcomposite" ,libxcomposite)
              ("libxdamage" ,libxdamage)
              ("libxext" ,libxext)
              ("libxfixes" ,libxfixes)
              ("libxkbcommon" ,libxkbcommon)
              ("libxrandr" ,libxrandr)
              ("mesa" ,mesa)
              ("nss" ,nss)))
    (home-page "https://www.mysql.com/products/workbench/")
    (synopsis
     "Visual tool for MySQL database design, administration and development")
    (description
     "MySQL Workbench is a unified visual tool for database architects,
developers and DBAs.  It provides data modeling, SQL development and
comprehensive administration tools for server configuration, user
administration and backup.  This package tracks the Electron-based 26.x
distribution line built on MySQL Shell; it ships prebuilt binaries from
the official archive.")
    (license license:gpl2)))
