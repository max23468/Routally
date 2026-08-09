import { pathToFileURL } from "node:url";

const CODEX_BOT = "chatgpt-codex-connector[bot]";
const isDirectExecution =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

const timestamp = (value) => new Date(value ?? 0).getTime();
const reviewedCommit = (body = "") =>
  body.match(/\*\*Reviewed commit:\*\*\s*`([0-9a-f]{10,40})`/i)?.[1];

export function classifyCodexReview({
  headSha,
  requestedAt,
  now = Date.now(),
  comments,
  reactions,
  progressReactions = reactions,
  requiresReviewedCommit = false,
  reviews = [],
  reviewComments,
  timeline = [],
}) {
  const completions = [];
  const advisoryFindings = [];
  const cleanComments = [];
  const reviewRequestIndex = comments.reduce(
    (latest, comment, index) =>
      comment.user?.login !== CODEX_BOT && /^\s*@codex\s+review\b/im.test(comment.body)
        ? index
        : latest,
    -1,
  );
  const attemptStartedAt = Math.max(
    timestamp(requestedAt),
    timestamp(comments[reviewRequestIndex]?.created_at),
  );
  const reviewRequestTimelineIndex = timeline.reduce(
    (latest, item, index) =>
      item.event === "commented" &&
      item.user?.login !== CODEX_BOT &&
      /^\s*@codex\s+review\b/im.test(item.body)
        ? index
        : latest,
    -1,
  );
  const currentReviewIds = new Set(
    timeline
      .slice(reviewRequestTimelineIndex + 1)
      .filter(
        (item) =>
          item.event === "reviewed" &&
          item.user?.login === CODEX_BOT &&
          item.commit_id === headSha,
      )
      .map((item) => item.id),
  );
  const inProgress = progressReactions.some(
    (reaction) =>
      reaction.user?.login === CODEX_BOT &&
      reaction.content === "eyes" &&
      timestamp(reaction.created_at) >= attemptStartedAt,
  );

  for (const comment of reviewComments) {
    if (
      comment.user?.login === CODEX_BOT &&
      (comment.original_commit_id ?? comment.commit_id) === headSha &&
      (reviewRequestTimelineIndex < 0 ||
        currentReviewIds.has(comment.pull_request_review_id)) &&
      timestamp(comment.created_at) >= attemptStartedAt &&
      /\bP[0-3]\b/.test(comment.body)
    ) {
      if (/\bP[01]\b/.test(comment.body)) {
        completions.push({
          state: "failure",
          at: timestamp(comment.created_at),
          description: "Codex ha trovato problemi P0/P1 nell'ultimo commit",
        });
      } else {
        advisoryFindings.push(timestamp(comment.created_at));
      }
    }
  }

  if (completions.length) {
    return completions.sort((left, right) => right.at - left.at)[0];
  }

  for (const [commentIndex, comment] of comments.entries()) {
    if (comment.user?.login !== CODEX_BOT) continue;

    const commit = reviewedCommit(comment.body);
    if (
      (commit
        ? headSha.startsWith(commit)
        : attemptStartedAt > 0 &&
          (reviewRequestIndex < 0 || commentIndex > reviewRequestIndex)) &&
      timestamp(comment.created_at) >= attemptStartedAt &&
      /\bP[0-3]\b/.test(comment.body)
    ) {
      if (/\bP[01]\b/.test(comment.body)) {
        completions.push({
          state: "failure",
          at: timestamp(comment.created_at),
          description: "Codex ha trovato problemi P0/P1 nell'ultimo commit",
        });
      } else {
        advisoryFindings.push(timestamp(comment.created_at));
      }
    }

    if (
      commit &&
      headSha.startsWith(commit) &&
      timestamp(comment.created_at) >= attemptStartedAt &&
      /^Codex Review: Didn't find any major issues\./m.test(comment.body)
    ) {
      completions.push({
        state: "success",
        at: timestamp(comment.created_at),
        description: "Codex ha approvato l'ultimo commit",
      });
    }

    if (
      timestamp(comment.created_at) >= attemptStartedAt &&
      now - attemptStartedAt >= 30_000 &&
      !inProgress &&
      /reached your Codex usage limits|could not complete|unable to review/i.test(comment.body)
    ) {
      completions.push({
        state: "failure",
        at: timestamp(comment.created_at),
        description: "La review Codex non è stata completata",
      });
    }
  }

  const commentFailure = completions
    .filter((completion) => completion.state === "failure")
    .sort((left, right) => right.at - left.at)[0];
  if (commentFailure) return commentFailure;

  for (const review of reviews) {
    const commit = reviewedCommit(review.body);
    if (
      review.user?.login === CODEX_BOT &&
      commit &&
      headSha.startsWith(commit) &&
      (reviewRequestTimelineIndex < 0 || currentReviewIds.has(review.id)) &&
      timestamp(review.submitted_at) >= attemptStartedAt
    ) {
      cleanComments.push(timestamp(review.submitted_at));
    }
  }

  const latestAdvisoryAt = Math.max(...advisoryFindings, 0);
  const matchingReviewAt = cleanComments
    .filter((reviewAt) => Math.abs(reviewAt - latestAdvisoryAt) <= 30_000)
    .sort((left, right) => right - left)[0];
  if (latestAdvisoryAt && matchingReviewAt && now - matchingReviewAt >= 30_000) {
    completions.push({
      state: "success",
      at: matchingReviewAt,
      description: "Codex ha completato la review con soli finding P2/P3 advisory",
    });
  }

  const thumbsUpAt = reactions
    .filter(
      (reaction) =>
        reaction.user?.login === CODEX_BOT &&
        reaction.content === "+1" &&
        timestamp(reaction.created_at) >= attemptStartedAt,
    )
    .reduce((latest, reaction) => Math.max(latest, timestamp(reaction.created_at)), 0);

  if (thumbsUpAt) {
    if (!requiresReviewedCommit) cleanComments.push(thumbsUpAt);
    for (const commentAt of cleanComments) {
      if (thumbsUpAt < commentAt) continue;
      completions.push({
        state: "success",
        at: Math.max(thumbsUpAt, commentAt),
        description: "Codex ha approvato l'ultimo commit",
      });
    }
  }

  return (
    completions.sort((left, right) => right.at - left.at)[0] ?? {
      state: "pending",
      description: "In attesa della review Codex sull'ultimo commit",
    }
  );
}

