;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;;; 遥测默认关闭的单一真相源：变量表 + shell 片段生成器。
;;;
;;; 本模块是纯数据 + 纯 Guile，host 侧（home 服务）与 build 侧
;;; （(jeans build telemetry) 的 phase）共用同一张表，避免两处各写一份漂移。
;;; 因此这里**不得** import 任何 (guix build …) 模块。
;;;
;;; 变量选择原则：只收跨厂商标准与已在本通道软件里实证的开关，且都能被用户
;;; export 覆盖（片段用 ${VAR:-default} 而非 hard assignment）。厂商私有、
;;; 语义不清的键不进表——宁可留给包定义里的配置层。
;;;
;;; 逐项证据（2026-11，扫 /gnu/store 里已构建产物得到的上游字符串）：
;;;
;;;   DO_NOT_TRACK            consoledonottrack.com 标准。github-copilot 的
;;;                           impeccable 分析库直接判 `IMPECCABLE_NO_TELEMETRY
;;;                           || DO_NOT_TRACK`；omo-bin/cindy-cn-bin 里由
;;;                           Claude Code 派生的 `yre()`/`J7()` 判
;;;                           `DISABLE_TELEMETRY || DO_NOT_TRACK`；paseo-bin 的
;;;                           app.asar、ardia-bin 的 UI bundle、eta-host-bin 与
;;;                           magpie-bin 的二进制里也能找到该变量名。
;;;   DISABLE_TELEMETRY       Claude Code 衍生 CLI 的总开关（omo-bin 的
;;;                           `process.env.DISABLE_TELEMETRY -> "no-telemetry"`）；
;;;                           workbuddy-cn 的 TraceServiceLifecycle 用
;;;                           `process.env.DISABLE_TELEMETRY || (... initTracing)`。
;;;   DISABLE_ERROR_REPORTING Claude Code 衍生的错误上报开关（cindy-cn-bin 的
;;;                           app.asar 给内嵌 cc 子进程设的就是它 + DISABLE_TELEMETRY）。
;;;   OTEL_SDK_DISABLED       OpenTelemetry 官方 SDK 的总开关。zcode、qoder-cn、
;;;                           deepseek-harness-desktop-bin、opencode-desktop-bin
;;;                           都内嵌 otel-js，认这个环境变量；置 true 后 SDK
;;;                           不起 exporter，用户想要自己的 collector 时
;;;                           `OTEL_SDK_DISABLED=false` 即可放开。
;;;   NEXT_TELEMETRY_DISABLED Next.js 内建遥测（Next 16 起默认关，旧版默认开）。
;;;                           bun-bin/pnpm-bin 生态里大量 CLI 是 Next 应用。
;;;   DOTNET_CLI_TELEMETRY_OPTOUT
;;;                           .NET SDK/工具的遥测开关，与 nonguix 的 dotnet、
;;;                           本通道 games.scm 的既有做法同口径。
;;;
;;; 不在本表（各包自己处理或只能用户侧处理）：
;;;   - zed-bin / wu-bin：只有 settings.json 的 telemetry.diagnostics/metrics。
;;;   - fresh-editor-bin：只有 `--no-upgrade-check` 命令行开关与配置项。
;;;   - zen-browser-bin / librewolf-nongnu：Firefox 系走 distribution/policies.json
;;;     （见 (jeans packages browser)）。
;;;   - codex-bin：OpenTelemetry 只在显式配了 exporter 时才启用，默认不发。

(define-module (jeans telemetry)
  #:export (%telemetry-off-variables
            %update-optout-variables
            telemetry-off-shell-snippet))

;; 通用遥测关闭变量：((NAME . VALUE) ...)。顺序即 wrapper 里的出现顺序。
(define %telemetry-off-variables
  '(("DO_NOT_TRACK" . "1")
    ("DISABLE_TELEMETRY" . "1")
    ("DISABLE_ERROR_REPORTING" . "1")
    ("OTEL_SDK_DISABLED" . "true")
    ("NEXT_TELEMETRY_DISABLED" . "1")
    ("DOTNET_CLI_TELEMETRY_OPTOUT" . "1")))

;; 自动更新默认关闭变量：store 只读，自更新必然失败，还会先联网检查一遍；
;; 升级由 Guix 拥有。只收跨厂商或已在本通道软件里实证的键。
;;
;;   DISABLE_AUTOUPDATER  Claude Code 官方开关（cindy-cn-bin 内置 cc-manager 3 处、
;;                        omo-bin 5 处读取）。
;;   DISABLE_UPDATES      同族的全量开关；eta-host-bin 直接读
;;                        `process.env.DISABLE_UPDATES'。
;;   NO_UPDATE_NOTIFIER   update-notifier npm 包认的开关，pnpm-bin 内置该包。
;;
;; 只认配置文件或命令行的（fresh-editor 的 --no-upgrade-check、zed/wu 的
;; auto_update 设置）在包定义与文档里说明，不进这张表。
(define %update-optout-variables
  '(("DISABLE_AUTOUPDATER" . "1")
    ("DISABLE_UPDATES" . "1")
    ("NO_UPDATE_NOTIFIER" . "1")))

(define* (telemetry-off-shell-snippet
          #:key (variables %telemetry-off-variables) (indent ""))
  "生成 shell 片段（含末尾换行）。`${VAR:-VALUE}' 语义：变量未设或为空时才写默认值，
用户 export 自己的值即覆盖——与 wrap-electron-program 里 SSL_CERT_DIR 同款。"
  (apply string-append
         (map (lambda (pair)
                (format #f "~aexport ~a=\"${~a:-~a}\"~%"
                        indent (car pair) (car pair) (cdr pair)))
              variables)))

;;; telemetry.scm ends here
