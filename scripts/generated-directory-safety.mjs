import {
  lstatSync,
  mkdirSync,
  realpathSync,
} from "node:fs";
import {
  isAbsolute,
  relative,
  resolve,
  sep,
} from "node:path";

function lstatIfPresent(path) {
  try {
    return lstatSync(path);
  } catch (error) {
    if (error.code === "ENOENT") return undefined;
    throw error;
  }
}

function assertRealDirectory(path, stat = lstatSync(path)) {
  if (stat.isSymbolicLink()) {
    throw new Error(`Directory generata non sicura: ${path} è un collegamento simbolico`);
  }
  if (!stat.isDirectory()) {
    throw new Error(`Directory generata non sicura: ${path} non è una directory`);
  }
}

function isContained(parent, child) {
  const offset = relative(parent, child);
  return offset === ""
    || (!offset.startsWith(`..${sep}`) && offset !== ".." && !isAbsolute(offset));
}

export function generatedDirectory(root, relativePath = ".", { create = false } = {}) {
  const rootPath = resolve(root);
  const requestedPath = resolve(rootPath, relativePath);
  if (!isContained(rootPath, requestedPath)) {
    throw new Error(`Directory generata fuori dalla root autorizzata: ${relativePath}`);
  }

  const rootStat = lstatIfPresent(rootPath);
  if (!rootStat) {
    if (!create) throw new Error(`Directory generata mancante: ${rootPath}`);
    mkdirSync(rootPath, { recursive: true });
  }
  assertRealDirectory(rootPath, rootStat);
  const realRoot = realpathSync(rootPath);

  const offset = relative(rootPath, requestedPath);
  let current = rootPath;
  for (const component of offset ? offset.split(sep) : []) {
    current = resolve(current, component);
    const stat = lstatIfPresent(current);
    if (!stat) {
      if (!create) throw new Error(`Directory generata mancante: ${current}`);
      mkdirSync(current);
    }
    assertRealDirectory(current, stat);
  }

  const realDirectory = realpathSync(requestedPath);
  if (!isContained(realRoot, realDirectory)) {
    throw new Error(`Directory generata fuori dalla root reale autorizzata: ${relativePath}`);
  }
  return realDirectory;
}

export function prepareGeneratedDirectory(root, relativePath = ".") {
  return generatedDirectory(root, relativePath, { create: true });
}

export function requireGeneratedDirectory(root, relativePath = ".") {
  return generatedDirectory(root, relativePath);
}
