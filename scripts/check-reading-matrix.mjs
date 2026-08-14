#!/usr/bin/env node
// Verifica l'invariante di copertura della matrice di lettura selettiva:
// ogni sezione di primo livello del Master Plan deve essere sempre letta
// oppure comparire in almeno una riga della matrice in agent-workflow.md.
//
// Uso: node scripts/check-reading-matrix.mjs

import { readFileSync } from "node:fs";

const PLAN = "docs/MASTER_PLAN.md";
const WORKFLOW = "docs/ENGINEERING/agent-workflow.md";
const ALWAYS_READ = new Set([0, 5, 6, 40, 50, 51]);

const sectionsOf = (text) =>
  new Set([...text.matchAll(/^# (\d+)\./gm)].map((m) => Number(m[1])));

const mappedIn = (text) => {
  const rows = [...text.matchAll(/^\|.+\|\s*([\d,\s]+?)\s*\|\s*$/gm)];
  return new Set(
    rows.flatMap((m) =>
      m[1]
        .split(",")
        .map((n) => Number(n.trim()))
        .filter((n) => Number.isInteger(n)),
    ),
  );
};

const sections = sectionsOf(readFileSync(PLAN, "utf8"));
const mapped = mappedIn(readFileSync(WORKFLOW, "utf8"));
const unreachable = [...sections]
  .filter((n) => !ALWAYS_READ.has(n) && !mapped.has(n))
  .sort((a, b) => a - b);

if (sections.size === 0) {
  console.error(`Nessuna sezione di primo livello trovata in ${PLAN}.`);
  process.exit(1);
}

if (unreachable.length > 0) {
  console.error(
    `Sezioni irraggiungibili dalla matrice di lettura: ${unreachable.join(", ")}.\n` +
      `Aggiungile a una riga della matrice in ${WORKFLOW} oppure all'insieme sempre letto.`,
  );
  process.exit(1);
}

console.log(
  `Matrice di lettura completa: ${sections.size} sezioni, ` +
    `${ALWAYS_READ.size} sempre lette, nessuna irraggiungibile.`,
);
