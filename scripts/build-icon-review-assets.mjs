#!/usr/bin/env node
// Genera gli asset di confronto per DG-ICON senza modificare gli SVG canonici della PR #18.
// Gli output restano SVG nativi e deterministici: livelli autonomi per Icon Composer,
// microvarianti A1 e tavole di evidenza vettoriali.

import {
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { prepareGeneratedDirectory } from "./generated-directory-safety.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ICON_DIR = join(ROOT, "docs", "DESIGN", "icon");
const COMPOSER_DIR = join(ICON_DIR, "composer-layers");
const EXPERIMENT_DIR = join(ICON_DIR, "experiments");
const EVIDENCE_DIR = join(ICON_DIR, "evidence");

const THEMES = ["indigo", "light"];
const VARIANTS = [
  { slug: "a1-air-medium", label: "A1 · aria misurata", groups: ["background", "symbol", "accent"] },
  { slug: "a2-air-wide", label: "A2 · aria decisa", groups: ["background", "symbol", "accent"] },
  { slug: "a3-air-wide-short", label: "A3 · arco corto", groups: ["background", "symbol", "accent"] },
  { slug: "t1-cycle-consequence", label: "T1 · silhouette essenziale", groups: ["background", "symbol"] },
  { slug: "t2-cycle-threshold", label: "T2 · soglia", groups: ["background", "symbol"] },
  { slug: "v1-nested-cycle", label: "V1 · ciclo incastrato", groups: ["background", "symbol", "accent"] },
  { slug: "v2-nested-cycle-threshold", label: "V2 · incastro e soglia", groups: ["background", "symbol", "accent"] },
  { slug: "v3-nested-cycle-opening", label: "V3 · incastro aperto", groups: ["background", "symbol", "accent"] },
  { slug: "dev-app-icon", label: "Dev · fascia diagonale", groups: ["background", "symbol", "accent", "overlay"] },
];

const round4 = (value) => Math.round(value * 10000) / 10000;
const format = (value) => String(round4(value));

function clearGeneratedDirectory(path) {
  for (const name of readdirSync(path)) {
    if (name.endsWith(".svg")) rmSync(join(path, name), { force: true });
  }
}

function readIcon(slug, theme, directory = ICON_DIR) {
  return readFileSync(join(directory, `${slug}-${theme}.svg`), "utf8");
}

function extractGroup(svg, id) {
  const match = svg.match(new RegExp(`<g id="${id}"([^>]*)>([\\s\\S]*?)</g>`));
  if (!match) throw new Error(`gruppo ${id} non trovato`);
  return { attributes: match[1], body: match[2].trim() };
}

function parseTransform(attributes) {
  const match = attributes.match(
    /transform="translate\(([-\d.]+)(?:[, ]+)([-\d.]+)\)\s+scale\(([-\d.]+)\)"/,
  );
  if (!match) return { tx: 0, ty: 0, scale: 1 };
  return { tx: Number(match[1]), ty: Number(match[2]), scale: Number(match[3]) };
}

function flattenPath(path, tx, ty, scale) {
  const tokens = path.match(/[MLAZ]|-?[\d.]+/g) ?? [];
  const out = [];
  const point = (x, y) => [round4(x * scale + tx), round4(y * scale + ty)];
  let index = 0;

  while (index < tokens.length) {
    const command = tokens[index++];
    if (command === "M" || command === "L") {
      const [x, y] = point(Number(tokens[index]), Number(tokens[index + 1]));
      index += 2;
      out.push(`${command} ${x} ${y}`);
    } else if (command === "A") {
      const rx = Number(tokens[index]);
      const ry = Number(tokens[index + 1]);
      const rotation = tokens[index + 2];
      const largeArc = tokens[index + 3];
      const sweep = tokens[index + 4];
      const [x, y] = point(Number(tokens[index + 5]), Number(tokens[index + 6]));
      index += 7;
      out.push(
        `A ${round4(rx * scale)} ${round4(ry * scale)} ${rotation} ${largeArc} ${sweep} ${x} ${y}`,
      );
    } else if (command === "Z") {
      out.push("Z");
    } else {
      throw new Error(`comando SVG non gestito: ${command}`);
    }
  }

  return out.join(" ");
}

function flattenMarkup(markup, tx, ty, scale) {
  const point = (x, y) => [round4(x * scale + tx), round4(y * scale + ty)];
  return markup
    .replace(
      /<rect x="([-\d.]+)" y="([-\d.]+)" width="([\d.]+)" height="([\d.]+)"/g,
      (_, x, y, width, height) => {
        const [newX, newY] = point(Number(x), Number(y));
        return `<rect x="${newX}" y="${newY}" width="${round4(Number(width) * scale)}" height="${round4(Number(height) * scale)}"`;
      },
    )
    .replace(
      /<circle cx="([-\d.]+)" cy="([-\d.]+)" r="([\d.]+)"/g,
      (_, cx, cy, radius) => {
        const [newX, newY] = point(Number(cx), Number(cy));
        return `<circle cx="${newX}" cy="${newY}" r="${round4(Number(radius) * scale)}"`;
      },
    )
    .replace(
      /<ellipse cx="([-\d.]+)" cy="([-\d.]+)" rx="([\d.]+)" ry="([\d.]+)"/g,
      (_, cx, cy, rx, ry) => {
        const [newX, newY] = point(Number(cx), Number(cy));
        return `<ellipse cx="${newX}" cy="${newY}" rx="${round4(Number(rx) * scale)}" ry="${round4(Number(ry) * scale)}"`;
      },
    )
    .replace(/stroke-width="([\d.]+)"/g, (_, width) =>
      `stroke-width="${round4(Number(width) * scale)}"`,
    )
    .replace(/ d="([^"]+)"/g, (_, path) =>
      ` d="${flattenPath(path, tx, ty, scale)}"`,
    );
}

