#!/usr/bin/env node

import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const colorsDirectory = join(
  root,
  "Packages",
  "RoutallyModules",
  "Sources",
  "RoutallyDesign",
  "Resources",
  "Colors.xcassets",
);
const accentNames = [
  "accentOcean",
  "accentTeal",
  "accentAmber",
  "accentCoral",
  "accentViolet",
];

function appearanceKey(entry) {
  return (entry.appearances ?? [])
    .map(({ appearance, value }) => `${appearance}:${value}`)
    .sort()
    .join("+");
}

function components(entry) {
  return JSON.stringify(entry.color.components);
}

for (const accentName of accentNames) {
  const path = join(colorsDirectory, `${accentName}.colorset`, "Contents.json");
  const asset = JSON.parse(readFileSync(path, "utf8"));
  const variants = new Map(asset.colors.map((entry) => [appearanceKey(entry), entry]));
  const light = variants.get("");
  const dark = variants.get("luminosity:dark");
  const highContrastLight = variants.get("contrast:high");
  const highContrastDark = variants.get("contrast:high+luminosity:dark");

  if (!light || !dark || !highContrastLight || !highContrastDark) {
    throw new Error(`${accentName}: matrice Light/Dark + Increase Contrast incompleta`);
  }
  if (components(light) !== components(highContrastLight)) {
    throw new Error(`${accentName}: Increase Contrast Light diverge dalla coppia confermata`);
  }
  if (components(dark) !== components(highContrastDark)) {
    throw new Error(`${accentName}: Increase Contrast Dark diverge dalla coppia confermata`);
  }
}

console.log(`Asset UI Foundation validati: ${accentNames.length} accenti completi.`);
