import { pathToFileURL } from "node:url";

const required = (value) => value === true || value === "true";

export function visualEvidenceApproved(body) {
  return /^- \[[xX]\] Screenshot o video allegati per modifiche UI\s*$/m.test(body || "");
}

export function evaluatePublicationGate(input) {
  const checks = [
    ["classificazione", true, input.classifyResult],
    ["validazioni", required(input.validationRequired), input.validationResult],
    ["Swift format", required(input.formatRequired), input.formatResult],
    ["build e test", required(input.buildRequired), input.buildResult],
    ["CodeQL", required(input.codeqlRequired), input.codeqlResult],
  ];
  const failures = checks.filter(([, isRequired, result]) => isRequired && result !== "success");
  if (failures.length) {
    throw new Error(failures.map(([name, , result]) => `${name}: ${result}`).join("; "));
  }
  if (
    required(input.visualEvidenceRequired)
    && !visualEvidenceApproved(input.pullRequestBody)
  ) {
    throw new Error("Evidenza visuale UI non registrata nella checklist della PR");
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
    const result = evaluatePublicationGate({
      buildRequired: process.env.BUILD_REQUIRED,
      buildResult: process.env.BUILD_RESULT,
      classifyResult: process.env.CLASSIFY_RESULT,
      codeqlRequired: process.env.CODEQL_REQUIRED,
      codeqlResult: process.env.CODEQL_RESULT,
      formatRequired: process.env.FORMAT_REQUIRED,
      formatResult: process.env.FORMAT_RESULT,
      validationRequired: process.env.VALIDATION_REQUIRED,
      validationResult: process.env.VALIDATION_RESULT,
      visualEvidenceRequired: process.env.VISUAL_EVIDENCE_REQUIRED,
      pullRequestBody: process.env.PULL_REQUEST_BODY,
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
