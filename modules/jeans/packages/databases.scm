;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;; SPDX-FileCopyrightText: Christopher Rodriguez <yewscion@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; Database tools.
;;;
;;; mysql-workbench-community (the classic source line), mysql-connector-cpp
;;; and vsqlite++ were imported from the yewscion Guix channel
;;; <https://git.sr.ht/~yewscion/yewscion-guix-channel/> (cdr255/utils.scm,
;;; by Christopher Rodriguez) and are maintained here.
;;;
;;; Upstream version lines: MySQL stopped publishing 8.0.x source tags on
;;; GitHub in favour of the Electron-based "26.x" binary-only line that
;;; mysql-workbench-community-bin packages.  The 8.0.x line is the last
;;; line whose sources are published as a git tag, and its packages carry
;;; the -classic suffix: the source build below, and
;;; mysql-workbench-community-classic-bin repacked from Oracle's Ubuntu
;;; .deb of the same line.

(define-module (jeans packages databases)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)            ; alsa-lib
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)             ; glibc
  #:use-module (gnu packages bash)             ; bash-minimal
  #:use-module (gnu packages boost)
  #:use-module (gnu packages bootstrap)        ; glibc-dynamic-linker
  #:use-module (gnu packages certs)            ; nss-certs
  #:use-module (gnu packages compression)      ; unzip, libzip, zlib
  #:use-module (gnu packages cups)
 #:use-module (gnu packages crypto)           ; keyutils
 #:use-module (gnu packages cyrus-sasl)       ; cyrus-sasl
 #:use-module (gnu packages databases)        ; mysql, unixodbc
 #:use-module (gnu packages elf)              ; patchelf
 #:use-module (gnu packages fontutils)        ; fontconfig
 #:use-module (gnu packages gcc)              ; gcc "lib"
 #:use-module (gnu packages geo)              ; gdal, proj
 #:use-module (gnu packages gl)               ; mesa, libglvnd
 #:use-module (gnu packages image)            ; libjpeg-turbo, libpng, libwebp
 #:use-module (gnu packages kerberos)         ; mit-krb5
  #:use-module (gnu packages glib)             ; glibmm, libsigc++, dbus
  #:use-module (gnu packages gnome)            ; libglade, libsecret
  #:use-module (gnu packages gtk)              ; gtk+, gtkmm-3, at-spi2-core
  #:use-module (gnu packages java)             ; antlr4
 #:use-module (gnu packages linux)            ; eudev
 #:use-module (gnu packages ncurses)          ; ncurses
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

