#!/usr/bin/env node
// Verifica la gerarchia operativa del Master Plan:
// fase/versione -> milestone -> epiche -> gate, senza inventari duplicati.
//
// Uso: node scripts/check-roadmap-hierarchy.mjs

import { readFileSync } from "node:fs";

const PLAN = "docs/MASTER_PLAN.md";
const EXPECTED_MILESTONES = 12;
const EXPECTED_EPICS = 22;
const EXPECTED_PHASES = [
  "0.1",
  "0.2",
  "0.3",
  "0.4",
  "0.5",
  "0.5",
  "0.6",
  "0.6",
  "0.7",
  "0.8",
  "0.9",
  "1.0",
];
const text = readFileSync(PLAN, "utf8");

const section = (start, end) => {
  const from = text.indexOf(start);
  const to = text.indexOf(end, from + start.length);
  if (from < 0 || to < 0) throw new Error(`Sezione mancante: ${start} -> ${end}`);
  return text.slice(from, to);
};

const roadmap = section("## 37.2 Milestone operative", "## 37.3 Feature freeze");
const definitions = section("# 48. Definition of Done per milestone", "# 49.");
const epicCatalog = section("# 49. Backlog per epiche", "# 50.");
const technicalGates = section("# 40. Technical spikes e validation gates", "# 41.");

const fail = (message) => {
  console.error(message);
  process.exitCode = 1;
};

const unique = (values) => new Set(values).size === values.length;
const expectedSequence = (prefix, count) =>
  Array.from({ length: count }, (_, index) => `${prefix}${String(index + 1).padStart(2, "0")}`);
const same = (left, right) =>
  left.length === right.length && left.every((value, index) => value === right[index]);
const clean = (value) => value.replaceAll("`", "").trim();

const rows = roadmap
  .split("\n")
  .filter((line) => /^\| `(?:0\.\d|1\.0)` /.test(line))
  .map((line) => line.split("|").slice(1, -1).map(clean));

const mappedPhases = rows.map((cells) => cells[0]);
const mappedMilestones = rows.map((cells) => cells[1].match(/M\d{2}/)?.[0]);
const mappedEpics = [];
const epicToMilestone = new Map();

for (const cells of rows) {
  const milestone = cells[1].match(/M\d{2}/)?.[0];
  const epicCell = cells[2];
  for (const match of epicCell.matchAll(/E(\d{2})(?:–E(\d{2}))?/g)) {
    const first = Number(match[1]);
    const last = Number(match[2] ?? match[1]);
    for (let number = first; number <= last; number += 1) {
      const epic = `E${String(number).padStart(2, "0")}`;
      mappedEpics.push(epic);
      if (epicToMilestone.has(epic)) fail(`${epic} compare in più milestone.`);
      epicToMilestone.set(epic, milestone);
    }
  }
}

const definitionMilestones = [...definitions.matchAll(/^## 48\.\d+ (M\d{2})/gm)].map(
  (match) => match[1],
);
const catalogEpics = [...epicCatalog.matchAll(/^\| `(E\d{2})` /gm)].map((match) => match[1]);
const expectedMilestones = expectedSequence("M", mappedMilestones.length);
const expectedEpics = expectedSequence("E", EXPECTED_EPICS);

if (rows.length !== EXPECTED_MILESTONES || !same(mappedPhases, EXPECTED_PHASES)) {
  fail(`Fasi o numero di milestone inattesi: ${mappedPhases.join(", ")}.`);
}
if (!unique(mappedMilestones)) fail("Una milestone compare più volte nella mappa canonica.");
if (!same(mappedMilestones, expectedMilestones)) {
  fail(`Milestone non contigue o fuori ordine: ${mappedMilestones.join(", ")}.`);
}
if (!same(definitionMilestones, mappedMilestones)) {
  fail("Le Definition of Done non corrispondono alle milestone della mappa canonica.");
}
if (!unique(mappedEpics) || !same(mappedEpics, expectedEpics)) {
  fail(`Epiche non contigue, duplicate o fuori ordine: ${mappedEpics.join(", ")}.`);
}
if (!same(catalogEpics, mappedEpics)) {
  fail("Il catalogo delle epiche non corrisponde alla mappa canonica.");
}

const gateIds = [...technicalGates.matchAll(/^## 40\.\d+ (TG-[A-Z-]+)/gm)].map(
  (match) => match[1],
);
const missingGates = gateIds.filter((gate) => !roadmap.includes(gate));
if (missingGates.length > 0) fail(`Technical Gate assenti dalla mappa: ${missingGates.join(", ")}.`);

if (!roadmap.includes("DG-CLOUD-PRICING") || !roadmap.includes("DG-FUTURE-ANALYTICS")) {
  fail("La mappa non dichiara esplicitamente i Decision Gate futuri esclusi dal percorso 1.0.");
}

if (!process.exitCode) {
  console.log(
    `Gerarchia completa: ${mappedMilestones.length} milestone, ${mappedEpics.length} epiche ` +
      `e ${gateIds.length} Technical Gate coperti.`,
  );
}
