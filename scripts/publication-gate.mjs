import { pathToFileURL } from "node:url";

const required = (value) => value === true || value === "true";
const validSha = (value) => /^[0-9a-f]{40}$/.test(value || "");

export const manualEvidenceContexts = {
  apple: "manual-evidence/apple",
  visual: "manual-evidence/visual",
};

export function manualEvidenceApproved(evidence, headSha, context) {
  if (!validSha(headSha) || evidence?.headSha !== headSha || !Array.isArray(evidence.statuses)) {
    return false;
  }
  const latestStatus = evidence.statuses.find((status) => status.context === context);
  return latestStatus?.state === "success";
}

async function githubJSON(path, token) {
  const response = await fetch(`https://api.github.com${path}`, {
    headers: {
      accept: "application/vnd.github+json",
      authorization: `Bearer ${token}`,
      "x-github-api-version": "2022-11-28",
    },
  });
  if (!response.ok) throw new Error(`Lettura attestazioni manuali fallita: ${response.status}`);
  return response.json();
}

export async function readManualEvidence({
  headSha,
  repository,
  token,
  requestJSON = githubJSON,
}) {
  if (!validSha(headSha)) throw new Error("HEAD delle attestazioni manuali non valido");
  if (!/^[^/\s]+\/[^/\s]+$/.test(repository || "")) {
    throw new Error("Repository delle attestazioni manuali non valido");
  }
  if (!token) throw new Error("Token GitHub delle attestazioni manuali mancante");
  const statuses = await requestJSON(
    `/repos/${repository}/commits/${headSha}/statuses?per_page=100`,
    token,
  );
  if (!Array.isArray(statuses)) throw new Error("Risposta attestazioni manuali non valida");
  return { headSha, statuses };
}

export function evaluatePublicationGate(input) {
  const checks = [
    ["classificazione", true, input.classifyResult],
    ["validazioni", required(input.validationRequired), input.validationResult],
    ["Swift format", required(input.formatRequired), input.formatResult],
    ["CodeQL", required(input.codeqlRequired), input.codeqlResult],
  ];
  const failures = checks.filter(([, isRequired, result]) => isRequired && result !== "success");
  if (failures.length) {
    throw new Error(failures.map(([name, , result]) => `${name}: ${result}`).join("; "));
  }
  if (
    required(input.visualEvidenceRequired)
    && !manualEvidenceApproved(
      input.manualEvidence,
      input.pullRequestHead,
      manualEvidenceContexts.visual,
    )
  ) {
    throw new Error("Evidenza visuale UI trusted non registrata per l'HEAD corrente");
  }
  if (
    required(input.appleEvidenceRequired)
    && !manualEvidenceApproved(
      input.manualEvidence,
      input.pullRequestHead,
      manualEvidenceContexts.apple,
    )
  ) {
    throw new Error("Build e test Apple trusted non registrati per l'HEAD corrente");
  }
  return {
    needsVisualEvidence: required(input.visualEvidenceRequired),
  };
}

export function publicationStatus({ description, state }, environment = process.env) {
  if (!["error", "failure", "pending", "success"].includes(state)) {
    throw new Error("Stato publication-gate non valido");
  }
  return {
    context: "publication-gate",
    description,
    state,
    target_url: environment.GITHUB_SERVER_URL && environment.GITHUB_RUN_ID
      ? `${environment.GITHUB_SERVER_URL}/${environment.GITHUB_REPOSITORY}/actions/runs/${environment.GITHUB_RUN_ID}`
      : undefined,
  };
}

async function setStatus(payload) {
  const response = await fetch(
    `https://api.github.com/repos/${process.env.GITHUB_REPOSITORY}/statuses/${process.env.PULL_REQUEST_HEAD}`,
    {
      method: "POST",
      headers: {
        accept: "application/vnd.github+json",
        authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
        "content-type": "application/json",
        "x-github-api-version": "2022-11-28",
      },
      body: JSON.stringify(payload),
    },
  );
  if (!response.ok) throw new Error(`Aggiornamento publication-gate fallito: ${response.status}`);
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  try {
    const manualEvidenceRequired = required(process.env.APPLE_EVIDENCE_REQUIRED)
      || required(process.env.VISUAL_EVIDENCE_REQUIRED);
    const manualEvidence = manualEvidenceRequired
      ? await readManualEvidence({
          headSha: process.env.PULL_REQUEST_HEAD,
          repository: process.env.GITHUB_REPOSITORY,
          token: process.env.GITHUB_TOKEN,
        })
      : undefined;
    const result = evaluatePublicationGate({
      appleEvidenceRequired: process.env.APPLE_EVIDENCE_REQUIRED,
      classifyResult: process.env.CLASSIFY_RESULT,
      codeqlRequired: process.env.CODEQL_REQUIRED,
      codeqlResult: process.env.CODEQL_RESULT,
      formatRequired: process.env.FORMAT_REQUIRED,
      formatResult: process.env.FORMAT_RESULT,
      validationRequired: process.env.VALIDATION_REQUIRED,
      validationResult: process.env.VALIDATION_RESULT,
      visualEvidenceRequired: process.env.VISUAL_EVIDENCE_REQUIRED,
      manualEvidence,
      pullRequestHead: process.env.PULL_REQUEST_HEAD,
    });
    if (result.needsVisualEvidence) {
      console.log("Evidenza visuale richiesta nel ciclo di pubblicazione.");
    }
    await setStatus(
      publicationStatus({
        description: "Tutti i controlli applicabili sono verdi",
        state: "success",
      }),
    );
    console.log("Tutti i gate applicabili sono verdi.");
  } catch (error) {
    try {
      await setStatus(
        publicationStatus({
          description: "Uno o più controlli applicabili non sono verdi",
          state: "failure",
        }),
      );
    } catch (statusError) {
      console.error(statusError.message);
    }
    console.error(error.message);
    process.exitCode = 1;
  }
}
