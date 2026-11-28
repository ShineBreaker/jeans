#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-only
"""预编译 Electron 应用 app.asar：把写死的系统路径改走 Guix profile。

给 (jeans build electron) 的包共用：`asar-guix-paths.py <app-id> <app.asar>`，
app-id 取 SPECS 的键。每个 app 一张锚点表，锚点落在哪个 chunk 由内容决定
（主进程逻辑常被摊在 bootstrap-electron / browser-control-runtime / index
等多个 chunk 里，按文件名匹配会改错地方）。

Guix System 没有 /usr/bin（本机那个 /usr/bin/env 是系统配置另建的），/bin
里只有 /bin/sh。上游把这些绝对路径当标配：浏览器候选表、远程桌面 sidecar、
POSIX shell/ps 的 spawn 目标、默认 PATH —— 落空即静默降级或 ENOENT。

SPECS 里每个 app 的条目分三类：
  - 候选表：Guix 路径插到发行版路径之前，只在存在时列入；
  - spawn/execFile 目标：换成 gxResolveBin()，否则 ENOENT；
  - 固定 PATH 字面量：换成 gxProfilePath()（profile 目录 + 现 PATH）。

做法是给每个改到的 chunk 顶层注入 gxResolveBin() / gxProfilePath() 等辅助
函数（按 /run/current-system/profile/bin、~/.guix-home/profile/bin、$PATH
依次解析），再把命中的字面量换成它们。

cindy 那条还让 native binding 优先使用随包安装的 cindy-browser-native（见
gxNativeHostBinary，指向 lib/cindy/native-host/）：插件市场自带的 Go host 在
parent_linux.go 里把父进程可执行文件白名单写死成 /usr/lib、/opt 下的发行版
路径，Guix 的浏览器永远不合格，扩展因此一直等配对；换上本仓库构建的 host
后，插件更新时字节相同，Cindy 不会把它覆盖回插件自带那份。

改写长度会变，asar 的 offset 与每个成员的 SHA256/块哈希必须整体重算
（Electron 的 asar integrity fuse 已开启）；锚点缺失时直接失败，不做半套。

用法：asar-guix-paths.py <app-id> <app.asar>
"""

import hashlib
import json
import re
import struct
import sys

BLOCK_SIZE = 4 * 1024 * 1024

# ---------------------------------------------------------------------------
# 注入的 JavaScript
# ---------------------------------------------------------------------------
# 不引用 chunk 里的压缩别名（z / Ot / fs$6 …，每次构建都会变），只用 require。

