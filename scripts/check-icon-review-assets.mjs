#!/usr/bin/env node
// Verifica che gli asset di revisione versionati coincidano con il builder deterministico
// senza lasciare modifiche nel working tree.

import {
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { basename, dirname, join, relative, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { buildIconReviewAssets } from "./build-icon-review-assets.mjs";
import {
  prepareGeneratedDirectory,
  requireGeneratedDirectory,
} from "./generated-directory-safety.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ICON_DIR = join(ROOT, "docs", "DESIGN", "icon");
const DIRECTORIES = ["composer-layers", "experiments", "evidence"];

export function snapshot(iconDir = ICON_DIR) {
  const files = new Map();
  for (const directory of DIRECTORIES) {
    const path = requireGeneratedDirectory(iconDir, directory);
    for (const name of readdirSync(path)) {
      if (!name.endsWith(".svg")) continue;
      const file = join(path, name);
      files.set(relative(iconDir, file), readFileSync(file, "utf8"));
    }
  }
  return files;
}

export function restore(files, iconDir = ICON_DIR) {
  const safeDirectories = new Map(
    DIRECTORIES.map((directory) => [
      directory,
      prepareGeneratedDirectory(iconDir, directory),
    ]),
  );
  for (const path of safeDirectories.values()) {
    for (const name of readdirSync(path)) {
      if (name.endsWith(".svg")) rmSync(join(path, name), { force: true });
    }
  }
  for (const [name, body] of files) {
    const directory = dirname(name);
    if (!safeDirectories.has(directory) || basename(name) !== name.slice(directory.length + 1)) {
      throw new Error(`Percorso di ripristino non gestito: ${name}`);
    }
    writeFileSync(join(safeDirectories.get(directory), basename(name)), body, "utf8");
  }
}

export function compareIconReviewAssets() {
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

  return [
    ["mancanti", missing],
    ["non prodotti", extra],
    ["diversi dal builder", different],
  ].filter(([, list]) => list.length > 0);
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  const problems = compareIconReviewAssets();
  if (problems.length === 0) {
    console.log("Asset di revisione allineati al builder.");
  } else {
    for (const [label, list] of problems) console.error(`File ${label}: ${list.join(", ")}`);
    console.error("Rigenera con: node scripts/build-icon-review-assets.mjs");
    process.exitCode = 1;
  }
}
