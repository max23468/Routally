#!/usr/bin/env node
// Verifica che gli asset di revisione versionati coincidano con il builder deterministico
// senza lasciare modifiche nel working tree.

import {
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { buildIconReviewAssets } from "./build-icon-review-assets.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ICON_DIR = join(ROOT, "docs", "DESIGN", "icon");
const DIRECTORIES = ["composer-layers", "experiments", "evidence"];

function snapshot() {
  const files = new Map();
  for (const directory of DIRECTORIES) {
    const path = join(ICON_DIR, directory);
    for (const name of readdirSync(path)) {
      if (!name.endsWith(".svg")) continue;
      const file = join(path, name);
      files.set(relative(ICON_DIR, file), readFileSync(file, "utf8"));
    }
  }
  return files;
}

function restore(files) {
  for (const directory of DIRECTORIES) {
    rmSync(join(ICON_DIR, directory), { recursive: true, force: true });
    mkdirSync(join(ICON_DIR, directory), { recursive: true });
  }
  for (const [name, body] of files) writeFileSync(join(ICON_DIR, name), body, "utf8");
}

const versioned = snapshot();
let generated;
try {
  buildIconReviewAssets();
  generated = snapshot();
} finally {
  restore(versioned);
}

const missing = [...generated.keys()].filter((name) => !versioned.has(name));
const extra = [...versioned.keys()].filter((name) => !generated.has(name));
const different = [...generated.entries()]
  .filter(([name, body]) => versioned.has(name) && versioned.get(name) !== body)
  .map(([name]) => name);

const problems = [
  ["mancanti", missing],
  ["non prodotti", extra],
  ["diversi dal builder", different],
].filter(([, list]) => list.length > 0);

if (problems.length === 0) {
  console.log(`Asset di revisione allineati al builder: ${generated.size} file.`);
  process.exit(0);
}

for (const [label, list] of problems) console.error(`File ${label}: ${list.join(", ")}`);
console.error("Rigenera con: node scripts/build-icon-review-assets.mjs");
process.exit(1);
