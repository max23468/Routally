import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";

const commitPattern = /^[0-9a-f]{7,40}$/i;

function git(args) {
  const result = spawnSync("git", args, { encoding: "utf8" });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`git ${args.join(" ")} non riuscito\n${result.stderr || result.stdout}`);
  }
  return result.stdout.trim();
}

export function validateCommit(value, label) {
  if (!commitPattern.test(value ?? "")) throw new Error(`${label} non è un commit valido`);
  return value;
}

export function compareTrees(expectedTree, actualTree) {
  if (expectedTree !== actualTree) {
    throw new Error(
      `Il tree pubblicato ${actualTree} non coincide con il tree validato ${expectedTree}`,
    );
  }
  return true;
}

export function verifyMergeTree({ mergeCommit, pullRequestHead }) {
  validateCommit(mergeCommit, "merge commit");
  validateCommit(pullRequestHead, "PR head");
  const mergeParent = git(["rev-parse", `${mergeCommit}^1`]);
  const mergeTreeOutput = git(["merge-tree", "--write-tree", mergeParent, pullRequestHead]);
  const expectedTree = mergeTreeOutput.split("\n")[0];
  const actualTree = git(["rev-parse", `${mergeCommit}^{tree}`]);
  compareTrees(expectedTree, actualTree);
  return { actualTree, expectedTree, mergeCommit, mergeParent, pullRequestHead };
}

function argumentValue(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? undefined : process.argv[index + 1];
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  try {
    const result = verifyMergeTree({
      mergeCommit: argumentValue("--merge"),
      pullRequestHead: argumentValue("--pr-head"),
    });
    process.stdout.write(
      `Tree pubblicato equivalente al contenuto validato: ${result.actualTree}\n`,
    );
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
