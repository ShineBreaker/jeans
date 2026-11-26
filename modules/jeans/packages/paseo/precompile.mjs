// SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-only
//
// Paseo 构建期内置插件预编译。
//
// Paseo 的 daemon 每次启动都会把内置插件逐个从 TypeScript 编译成 CJS
// bundle，且桌面端要等全部插件就绪（`startPaused` →
// `beginAcceptingConnections`）才允许 WebSocket 连接。插件源码位于 store
// 路径下时，esbuild 的边界校验（`buildContext.resolve`）会为每个 import
// 反复整目录遍历 /gnu/store（十万级条目）：最小插件 2 s、muse-provider
// 30 s，0.16.2 的 14 个插件合计约 74 s，桌面端在这段时间里只显示 Logo
// 启动页。同一棵树放到 store 之外编译则只要 10–300 ms（慢 75 倍）。
//
// 本脚本以 Electron 的 node 模式（自带 asar fs shim）运行，在打包时完成：
//
//   1. 改写 resources/app.asar：`compileDirectoryPlugin()` 对内置插件优先读取
//      `<插件目录>/.paseo-precompiled.json`，版本/id 不匹配时静默回落编译；
//   2. 用 daemon 自己的编译入口把每个内置插件写入该 JSON；
//   3. 再走一遍第 2 步的入口，断言确实命中预编译路径且 bundle 逐字节一致；
//   4. 按 header 里的 SHA256/块哈希校验 asar 全部 payload 文件（改长度会让后续
//      offset 整体位移，integrity 必须同步重算）。
//
// 用法（由包定义在 patchelf 之后调用）：
//   ELECTRON_RUN_AS_NODE=1 Paseo.bin precompile.mjs <app-dir>
// 其中 <app-dir> 是 <out>/lib/paseo（内含 resources/）。

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

const ASAR_FILE =
  "/node_modules/@getpaseo/server/dist/server/server/plugins/compiler-build.js";
const PLUGIN_DIR =
  "node_modules/@getpaseo/server/dist/server/server/plugins";
const PRECOMPILED_FILE = ".paseo-precompiled.json";

const ORIGINAL_TAIL =
  "    const bundles = await compilePlugin(await resolveEntryPaths(directory));\n" +
  "    return { ...bundles, manifest };\n" +
  "}";

const PATCHED_TAIL =
  "    const precompiled = builtinId === undefined\n" +
  "        ? null\n" +
  "        : readPrecompiledBundles(directory, version, builtinId);\n" +
  "    const bundles = precompiled ?? await compilePlugin(await resolveEntryPaths(directory));\n" +
  "    return { ...bundles, manifest };\n" +
  "}\n" +
  "function readPrecompiledBundles(directory, version, builtinId) {\n" +
  "    // Guix: built-in plugins ship precompiled (see .paseo-precompiled.json).\n" +
  "    // Compiling them from a store path makes esbuild's boundary resolve walk\n" +
  "    // /gnu/store once per import, which costs 2-30 s per plugin at startup.\n" +
  "    const file = path.join(directory, " + JSON.stringify(PRECOMPILED_FILE) + ");\n" +
  "    if (!existsSync(file)) {\n" +
  "        return null;\n" +
  "    }\n" +
  "    const built = JSON.parse(readFileSync(file, \"utf8\"));\n" +
  "    if (built.version !== version || built.id !== builtinId\n" +
  "        || typeof built.serverBundle !== \"string\"\n" +
  "        || (built.clientBundle !== null && typeof built.clientBundle !== \"string\")) {\n" +
  "        return null;\n" +
  "    }\n" +
  "    return { clientBundle: built.clientBundle, serverBundle: built.serverBundle };\n" +
  "}";

function fail(message) {
  console.error(`paseo-precompile: ${message}`);
  process.exit(1);
}

function align4(n) {
  return (n + 3) & ~3;
}

// Electron 的 fs shim 会把 *.asar 下的任何路径当成归档成员，读写归档本身必须
// 先关掉 asar 处理（process.noAsar）。
function withoutAsar(fn) {
  const previous = process.noAsar;
  process.noAsar = true;
  try {
    return fn();
  } finally {
    process.noAsar = previous;
  }
}