function standaloneLayer(slug, theme, groupName, svg) {
  const { attributes, body } = extractGroup(svg, groupName);
  const transform = parseTransform(attributes);
  const cleanAttributes = attributes
    .replace(/\s+transform="[^"]+"/, "")
    .trim();
  const flattened = flattenMarkup(body, transform.tx, transform.ty, transform.scale);
  const attributesText = cleanAttributes ? ` ${cleanAttributes}` : "";
  const title = `${slug} · ${theme} · ${groupName}`;

  return [
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024" role="img" aria-labelledby="title desc">`,
    `  <title id="title">${title}</title>`,
    `  <desc id="desc">Livello SVG autonomo per il confronto in Icon Composer; coordinate già trasformate e nessuna dipendenza esterna.</desc>`,
    `  <g id="${groupName}"${attributesText}>`,
    ...flattened.split("\n").map((line) => `    ${line.trim()}`),
    `  </g>`,
    `</svg>`,
    "",
  ].join("\n");
}

function buildComposerLayers(composerDir) {
  let count = 0;
  for (const variant of VARIANTS) {
    for (const theme of THEMES) {
      const svg = readIcon(variant.slug, theme);
      for (const group of variant.groups) {
        const body = standaloneLayer(variant.slug, theme, group, svg);
        writeFileSync(
          join(composerDir, `${variant.slug}-${theme}-${group}.svg`),
          body,
          "utf8",
        );
        count += 1;
      }
    }
  }
  return count;
}

function updateMetadata(svg, title, note) {
  return svg
    .replace(/<title id="title">[\s\S]*?<\/title>/, `<title id="title">${title}</title>`)
    .replace(/<\/desc>/, ` ${note}</desc>`);
}

function setAccentColor(svg, color) {
  return svg.replace(
    /(<g id="accent"\s+fill=")[^"]+("\s+color=")[^"]+("[^>]*>)/,
    `$1${color}$2${color}$3`,
  );
}

