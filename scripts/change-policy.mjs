const matchesAny = (file, patterns) => patterns.some((pattern) => pattern.test(file));

const swiftSource = /\.swift$/;
const projectConfiguration = [
  /(^|\/)Package\.swift$/,
  /(^|\/)Package\.resolved$/,
  /\.xcodeproj\//,
  /^Configuration\//,
];
const uiSurface = [
  /^RoutallyApp\//,
  /^Packages\/RoutallyModules\/Sources\/[^/]+\/Resources\//,
  /^Packages\/RoutallyModules\/Sources\/RoutallyDesign\//,
  /^Packages\/RoutallyModules\/Sources\/RoutallyFeatures\//,
  /\.xcassets\//,
  /\.icon\//,
];
const canonicalDocumentation = [
  /^AGENTS\.md$/,
  /^CLAUDE\.md$/,
  /^docs\/MASTER_PLAN\.md$/,
  /^docs\/DECISION_REGISTER\.md$/,
  /^docs\/ADR\//,
  /^docs\/ENGINEERING\/agent-workflow\.md$/,
  /^docs\/PRODUCT\/ROADMAP\.md$/,
];
const governance = [/^\.github\//, /^scripts\//];
const releaseOrSecurity = [
  /^Configuration\//,
  /^docs\/RELEASE\//,
  /^docs\/SECURITY\//,
  /^SECURITY\.md$/,
];
const applicationPipeline = [
  /^\.github\/workflows\/codeql\.yml$/,
  /^\.github\/workflows\/publication-gate\.yml$/,
  /^\.github\/workflows\/swift-format\.yml$/,
];

export function classifyChangedFiles(inputFiles) {
  const files = [...new Set(inputFiles.filter(Boolean))].sort();
  const hasSwift = files.some((file) => swiftSource.test(file));
  const hasProjectConfiguration = files.some((file) =>
    matchesAny(file, projectConfiguration),
  );
  const hasUI = files.some((file) => matchesAny(file, uiSurface));
  const hasCanonicalDocumentation = files.some((file) =>
    matchesAny(file, canonicalDocumentation),
  );
  const hasGovernance = files.some((file) => matchesAny(file, governance));
  const hasReleaseOrSecurity = files.some((file) => matchesAny(file, releaseOrSecurity));
  const changesApplicationPipeline = files.some((file) => matchesAny(file, applicationPipeline));
  const hasDocumentation = files.some((file) => /\.md$/.test(file));
  const needsBuild = hasSwift || hasProjectConfiguration || hasUI || changesApplicationPipeline;
  const needsCodeQL = hasSwift || hasProjectConfiguration || changesApplicationPipeline;
  const needsRoadmap = hasCanonicalDocumentation || hasGovernance;
  const needsNodeTests = hasGovernance || hasCanonicalDocumentation;
  const needsSwiftFormat =
    hasSwift
    || files.some((file) => /\.colorset\/Contents\.json$/.test(file))
    || files.includes(".swift-format")
    || files.includes("scripts/check-ui-assets.mjs")
    || changesApplicationPipeline;
  const needsUIAssets = hasUI || files.includes("scripts/check-ui-assets.mjs");
  const needsVisualEvidence = hasUI;

  let kind = "other";
  if (hasDocumentation) kind = "documentation";
  if (hasCanonicalDocumentation) kind = "canonical-documentation";
  if (hasGovernance) kind = "governance";
  if (hasSwift || hasProjectConfiguration) kind = "swift";
  if (hasUI) kind = "ui";
  if (hasReleaseOrSecurity || changesApplicationPipeline) kind = "release-security";

  return {
    files,
    kind,
    needsBuild,
    needsCodeQL,
    needsNodeTests,
    needsRoadmap,
    needsSwiftFormat,
    needsUIAssets,
    needsVisualEvidence,
  };
}

export function githubOutputs(classification) {
  return {
    kind: classification.kind,
    needs_build: String(classification.needsBuild),
    needs_codeql: String(classification.needsCodeQL),
    needs_node_tests: String(classification.needsNodeTests),
    needs_roadmap: String(classification.needsRoadmap),
    needs_swift_format: String(classification.needsSwiftFormat),
    needs_ui_assets: String(classification.needsUIAssets),
    needs_visual_evidence: String(classification.needsVisualEvidence),
  };
}
