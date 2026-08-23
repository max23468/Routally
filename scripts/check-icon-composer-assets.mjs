#!/usr/bin/env node
// Verifica i pacchetti Icon Composer e il loro collegamento ai target Xcode.

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const root = new URL("../", import.meta.url).pathname;
const projectPath = join(root, "Routally.xcodeproj/project.pbxproj");
const project = readFileSync(projectPath, "utf8");

const darkColors = {
  "01 Background": "extended-srgb:0.07059,0.07451,0.16471,1.00000",
  "02 Symbol": "extended-srgb:0.95686,0.96078,1.00000,1.00000",
  "03 Accent": "extended-srgb:0.59608,0.58431,1.00000,1.00000",
  "04 Dev Overlay": "extended-srgb:0.42353,0.40784,0.78039,1.00000",
};

const problems = [];

function check(condition, message) {
  if (!condition) problems.push(message);
}

function inspectIcon(directory, expectedLayers) {
  const iconPath = join(root, "RoutallyApp", directory);
  const manifestPath = join(iconPath, "icon.json");
  check(existsSync(manifestPath), `${directory}: icon.json mancante`);
  if (!existsSync(manifestPath)) return;

  const icon = JSON.parse(readFileSync(manifestPath, "utf8"));
  check(
    JSON.stringify(icon["supported-platforms"]?.squares) === JSON.stringify(["iOS"]),
    `${directory}: deve supportare soltanto iOS`,
  );
  check(icon.groups?.length === 1, `${directory}: atteso un solo gruppo Liquid Glass`);

  const group = icon.groups?.[0];
  check(group?.translucency?.enabled === true, `${directory}: translucenza disattivata`);
  check(group?.translucency?.value === 0.5, `${directory}: translucenza diversa dal 50%`);
  check(group?.shadow?.kind === "neutral", `${directory}: ombra non neutra`);
  check(group?.shadow?.opacity === 0.5, `${directory}: ombra diversa dal 50%`);

  const layers = new Map((group?.layers ?? []).map((layer) => [layer.name, layer]));
  check(
    JSON.stringify([...layers.keys()].sort()) === JSON.stringify([...expectedLayers].sort()),
    `${directory}: livelli inattesi (${[...layers.keys()].join(", ")})`,
  );

  for (const [name, layer] of layers) {
    check(
      existsSync(join(iconPath, "Assets", layer["image-name"])),
      `${directory}: asset mancante per ${name}`,
    );
    const dark = layer["fill-specializations"]?.find(
      (specialization) => specialization.appearance === "dark",
    );
    check(dark?.value?.solid === darkColors[name], `${directory}: colore Dark errato per ${name}`);
  }
}

inspectIcon("AppIcon.icon", ["01 Background", "02 Symbol", "03 Accent"]);
inspectIcon("AppIconDev.icon", [
  "01 Background",
  "02 Symbol",
  "03 Accent",
  "04 Dev Overlay",
]);

const devResources = project.match(
  /P30000000000000000000011 \/\* Resources \*\/ = \{[\s\S]*?\n\t\t\};/,
)?.[0];
const publicResources = project.match(
  /P30000000000000000000021 \/\* Resources \*\/ = \{[\s\S]*?\n\t\t\};/,
)?.[0];

check(devResources?.includes("AppIconDev.icon in Resources"), "target Dev: AppIconDev non collegata");
check(!devResources?.includes("AppIcon.icon in Resources"), "target Dev: icona pubblica collegata");
check(publicResources?.includes("AppIcon.icon in Resources"), "target pubblico: AppIcon non collegata");
check(
  !publicResources?.includes("AppIconDev.icon in Resources"),
  "target pubblico: icona Dev collegata",
);
check(
  (project.match(/ASSETCATALOG_COMPILER_APPICON_NAME = AppIconDev;/g) ?? []).length === 3,
  "target Dev: nome icona non configurato in tutte le build configuration",
);
check(
  (project.match(/ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;/g) ?? []).length === 3,
  "target pubblico: nome icona non configurato in tutte le build configuration",
);

if (problems.length > 0) {
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}

console.log("Pacchetti Icon Composer e target Xcode allineati.");
