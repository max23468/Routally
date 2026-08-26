import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { classifyChangedFiles, githubOutputs } from "./change-policy.mjs";

test("mantiene leggera la documentazione ordinaria", () => {
  const result = classifyChangedFiles(["docs/DESIGN/ui-foundation.md"]);
  assert.equal(result.kind, "documentation");
  assert.equal(result.needsBuild, false);
  assert.equal(result.needsCodeQL, false);
  assert.equal(result.needsRoadmap, false);
});

test("tratta Master Plan e ADR come documentazione canonica", () => {
  const result = classifyChangedFiles(["docs/MASTER_PLAN.md", "docs/ADR/0003.md"]);
  assert.equal(result.kind, "canonical-documentation");
  assert.equal(result.needsRoadmap, true);
  assert.equal(result.needsNodeTests, true);
  assert.equal(result.needsBuild, false);
});

test("richiede build, format e CodeQL per Swift di dominio", () => {
  const result = classifyChangedFiles([
    "Packages/RoutallyModules/Sources/RoutallyDomain/DomainEngine.swift",
  ]);
  assert.equal(result.kind, "swift");
  assert.equal(result.needsBuild, true);
  assert.equal(result.needsCodeQL, true);
  assert.equal(result.needsSwiftFormat, true);
  assert.equal(result.needsVisualEvidence, false);
});

test("aggiunge evidenza visuale per una superficie UI", () => {
  const result = classifyChangedFiles([
    "Packages/RoutallyModules/Sources/RoutallyFeatures/TodayView.swift",
  ]);
  assert.equal(result.kind, "ui");
  assert.equal(result.needsBuild, true);
  assert.equal(result.needsCodeQL, true);
  assert.equal(result.needsVisualEvidence, true);
});

test("costruisce anche le risorse processate dei package", () => {
  const result = classifyChangedFiles([
    "Packages/RoutallyModules/Sources/RoutallyFixtures/Resources/Localizable.xcstrings",
  ]);
  assert.equal(result.kind, "ui");
  assert.equal(result.needsBuild, true);
  assert.equal(result.needsCodeQL, false);
  assert.equal(result.needsUIAssets, true);
  assert.equal(result.needsVisualEvidence, true);
});

test("classifica configurazioni e sicurezza al livello massimo", () => {
  const result = classifyChangedFiles(["Configuration/Release.xcconfig"]);
  assert.equal(result.kind, "release-security");
  assert.equal(result.needsBuild, true);
  assert.equal(result.needsCodeQL, true);
});

test("valida realmente le modifiche alla pipeline applicativa", () => {
  const result = classifyChangedFiles([".github/workflows/publication-gate.yml"]);
  assert.equal(result.kind, "release-security");
  assert.equal(result.needsBuild, true);
  assert.equal(result.needsCodeQL, true);
  assert.equal(result.needsSwiftFormat, true);
});

test("espone output GitHub booleani e stabili", () => {
  const outputs = githubOutputs(classifyChangedFiles(["README.md"]));
  assert.deepEqual(outputs, {
    kind: "documentation",
    needs_build: "false",
    needs_codeql: "false",
    needs_node_tests: "false",
    needs_roadmap: "false",
    needs_swift_format: "false",
    needs_ui_assets: "false",
    needs_visual_evidence: "false",
  });
});

test("l'inventario tratta un rename come rimozione e aggiunta", async () => {
  const source = await readFile(new URL("./verify-change.mjs", import.meta.url), "utf8");
  assert.match(source, /"diff",\s*\n\s*"--no-renames",\s*\n\s*"--name-only"/);
  assert.match(source, /"diff", "--no-renames", "--name-only"/);
  assert.match(source, /"--no-renames",\s*\n\s*"--cached"/);
});

test("il gate Apple locale costruisce entrambi gli scheme applicativi", async () => {
  const source = await readFile(new URL("./verify-change.mjs", import.meta.url), "utf8");
  assert.match(source, /"-scheme",\s*\n\s*"Routally Dev"/);
  assert.match(source, /"-scheme",\s*\n\s*"Routally"/);
  assert.match(source, /"-scheme",\s*\n\s*"Routally Tests"/);
});