function setHeadRadius(svg, theme, radius) {
  const compensated = theme === "indigo" ? radius * 0.97 : radius;
  return svg.replace(
    /(<g id="accent"[\s\S]*?<circle\s+cx="[^"]+"\s+cy="[^"]+"\s+r=")[^"]+("[^>]*>)/,
    `$1${format(compensated)}$2`,
  );
}

function relativeLuminance(hex) {
  const channels = hex
    .slice(1)
    .match(/.{2}/g)
    .map((value) => Number.parseInt(value, 16) / 255)
    .map((value) => (value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4));
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function grayscaleEquivalent(hex) {
  const linear = relativeLuminance(hex);
  const srgb = linear <= 0.0031308
    ? linear * 12.92
    : 1.055 * linear ** (1 / 2.4) - 0.055;
  const channel = Math.max(0, Math.min(255, Math.round(srgb * 255)));
  const pair = channel.toString(16).padStart(2, "0").toUpperCase();
  return `#${pair}${pair}${pair}`;
}

function makeMonochromeSimulation(svg) {
  const colors = [...new Set(svg.match(/#[0-9A-Fa-f]{6}/g) ?? [])];
  let out = svg;
  for (const color of colors) out = out.replaceAll(color, grayscaleEquivalent(color));
  return updateMetadata(
    out,
    "Routally — simulazione monocromatica a luminanza equivalente",
    "Questa è una simulazione vettoriale di leggibilità: non sostituisce l'aspetto Mono prodotto da Icon Composer.",
  );
}

function buildExperiments(experimentDir) {
  const files = [];
  for (const theme of THEMES) {
    const base = readIcon("a1-air-medium", theme);
    const amber = theme === "indigo" ? "#FFBF66" : "#9A5B00";

    files.push([
      `a1-air-medium-head54-${theme}.svg`,
      updateMetadata(
        setHeadRadius(base, theme, 54),
        "Routally — A1 archiviata con testa da 54",
        "Confronto storico archiviato: testa terminale da 54 unità; la baseline canonica usa 50.",
      ),
    ]);
    files.push([
      `a1-air-medium-amber-${theme}.svg`,
      updateMetadata(
        setAccentColor(base, amber),
        "Routally — A1 con accento Amber",
        "Controllo cromatico per il test cieco: geometria canonica con testa da 50 e token Amber approvati.",
      ),
    ]);
  }

  files.push([
    "a1-air-medium-monochrome-simulation.svg",
    makeMonochromeSimulation(readIcon("a1-air-medium", "indigo")),
  ]);

  for (const [name, body] of files) writeFileSync(join(experimentDir, name), body, "utf8");
  return files.length;
}

function svgInner(svg) {
  const match = svg.match(/<svg[^>]*>([\s\S]*?)<\/svg>/);
  if (!match) throw new Error("SVG esterno non trovato");
  return match[1]
    .replace(/\s*<title[\s\S]*?<\/title>\s*/g, "\n")
    .replace(/\s*<desc[\s\S]*?<\/desc>\s*/g, "\n")
    .replace(/\s+aria-labelledby="[^"]*"/g, "")
    .replace(/\s+role="img"/g, "")
    .replace(/\s+id="[^"]*"/g, "");
}

let clipCounter = 0;
function iconCell(svg, x, y, size, label = null) {
  clipCounter += 1;
  const clip = `icon-clip-${clipCounter}`;
  const radius = size * 0.225;
  return [
    `<defs><clipPath id="${clip}"><rect x="${x}" y="${y}" width="${size}" height="${size}" rx="${radius}"/></clipPath></defs>`,
    `<g clip-path="url(#${clip})">`,
    `<svg x="${x}" y="${y}" width="${size}" height="${size}" viewBox="0 0 1024 1024">`,
    svgInner(svg),
    `</svg>`,
    `</g>`,
    label
      ? `<text x="${x + size / 2}" y="${y + size + 24}" text-anchor="middle" class="caption">${label}</text>`
      : "",
  ].join("\n");
}

const BOARD_STYLE = `
  .title { font: 700 32px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #17171A; }
  .subtitle { font: 400 17px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #56565C; }
  .label { font: 600 18px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #17171A; }
  .caption { font: 500 14px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #56565C; }
  .note { font: 400 15px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #56565C; }
  .panel { fill: #F4F4F7; stroke: #D8D8DE; stroke-width: 1; }
  .separator { stroke: #D8D8DE; stroke-width: 1; }
`;

function board(width, height, title, subtitle, content) {
  return [
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}" role="img" aria-labelledby="title desc">`,
    `<title id="title">${title}</title>`,
    `<desc id="desc">${subtitle}</desc>`,
    `<style>${BOARD_STYLE}</style>`,
    `<rect width="${width}" height="${height}" fill="#FFFFFF"/>`,
    `<text x="48" y="54" class="title">${title}</text>`,
    `<text x="48" y="84" class="subtitle">${subtitle}</text>`,
    content,
    `</svg>`,
    "",
  ].join("\n");
}

function buildCandidateComparison() {
  const sizes = [180, 120, 60, 40, 29];
  const xCenters = [420, 660, 860, 1040, 1200];
  const rows = [
    ["a1-air-medium", "A1 · baseline canonica Lavender 50"],
    ["t1-cycle-consequence", "T1 · fallback globale"],
    ["a3-air-wide-short", "A3 · alternativa archiviata"],
  ];
  const content = [];

  rows.forEach(([slug, label], row) => {
    const yTop = 130 + row * 210;
    content.push(`<text x="48" y="${yTop + 92}" class="label">${label}</text>`);
    const source = readIcon(slug, "indigo");
    sizes.forEach((size, index) => {
      content.push(
        iconCell(source, xCenters[index] - size / 2, yTop + (180 - size) / 2, size, `${size} pt`),
      );
    });
    if (row < rows.length - 1) {
      content.push(`<line x1="48" y1="${yTop + 194}" x2="1320" y2="${yTop + 194}" class="separator"/>`);
    }
  });

  return board(
    1380,
    790,
    "DG-ICON · confronto dimensionale",
    "Baseline canonica A1 Lavender 50, fallback T1 e alternativa A3 archiviata; 29 e 40 pt richiedono ancora la prova Apple.",
    content.join("\n"),
  );
}

function buildRefinementMatrix(experimentDir) {
  const variants = [
    [readIcon("a1-air-medium", "indigo"), "50 · Lavender · baseline"],
    [readFileSync(join(experimentDir, "a1-air-medium-amber-indigo.svg"), "utf8"), "50 · Amber · controllo"],
    [readFileSync(join(experimentDir, "a1-air-medium-head54-indigo.svg"), "utf8"), "54 · Lavender · archivio"],
  ];
  const content = [];
  variants.forEach(([source, label], index) => {
    const x = 80 + index * 410;
    content.push(`<rect x="${x}" y="130" width="350" height="470" rx="28" class="panel"/>`);
    content.push(`<text x="${x + 175}" y="170" text-anchor="middle" class="label">${label}</text>`);
    content.push(iconCell(source, x + 65, 200, 220));
    content.push(iconCell(source, x + 95, 460, 40, "40 pt"));
    content.push(iconCell(source, x + 230, 465.5, 29, "29 pt"));
  });
  content.push(`<text x="80" y="650" class="note">La decisione preliminare è chiusa: Lavender 50 è canonica; Amber 50 resta controllo, 54 è conservata soltanto come storico.</text>`);
  return board(
    1320,
    710,
    "A1 · baseline e controlli residui",
    "Confronto finale predisposto per Icon Composer e user test senza riaprire le alternative già archiviate.",
    content.join("\n"),
  );
}

function buildAppearanceReadiness(experimentDir) {
  const sources = [
    [readIcon("a1-air-medium", "indigo"), "Default · fondo indaco"],
    [readIcon("a1-air-medium", "light"), "Trattamento chiaro"],
    [readFileSync(join(experimentDir, "a1-air-medium-monochrome-simulation.svg"), "utf8"), "Mono · simulazione luminanza"],
  ];
  const content = [];
  sources.forEach(([source, label], index) => {
    const x = 80 + index * 300;
    content.push(`<rect x="${x}" y="140" width="250" height="330" rx="28" class="panel"/>`);
    content.push(iconCell(source, x + 35, 180, 180));
    content.push(`<text x="${x + 125}" y="410" text-anchor="middle" class="label">${label}</text>`);
  });
  content.push(`<rect x="980" y="140" width="250" height="330" rx="28" class="panel"/>`);
  content.push(`<text x="1105" y="255" text-anchor="middle" class="label">Dark</text>`);
  content.push(`<text x="1105" y="295" text-anchor="middle" class="note">Da produrre e verificare</text>`);
  content.push(`<text x="1105" y="320" text-anchor="middle" class="note">in Icon Composer</text>`);
  content.push(`<text x="80" y="535" class="note">Le prime tre colonne sono prove SVG piatte. Nessuna equivale al materiale, alla rifrazione o alle specializzazioni di Icon Composer.</text>`);
  return board(
    1320,
    590,
    "A1 · prontezza degli aspetti",
    "Le simulazioni servono a individuare rischi; Default, Dark e Mono definitivi richiedono Icon Composer.",
    content.join("\n"),
  );
}

function genericIcon(x, y, size, variant) {
  const fills = ["#D9D9DE", "#E6E6EA", "#CFCFD5", "#EDEDF0"];
  const fill = fills[variant % fills.length];
  const radius = size * 0.225;
  return [
    `<rect x="${x}" y="${y}" width="${size}" height="${size}" rx="${radius}" fill="${fill}"/>`,
    `<circle cx="${x + size / 2}" cy="${y + size / 2}" r="${size * 0.18}" fill="#FFFFFF" opacity="0.82"/>`,
  ].join("\n");
}

function buildContextSimulation() {
  const content = [];
  content.push(`<rect x="48" y="130" width="720" height="650" rx="48" fill="#F2F2F7" stroke="#D8D8DE"/>`);
  content.push(`<text x="80" y="175" class="label">Home Screen · simulazione vettoriale</text>`);
  const source = readIcon("a1-air-medium", "indigo");
  const startX = 95;
  const startY = 210;
  const size = 88;
  const gapX = 42;
  const gapY = 48;
  let counter = 0;
  for (let row = 0; row < 4; row += 1) {
    for (let col = 0; col < 5; col += 1) {
      const x = startX + col * (size + gapX);
      const y = startY + row * (size + gapY);
      if (row === 1 && col === 2) content.push(iconCell(source, x, y, size));
      else content.push(genericIcon(x, y, size, counter));
      counter += 1;
    }
  }

  content.push(`<rect x="820" y="130" width="510" height="280" rx="32" class="panel"/>`);
  content.push(`<text x="855" y="175" class="label">Notifica · scala simulata</text>`);
  content.push(iconCell(source, 860, 215, 60));
  content.push(`<rect x="945" y="215" width="320" height="18" rx="9" fill="#CFCFD5"/>`);
  content.push(`<rect x="945" y="250" width="250" height="14" rx="7" fill="#DEDEE3"/>`);
  content.push(`<rect x="945" y="280" width="290" height="14" rx="7" fill="#DEDEE3"/>`);

  content.push(`<rect x="820" y="450" width="510" height="330" rx="32" class="panel"/>`);
  content.push(`<text x="855" y="495" class="label">Impostazioni / elenco</text>`);
  [60, 40, 29].forEach((iconSize, index) => {
    const y = 535 + index * 78;
    content.push(iconCell(source, 860 + (60 - iconSize) / 2, y + (60 - iconSize) / 2, iconSize));
    content.push(`<rect x="950" y="${y + 12}" width="250" height="16" rx="8" fill="#CFCFD5"/>`);
    content.push(`<rect x="950" y="${y + 40}" width="170" height="12" rx="6" fill="#DEDEE3"/>`);
  });
  content.push(`<text x="48" y="840" class="note">Questa tavola non sostituisce screenshot del simulatore o di un dispositivo reale.</text>`);

  return board(
    1380,
    890,
    "A1 · simulazioni di contesto",
    "Controllo vettoriale preliminare della riconoscibilità fra riempitivi neutri e in contesti compatti.",
    content.join("\n"),
  );
}

function buildDevComparison() {
  const publicIcon = readIcon("a1-air-medium", "indigo");
  const devIcon = readIcon("dev-app-icon", "indigo");
  const sizes = [180, 60, 40, 29];
  const content = [];
  [[publicIcon, "Pubblica"], [devIcon, "Dev"]].forEach(([source, label], row) => {
    const y = 145 + row * 230;
    content.push(`<text x="60" y="${y + 95}" class="label">${label}</text>`);
    let x = 250;
    for (const size of sizes) {
      content.push(iconCell(source, x, y + (180 - size) / 2, size, `${size} pt`));
      x += size + 95;
    }
  });
  return board(
    1100,
    650,
    "Icona pubblica e build Dev",
    "La fascia Dev deve restare distinguibile senza compromettere il segno alle misure compatte.",
    content.join("\n"),
  );
}

function buildEvidence(evidenceDir, experimentDir) {
  const outputs = new Map([
    ["candidate-comparison.svg", buildCandidateComparison()],
    ["refinement-matrix.svg", buildRefinementMatrix(experimentDir)],
    ["appearance-readiness.svg", buildAppearanceReadiness(experimentDir)],
    ["context-simulation.svg", buildContextSimulation()],
    ["dev-comparison.svg", buildDevComparison()],
  ]);
  for (const [name, body] of outputs) writeFileSync(join(evidenceDir, name), body, "utf8");
  return outputs.size;
}

export function buildIconReviewAssets() {
  const composerDir = prepareGeneratedDirectory(ROOT, relative(ROOT, COMPOSER_DIR));
  const experimentDir = prepareGeneratedDirectory(ROOT, relative(ROOT, EXPERIMENT_DIR));
  const evidenceDir = prepareGeneratedDirectory(ROOT, relative(ROOT, EVIDENCE_DIR));
  for (const path of [composerDir, experimentDir, evidenceDir]) clearGeneratedDirectory(path);
  const layers = buildComposerLayers(composerDir);
  const experiments = buildExperiments(experimentDir);
  const evidence = buildEvidence(evidenceDir, experimentDir);
  return { layers, experiments, evidence };
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) {
  const result = buildIconReviewAssets();
  const generated = readdirSync(COMPOSER_DIR).length
    + readdirSync(EXPERIMENT_DIR).length
    + readdirSync(EVIDENCE_DIR).length;
  console.log(
    `Asset di revisione generati: ${result.layers} livelli, ${result.experiments} esperimenti, ${result.evidence} tavole (${generated} file).`,
  );
}