HELPER = r"""
function gxRequire(gxName){try{return require(gxName)}catch(gxErr){}try{return process.getBuiltinModule(gxName)}catch(gxErr){}return null}
function gxHomeDir(){try{return gxRequire("node:os").homedir()}catch(gxErr){return process.env.HOME||""}}
function gxBinDirs(){const gxOut=[];const gxFixed=["/run/current-system/profile/bin",gxHomeDir()+"/.guix-home/profile/bin","/run/privileged/bin",gxHomeDir()+"/.local/bin","/usr/local/bin","/usr/bin"];for(const gxDir of gxFixed.concat(String(process.env.PATH||"").split(":"))){if(!gxDir)continue;const gxNorm=String(gxDir).replace(/\/+$/,"");if(gxNorm&&gxOut.indexOf(gxNorm)<0)gxOut.push(gxNorm)}return gxOut}
function gxResolveBin(gxName){if(String(gxName).indexOf("/")>=0)return gxName;let gxFs=null;try{gxFs=gxRequire("node:fs")}catch(gxErr){return gxName}for(const gxDir of gxBinDirs()){const gxPath=gxDir+"/"+gxName;try{if(gxFs.existsSync(gxPath))return gxPath}catch(gxErr){}}return gxName}
function gxBrowserPaths(gxKind){const gxNames={chrome:["google-chrome","google-chrome-stable","chrome"],edge:["microsoft-edge","microsoft-edge-stable"],brave:["brave-browser","brave"],chromium:["chromium","chromium-browser"]}[gxKind]||[];const gxOut=[];for(const gxName of gxNames){const gxPath=gxResolveBin(gxName);if(gxPath===gxName)continue;let gxBase=gxName;try{gxBase=gxRequire("node:path").basename(gxRequire("node:fs").realpathSync(gxPath))}catch(gxErr){}const gxReal=gxBase.toLowerCase();const gxDetected=gxReal.indexOf("brave")>=0?"brave":gxReal.indexOf("edge")>=0?"edge":gxReal.indexOf("chromium")>=0?"chromium":gxReal.indexOf("chrome")>=0?"chrome":null;if(gxDetected!==null&&gxDetected!==gxKind)continue;gxOut.push(gxPath)}return gxOut}
function gxChromiumBins(){const gxOut=[];for(const gxKind of ["chromium","chrome","brave","edge"]){for(const gxPath of gxBrowserPaths(gxKind))gxOut.push({kind:gxKind,path:gxPath})}return gxOut}
function gxNativeHostBinary(){const gxCands=[];if(process.env.CINDY_BROWSER_NATIVE_HOST)gxCands.push(process.env.CINDY_BROWSER_NATIVE_HOST);try{gxCands.push(gxRequire("node:path").join(process.resourcesPath,"..","native-host","cindy-browser-native"))}catch(gxErr){}gxCands.push("cindy-browser-native");let gxFs=null;try{gxFs=gxRequire("node:fs")}catch(gxErr){return null}for(const gxCand of gxCands){if(!gxCand)continue;const gxPath=String(gxCand).indexOf("/")>=0?gxCand:gxResolveBin(gxCand);try{if(gxFs.existsSync(gxPath))return gxPath}catch(gxErr){}}return null}
function gxProfilePath(){return gxBinDirs().join(":")}
function gxDesktopEntryPaths(gxName){const gxOut=[];for(const gxDir of [gxHomeDir()+"/.guix-home/profile/share/applications","/run/current-system/profile/share/applications","/run/privileged/share/applications"])gxOut.push(gxDir+"/"+gxName);for(const gxDir of String(process.env.XDG_DATA_DIRS||"").split(":")){if(gxDir)gxOut.push(String(gxDir).replace(/\/+$/,"")+"/applications/"+gxName)}return gxOut}
"""

# 浏览器候选：Guix 路径排在 /usr/bin 之前，但只在存在时列入。
CINDY_BROWSER_ARRAYS = [
    (
        'return["/usr/bin/google-chrome-stable","/usr/bin/google-chrome",'
        '"/usr/bin/chrome","/opt/google/chrome/chrome","/snap/bin/google-chrome"]',
        'return[...gxBrowserPaths("chrome"),"/usr/bin/google-chrome-stable",'
        '"/usr/bin/google-chrome","/usr/bin/chrome","/opt/google/chrome/chrome",'
        '"/snap/bin/google-chrome"]',
    ),
    (
        'return["/usr/bin/microsoft-edge","/usr/bin/microsoft-edge-stable"]',
        'return[...gxBrowserPaths("edge"),"/usr/bin/microsoft-edge",'
        '"/usr/bin/microsoft-edge-stable"]',
    ),
    (
        'return["/usr/bin/brave-browser","/usr/bin/brave-browser-stable",'
        '"/usr/bin/brave","/opt/brave.com/brave/brave-browser","/snap/bin/brave"]',
        'return[...gxBrowserPaths("brave"),"/usr/bin/brave-browser",'
        '"/usr/bin/brave-browser-stable","/usr/bin/brave",'
        '"/opt/brave.com/brave/brave-browser","/snap/bin/brave"]',
    ),
    (
        'return["/usr/bin/chromium-browser","/usr/bin/chromium",'
        '"/usr/lib/chromium/chromium","/usr/lib/chromium-browser/chromium-browser",'
        '"/snap/bin/chromium"]',
        'return[...gxBrowserPaths("chromium"),"/usr/bin/chromium-browser",'
        '"/usr/bin/chromium","/usr/lib/chromium/chromium",'
        '"/usr/lib/chromium-browser/chromium-browser","/snap/bin/chromium"]',
    ),
]

