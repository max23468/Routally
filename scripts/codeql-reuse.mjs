import { appendFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

export const codeQLAnalysisIdentity = {
  analysisKey: ".github/workflows/publication-gate.yml:codeql-upload",
  category: "/language:swift/pr-validation",
};

export function reusableCodeQLAnalysis(analyses, mergeSha) {
  if (!/^[0-9a-f]{40}$/.test(mergeSha || "")) return undefined;
  return analyses.find(
    (analysis) =>
      analysis.ref?.startsWith("refs/pull/")
      && analysis.commit_sha === mergeSha
      && analysis.category === codeQLAnalysisIdentity.category
      && analysis.analysis_key === codeQLAnalysisIdentity.analysisKey
      && analysis.error === "",
  );
}

async function githubJSON(path, token) {
  const response = await fetch(`https://api.github.com${path}`, {
    headers: {
      accept: "application/vnd.github+json",
      authorization: `Bearer ${token}`,
      "x-github-api-version": "2022-11-28",
    },
  });
  if (!response.ok) {
    throw new Error(`Lettura GitHub fallita per ${path}: ${response.status}`);
  }
  return response.json();
}

export async function inspectReusableCodeQL({
  expectedHeadSha,
  pullRequestNumber,
  requestJSON = githubJSON,
  repository,
  token,
}) {
  if (!/^\d+$/.test(pullRequestNumber || "")) {
    throw new Error("Numero della pull request non valido");
  }
  if (!/^[0-9a-f]{40}$/.test(expectedHeadSha || "")) {
    throw new Error("HEAD atteso della pull request non valido");
  }
  if (!/^[^/]+\/[^/]+$/.test(repository || "")) {
    throw new Error("Repository GitHub non valida");
  }
  if (!token) throw new Error("Token GitHub assente");

  const pullRequest = await requestJSON(
    `/repos/${repository}/pulls/${pullRequestNumber}`,
    token,
  );
  if (pullRequest.head?.sha !== expectedHeadSha) {
    throw new Error("L'HEAD della pull request è cambiato durante la verifica");
  }
  const mergeSha = pullRequest.merge_commit_sha;
  if (!/^[0-9a-f]{40}$/.test(mergeSha || "")) {
    throw new Error("Merge SHA della pull request non disponibile");
  }

  const ref = encodeURIComponent(`refs/pull/${pullRequestNumber}/merge`);
  const analyses = await requestJSON(
    `/repos/${repository}/code-scanning/analyses?ref=${ref}&per_page=100`,
    token,
  );
  return {
    analysis: reusableCodeQLAnalysis(analyses, mergeSha),
    mergeSha,
  };
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  try {
    const result = await inspectReusableCodeQL({
      expectedHeadSha: process.env.PULL_REQUEST_HEAD,
      pullRequestNumber: process.env.PULL_REQUEST_NUMBER,
      repository: process.env.GITHUB_REPOSITORY,
      token: process.env.GITHUB_TOKEN,
    });
    const reusable = Boolean(result.analysis);
    if (!process.env.GITHUB_OUTPUT) throw new Error("GITHUB_OUTPUT assente");
    await appendFile(
      process.env.GITHUB_OUTPUT,
      `reusable=${reusable}\nmerge_sha=${result.mergeSha}\n`,
    );
    console.log(
      reusable
        ? `Analisi CodeQL riutilizzabile per ${result.mergeSha}.`
        : `Nessuna analisi CodeQL riutilizzabile per ${result.mergeSha}.`,
    );
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
