import { pathToFileURL } from "node:url";

const required = (value) => value === true || value === "true";

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
  return {
    needsVisualEvidence: required(input.visualEvidenceRequired),
  };
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
    });
    if (result.needsVisualEvidence) {
      console.log("Evidenza visuale richiesta nel ciclo di pubblicazione.");
    }
    console.log("Tutti i gate applicabili sono verdi.");
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