SPECS = {
    # Cindy：见 agent.scm cindy-cn-bin 的包注释。
    "cindy": {"prefixes": [".vite/build/"], "edits": CINDY_BROWSER_ARRAYS + [
    ('"/usr/bin/loginctl"', 'gxResolveBin("loginctl")', 3),
    ('"/usr/bin/wl-paste"', 'gxResolveBin("wl-paste")', 2),
    ('"/usr/bin/python3"', 'gxResolveBin("python3")', 8),
    ('process.platform==="win32"?windowsTarBin():"/usr/bin/tar"',
     'process.platform==="win32"?windowsTarBin():gxResolveBin("tar")', 1),
    ('"/usr/bin/xdotool"', 'gxResolveBin("xdotool")', 1),
    ('"/usr/bin/pw-record"', 'gxResolveBin("pw-record")', 1),
    ('"/usr/bin/grim"', 'gxResolveBin("grim")', 1),
    ('"/usr/bin/hyprctl"', 'gxResolveBin("hyprctl")', 4),
    ('"/usr/bin/omarchy"', 'gxResolveBin("omarchy")', 2),
    ('"/usr/bin/omarchy-menu"', 'gxResolveBin("omarchy-menu")', 1),
    ('"/usr/bin/omarchy-shell"', 'gxResolveBin("omarchy-shell")', 1),
    ('path$4.join(l.binaryDir,n+"-"+R,Do)',
     '(gxNativeHostBinary()||path$4.join(l.binaryDir,n+"-"+R,Do))', 1),
    ('"/usr/bin/ps"', 'gxResolveBin("ps")', 1),
    ('`/usr/bin/${l}`', 'gxResolveBin(l)', 1),
    ('`/usr/bin/${R}`', 'gxResolveBin(R)', 1),
    # ---- POSIX shell / ps：Guix 只有 /bin/sh，没有 /bin/bash、/bin/zsh、
    # /bin/ps。这些都是 spawn/execFile 的目标，不是可选候选表，落空即 ENOENT。
    ('spawn("/bin/bash",[cr],', 'spawn(gxResolveBin("bash"),[cr],', 1),
    ('spawn("/bin/bash",["-c",xr,"cindy-linux-update"]',
     'spawn(gxResolveBin("bash"),["-c",xr,"cindy-linux-update"]', 1),
    ('process.platform==="win32"?"bash":"/bin/bash"',
     'process.platform==="win32"?"bash":gxResolveBin("bash")', 1),
    ('execFileSync("/bin/bash",["-c",',
     'execFileSync(gxResolveBin("bash"),["-c",', 1),
    ('existsSync("/bin/bash")?"/bin/bash":"/bin/sh"',
     'existsSync(gxResolveBin("bash"))?gxResolveBin("bash"):"/bin/sh"', 1),
    ('[["/bin/zsh","zsh","zsh"],["/bin/bash","bash","bash"],'
     '["/bin/sh","sh","sh"]]',
     '[[gxResolveBin("zsh"),"zsh","zsh"],[gxResolveBin("bash"),"bash","bash"],'
     '[gxResolveBin("sh"),"sh","sh"]]', 1),
    ('fallbackShells=["/bin/zsh","/bin/bash"]',
     'fallbackShells=[gxResolveBin("zsh"),gxResolveBin("bash")]', 1),
    ('("/bin/ps",["-ww","-o","pid=,ppid=,uid=,args="',
     '(gxResolveBin("ps"),["-ww","-o","pid=,ppid=,uid=,args="', 1),
    ('("/bin/ps",["-o","args=","-p"',
     '(gxResolveBin("ps"),["-o","args=","-p"', 1),
    ('existsSync("/bin/ps")?"/bin/ps"',
     'existsSync(gxResolveBin("ps"))?gxResolveBin("ps")', 1),
    # BROWSER=/bin/true 是「不要开浏览器」的哑元；Guix 没有 /bin/true。
    ('BROWSER:"/bin/true"', 'BROWSER:gxResolveBin("true")', 2),
    # 用户级工具安装脚本：spawn 目标与管道解释器都写死了 /bin/bash。
    ('("/bin/bash",["-c",`curl -fsSL ${Mi} | /bin/bash`]',
     '(gxResolveBin("bash"),["-c",`curl -fsSL ${Mi} | ${gxResolveBin("bash")}`]', 1),
    # /usr/bin/env 在本机由系统配置创建，不是 Guix System 标配。
    ('["/usr/bin/env",', '[gxResolveBin("env"),', 1),
    ('\'mcp_servers.node_repl.command="/usr/bin/env"\'',
     '\'mcp_servers.node_repl.command="\'+gxResolveBin("env")+\'"\'', 1),
    # 默认浏览器解析：候选表前缀 + desktop entry 搜索目录。
    ("function mG(){const e=[{kind:\"chrome\",path:\"/usr/bin/google-chrome\"}",
     "function mG(){const e=[...gxChromiumBins(),"
     "{kind:\"chrome\",path:\"/usr/bin/google-chrome\"}", 1),
    ("function iG(e){const t=[", "function iG(e){const t=[...gxDesktopEntryPaths(e),", 1),
    ]},
    # Qoder：重启脚本、ELECTRON_RUN_AS_NODE 包装、进程清理、硬件探测。
    #
    # 重启辅助进程那条锚点里的变量名是压缩后的别名（0.5.20 是 xli、0.5.21
    # 变成 gli），写死字面量每次上游发版都会断，故用正则只锁结构与
    # "qoder-relaunch" 标记；其余锚点仍是字面量（跨版本稳定，实证）。
    "qoder-cn": {"prefixes": ["out/main/"], "edits": [
        (re.compile(r'\(\"/bin/bash\",\["-c\",([A-Za-z_$][\w$]*),"qoder-relaunch"'),
         r'(gxResolveBin("bash"),["-c",\1,"qoder-relaunch"', 1),
        ('[r==="win32"?"env":"/usr/bin/env","ELECTRON_RUN_AS_NODE=1"]',
         '[r==="win32"?"env":gxResolveBin("env"),"ELECTRON_RUN_AS_NODE=1"]', 1),
        ('("/usr/bin/pkill",["-f","esa-agent"]',
         '(gxResolveBin("pkill"),["-f","esa-agent"]', 1),
        ('"/usr/bin/which"', 'gxResolveBin("which")', 1),
        ('"/usr/bin/lsof"', 'gxResolveBin("lsof")', 1),
        ('"/usr/bin/nvidia-smi"', 'gxResolveBin("nvidia-smi")', 1),
        ('"/usr/bin/lspci"', 'gxResolveBin("lspci")', 1),
    ]},
    # ZCode：Linux 分支的 login-env 默认 PATH 是发行版布局，登录 shell 捕获
    # 出来等于空环境。darwin 分支与命令表（codesign/ditto/mdfind/PlistBuddy）
    # 是 macOS 专用，不动。
    "zcode": {"prefixes": ["out/main/", "out/host/", "out/scheduler/"],
              "edits": [
        ('"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
         'gxProfilePath()', 3),
    ]},
}


