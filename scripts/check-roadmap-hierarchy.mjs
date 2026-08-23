#!/usr/bin/env node
// Verifica l'unica gerarchia operativa della 1.0 e che lo scope rinviato
// resti conservato nella roadmap successiva.

import { readFileSync } from "node:fs";

const plan = readFileSync("docs/MASTER_PLAN.md", "utf8");
const future = readFileSync("docs/PRODUCT/ROADMAP.md", "utf8");

const expectedMilestones = ["M01", "M02", "M03", "M04", "M05", "M06"];
const expectedEpics = Array.from(
  { length: 12 },
  (_, index) => `E${String(index + 1).padStart(2, "0")}`,
);
const expectedGates = ["TG-DATA", "TG-RECALC", "TG-STOREKIT"];
const deferredSignals = [
  "CloudKit",
  "Geofencing",
  "iPad ottimizzato",
  "Ricerca e Analisi",
  "Universal Links",
  "Plus Annual",
  "App Preview",
  "Apple Watch",
  "Account Routally",
];

const fail = (message) => {
  console.error(message);
  process.exitCode = 1;
};

const same = (left, right) =>
  left.length === right.length && left.every((value, index) => value === right[index]);

const sectionStart = plan.indexOf("# 9. Roadmap operativa");
const sectionEnd = plan.indexOf("# 10. Qualità", sectionStart);
if (sectionStart < 0 || sectionEnd < 0) {
  fail("Sezione canonica della roadmap 1.0 mancante.");
} else {
  const roadmap = plan.slice(sectionStart, sectionEnd);
  const tree = roadmap.match(/```text\n([\s\S]*?)\n```/)?.[1] ?? "";
  const milestones = [...tree.matchAll(/(?:^|\s)(M\d{2})(?:\s|$)/gm)].map(
    (match) => match[1],
  );
  const epics = [...tree.matchAll(/(?:^|\s)(E\d{2})(?:\s|$)/gm)].map(
    (match) => match[1],
  );
  const gates = [...tree.matchAll(/(?:^|\s)(TG-[A-Z-]+)(?:\s|$)/gm)].map(
    (match) => match[1],
  );

  if (!same(milestones, expectedMilestones)) {
    fail(`Milestone inattese o duplicate: ${milestones.join(", ")}.`);
  }
  if (!same(epics, expectedEpics)) {
    fail(`Epiche inattese, duplicate o fuori ordine: ${epics.join(", ")}.`);
  }
  if (!same(gates, expectedGates)) {
    fail(`Technical Gate inattesi o non coperti: ${gates.join(", ")}.`);
  }

  for (const milestone of expectedMilestones) {
    if (!roadmap.includes(`## ${milestone} —`)) {
      fail(`Esito operativo mancante per ${milestone}.`);
    }
  }
  for (const epic of expectedEpics.slice(3)) {
    if (!roadmap.includes(`### ${epic} —`)) {
      fail(`Definizione operativa mancante per ${epic}.`);
    }
  }
}

for (const signal of deferredSignals) {
  if (!future.includes(signal)) fail(`Scope rinviato non conservato: ${signal}.`);
}

if (!plan.includes("docs/PRODUCT/ROADMAP.md") && !plan.includes("PRODUCT/ROADMAP.md")) {
  fail("Il Master Plan non collega la roadmap successiva.");
}

if (!process.exitCode) {
  console.log(
    "Gerarchia completa: 6 milestone, 12 epiche, 3 Technical Gate e scope 1.1+ conservato.",
  );
}
