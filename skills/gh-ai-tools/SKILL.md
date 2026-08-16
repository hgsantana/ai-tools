---
name: gh-ai-tools
description: >
  Dispatch the gh-ai-tools agent to query or manage GitHub via the GitHub CLI (gh). Use
  for /gh-ai-tools or whenever the user asks about GitHub repositories, pull requests,
  issues, releases, or workflows, or wants something created, changed, or removed there.
argument-hint: "[what to inspect or change on GitHub]"
---

# GitHub dispatch

This skill runs no `gh` command itself. It dispatches the `gh-ai-tools` agent — whose harness wrapper pins its model — and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: this agent works on GitHub, where actions can merge, close, comment, push, and delete — visible to other people immediately and often irreversible. It executes a mutation only after explicit per-action approval relayed through this session. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `gh-ai-tools` agent with the user's request, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not run `gh` inline under this skill.

## Relay

- The agent reads freely and returns every mutation for approval. Relay each request to the user in their language; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.
- Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Report

- Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
