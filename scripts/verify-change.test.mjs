import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import {
  mkdtempSync,
  mkdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { dirname, join } from "node:path";
import { tmpdir } from "node:os";
import test from "node:test";
import { classifyChangedFiles } from "./change-policy.mjs";
import { changedFiles } from "./verify-change.mjs";

function git(repository, args) {
  return execFileSync("git", args, { cwd: repository, encoding: "utf8" }).trim();
}

function write(repository, path, body) {
  const absolutePath = join(repository, path);
  mkdirSync(dirname(absolutePath), { recursive: true });
  writeFileSync(absolutePath, body, "utf8");
}

test("inventa pathname Git letterali per ogni sorgente del working tree", () => {
  const repository = mkdtempSync(join(tmpdir(), "routally-verify-change-"));
  try {
    git(repository, ["init", "--initial-branch=main"]);
    git(repository, ["config", "user.email", "test@example.invalid"]);
    git(repository, ["config", "user.name", "Routally test"]);

    const unstaged = "Packages/RoutallyModules/Sources/RoutallyDomain/unstaged\tfile.swift";
    const staged = "Packages/RoutallyModules/Sources/RoutallyDomain/staged\nfile.swift";
    write(repository, "README.md", "baseline\n");
    write(repository, unstaged, "let unstaged = 0\n");
    write(repository, staged, "let staged = 0\n");
    git(repository, ["add", "."]);
    git(repository, ["commit", "-m", "baseline"]);
    const base = git(repository, ["rev-parse", "HEAD"]);

    const committed = "Packages/RoutallyModules/Sources/RoutallyDomain/committed-è\nfile.swift";
    write(repository, committed, "let committed = true\n");
    git(repository, ["add", "."]);
    git(repository, ["commit", "-m", "committed special path"]);

    write(repository, unstaged, "let unstaged = 1\n");
    write(repository, staged, "let staged = 1\n");
    git(repository, ["add", staged]);
    const untracked = "RoutallyApp/Untracked\tView.swift";
    write(repository, untracked, "let untracked = true\n");

    const files = changedFiles(base, "HEAD", repository);
    assert.deepEqual(new Set(files), new Set([committed, unstaged, staged, untracked]));

    const classification = classifyChangedFiles(files);
    assert.equal(classification.needsBuild, true);
    assert.equal(classification.needsCodeQL, true);
    assert.equal(classification.needsSwiftFormat, true);
    assert.equal(classification.needsVisualEvidence, true);

    assert.deepEqual(changedFiles(base, git(repository, ["rev-parse", "HEAD"]), repository), [
      committed,
    ]);
  } finally {
    rmSync(repository, { force: true, recursive: true });
  }
});
