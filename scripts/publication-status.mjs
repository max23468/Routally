import { pathToFileURL } from "node:url";

export function statusFromWorkflow({ conclusion, runURL }) {
  const success = conclusion === "success";
  return {
    context: "publication-gate",
    description: success
      ? "Tutti i controlli applicabili sono verdi"
      : `Gate di pubblicazione concluso: ${conclusion || "esito assente"}`,
    state: success ? "success" : "failure",
    target_url: runURL,
  };
}

export function validateStatusEnvironment(environment) {
  const required = [
    "GITHUB_REPOSITORY",
    "GITHUB_TOKEN",
    "PUBLICATION_CONCLUSION",
    "PUBLICATION_HEAD",
    "PUBLICATION_RUN_URL",
  ];
  const missing = required.filter((name) => !environment[name]);
  if (missing.length) {
    throw new Error(`Ambiente publication-status incompleto: ${missing.join(", ")}`);
  }
}

async function setStatus(environment, payload) {
  const response = await fetch(
    `https://api.github.com/repos/${environment.GITHUB_REPOSITORY}/statuses/${environment.PUBLICATION_HEAD}`,
    {
      method: "POST",
      headers: {
        accept: "application/vnd.github+json",
        authorization: `Bearer ${environment.GITHUB_TOKEN}`,
        "content-type": "application/json",
        "x-github-api-version": "2022-11-28",
      },
      body: JSON.stringify(payload),
    },
  );
  if (!response.ok) {
    throw new Error(`Aggiornamento publication-gate fallito: ${response.status}`);
  }
}

const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isDirectExecution) {
  try {
    validateStatusEnvironment(process.env);
    const payload = statusFromWorkflow({
      conclusion: process.env.PUBLICATION_CONCLUSION,
      runURL: process.env.PUBLICATION_RUN_URL,
    });
    await setStatus(process.env, payload);
    console.log(`${payload.context}: ${payload.state}`);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