export const hasSuccessfulCodexStatus = (statuses) =>
  statuses.find((status) => status.context === "codex-review")?.state === "success";

export function pullRequestNumber(event, input) {
  const number = String(event.pull_request?.number ?? input);
  if (!/^\d+$/.test(number)) throw new Error("Numero PR non valido");
  return number;
}

async function request(path, options = {}) {
  const response = await fetch(`https://api.github.com${path}`, {
    ...options,
    headers: {
      accept: "application/vnd.github+json",
      authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
      "x-github-api-version": "2022-11-28",
      ...options.headers,
    },
  });
  if (!response.ok) throw new Error(`${options.method ?? "GET"} ${path}: ${response.status}`);
  return response.json();
}

async function all(path) {
  const items = [];
  for (let page = 1; ; page += 1) {
    const batch = await request(
      `${path}${path.includes("?") ? "&" : "?"}per_page=100&page=${page}`,
    );
    items.push(...batch);
    if (batch.length < 100) return items;
  }
}

async function setStatus(repository, sha, state, description) {
  await request(`/repos/${repository}/statuses/${sha}`, {
    method: "POST",
    body: JSON.stringify({
      state,
      context: "codex-review",
      description,
      target_url: `${process.env.GITHUB_SERVER_URL}/${repository}/actions/runs/${process.env.GITHUB_RUN_ID}`,
    }),
  });
}

const reviewSignals = (repository, number) =>
  Promise.all([
    all(`/repos/${repository}/issues/${number}/comments`),
    all(`/repos/${repository}/issues/${number}/reactions`),
    all(`/repos/${repository}/pulls/${number}/reviews`),
    all(`/repos/${repository}/pulls/${number}/comments`),
    all(`/repos/${repository}/issues/${number}/timeline`),
  ]);

async function main() {
  const event = JSON.parse(
    await (await import("node:fs/promises")).readFile(process.env.GITHUB_EVENT_PATH),
  );
  const repository = process.env.GITHUB_REPOSITORY;
  const requestedNumber = pullRequestNumber(event, process.env.PULL_REQUEST_NUMBER);
  const pullRequest =
    event.pull_request ?? (await request(`/repos/${repository}/pulls/${requestedNumber}`));
  const number = pullRequest.number;
  const headSha = pullRequest.head.sha;
  const reusesExistingReview =
    process.env.GITHUB_EVENT_NAME === "workflow_dispatch" || event.action === "reopened";

  if (reusesExistingReview) {
    const statuses = await all(`/repos/${repository}/commits/${headSha}/statuses`);
    if (hasSuccessfulCodexStatus(statuses)) return;
  }

  await setStatus(
    repository,
    headSha,
    "pending",
    "In attesa della review Codex sull'ultimo commit",
  );
  if (pullRequest.draft) return;

  if (["opened", "ready_for_review"].includes(event.action)) {
    await new Promise((resolve) => setTimeout(resolve, 30_000));
    const currentPullRequest = await request(`/repos/${repository}/pulls/${number}`);
    if (currentPullRequest.head.sha !== headSha) return;
  }

  const freshReview = ["opened", "ready_for_review"].includes(event.action);
  const requestedAt = reusesExistingReview ? 0 : pullRequest.updated_at;
  for (let attempt = 0; attempt < 600; attempt += 1) {
    const [comments, reactions, reviews, reviewComments, timeline] = await reviewSignals(
      repository,
      number,
    );
    const result = classifyCodexReview({
      headSha,
      requestedAt,
      comments,
      reactions,
      requiresReviewedCommit: !freshReview,
      reviews,
      reviewComments,
      timeline,
    });
    if (result.state !== "pending") {
      await setStatus(repository, headSha, result.state, result.description);
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 30_000));
  }

  await setStatus(repository, headSha, "error", "Review Codex non conclusa entro cinque ore");
}

if (process.env.GITHUB_ACTIONS === "true" && isDirectExecution) {
  await main().catch(async (error) => {
    console.error(error);
    const event = JSON.parse(
      await (await import("node:fs/promises")).readFile(process.env.GITHUB_EVENT_PATH),
    );
    let requestedNumber;
    try {
      requestedNumber = pullRequestNumber(event, process.env.PULL_REQUEST_NUMBER);
    } catch {
      return;
    }
    const pullRequest =
      event.pull_request ??
      (await request(`/repos/${process.env.GITHUB_REPOSITORY}/pulls/${requestedNumber}`).catch(
        () => null,
      ));
    if (!pullRequest) return;
    await setStatus(
      process.env.GITHUB_REPOSITORY,
      pullRequest.head.sha,
      "error",
      "Impossibile verificare la review Codex",
    ).catch(console.error);
  });
}
