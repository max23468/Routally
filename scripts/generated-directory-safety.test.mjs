import assert from "node:assert/strict";
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import test from "node:test";
import { build } from "./build-icon-assets.mjs";
import { restore, snapshot } from "./check-icon-review-assets.mjs";
import {
  prepareGeneratedDirectory,
  requireGeneratedDirectory,
} from "./generated-directory-safety.mjs";

function temporaryDirectory(name) {
  return mkdtempSync(join(tmpdir(), `${name}-`));
}

test("prepara soltanto directory reali contenute nella root", () => {
  const root = temporaryDirectory("routally-generated-directory");
  try {
    const nested = prepareGeneratedDirectory(root, "nested/output");
    assert.equal(requireGeneratedDirectory(root, "nested/output"), nested);
    assert.throws(() => prepareGeneratedDirectory(root, "../outside"), /fuori dalla root/);
  } finally {
    rmSync(root, { force: true, recursive: true });
  }
});

test("il builder rifiuta root e sottodirectory symlink prima di cancellare SVG", () => {
  const root = temporaryDirectory("routally-icon-builder");
  const victim = temporaryDirectory("routally-icon-victim");
  try {
    const sentinel = join(victim, "sentinel.svg");
    writeFileSync(sentinel, "sentinel", "utf8");

    const linkedRoot = join(root, "linked-root");
    symlinkSync(victim, linkedRoot, "dir");
    assert.throws(() => build(linkedRoot, root), /collegamento simbolico/);
    assert.equal(readFileSync(sentinel, "utf8"), "sentinel");

    const output = join(root, "output");
    mkdirSync(output);
    symlinkSync(victim, join(output, "layers"), "dir");
    assert.throws(() => build(output, root), /collegamento simbolico/);
    assert.equal(readFileSync(sentinel, "utf8"), "sentinel");

    const nestedRoot = join(root, "nested-root");
    mkdirSync(nestedRoot);
    symlinkSync(victim, join(nestedRoot, "docs"), "dir");
    assert.throws(() => build("docs/icon", nestedRoot), /collegamento simbolico/);
    assert.equal(readFileSync(sentinel, "utf8"), "sentinel");

    const absoluteNestedOutput = join(nestedRoot, "docs", "absolute-icon");
    assert.throws(
      () => build(absoluteNestedOutput, nestedRoot),
      /collegamento simbolico/,
    );
    assert.equal(readFileSync(sentinel, "utf8"), "sentinel");

    assert.throws(() => build(victim, root), /fuori dalla root autorizzata/);
  } finally {
    rmSync(root, { force: true, recursive: true });
    rmSync(victim, { force: true, recursive: true });
  }
});

test("snapshot e ripristino rifiutano directory review symlink", () => {
  const iconRoot = temporaryDirectory("routally-review-root");
  const victim = temporaryDirectory("routally-review-victim");
  try {
    mkdirSync(join(iconRoot, "composer-layers"));
    mkdirSync(join(iconRoot, "experiments"));
    symlinkSync(victim, join(iconRoot, "evidence"), "dir");
    const sentinel = join(victim, "sentinel.svg");
    writeFileSync(sentinel, "sentinel", "utf8");
    const managedSentinel = join(iconRoot, "composer-layers", "managed.svg");
    writeFileSync(managedSentinel, "managed", "utf8");

    assert.throws(() => snapshot(iconRoot), /collegamento simbolico/);
    assert.throws(() => restore(new Map(), iconRoot), /collegamento simbolico/);
    assert.equal(readFileSync(sentinel, "utf8"), "sentinel");
    assert.equal(readFileSync(managedSentinel, "utf8"), "managed");
  } finally {
    rmSync(iconRoot, { force: true, recursive: true });
    rmSync(victim, { force: true, recursive: true });
  }
});