function walkFiles(node, prefix, out) {
  for (const [name, child] of Object.entries(node.files ?? {})) {
    const entryPath = `${prefix}/${name}`;
    if (child.files) {
      walkFiles(child, entryPath, out);
    } else {
      out.push([entryPath, child]);
    }
  }
  return out;
}

function readAsar(file) {
  const buf = withoutAsar(() => fs.readFileSync(file));
  const jsonLength = buf.readUInt32LE(12);
  const header = JSON.parse(buf.subarray(16, 16 + jsonLength).toString("utf8"));
  // asar 头部是 pickle：[u32 4][u32 headerPickleLen][u32 payloadLen][u32 jsonLen]
  // [json][padding]，payload 从 align4(16 + jsonLen) 开始。
  return { buf, header, jsonLength, base: 16 + align4(jsonLength) };
}

function entryBytes(asar, entry) {
  const start = asar.base + Number(entry.offset);
  return asar.buf.subarray(start, start + Number(entry.size));
}

function payloadEntries(asar) {
  return walkFiles(asar.header, "", [])
    .filter(([, entry]) => entry.offset !== undefined && !entry.unpacked)
    // payload 内文件按 offset 紧凑排列（0 间隙），offset 是相对 payload 起点的
    // 字符串；空文件的 offset 会与相邻文件相同，排序需保持遍历顺序。
    .sort((a, b) => Number(a[1].offset) - Number(b[1].offset));
}

function integrityOf(bytes) {
  const hash = crypto.createHash("sha256").update(bytes).digest("hex");
  const blocks = [];
  for (let i = 0; i < bytes.length; i += 4194304) {
    blocks.push(
      crypto.createHash("sha256").update(bytes.subarray(i, i + 4194304)).digest("hex"));
  }
  // 空成员在 header 里带一个"空块"，不是零块。
  if (blocks.length === 0) blocks.push(hash);
  return { hash, blocks };
}

function findEntry(header, entryPath) {
  let node = header;
  for (const part of entryPath.split("/").filter(Boolean)) {
    node = node.files?.[part];
    if (node === undefined) return null;
  }
  return node;
}

// 就地重打包：UPATES 里命中的成员换内容，随后重排所有 offset、重算改动成员的
// integrity，并按 asar 的 pickle 形状重写 header。
function repackAsar(asar, updates) {
  const chunks = [];
  let offset = 0;
  for (const [entryPath, entry] of payloadEntries(asar)) {
    const bytes = updates.get(entryPath) ?? entryBytes(asar, entry);
    if (updates.has(entryPath)) {
      entry.size = bytes.length;
      if (entry.integrity) {
        const { hash, blocks } = integrityOf(bytes);
        entry.integrity.hash = hash;
        entry.integrity.blocks = blocks;
      }
    }
    entry.offset = String(offset);
    offset += bytes.length;
    chunks.push(bytes);
  }
  const payload = Buffer.concat(chunks);

  const json = Buffer.from(JSON.stringify(asar.header), "utf8");
  const paddedJson = align4(json.length);
  const headerPayload = 4 + paddedJson;
  const headerPickle = 4 + headerPayload;
  const base = 16 + paddedJson;
  const out = Buffer.alloc(base + payload.length);
  out.writeUInt32LE(4, 0);
  out.writeUInt32LE(headerPickle, 4);
  out.writeUInt32LE(headerPayload, 8);
  out.writeUInt32LE(json.length, 12);
  json.copy(out, 16);
  payload.copy(out, base);
  return out;
}

function verifyAsar(file) {
  const asar = readAsar(file);
  let checked = 0;
  for (const [entryPath, entry] of payloadEntries(asar)) {
    if (!entry.integrity) continue;
    const bytes = entryBytes(asar, entry);
    if (bytes.length !== Number(entry.size)) {
      fail(`asar: ${entryPath} size mismatch`);
    }
    const { hash, blocks } = integrityOf(bytes);
    if (hash !== entry.integrity.hash) {
      fail(`asar: ${entryPath} SHA256 mismatch`);
    }
    if (blocks.length !== entry.integrity.blocks.length) {
      fail(`asar: ${entryPath} block count mismatch`);
    }
    for (let i = 0; i < blocks.length; i += 1) {
      if (blocks[i] !== entry.integrity.blocks[i]) {
        fail(`asar: ${entryPath} block ${i} mismatch`);
      }
    }
    checked += 1;
  }
  return checked;
}

