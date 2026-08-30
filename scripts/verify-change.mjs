import { appendFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import { TextDecoder } from "node:util";
import { pathToFileURL } from "node:url";
import { classifyChangedFiles, githubOutputs } from "./change-policy.mjs";

const utf8Decoder = new TextDecoder("utf-8", { fatal: true });

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd,
    stdio: options.capture ? "pipe" : "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    const detail = options.capture
      ? `\n${utf8Decoder.decode(result.stderr?.length ? result.stderr : result.stdout)}`
      : "";
    throw new Error(`${command} ${args.join(" ")} non riuscito${detail}`);
  }
  return options.capture ? result.stdout : undefined;
}

function nulSeparatedOutput(command, args, cwd) {
  const output = utf8Decoder.decode(run(command, args, { capture: true, cwd }));
  if (!output) return [];
  const records = output.split("\0");
  if (records.at(-1) === "") records.pop();
  if (records.some((record) => record.length === 0)) {
    throw new Error(`${command} ha restituito un pathname vuoto`);
  }
  return records;
}

export function changedFiles(base, head = "HEAD", cwd = process.cwd()) {
  const committed = nulSeparatedOutput("git", [
    "diff",
    "--no-renames",
    "--name-only",
    "-z",
    "--diff-filter=ACMRD",
    `${base}...${head}`,
  ], cwd);
  if (head !== "HEAD") return committed;
  return [
    ...committed,
    ...nulSeparatedOutput(
      "git",
      ["diff", "--no-renames", "--name-only", "-z", "--diff-filter=ACMRD"],
      cwd,
    ),
    ...nulSeparatedOutput("git", [
      "diff",
      "--no-renames",
      "--cached",
      "--name-only",
      "-z",
      "--diff-filter=ACMRD",
    ], cwd),
    ...nulSeparatedOutput(
      "git",
      ["ls-files", "--others", "--exclude-standard", "-z"],
      cwd,
    ),
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
    "scripts/generated-directory-safety.test.mjs",
    "scripts/publication-gate.test.mjs",
    "scripts/verify-change.test.mjs",
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

async function main() {
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
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  await main();
}