# 只扫主进程 chunk（前缀由 SPECS 给）；renderer 的 assets/ 里有同名常量但那
# 是浏览器上下文，改错地方没意义。
STRICT_PREFIX = '"use strict";'


# ---------------------------------------------------------------------------
# asar 读写
# ---------------------------------------------------------------------------

def align4(value):
    return (value + 3) & ~3


def integrity_of(data):
    digest = hashlib.sha256(data).hexdigest()
    blocks = [hashlib.sha256(data[i:i + BLOCK_SIZE]).hexdigest()
              for i in range(0, len(data), BLOCK_SIZE)]
    if not blocks:  # 空成员在 header 里带一个空块，不是零块
        blocks = [digest]
    return {"algorithm": "SHA256", "hash": digest,
            "blockSize": BLOCK_SIZE, "blocks": blocks}


class Asar:
    def __init__(self, path):
        self.path = path
        with open(path, "rb") as handle:
            self.buf = handle.read()
        magic, _, _, json_len = struct.unpack("<IIII", self.buf[:16])
        if magic != 4:
            raise SystemExit("asar: 头部魔数不是 4（格式变了？）")
        self.json_len = json_len
        self.header = json.loads(self.buf[16:16 + json_len].decode("utf-8"))
        self.base = 16 + align4(json_len)

    def walk(self, node=None, prefix=""):
        node = self.header if node is None else node
        for name, child in node.get("files", {}).items():
            path = f"{prefix}/{name}" if prefix else name
            if "files" in child:
                yield from self.walk(child, path)
            else:
                yield path, child

    def payload(self):
        """按 offset 排好的 payload 成员（紧凑排列，空文件共享 offset）。"""
        entries = [(path, entry) for path, entry in self.walk()
                   if entry.get("offset") is not None
                   and not entry.get("unpacked")]
        entries.sort(key=lambda item: int(item[1]["offset"]))
        return entries

    def read(self, entry):
        start = self.base + int(entry["offset"])
        return self.buf[start:start + int(entry["size"])]

    def chunks(self, prefixes):
        """给定前缀下真正进了 payload 的 .js 成员。"""
        for path, entry in self.walk():
            if path.endswith(".js") and entry.get("offset") is not None \
                    and not entry.get("unpacked") \
                    and any(path.startswith(p) for p in prefixes):
                yield path, entry


