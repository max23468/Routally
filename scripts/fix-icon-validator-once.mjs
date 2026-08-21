#!/usr/bin/env node

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const path = join(root, "scripts", "validate-icon-assets.mjs");
let source = readFileSync(path, "utf8");

const before = `function rightEdge(points) {
  const edges = [
    [points[0], points[1]],
    [points[1], points[2]],
    [points[2], points[3]],
    [points[3], points[0]],
  ];
  return edges.reduce((best, edge) => {
    const average = (edge[0].x + edge[1].x) / 2;
    const bestAverage = (best[0].x + best[1].x) / 2;
    return average > bestAverage ? edge : best;
  });
}`;

const after = `function rightEdge(points) {
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
}`;

if (source.includes(before)) source = source.replace(before, after);
else if (!source.includes(after)) throw new Error("funzione rightEdge non riconosciuta");

writeFileSync(path, source, "utf8");
console.log("Validatore della tangenza corretto.");
