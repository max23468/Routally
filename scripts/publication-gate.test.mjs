import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  appleEvidenceApproved,
  evaluatePublicationGate,
  publicationStatus,
  visualEvidenceApproved,
} from "./publication-gate.mjs";

const workflowURL = new URL("../.github/workflows/publication-gate.yml", import.meta.url);
const codeqlURL = new URL("../.github/workflows/codeql.yml", import.meta.url);

test("il gate aggregato parte per ogni PR senza filtri di percorso", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  assert.match(workflow, /on:\s*\n  pull_request_target:/);
  assert.doesNotMatch(workflow, /\n\s+paths(?:-ignore)?:/);
  assert.match(workflow, /publication-gate:\s*\n    name: Consolida pubblicazione/);
  assert.match(workflow, /publication-gate:[\s\S]*?if: always\(\)/);
  assert.match(workflow, /jobs:\s*\n  invalidate:/);
  assert.match(workflow, /state=pending/);
  assert.match(workflow, /classify:\s*\n    name: Classifica modifica\s*\n    needs: invalidate/);
  assert.match(workflow, /needs: \[invalidate, classify,/);
  assert.match(workflow, /publication-gate:[\s\S]*?statuses: write/);
  assert.match(workflow, /PULL_REQUEST_HEAD:/);
  assert.match(workflow, /--head FETCH_HEAD/);
  assert.match(workflow, /ref: refs\/pull\/\$\{\{ github\.event\.pull_request\.number \}\}\/merge/);
  assert.match(workflow, /ref: \$\{\{ github\.event\.repository\.default_branch \}\}/);
});

test("consolida soltanto i job richiesti dalla classificazione", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  assert.match(workflow, /needs_codeql == 'true'/);
  assert.match(workflow, /APPLE_EVIDENCE_REQUIRED:.*needs_build/);
  assert.match(workflow, /needs_swift_format == 'true'/);
  assert.match(workflow, /needs_visual_evidence/);
  assert.match(workflow, /PULL_REQUEST_BODY:/);
  assert.match(workflow, /ready_for_review, edited/);
  assert.match(workflow, /node scripts\/publication-gate\.mjs/);
});

test("CodeQL PR usa il build manuale e main resta settimanale", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  const scheduled = await readFile(codeqlURL, "utf8");
  assert.match(workflow, /build-mode: manual/);
  assert.match(workflow, /upload: never/);
  assert.match(workflow, /codeql-upload:/);
  assert.match(workflow, /actions\/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/);
  assert.match(workflow, /actions\/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/);
  assert.match(workflow, /codeql-upload:[\s\S]*?security-events: write/);
  assert.doesNotMatch(
    workflow.match(/  codeql:\n[\s\S]*?\n  codeql-upload:/)?.[0] || "",
    /security-events: write/,
  );
  assert.match(workflow, /category: \/language:swift\/pr-validation/);
  assert.match(scheduled, /schedule:/);
  assert.match(scheduled, /workflow_dispatch:/);
  assert.doesNotMatch(scheduled, /\n  push:/);
  assert.match(scheduled, /category: \/language:swift\/scheduled/);
});

test("mantiene build e test Simulator sul Mac controllato", async () => {
  const workflow = await readFile(workflowURL, "utf8");
  assert.doesNotMatch(workflow, /name: Build e test/);
  assert.doesNotMatch(workflow, /scheme "Routally Tests"/);
  assert.doesNotMatch(workflow, /name=iPhone 17 Pro/);
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
      appleEvidenceRequired: false,
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
        appleEvidenceRequired: false,
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

test("blocca una PR UI finché la prova visuale non è registrata", () => {
  const input = {
    appleEvidenceRequired: false,
    classifyResult: "success",
    codeqlRequired: false,
    codeqlResult: "skipped",
    formatRequired: false,
    formatResult: "skipped",
    validationRequired: false,
    validationResult: "skipped",
    visualEvidenceRequired: true,
  };
  assert.throws(
    () => evaluatePublicationGate({
      ...input,
      pullRequestBody: "- [ ] Screenshot o video allegati per modifiche UI",
    }),
    /Evidenza visuale UI non registrata/,
  );
  assert.deepEqual(
    evaluatePublicationGate({
      ...input,
      pullRequestBody: "- [x] Screenshot o video allegati per modifiche UI",
    }),
    { needsVisualEvidence: true },
  );
  assert.equal(
    visualEvidenceApproved("- [X] Screenshot o video allegati per modifiche UI"),
    true,
  );
});

test("lega l'evidenza Apple all'HEAD completo verificato localmente", () => {
  const head = "0123456789abcdef0123456789abcdef01234567";
  const body = [
    "- [x] Build e test applicabili completati",
    `- HEAD Apple verificato: \`${head}\``,
  ].join("\n");
  assert.equal(appleEvidenceApproved(body, head), true);
  assert.equal(
    appleEvidenceApproved(body, "abcdef0123456789abcdef0123456789abcdef01"),
    false,
  );
  assert.throws(
    () => evaluatePublicationGate({
      appleEvidenceRequired: true,
      classifyResult: "success",
      codeqlRequired: false,
      codeqlResult: "skipped",
      formatRequired: false,
      formatResult: "skipped",
      pullRequestBody: "- [x] Build e test applicabili completati",
      pullRequestHead: head,
      validationRequired: false,
      validationResult: "skipped",
    }),
    /Build e test Apple non registrati/,
  );
});

test("pubblica uno status required sull'HEAD con un contesto stabile", () => {
  assert.deepEqual(
    publicationStatus({ description: "Verde", state: "success" }, {}),
    {
      context: "publication-gate",
      description: "Verde",
      state: "success",
      target_url: undefined,
    },
  );
  assert.equal(
    publicationStatus(
      { description: "Verde", state: "success" },
      {
        GITHUB_REPOSITORY: "max23468/Routally",
        GITHUB_RUN_ID: "123",
        GITHUB_SERVER_URL: "https://github.com",
      },
    ).target_url,
    "https://github.com/max23468/Routally/actions/runs/123",
  );
  assert.throws(
    () => publicationStatus({ description: "X", state: "skipped" }),
    /non valido/,
  );
});

test("non esiste un publisher separato che si fida del workflow della PR", async () => {
  await assert.rejects(
    readFile(new URL("../.github/workflows/publication-status.yml", import.meta.url), "utf8"),
    (error) => error.code === "ENOENT",
  );
});