def patch_chunks(asar, app_id, prefixes, edits):
    """把 EDITS 应用到命中的 chunk，返回 {成员路径: 新字节}。

    锚点先在每个 chunk 里计数、再断言总数等于期望值：上游把同一批逻辑摊在
    bootstrap-electron / browser-control-runtime / index 三个 chunk 里，哪条
    落在哪个 chunk 是上游的自由，按文件名匹配会改错地方。同一条锚点允许出现
    在多个 chunk（替换内容相同），只断言总命中次数。
    """
    sources = {}
    for member, entry in asar.chunks(prefixes):
        try:
            sources[member] = asar.read(entry).decode("utf-8")
        except UnicodeDecodeError:
            continue

    touched = set()
    for item in edits:
        anchor, replacement = item[0], item[1]
        expected = item[2] if len(item) > 2 else 1
        # 字面量锚点直接 in/count；正则锚点用于含压缩别名的结构，替换串里的
        # \1 回填捕获到的别名（别名本身不动，只改调用形态）。
        if isinstance(anchor, re.Pattern):
            hits = [m for m, text in sources.items() if anchor.search(text)]
            found = sum(len(anchor.findall(sources[m])) for m in hits)
        else:
            hits = [m for m, text in sources.items() if anchor in text]
            found = sum(sources[m].count(anchor) for m in hits)
        if found != expected:
            where = ", ".join(hits) or "无"
            raise SystemExit(
                f"asar: 锚点命中 {found} 次（期望 {expected}，位于 {where}）："
                f"{anchor[:120]!r}")
        for member in hits:
            if isinstance(anchor, re.Pattern):
                sources[member] = anchor.sub(replacement, sources[member])
            else:
                sources[member] = sources[member].replace(anchor, replacement)
            touched.add(member)

    updates = {}
    for member in sorted(touched):
        updates[member] = inject_helper(sources[member]).encode("utf-8")
        print(f"asar-guix-paths: {app_id} 改写 {member}")
    return updates


