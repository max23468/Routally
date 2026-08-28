import { appendFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import { classifyChangedFiles, githubOutputs } from "./change-policy.mjs";

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    encoding: "utf8",
    stdio: options.capture ? "pipe" : "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    const detail = options.capture ? `\n${result.stderr || result.stdout}` : "";
    throw new Error(`${command} ${args.join(" ")} non riuscito${detail}`);
  }
  return options.capture ? result.stdout.trim() : "";
}

function outputLines(command, args) {
  const output = run(command, args, { capture: true });
  return output ? output.split("\n").filter(Boolean) : [];
}

export function changedFiles(base, head = "HEAD") {
  const committed = outputLines("git", [
    "diff",
    "--no-renames",
    "--name-only",
    "--diff-filter=ACMRD",
    `${base}...${head}`,
  ]);
  if (head !== "HEAD") return committed;
  return [
    ...committed,
    ...outputLines("git", ["diff", "--no-renames", "--name-only", "--diff-filter=ACMRD"]),
    ...outputLines("git", [
      "diff",
      "--no-renames",
      "--cached",
      "--name-only",
      "--diff-filter=ACMRD",
    ]),
    ...outputLines("git", ["ls-files", "--others", "--exclude-standard"]),
  ];
}

function argumentValue(name, fallback) {
  const index = process.argv.indexOf(name);
  return index === -1 ? fallback : process.argv[index + 1];
}

function runNodeTests() {
  run("node", [
    "--test",
    "scripts/change-policy.test.mjs",
    "scripts/publication-gate.test.mjs",
    "scripts/verify-merge-tree.test.mjs",
  ]);
}

function executeChecks(classification, base) {
  run("git", ["diff", "--check", `${base}...HEAD`]);
  run("git", ["diff", "--check"]);
  run("git", ["diff", "--cached", "--check"]);

  if (classification.needsRoadmap) {
    run("node", ["scripts/check-reading-matrix.mjs"]);
    run("node", ["scripts/check-roadmap-hierarchy.mjs"]);
  }
  if (classification.needsNodeTests) runNodeTests();
  if (classification.needsSwiftFormat) {
    run("swift", [
      "format",
      "lint",
      "--recursive",
      "--strict",
      "RoutallyApp",
      "RoutallyTests",
      "Packages/RoutallyModules",
    ]);
  }
  if (classification.needsUIAssets) run("node", ["scripts/check-ui-assets.mjs"]);
  if (classification.needsBuild) {
    run("xcodebuild", [
      "build",
      "-project",
      "Routally.xcodeproj",
      "-scheme",
      "Routally Dev",
      "-destination",
      "platform=iOS Simulator,name=iPhone 17 Pro",
    ]);
    run("xcodebuild", [
      "build",
      "-project",
      "Routally.xcodeproj",
      "-scheme",
      "Routally",
      "-destination",
      "platform=iOS Simulator,name=iPhone 17 Pro",
    ]);
    run("xcodebuild", [
      "test",
      "-project",
      "Routally.xcodeproj",
      "-scheme",
      "Routally Tests",
      "-destination",
      "platform=iOS Simulator,name=iPhone 17 Pro",
    ]);
  }
}

const base = argumentValue("--base", "origin/main");
const head = argumentValue("--head", "HEAD");
const classification = classifyChangedFiles(changedFiles(base, head));
const githubOutputPath = argumentValue("--github-output");

if (githubOutputPath) {
  const lines = Object.entries(githubOutputs(classification))
    .map(([key, value]) => `${key}=${value}`)
    .join("\n");
  await appendFile(githubOutputPath, `${lines}\n`);
}

if (process.argv.includes("--json")) {
  process.stdout.write(`${JSON.stringify(classification, null, 2)}\n`);
} else {
  process.stdout.write(
    `Profilo: ${classification.kind}; ${classification.files.length} file modificati.\n`,
  );
}

if (!process.argv.includes("--plan-only")) {
  executeChecks(classification, base);
  if (classification.needsVisualEvidence) {
    process.stdout.write(
      "Verifica manuale richiesta: evidenza visuale proporzionata su iPhone e iPad Simulator.\n",
    );
  }
}
