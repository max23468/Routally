#!/usr/bin/env node

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function patch(path, transform) {
  const fullPath = join(root, path);
  const before = readFileSync(fullPath, "utf8");
  const after = transform(before);
  writeFileSync(fullPath, after, "utf8");
}

patch("docs/MASTER_PLAN.md", (text) =>
  text.replace("del `decision-record.md`", "del `DESIGN/icon/decision-record.md`"),
);

for (const path of [
  "docs/DESIGN/icon/README.md",
  "docs/DESIGN/icon/validation-plan.md",
]) {
  patch(path, (text) => text.replace(
    "node scripts/build-icon-review-assets.mjs\nnode scripts/validate-icon-assets.mjs",
    "node scripts/build-icon-review-assets.mjs\nnode scripts/check-icon-review-assets.mjs\nnode scripts/validate-icon-assets.mjs",
  ));
}

patch("docs/DESIGN/icon/decision-record.md", (text) => text.replace(
  "| Invarianti geometriche indipendenti | Da eseguire sul commit finale | `scripts/validate-icon-assets.mjs` |",
  "| Asset di revisione allineati al builder | Da eseguire sul commit finale | `scripts/check-icon-review-assets.mjs` |\n| Invarianti geometriche indipendenti | Da eseguire sul commit finale | `scripts/validate-icon-assets.mjs` |",
));

console.log("Riferimenti e comandi della documentazione corretti.");