def inject_helper(text):
    """把 HELPER 放到模块顶层作用域，且不破坏已有语义。

    函数声明会提升，所以插在文件开头即可被后续代码看到；唯一的例外是
    "use strict" 指令序言——前面加东西会让它退化成普通表达式，整份文件掉回
    sloppy mode，故把它留在第一位。shebang 同理必须留在第一行。
    """
    if text.startswith("#!"):
        end = text.index("\n") + 1
        return text[:end] + HELPER + text[end:]
    if text.startswith(STRICT_PREFIX):
        return STRICT_PREFIX + HELPER + text[len(STRICT_PREFIX):]
    return HELPER + text


def repack(asar, updates):
    chunks = []
    offset = 0
    for path, entry in asar.payload():
        data = updates.get(path)
        if data is None:
            data = asar.read(entry)
        else:
            entry["size"] = len(data)
            if "integrity" in entry:
                entry["integrity"] = integrity_of(data)
        entry["offset"] = str(offset)
        offset += len(data)
        chunks.append(data)
    payload = b"".join(chunks)

    header_json = json.dumps(asar.header, separators=(",", ":"),
                             ensure_ascii=False).encode("utf-8")
    padded_json_len = align4(len(header_json))
    header_payload = 4 + padded_json_len
    header_pickle = 4 + header_payload
    base = 16 + padded_json_len
    out = bytearray(base + len(payload))
    struct.pack_into("<IIII", out, 0, 4, header_pickle, header_payload,
                     len(header_json))
    out[16:16 + len(header_json)] = header_json
    out[base:] = payload
    return bytes(out)


def broken_members(asar):
    """重打包前就已对不上 header 的成员。

    上游偶尔会在打包后再改文件（zcode 0.5/4.0 的 out/main/index.js 就是），
    这类既有不符不该由我们的阶段负责，也不能因此拒绝出包；但要报出来，免得
    把「我们改坏了」和「上游本来就坏」混为一谈。
    """
    broken = set()
    for member, entry in asar.payload():
        expected = entry.get("integrity")
        if not expected:
            continue
        if integrity_of(asar.read(entry))["hash"] != expected["hash"]:
            broken.add(member)
    return broken


def verify(path, tolerate=()):
    asar = Asar(path)
    checked = 0
    tolerated = []
    for member, entry in asar.payload():
        data = asar.read(entry)
        if len(data) != int(entry["size"]):
            raise SystemExit(f"asar: {member} 尺寸不符")
        expected = entry.get("integrity")
        if not expected:
            continue
        actual = integrity_of(data)
        if actual["hash"] != expected["hash"] or \
                actual["blocks"] != expected["blocks"]:
            if member in tolerate:
                tolerated.append(member)
                continue
            raise SystemExit(f"asar: {member} 哈希不符")
        checked += 1
    return checked, tolerated


def main():
    if len(sys.argv) != 3:
        raise SystemExit("用法：asar-guix-paths.py <app-id> <app.asar>")
    app_id, path = sys.argv[1], sys.argv[2]
    if app_id not in SPECS:
        raise SystemExit(f"asar-guix-paths: 未知 app-id {app_id!r}，"
                         f"可选：{', '.join(sorted(SPECS))}")
    asar = Asar(path)

    if any("function gxResolveBin(" in asar.read(entry).decode("utf-8", "replace")
           for _, entry in asar.chunks(SPECS[app_id]["prefixes"])):
        print(f"asar-guix-paths: {app_id} 已打过补丁，跳过")
        return

    spec = SPECS[app_id]
    updates = patch_chunks(asar, app_id, spec["prefixes"], spec["edits"])
    if not updates:
        raise SystemExit("asar: 没有任何 chunk 被改写（锚点表为空？）")

    pre_broken = broken_members(asar)
    data = repack(asar, updates)
    with open(path, "wb") as handle:
        handle.write(data)
    checked, tolerated = verify(path, tolerate=pre_broken)
    for member in tolerated:
        print(f"asar-guix-paths: 注意 {member} 的 integrity 上游本来就不符，"
              "未改动、原样保留")
    print(f"asar-guix-paths: {app_id} 重打包完成，"
          f"asar integrity 校验通过（{checked} 个成员）")


if __name__ == "__main__":
    main()
