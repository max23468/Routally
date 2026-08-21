#!/usr/bin/env node
// Verifica che gli SVG versionati in docs/DESIGN/icon coincidano con la sorgente
// parametrica di scripts/build-icon-assets.mjs.
//
//   node scripts/check-icon-assets.mjs
//
// Fallisce se un file e' stato ritoccato a mano, se ne manca uno o se ne avanza uno non
// piu' prodotto dalla sorgente. Serve a impedire che il segno e la sua sorgente divergano:
// una correzione manuale su un file solo disallinea i due trattamenti cromatici, i livelli
// separati e la derivata Dev.
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { DEFAULT_OUTPUT, iconAssets } from "./build-icon-assets.mjs";

const outDir = process.argv[2] ?? DEFAULT_OUTPUT;
const expected = iconAssets();

const onDisk = new Set();
for (const dir of [outDir, join(outDir, "layers")]) {
  if (!existsSync(dir)) continue;
  const prefix = dir === outDir ? "" : "layers";
  for (const f of readdirSync(dir)) if (f.endsWith(".svg")) onDisk.add(join(prefix, f));
}

const missing = [...expected.keys()].filter((name) => !onDisk.has(name));
const extra = [...onDisk].filter((name) => !expected.has(name));
const different = [...expected.entries()]
  .filter(([name, body]) => onDisk.has(name) && readFileSync(join(outDir, name), "utf8") !== body)
  .map(([name]) => name);

const problems = [
  ["mancanti", missing],
  ["non piu' prodotti dalla sorgente", extra],
  ["diversi dalla sorgente", different],
].filter(([, list]) => list.length > 0);

if (problems.length === 0) {
  console.log(`Asset dell'icona allineati alla sorgente: ${expected.size} file.`);
  process.exit(0);
}

for (const [label, list] of problems) {
  console.error(`File ${label}: ${list.join(", ")}`);
}
console.error("Rigenera con: node scripts/build-icon-assets.mjs");
process.exit(1);
