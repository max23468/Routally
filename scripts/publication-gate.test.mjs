import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { evaluatePublicationGate } from "./publication-gate.mjs";

const workflowURL = new URL("../.github/workflows/publication-gate.yml", import.meta.url);
const statusWorkflowURL = new URL(
  "../.github/workflows/publication-status.yml",
  import.meta.url,
);
const codeqlURL = new URL("../.github/workflows/codeql.yml", import.meta.url);

test("il gate aggregato parte per ogni PR senza filtri di percorso", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  assert.match(workflow, /on:\s*\n  pull_request:/);
  assert.doesNotMatch(workflow, /\n\s+paths(?:-ignore)?:/);
  assert.match(workflow, /publication-gate:\s*\n    name: Consolida pubblicazione/);
  assert.match(workflow, /publication-gate:[\s\S]*?if: always\(\)/);
  assert.doesNotMatch(workflow, /statuses: write/);
  assert.doesNotMatch(workflow, /PULL_REQUEST_HEAD:/);
});

test("consolida soltanto i job richiesti dalla classificazione", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  assert.match(workflow, /needs_codeql == 'true'/);
  assert.match(workflow, /needs_build == 'true'/);
  assert.match(workflow, /needs_swift_format == 'true'/);
  assert.match(workflow, /needs_visual_evidence/);
  assert.match(workflow, /node scripts\/publication-gate\.mjs/);
});

test("CodeQL PR usa il build manuale e main resta settimanale", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  const scheduled = await readFile(codeqlURL, "utf8");
  assert.match(workflow, /build-mode: manual/);
  assert.match(workflow, /category: \/language:swift\/pr-validation/);
  assert.match(scheduled, /schedule:/);
  assert.match(scheduled, /workflow_dispatch:/);
  assert.doesNotMatch(scheduled, /\n  push:/);
  assert.match(scheduled, /category: \/language:swift\/scheduled/);
});

test("format non viene più duplicato in un workflow separato", async () => {
  await assert.rejects(
    readFile(new URL("../.github/workflows/swift-format.yml", import.meta.url), "utf8"),
    (error) => error.code === "ENOENT",
  );
});

test("accetta i job costosi saltati per una modifica documentale", () => {
  assert.deepEqual(
    evaluatePublicationGate({
      buildRequired: false,
      buildResult: "skipped",
      classifyResult: "success",
      codeqlRequired: false,
      codeqlResult: "skipped",
      formatRequired: false,
      formatResult: "skipped",
      validationRequired: true,
      validationResult: "success",
      visualEvidenceRequired: false,
    }),
    { needsVisualEvidence: false },
  );
});

test("blocca un job richiesto saltato o fallito", () => {
  assert.throws(
    () =>
      evaluatePublicationGate({
        buildRequired: true,
        buildResult: "success",
        classifyResult: "success",
        codeqlRequired: true,
        codeqlResult: "skipped",
        formatRequired: true,
        formatResult: "failure",
        validationRequired: false,
        validationResult: "skipped",
      }),
    /Swift format: failure; CodeQL: skipped/,
  );
});

test("pubblica lo status da un workflow trusted", async () => {
  const workflow = await readFile(statusWorkflowURL, "utf8");
  assert.match(workflow, /workflow_run:/);
  assert.match(workflow, /workflows: \["Publication gate"\]/);
  assert.match(workflow, /statuses: write/);
  assert.match(workflow, /PUBLICATION_HEAD:/);
  assert.match(workflow, /ref: \$\{\{ github\.event\.repository\.default_branch \}\}/);
  assert.doesNotMatch(workflow, /pull_request_target:/);
});
