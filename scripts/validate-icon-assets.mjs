#!/usr/bin/env node
// Validazione indipendente degli asset dell'icona Routally.
// Non importa la sorgente parametrica: legge i file versionati, ricostruisce la geometria
// osservabile e verifica invarianti, contrasti, livelli autonomi ed evidenze SVG.

import {
  existsSync,
  readFileSync,
  readdirSync,
  statSync,
} from "node:fs";
import { dirname, extname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ICON_DIR = join(ROOT, "docs", "DESIGN", "icon");
const COMPOSER_DIR = join(ICON_DIR, "composer-layers");
const EXPERIMENT_DIR = join(ICON_DIR, "experiments");
const EVIDENCE_DIR = join(ICON_DIR, "evidence");

const THEMES = ["indigo", "light"];
const VARIANTS = [
  { slug: "a1-air-medium", groups: ["background", "symbol", "accent"] },
  { slug: "a2-air-wide", groups: ["background", "symbol", "accent"] },
  { slug: "a3-air-wide-short", groups: ["background", "symbol", "accent"] },
  { slug: "t1-cycle-consequence", groups: ["background", "symbol"] },
  { slug: "t2-cycle-threshold", groups: ["background", "symbol"] },
  { slug: "v1-nested-cycle", groups: ["background", "symbol", "accent"] },
  { slug: "v2-nested-cycle-threshold", groups: ["background", "symbol", "accent"] },
  { slug: "v3-nested-cycle-opening", groups: ["background", "symbol", "accent"] },
  { slug: "dev-app-icon", groups: ["background", "symbol", "accent", "overlay"] },
];

const CANONICAL_COLORS = new Set(["#FFFFFF", "#4C46D8", "#CAC7FF", "#3429BD"]);
const AMBER_COLORS = new Set(["#FFBF66", "#9A5B00"]);
const failures = [];
const checks = [];

function check(condition, message) {
  if (!condition) failures.push(message);
  else checks.push(message);
}

function near(actual, expected, tolerance, message) {
  check(
    Number.isFinite(actual) && Math.abs(actual - expected) <= tolerance,
    `${message}: atteso ${expected} ± ${tolerance}, ottenuto ${actual}`,
  );
}

function read(path) {
  return readFileSync(path, "utf8");
}

function readIcon(slug, theme, directory = ICON_DIR) {
  return read(join(directory, `${slug}-${theme}.svg`));
}

function extractGroup(svg, id) {
  const match = svg.match(new RegExp(`<g id="${id}"([^>]*)>([\\s\\S]*?)</g>`));
  if (!match) throw new Error(`gruppo ${id} non trovato`);
  return { attributes: match[1], body: match[2] };
}

function parseTransform(attributes) {
  const match = attributes.match(
    /transform="translate\(([-\d.]+)(?:[, ]+)([-\d.]+)\)\s+scale\(([-\d.]+)\)"/,
  );
  return match
    ? { tx: Number(match[1]), ty: Number(match[2]), scale: Number(match[3]) }
    : { tx: 0, ty: 0, scale: 1 };
}

function pathElements(markup) {
  return [...markup.matchAll(/<path\b([^>]*)\bd="([^"]+)"([^>]*)\/?>(?:<\/path>)?/g)]
    .map((match) => ({ attributes: `${match[1]} ${match[3]}`, d: match[2] }));
}

function rectElements(markup) {
  return [...markup.matchAll(/<rect\b[^>]*x="([-\d.]+)"[^>]*y="([-\d.]+)"[^>]*width="([\d.]+)"[^>]*height="([\d.]+)"[^>]*\/?>(?:<\/rect>)?/g)]
    .map((match) => ({
      x: Number(match[1]),
      y: Number(match[2]),
      width: Number(match[3]),
      height: Number(match[4]),
    }));
}

function circleElements(markup) {
  return [...markup.matchAll(/<circle\b[^>]*cx="([-\d.]+)"[^>]*cy="([-\d.]+)"[^>]*r="([\d.]+)"[^>]*\/?>(?:<\/circle>)?/g)]
    .map((match) => ({ cx: Number(match[1]), cy: Number(match[2]), r: Number(match[3]) }));
}

function numbers(path) {
  return path.match(/-?[\d.]+/g)?.map(Number) ?? [];
}

function parseClosedCycle(path) {
  const tokens = path.match(/[MLAZ]|-?[\d.]+/g) ?? [];
  if (tokens.length < 40 || tokens[0] !== "M" || tokens[20] !== "M") {
    throw new Error("path del ciclo chiuso non riconosciuto");
  }
  const right = Number(tokens[1]);
  const cy = Number(tokens[2]);
  const rx = Number(tokens[4]);
  const ry = Number(tokens[5]);
  const left = Number(tokens[9]);
  const innerRight = Number(tokens[21]);
  const innerCy = Number(tokens[22]);
  const riX = Number(tokens[24]);
  const riY = Number(tokens[25]);
  const innerLeft = Number(tokens[29]);
  return {
    cx: (right + left) / 2,
    cy,
    rx,
    ry,
    riX,
    riY,
    innerCx: (innerRight + innerLeft) / 2,
    innerCy,
  };
}

function parseOpenCycle(path, center) {
  const values = numbers(path);
  if (values.length < 18) throw new Error("path del ciclo aperto non riconosciuto");
  const start = { x: values[0], y: values[1] };
  const rx = values[2];
  const ry = values[3];
  const end = { x: values[7], y: values[8] };
  const ri = values[11];
  return { start, end, rx, ry, ri, center };
}

function parsePolygon(path) {
  const values = numbers(path);
  const points = [];
  for (let index = 0; index + 1 < values.length; index += 2) {
    points.push({ x: values[index], y: values[index + 1] });
  }
  return points;
}

function normalizeAngle(degrees) {
  return ((degrees % 360) + 360) % 360;
}

function angle(center, point) {
  return normalizeAngle(Math.atan2(point.y - center.y, point.x - center.x) * 180 / Math.PI);
}

function smallArc(a, b) {
  let delta = normalizeAngle(b - a);
  if (delta > 180) delta -= 360;
  return { width: Math.abs(delta), center: normalizeAngle(a + delta / 2) };
}

function parseColor(attributes, name) {
  const match = attributes.match(new RegExp(`${name}="(#[0-9A-Fa-f]{6})"`));
  return match?.[1].toUpperCase() ?? null;
}

function luminance(hex) {
  const channels = hex
    .slice(1)
    .match(/.{2}/g)
    .map((value) => Number.parseInt(value, 16) / 255)
    .map((value) => (value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4));
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function contrast(first, second) {
  const [lighter, darker] = [luminance(first), luminance(second)].sort((a, b) => b - a);
  return (lighter + 0.05) / (darker + 0.05);
}

function applyTransform(point, transform) {
  return {
    x: point.x * transform.scale + transform.tx,
    y: point.y * transform.scale + transform.ty,
  };
}

function boundsOfPoints(points) {
  return {
    x0: Math.min(...points.map((point) => point.x)),
    y0: Math.min(...points.map((point) => point.y)),
    x1: Math.max(...points.map((point) => point.x)),
    y1: Math.max(...points.map((point) => point.y)),
  };
}

function unionBounds(bounds) {
  return {
    x0: Math.min(...bounds.map((box) => box.x0)),
    y0: Math.min(...bounds.map((box) => box.y0)),
    x1: Math.max(...bounds.map((box) => box.x1)),
    y1: Math.max(...bounds.map((box) => box.y1)),
  };
}

function cycleBounds(cycle, transform) {
  const first = applyTransform({ x: cycle.cx - cycle.rx, y: cycle.cy - cycle.ry }, transform);
  const second = applyTransform({ x: cycle.cx + cycle.rx, y: cycle.cy + cycle.ry }, transform);
  return { x0: first.x, y0: first.y, x1: second.x, y1: second.y };
}

function rectBounds(rect, transform) {
  const first = applyTransform({ x: rect.x, y: rect.y }, transform);
  const second = applyTransform({ x: rect.x + rect.width, y: rect.y + rect.height }, transform);
  return { x0: first.x, y0: first.y, x1: second.x, y1: second.y };
}

function polygonBounds(points, transform) {
  return boundsOfPoints(points.map((point) => applyTransform(point, transform)));
}

function verifyCanonicalFiles() {
  const expected = new Set();
  for (const variant of VARIANTS) {
    for (const theme of THEMES) expected.add(`${variant.slug}-${theme}.svg`);
  }
  const actual = new Set(
    readdirSync(ICON_DIR).filter((name) => name.endsWith(".svg")),
  );
  check(expected.size === 18, "la matrice canonica contiene 18 SVG combinati");
  check(
    [...expected].every((name) => actual.has(name)),
    `tutti gli SVG combinati attesi sono presenti`,
  );

  for (const variant of VARIANTS) {
    for (const theme of THEMES) {
      const name = `${variant.slug}-${theme}.svg`;
      const svg = read(join(ICON_DIR, name));
      check(svg.includes('viewBox="0 0 1024 1024"'), `${name}: canvas 1024`);
      check(svg.includes('role="img"'), `${name}: role img`);
      check(svg.includes('aria-labelledby="title desc"'), `${name}: metadati collegati`);
      check(/<title id="title">[^<]+<\/title>/.test(svg), `${name}: title presente`);
      check(/<desc id="desc">[^<]+<\/desc>/.test(svg), `${name}: desc presente`);
      check(!/variante approvata|segno approvato/i.test(svg), `${name}: nessuna approvazione anticipata`);

      const colors = new Set((svg.match(/#[0-9A-Fa-f]{6}/g) ?? []).map((color) => color.toUpperCase()));
      check([...colors].every((color) => CANONICAL_COLORS.has(color)), `${name}: palette canonica`);

      for (const group of variant.groups) {
        check(new RegExp(`<g id="${group}"`).test(svg), `${name}: gruppo ${group}`);
      }

      const background = extractGroup(svg, "background");
      const symbol = extractGroup(svg, "symbol");
      const backgroundColor = parseColor(background.body, "fill");
      const symbolColor = parseColor(symbol.attributes, "fill");
      check(Boolean(backgroundColor && symbolColor), `${name}: colori fondo/simbolo leggibili`);
      if (backgroundColor && symbolColor) {
        check(contrast(backgroundColor, symbolColor) >= 4.5, `${name}: contrasto simbolo ≥ 4,5:1`);
      }
      if (variant.groups.includes("accent")) {
        const accent = extractGroup(svg, "accent");
        const accentColor = parseColor(accent.attributes, "fill");
        check(Boolean(accentColor), `${name}: colore accento leggibile`);
        if (backgroundColor && accentColor) {
          check(contrast(backgroundColor, accentColor) >= 3, `${name}: contrasto accento ≥ 3:1`);
        }
      }
    }
  }
}

function a1Geometry(theme) {
  const svg = readIcon("a1-air-medium", theme);
  const symbol = extractGroup(svg, "symbol");
  const accent = extractGroup(svg, "accent");
  const transform = parseTransform(symbol.attributes);
  const paths = pathElements(symbol.body);
  const cycle = parseClosedCycle(paths.find((path) => /fill-rule="evenodd"/.test(path.attributes)).d);
  const rect = rectElements(symbol.body)[0];
  const leg = parsePolygon(paths.find((path) => !/fill-rule="evenodd"/.test(path.attributes)).d);
  const head = circleElements(accent.body)[0];
  return { svg, symbol, accent, transform, cycle, rect, leg, head };
}

function verifyA1Geometry() {
  const light = a1Geometry("light");
  const indigo = a1Geometry("indigo");

  for (const [theme, geometry] of [["light", light], ["indigo", indigo]]) {
    const { cycle, rect, leg, head, transform, accent } = geometry;
    near(cycle.cx, cycle.innerCx, 0.001, `${theme}: centro orizzontale del contatore`);
    near(cycle.cy, cycle.innerCy, 0.001, `${theme}: centro verticale del contatore`);
    near(cycle.riX, cycle.riY, 0.001, `${theme}: contatore circolare`);
    near(rect.x, cycle.cx - cycle.rx, 0.01, `${theme}: fianco sulla tangente esterna`);
    near(rect.x + rect.width, cycle.cx - cycle.riX, 0.01, `${theme}: fianco sulla tangente interna`);
    near(rect.y, cycle.cy, 0.01, `${theme}: fianco dal centro del ciclo`);
    near(rect.y + rect.height, 848, 0.01, `${theme}: fianco sulla linea di base`);
    check(leg.length === 4, `${theme}: gamba quadrilatera`);
    near(Math.max(...leg.map((point) => point.y)), 848, 0.01, `${theme}: piede della gamba sulla base`);
    near(angle({ x: cycle.cx, y: cycle.cy }, { x: head.cx, y: head.cy }), 330, 0.15, `${theme}: testa a 30° sopra l'orizzontale`);

    const symbolBounds = unionBounds([
      cycleBounds(cycle, transform),
      rectBounds(rect, transform),
      polygonBounds(leg, transform),
    ]);
    const symbolCenter = {
      x: (symbolBounds.x0 + symbolBounds.x1) / 2,
      y: (symbolBounds.y0 + symbolBounds.y1) / 2,
    };
    check(symbolCenter.x >= 512 && symbolCenter.x <= 519, `${theme}: centraggio ottico orizzontale A1`);
    check(symbolCenter.y >= 509 && symbolCenter.y <= 515, `${theme}: centraggio ottico verticale A1`);

    const accentTransform = parseTransform(accent.attributes);
    const accentPoints = [];
    for (const path of pathElements(accent.body)) {
      const values = numbers(path.d);
      for (let index = 0; index + 1 < values.length; index += 2) {
        accentPoints.push(applyTransform({ x: values[index], y: values[index + 1] }, accentTransform));
      }
    }
    accentPoints.push(applyTransform({ x: head.cx - head.r, y: head.cy - head.r }, accentTransform));
    accentPoints.push(applyTransform({ x: head.cx + head.r, y: head.cy + head.r }, accentTransform));
    const total = unionBounds([symbolBounds, boundsOfPoints(accentPoints)]);
    check(Math.min(total.x0, total.y0, 1024 - total.x1, 1024 - total.y1) >= 35, `${theme}: margine minimo dal canvas ≥ 35 px`);
  }

  near(light.cycle.rx, 288, 0.01, "light: raggio orizzontale esterno");
  near(light.cycle.ry, 274, 0.01, "light: raggio verticale esterno");
  near(light.cycle.rx / light.cycle.ry, 288 / 274, 0.0001, "light: rapporto ellittico 288:274");
  near(indigo.cycle.rx, light.cycle.riX + (light.cycle.rx - light.cycle.riX) * 0.97, 0.02, "indigo: compensazione orizzontale 97%");
  near(indigo.cycle.ry, light.cycle.riY + (light.cycle.ry - light.cycle.riY) * 0.97, 0.02, "indigo: compensazione verticale 97%");
  near(light.head.r, 54, 0.01, "light: testa canonica 54");
  near(indigo.head.r, 54 * 0.97, 0.01, "indigo: testa canonica compensata");
}

function rightEdge(points) {
  // La gamba è un quadrilatero: i soli bordi longitudinali sono 0→1 e 3→2.
  // Includere il piede orizzontale selezionava il segmento sbagliato e produceva
  // un falso negativo sulla tangenza del secondo ciclo.
  const edges = [
    [points[0], points[1]],
    [points[3], points[2]],
  ];
  return edges.reduce((best, edge) => {
    const average = (edge[0].x + edge[1].x) / 2;
    const bestAverage = (best[0].x + best[1].x) / 2;
    return average > bestAverage ? edge : best;
  });
}

function sampleEllipse(cycle, count = 8192) {
  return Array.from({ length: count }, (_, index) => {
    const angle = index * 2 * Math.PI / count;
    return {
      x: cycle.cx + cycle.rx * Math.cos(angle),
      y: cycle.cy + cycle.ry * Math.sin(angle),
    };
  });
}

function cycleFromVariant(slug, theme, groupName) {
  const svg = readIcon(slug, theme);
  const group = extractGroup(svg, groupName);
  const path = pathElements(group.body).find((item) => /fill-rule="evenodd"/.test(item.attributes));
  if (!path) throw new Error(`${slug}-${theme}: ciclo chiuso non trovato in ${groupName}`);
  return parseClosedCycle(path.d);
}

function verifyNestedTangencies() {
  for (const theme of THEMES) {
    const v1 = readIcon("v1-nested-cycle", theme);
    const symbol = extractGroup(v1, "symbol");
    const mainPath = pathElements(symbol.body).find((path) => /fill-rule="evenodd"/.test(path.attributes));
    const main = parseClosedCycle(mainPath.d);
    const legPath = pathElements(symbol.body).find((path) => !/fill-rule="evenodd"/.test(path.attributes));
    const leg = parsePolygon(legPath.d);
    const secondary = cycleFromVariant("v1-nested-cycle", theme, "accent");
    const points = sampleEllipse(secondary);

    const mainClearances = points.map((point) =>
      ((point.x - main.cx) / main.rx) ** 2 + ((point.y - main.cy) / main.ry) ** 2 - 1,
    );
    const minMain = Math.min(...mainClearances);
    check(minMain >= -0.002 && minMain <= 0.002, `${theme}: secondo ciclo tangente al principale`);

    const [first, second] = rightEdge(leg);
    const dx = second.x - first.x;
    const dy = second.y - first.y;
    const length = Math.hypot(dx, dy);
    let nx = dy / length;
    let ny = -dx / length;
    if (nx < 0) { nx = -nx; ny = -ny; }
    const legClearances = points.map((point) =>
      (point.x - first.x) * nx + (point.y - first.y) * ny,
    );
    const minLeg = Math.min(...legClearances);
    check(minLeg >= -0.2 && minLeg <= 0.2, `${theme}: secondo ciclo tangente alla gamba`);
    near(secondary.cy + secondary.ry, 854, 0.02, `${theme}: overshoot del secondo ciclo`);

    for (const slug of ["v2-nested-cycle-threshold"]) {
      const candidate = cycleFromVariant(slug, theme, "accent");
      near(candidate.cx, secondary.cx, 0.01, `${slug}-${theme}: centro del secondo ciclo invariato`);
      near(candidate.cy, secondary.cy, 0.01, `${slug}-${theme}: altezza del secondo ciclo invariata`);
      near(candidate.rx, secondary.rx, 0.01, `${slug}-${theme}: raggio del secondo ciclo invariato`);
    }
  }
}

function openCycleGeometry(slug, theme, groupName, closedReference = null) {
  const svg = readIcon(slug, theme);
  const group = extractGroup(svg, groupName);
  const path = pathElements(group.body)[0];
  let center;
  if (closedReference) {
    center = { x: closedReference.cx, y: closedReference.cy };
  } else {
    const rect = rectElements(extractGroup(svg, "symbol").body)[0];
    const values = numbers(path.d);
    center = { x: rect.x + values[2], y: rect.y };
  }
  return parseOpenCycle(path.d, center);
}

function verifyObliqueAxes() {
  for (const theme of THEMES) {
    for (const slug of ["t2-cycle-threshold", "v2-nested-cycle-threshold"]) {
      const open = openCycleGeometry(slug, theme, "symbol");
      const gap = smallArc(angle(open.center, open.start), angle(open.center, open.end));
      near(gap.width, 26, 0.2, `${slug}-${theme}: apertura di 26°`);
      near(gap.center, 315, 0.2, `${slug}-${theme}: varco centrato sulla diagonale 315°`);
    }

    const reference = cycleFromVariant("v1-nested-cycle", theme, "accent");
    const open = openCycleGeometry("v3-nested-cycle-opening", theme, "accent", reference);
    const gap = smallArc(angle(open.center, open.start), angle(open.center, open.end));
    near(gap.width, 30, 0.2, `v3-${theme}: apertura di 30°`);
    near(gap.center, 225, 0.2, `v3-${theme}: apertura centrata sulla diagonale 225°`);
  }
}

function walk(path) {
  const out = [];
  for (const name of readdirSync(path)) {
    const child = join(path, name);
    if (statSync(child).isDirectory()) out.push(...walk(child));
    else out.push(child);
  }
  return out;
}

function verifyComposerLayers() {
  check(existsSync(COMPOSER_DIR), "cartella composer-layers presente");
  const expected = [];
  for (const variant of VARIANTS) {
    for (const theme of THEMES) {
      for (const group of variant.groups) {
        expected.push(`${variant.slug}-${theme}-${group}.svg`);
      }
    }
  }
  const actual = readdirSync(COMPOSER_DIR).filter((name) => name.endsWith(".svg")).sort();
  check(actual.length === 52, `composer-layers: 52 file autonomi`);
  check(expected.every((name) => actual.includes(name)), "composer-layers: matrice completa");

  for (const name of expected) {
    const svg = read(join(COMPOSER_DIR, name));
    const group = name.match(/-(background|symbol|accent|overlay)\.svg$/)?.[1];
    check(svg.includes('viewBox="0 0 1024 1024"'), `${name}: canvas 1024`);
    check(!svg.includes("transform="), `${name}: coordinate appiattite`);
    check(new RegExp(`<g id="${group}"`).test(svg), `${name}: gruppo corretto`);
    check(!/NaN|Infinity/.test(svg), `${name}: coordinate finite`);
    check(/<title id="title">/.test(svg) && /<desc id="desc">/.test(svg), `${name}: metadati presenti`);
  }
}

function normalizedWithoutMetadata(svg) {
  return svg
    .replace(/<title id="title">[\s\S]*?<\/title>/, "")
    .replace(/<desc id="desc">[\s\S]*?<\/desc>/, "")
    .replace(/#[0-9A-Fa-f]{6}/g, "#COLOR")
    .replace(/(<circle\b[^>]*\br=")[^"]+("[^>]*>)/, "$1RADIUS$2")
    .replace(/\s+/g, " ")
    .trim();
}

function verifyExperiments() {
  const expected = [
    "a1-air-medium-head50-indigo.svg",
    "a1-air-medium-head50-light.svg",
    "a1-air-medium-amber-indigo.svg",
    "a1-air-medium-amber-light.svg",
    "a1-air-medium-head50-amber-indigo.svg",
    "a1-air-medium-head50-amber-light.svg",
    "a1-air-medium-monochrome-simulation.svg",
  ];
  const actual = readdirSync(EXPERIMENT_DIR).filter((name) => name.endsWith(".svg")).sort();
  check(actual.length === expected.length, "experiments: sette SVG di prova");
  check(expected.every((name) => actual.includes(name)), "experiments: matrice completa");

  for (const theme of THEMES) {
    const base = readIcon("a1-air-medium", theme);
    const head50 = read(join(EXPERIMENT_DIR, `a1-air-medium-head50-${theme}.svg`));
    const amber = read(join(EXPERIMENT_DIR, `a1-air-medium-amber-${theme}.svg`));
    const combined = read(join(EXPERIMENT_DIR, `a1-air-medium-head50-amber-${theme}.svg`));
    const expectedRadius = theme === "indigo" ? 48.5 : 50;
    const headRadius = circleElements(extractGroup(head50, "accent").body)[0].r;
    const combinedRadius = circleElements(extractGroup(combined, "accent").body)[0].r;
    near(headRadius, expectedRadius, 0.01, `${theme}: testa ridotta a 50`);
    near(combinedRadius, expectedRadius, 0.01, `${theme}: testa ridotta nella variante Amber`);
    const amberColor = parseColor(extractGroup(amber, "accent").attributes, "fill");
    const combinedColor = parseColor(extractGroup(combined, "accent").attributes, "fill");
    check(AMBER_COLORS.has(amberColor), `${theme}: accento Amber da token approvato`);
    check(AMBER_COLORS.has(combinedColor), `${theme}: accento Amber combinato da token approvato`);
    check(
      normalizedWithoutMetadata(base) === normalizedWithoutMetadata(head50),
      `${theme}: la microvariante testa non altera il resto della geometria`,
    );
    check(
      normalizedWithoutMetadata(base) === normalizedWithoutMetadata(amber),
      `${theme}: la microvariante Amber non altera la geometria`,
    );
  }

  const mono = read(join(EXPERIMENT_DIR, "a1-air-medium-monochrome-simulation.svg"));
  const monoColors = new Set((mono.match(/#[0-9A-Fa-f]{6}/g) ?? []).map((color) => color.toUpperCase()));
  check([...monoColors].every((color) => /^#([0-9A-F]{2})\1\1$/.test(color)), "mono: soli colori neutri");
  check(mono.includes("non sostituisce l'aspetto Mono"), "mono: limite della simulazione dichiarato");
}

function verifyEvidence() {
  const expected = [
    "appearance-readiness.svg",
    "candidate-comparison.svg",
    "context-simulation.svg",
    "dev-comparison.svg",
    "refinement-matrix.svg",
  ];
  const actual = readdirSync(EVIDENCE_DIR).filter((name) => name.endsWith(".svg")).sort();
  check(actual.length === expected.length, "evidence: cinque tavole SVG");
  check(expected.every((name) => actual.includes(name)), "evidence: tavole attese presenti");
  for (const name of expected) {
    const svg = read(join(EVIDENCE_DIR, name));
    check(svg.includes("<title id=\"title\">"), `${name}: titolo accessibile`);
    check(svg.includes("<desc id=\"desc\">"), `${name}: descrizione accessibile`);
    check(!/<image\b|data:image|\.png|\.jpe?g|\.webp/i.test(svg), `${name}: nessuna risorsa raster`);
    check(!/NaN|Infinity/.test(svg), `${name}: coordinate finite`);
  }
}

function verifyNoRasterAssets() {
  const raster = walk(ICON_DIR).filter((path) => [".png", ".jpg", ".jpeg", ".webp", ".gif"].includes(extname(path).toLowerCase()));
  check(raster.length === 0, "icon/: nessun asset raster versionato");
}

function verifyDocumentationLanguage() {
  const files = [
    join(ICON_DIR, "README.md"),
    join(ROOT, "docs", "MASTER_PLAN.md"),
    join(ROOT, "docs", "DESIGN", "ui-foundation.md"),
  ];
  const text = files.map(read).join("\n");
  check(!/variante approvata|segno approvato/i.test(text), "documentazione: A1 non è indicata come approvata");
  check(/benchmark della silhouette/i.test(text), "documentazione: T1 definita come benchmark della silhouette");
  check(/monogramma `R`|monogramma R/i.test(text), "documentazione: descrizione esplicita del monogramma R");
  check(/non.*sostituit[oa].*automatic/i.test(text), "documentazione: nessuna sostituzione automatica di T1");
}

verifyCanonicalFiles();
verifyA1Geometry();
verifyNestedTangencies();
verifyObliqueAxes();
verifyComposerLayers();
verifyExperiments();
verifyEvidence();
verifyNoRasterAssets();
verifyDocumentationLanguage();

if (failures.length > 0) {
  console.error(`Validazione icona fallita: ${failures.length} problema/i.`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log(`Validazione icona completata: ${checks.length} controlli superati.`);
