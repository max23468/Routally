import assert from "node:assert/strict";
import test from "node:test";
import { statusFromWorkflow, validateStatusEnvironment } from "./publication-status.mjs";

test("traduce il successo del workflow nello status required", () => {
  assert.deepEqual(
    statusFromWorkflow({ conclusion: "success", runURL: "https://example.test/run/1" }),
    {
      context: "publication-gate",
      description: "Tutti i controlli applicabili sono verdi",
      state: "success",
      target_url: "https://example.test/run/1",
    },
  );
});

test("non promuove conclusioni incomplete o fallite", () => {
  for (const conclusion of ["cancelled", "failure", "skipped", "timed_out"]) {
    assert.equal(statusFromWorkflow({ conclusion, runURL: "run" }).state, "failure");
  }
});

test("rifiuta un ambiente trusted incompleto", () => {
  assert.throws(
    () => validateStatusEnvironment({ GITHUB_REPOSITORY: "max23468/Routally" }),
    /GITHUB_TOKEN.*PUBLICATION_CONCLUSION.*PUBLICATION_HEAD.*PUBLICATION_RUN_URL/,
  );
});