function patchAsar(asarPath) {
  const asar = readAsar(asarPath);
  const entry = findEntry(asar.header, ASAR_FILE);
  if (entry === null) {
    fail(`asar: ${ASAR_FILE} not found (上游布局变了？)`);
  }
  const source = entryBytes(asar, entry).toString("utf8");
  if (source.includes(PRECOMPILED_FILE)) {
    console.log("paseo-precompile: app.asar 已打过补丁");
    return;
  }
  const occurrences = source.split(ORIGINAL_TAIL).length - 1;
  if (occurrences !== 1) {
    fail(`asar: compileDirectoryPlugin 锚点命中 ${occurrences} 次（期望 1 次），` +
         "上游代码变了，需重新核对预编译补丁");
  }
  const patched = source.replace(ORIGINAL_TAIL, PATCHED_TAIL);
  const next = repackAsar(asar, new Map([[ASAR_FILE, Buffer.from(patched, "utf8")]]));
  withoutAsar(() => fs.writeFileSync(asarPath, next));
  console.log("paseo-precompile: 已改写 app.asar 的 compileDirectoryPlugin");
}

function parseCheck(name, source) {
  try {
    new vm.Script(source, { filename: name });
  } catch (error) {
    fail(`${name}: bundle 语法不合法：${error.message}`);
  }
}

async function main() {
  const appDir = process.argv[2];
  if (!appDir) fail("用法：precompile.mjs <app-dir>");
  const resources = path.join(appDir, "resources");
  const asarPath = path.join(resources, "app.asar");

  patchAsar(asarPath);
  const checked = verifyAsar(asarPath);
  console.log(`paseo-precompile: asar integrity 校验通过（${checked} 个成员）`);

  const { version } = JSON.parse(
    fs.readFileSync(path.join(asarPath, "package.json"), "utf8"));
  const pluginRoot = path.join(resources, "builtin-plugins");
  const { builtinPlugins } = await import(
    path.join(asarPath, PLUGIN_DIR, "builtin/index.js"));
  const { compileDirectoryPlugin } = await import(
    path.join(asarPath, PLUGIN_DIR, "compiler-build.js"));

  for (const id of builtinPlugins) {
    const directory = path.join(pluginRoot, id);
    const file = path.join(directory, PRECOMPILED_FILE);
    fs.rmSync(file, { force: true });
    const started = Date.now();
    const { clientBundle, serverBundle } =
      await compileDirectoryPlugin(directory, version, id);
    if (typeof serverBundle !== "string" || serverBundle.length === 0) {
      fail(`${id}: server bundle 为空`);
    }
    if (clientBundle !== null && typeof clientBundle !== "string") {
      fail(`${id}: client bundle 类型异常`);
    }
    parseCheck(`${id} server`, serverBundle);
    if (clientBundle) parseCheck(`${id} client`, clientBundle);
    fs.writeFileSync(file, JSON.stringify({
      version,
      id,
      clientBundle: clientBundle ?? null,
      serverBundle,
    }));
    console.log(`paseo-precompile: ${id} 编译耗时 ${Date.now() - started} ms` +
                `（server ${serverBundle.length} B，client ${clientBundle?.length ?? 0} B）`);
  }

  // 再走一遍 daemon 的入口：此时必须命中预编译路径，且返回逐字节一致的 bundle。
  for (const id of builtinPlugins) {
    const directory = path.join(pluginRoot, id);
    const stored = JSON.parse(fs.readFileSync(path.join(directory, PRECOMPILED_FILE), "utf8"));
    const started = Date.now();
    const { clientBundle, serverBundle } =
      await compileDirectoryPlugin(directory, version, id);
    const elapsed = Date.now() - started;
    if (serverBundle !== stored.serverBundle || (clientBundle ?? null) !== stored.clientBundle) {
      fail(`${id}: 未走预编译路径（bundle 不一致）`);
    }
    if (elapsed > 2000) {
      fail(`${id}: 预编译加载耗时 ${elapsed} ms，补丁未生效`);
    }
    console.log(`paseo-precompile: ${id} 预编译加载 ${elapsed} ms`);
  }
  console.log(`paseo-precompile: ${builtinPlugins.length} 个内置插件预编译完成`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