;;; LERC is not packaged in Guix proper, but the libgdal bundled with
;;; MySQL Workbench's .deb links against it (libLerc.so.4); this private
;;; build provides the exact soname for that binary line.
(define lerc
  (package
    (name "lerc")
    (version "4.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Esri/lerc.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1dj3k05lqljl6pcg9hfsyvxr6mqy8v348cabzvri7csqsd13sxi0"))))
    (build-system cmake-build-system)
    (arguments (list #:tests? #f))       ; no wired-up test target
    (home-page "https://github.com/Esri/lerc")
    (synopsis "Limited Error Raster Compression library")
    (description
     "LERC is an open-source raster compression format and library
developed by Esri.  It supports controlled lossy and lossless encoding
of 2D raster data with a per-pixel maximum compression error.")
    (license license:asl2.0)))

;;; Guix's libxml2 has moved on to libxml2.so.16 (symbol-versioned), but
;;; the libraries bundled with MySQL Workbench's .deb reference the
;;; classic unversioned libxml2.so.2; this private build of the last
;;; pre-versioning line provides that exact soname.  glibc matches the
;;; deb's versioned references against providers without version
;;; definitions ("no version information available" is the expected,
;;; harmless warning).
(define libxml2-legacy
  (package
    (name "libxml2-legacy")
    (version "2.12.9")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "mirror://gnome/sources/libxml2/2.12/libxml2-"
             version ".tar.xz"))
       (sha256
        (base32
         "141m90gsjqprwwsh57qnazzcyywcfsch5sl9cjcs6mmb6ssjv4ar"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f                    ; only used as an ABI provider
      #:configure-flags #~(list "--without-python")))
    (inputs `(("zlib" ,zlib)))
    (home-page "https://gitlab.gnome.org/GNOME/libxml2")
    (synopsis "XML C parser and toolkit (legacy 2.12 line)")
    (description
     "Libxml2 is the XML C parser and toolkit developed for the
GNOME project.  This package builds the 2.12 line, whose shared
library keeps the classic libxml2.so.2 soname and unversioned
symbols.")
    (license license:x11)))

;;; Guix's libjpeg-turbo is built with the 6b ABI (libjpeg.so.62), while
;;; the Workbench deb expects the v8 ABI (libjpeg.so.8) that Debian and
;;; Ubuntu ship; this private build selects that ABI.
(define libjpeg8
  (package
    (name "libjpeg8")
    (version "2.1.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/libjpeg-turbo/libjpeg-turbo.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0qsxg6c2snpr0r4jh12c9bj9k8w1wp4mwncni1r3hdnxwgsbj7mk"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      ;; v8 API/ABI emulation is what provides libjpeg.so.8; SIMD needs
      ;; nasm and is irrelevant for an ABI provider.
      #:configure-flags #~(list "-DWITH_JPEG8=ON" "-DWITH_SIMD=OFF")))
    (home-page "https://libjpeg-turbo.org")
    (synopsis "JPEG image codec with v8 API/ABI emulation")
    (description
     "libjpeg-turbo is a JPEG image codec that uses SIMD instructions
to accelerate baseline and progressive JPEG compression and
decompression.  This private build emulates the libjpeg v8 API/ABI,
providing the libjpeg.so.8 soname that Debian-based binaries link
against.")
    (license license:ijg)))

;;; MySQL Workbench (community source line, 8.0.x): the classic GTKmm
;;; application.  Imported from the yewscion Guix channel (based on
;;; 8.0.33); changes here: pinned to 8.0.47, the final source release of
;;; the 8.0.x line, unixODBC is taken from Guix proper instead of a
;;; pinned 2.3.11, icedtea-7 and java-antlr4-runtime-cpp were dropped (a
;;; private antlr4-runtime-cpp package and the official antlr-4.13.2 jar
;;; replace the latter), the connector was bumped to 1.1.13 for
;;; libmysqlclient 9.x header compatibility, and link-time libraries
;;; moved to inputs.  The -classic suffix keeps this line distinct from
;;; the Electron-based 26.x line packaged as mysql-workbench-community-bin.
(define-public mysql-workbench-community-classic
  (package
    (name "mysql-workbench-community-classic")
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

;;; MySQL Workbench classic binary line (8.0.x): the GTKmm application as
;;; Oracle last distributed it, an Ubuntu 24.04 .deb kept in the archives
;;; area of cdn.mysql.com (8.0.47 is the terminal release of the line, so
;;; this package is frozen by design).  The deb bundles almost all of its
;;; third-party stack under usr/lib/mysql-workbench (gdal, iODBC,
;;; libmysqlclient, connector/C++, libssh, the antlr4 runtime, sqlite and
;;; vsqlite++); only the GTK/GLib world, libzip, proj, Python 3.12 (the
;;; embedded interpreter and the pyodbc C extension), kerberos, sasl,
;;; unixODBC and a few small image codecs come from outside and are
;;; provided by Guix inputs.
;;;
;;; Several Debian-vs-Guix ABI deltas are bridged inside the package:
;;; the deb links libzip.so.4 / libsasl2.so.2 (Debian keeps upstream's
;;; older sonames; Guix ships .so.5 / .so.3) and libtinfo.so.6 — covered
;;; by compatibility symlinks, since the Guix providers carry no
;;; symbol-version definitions and glibc matches the deb's versioned
;;; references against them ("no version information available" is the
;;; expected, harmless warning).  Guix's libxml2 now provides
;;; libxml2.so.16 and its libjpeg-turbo the 6b ABI (libjpeg.so.62), so
;;; the private libxml2-legacy and libjpeg8 above supply the exact
;;; sonames the deb was linked against.
;;;
;;; The upstream launchers are relocatable through WB_DEST_DIR but
;;; hardcode the FHS usr/ prefix and probe libproj/ldd at startup; they
;;; are retargeted at this output's layout, and PROJSO in the wrapper
;;; short-circuits the ldconfig probe (there is no ldconfig in a Guix
;;; profile).  The launchers also pin GDK_BACKEND=x11 unconditionally;
;;; that pin is relaxed to an x11 default with an explicitly exported
;;; GDK_BACKEND winning, because XWayland rendering is
;;; compositor-upscaled and blurry on fractionally scaled outputs
;;; (GDK_BACKEND=wayland renders crisply there, but the model canvas
;;; is X11-only upstream — see the patch-launchers phase).
(define-public mysql-workbench-community-classic-bin
  (package
    (name "mysql-workbench-community-classic-bin")
    (version "8.0.47")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://cdn.mysql.com/archives/mysql-workbench/"
             "mysql-workbench-community_" version "-1ubuntu24.04_amd64.deb"))
       (sha256
        (base32
         "0fjz1vnf2aa0x5v23zizinjl5yf4mqma43ffdjyrcx8p4c771djm"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:validate-runpath? #f
      #:strip-binaries? #f
      #:modules '((guix build gnu-build-system)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (replace 'unpack
            (lambda _
              ;; A .deb is an ar archive; the payload sits in
              ;; data.tar.zst (Ubuntu 24.04 ships zstd compression).
              (invoke "ar" "x" #$source)
              (invoke "tar" "--zstd" "-xf" "data.tar.zst")))
          (add-after 'unpack 'patch-launchers
            (lambda _
              ;; Retarget the WB_DEST_DIR-relative paths at this
              ;; output's layout (no usr/ level here).  substitute* is
              ;; line-based; every pattern below is a single line and
              ;; $ / | are escaped as literals.
              (substitute* "usr/bin/mysql-workbench"
              ;; Upstream pins the x11 backend.  Keep x11 as the
              ;; default — the diagram canvas renders through X11
              ;; drawables and GLX (mdc_canvas_view_glx.cpp and
              ;; gdk_x11_window_get_xid in GtkCanvas::create_canvas),
              ;; and under GDK_BACKEND=wayland opening any model
              ;; aborts with "Error creating cairo context: invalid
              ;; value for an input Visual*" — but let an explicitly
              ;; exported GDK_BACKEND through: on fractionally scaled
              ;; Wayland outputs XWayland rendering is
              ;; compositor-upscaled and blurry, while
              ;; GDK_BACKEND=wayland renders natively and crisply (at
              ;; the cost of the model canvas).
              (("export GDK_BACKEND=x11")
               "export GDK_BACKEND=\"${GDK_BACKEND:-x11}\"")
                (("\\$destdir/usr/lib/mysql-workbench")
                 "$destdir/lib/mysql-workbench")
                (("\\$destdir/usr/share/mysql-workbench")
                 "$destdir/share/mysql-workbench")
                (("\\$destdir/usr/bin")
                 "$destdir/bin")
                (("MWB_BASE_DIR=\"\\$destdir/usr\"")
                 "MWB_BASE_DIR=\"$destdir\"")
                ;; ldd is not on PATH in a Guix profile; silence the
                ;; three probing lines (their LD_PRELOAD workarounds
                ;; targeted a bundling scheme this deb no longer uses).
                (("mysql-workbench-bin \\| grep libcairo")
                 "mysql-workbench-bin 2>/dev/null | grep libcairo")
                (("ldd \\$CAIRO \\| grep libpng")
                 "ldd $CAIRO 2>/dev/null | grep libpng")
                (("ldd \\$PNG \\| grep libz")
                 "ldd $PNG 2>/dev/null | grep libz"))
              (substitute* "usr/bin/wbcopytables"
                (("\\$destdir/usr/lib/mysql-workbench")
                 "$destdir/lib/mysql-workbench")
                (("\\$destdir/usr/bin")
                 "$destdir/bin"))))
          (replace 'install
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                (copy-recursively "usr/lib/mysql-workbench"
                                  (string-append out "/lib/mysql-workbench"))
                ;; iodbcadm-gtk and libiodbcadm are iODBC's standalone
                ;; GTK2 admin dialog (binary + implementation library,
                ;; dlopened on demand by libiodbcinst for the Windows-
                ;; style SQLManageDataSources API).  Nothing in the deb
                ;; references them and keeping them would drag the whole
                ;; GTK2 stack into the closure, so they are not shipped.
                (for-each
                 (lambda (f) (delete-file
                              (string-append out "/lib/mysql-workbench/" f)))
                 '("iodbcadm-gtk" "libiodbcadm.so.2" "libiodbcadm.so.2.1.31"))
                (copy-recursively "usr/share/mysql-workbench"
                                  (string-append out "/share/mysql-workbench"))
                (mkdir-p (string-append out "/bin"))
                (for-each (lambda (f)
                            (install-file (string-append "usr/bin/" f)
                                          (string-append out "/bin")))
                          '("mysql-workbench" "mysql-workbench-bin"
                            "wbcopytables" "wbcopytables-bin"))
                (for-each (lambda (dir)
                            (copy-recursively
                             (string-append "usr/share/" dir)
                             (string-append out "/share/" dir)))
                          '("applications" "icons" "mime" "mime-info")))))
          ;; patch-elf runs before compat-symlinks on purpose: find-files
          ;; must not descend into the symlinks that point at other
          ;; read-only store items.
          (add-after 'install 'patch-elf
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (wb-lib (string-append out "/lib/mysql-workbench"))
                     (ld.so (string-append #$(this-package-input "glibc")
                                           #$(glibc-dynamic-linker)))
                     (rpath (string-join
                             (append
                              (list wb-lib
                                    (string-append wb-lib "/modules")
                                    (string-append wb-lib "/plugins"))
                              ;; Bundled libraries must win over
                              ;; same-soname Guix libraries: $ORIGIN
                              ;; entries come first and cover the lib
                              ;; dir, modules/, plugins/ and bin/.
                              '("$ORIGIN"
                                "$ORIGIN/.."
                                "$ORIGIN/../lib/mysql-workbench")
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
                          (append (find-files wb-lib)
                                  (find-files (string-append out "/bin")))))))
          (add-after 'patch-elf 'compat-symlinks
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((libdir (string-append (assoc-ref outputs "out")
                                           "/lib/mysql-workbench")))
                (symlink (string-append (assoc-ref inputs "libzip")
                                        "/lib/libzip.so.5")
                         (string-append libdir "/libzip.so.4"))
                (symlink (string-append (assoc-ref inputs "cyrus-sasl")
                                        "/lib/libsasl2.so.3")
                         (string-append libdir "/libsasl2.so.2"))
                ;; The bundled mysql CLI links libtinfo.so.6 with
                ;; NCURSES6_TINFO_* version references; Guix's ncurses
                ;; bundles the tinfo symbols unversioned in
                ;; libncursesw, which glibc accepts (see header
                ;; comment).
                (symlink (string-append (assoc-ref inputs "ncurses")
                                        "/lib/libncursesw.so.6")
                         (string-append libdir "/libtinfo.so.6")))))
          (add-after 'compat-symlinks 'wrap-program
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                (for-each
                 (lambda (prog)
                   (wrap-program (string-append out "/bin/" prog)
                     ;; Upstream relocation hook.
                     `("WB_DEST_DIR" = (,out))
                     ;; The launchers probe libproj.so via ldconfig,
                     ;; which does not exist here; the bundled libgdal
                     ;; needs libproj at run time.
                     `("PROJSO" =
                       (,(string-append (assoc-ref inputs "proj")
                                        "/lib/libproj.so.25")))
                     `("XDG_DATA_DIRS" prefix
                       (,(string-append out "/share")))))
                 '("mysql-workbench" "wbcopytables"))))))))
    (native-inputs (list binutils patchelf tar zstd))
    (inputs `(("at-spi2-core" ,at-spi2-core)
              ("atkmm" ,atkmm)
              ("bash-minimal" ,bash-minimal)
              ("cairo" ,cairo)
              ("cyrus-sasl" ,cyrus-sasl)
              ("gcc:lib" ,gcc "lib")
              ("gdk-pixbuf" ,gdk-pixbuf)
              ("glib" ,glib)
              ("glibmm" ,glibmm)
              ("glibc" ,glibc)
              ("gtk+" ,gtk+)
              ("gtkmm" ,gtkmm-3)
              ;; Guix's kerberos stack dlopens libkeyutils.so.1.
              ("keyutils" ,keyutils)
              ("lerc" ,lerc)
              ("libdeflate" ,libdeflate)
              ("libglvnd" ,libglvnd)
              ("libjpeg8" ,libjpeg8)
              ("libpng" ,libpng)
              ("libsecret" ,libsecret)
              ("libsigc++" ,libsigc++)
              ("libwebp" ,libwebp)
              ("libx11" ,libx11)
              ("libxml2-legacy" ,libxml2-legacy)
              ("libzip" ,libzip)
              ("lz4" ,lz4)
              ("mit-krb5" ,mit-krb5)
              ("ncurses" ,ncurses)
              ("openssl" ,openssl)
              ("pango" ,pango)
              ("proj" ,proj)
              ;; The deb embeds Python 3.12 (libpython + the pyodbc
              ;; C extension are 3.12-ABI); Guix's python is 3.12.
              ("python" ,python)
              ("unixodbc" ,unixodbc)
              ("util-linux:lib" ,util-linux "lib")
              ("xz" ,xz)
              ("zlib" ,zlib)))
    (home-page "https://www.mysql.com/products/workbench/")
    (synopsis
     "Visual tool for MySQL database design, administration and development")
    (description
     "MySQL Workbench is a unified visual tool for database architects,
developers and DBAs.  It provides data modeling, SQL development and
comprehensive administration tools for server configuration, user
administration and backup.  This package tracks the classic 8.0.x line
from the official Ubuntu .deb archives.")
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
                  ;; Bundled libcrypto looks for CAs in an Oracle-internal
                  ;; OPENSSLDIR; mysqlsh's TLS connections need the Guix
                  ;; CA store (hash directory layout, hence CERT_DIR).
                  `("SSL_CERT_DIR" =
                    (,(string-append #$(this-package-input "nss-certs")
                                     "/etc/ssl/certs")))
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
              ("nss" ,nss)
              ;; The bundled libcrypto's compiled-in CA directory is an
              ;; Oracle-internal path that does not exist here; TLS
              ;; connections to real servers need the Guix CA store.
              ("nss-certs" ,nss-certs)))
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
