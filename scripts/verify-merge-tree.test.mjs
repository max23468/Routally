import assert from "node:assert/strict";
import test from "node:test";
import { compareTrees, validateCommit } from "./verify-merge-tree.mjs";

test("accetta hash Git abbreviati o completi", () => {
  assert.equal(validateCommit("5ec9d0e", "commit"), "5ec9d0e");
  assert.equal(
    validateCommit("5ec9d0e99ae0c24c5312fe0b0de25523c12768ab", "commit"),
    "5ec9d0e99ae0c24c5312fe0b0de25523c12768ab",
  );
});

test("rifiuta riferimenti Git arbitrari", () => {
  assert.throws(() => validateCommit("main^{tree}", "commit"), /non è un commit valido/);
});

test("conferma soltanto tree identici", () => {
  assert.equal(compareTrees("abc", "abc"), true);
  assert.throws(() => compareTrees("abc", "def"), /non coincide/);
});
