---
name: gc-ai-tools
description: >
  Dispatch the gc-ai-tools agent to query or manage Google Cloud via the gcloud CLI. Use
  for /gc-ai-tools or whenever the user asks about Google Cloud resources, projects,
  costs, or infrastructure, or wants something created, modified, or removed there.
argument-hint: "[what to inspect or change in Google Cloud]"
---

# Google Cloud dispatch

This skill runs no `gcloud` command itself. It dispatches the `gc-ai-tools` agent — whose harness wrapper pins its model — and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: this agent works on Google Cloud, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. It executes a mutation only after explicit per-action approval relayed through this session. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `gc-ai-tools` agent with the user's request, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not run `gcloud` inline under this skill.

## Relay

- The agent reads freely and returns every mutation for approval. Relay each request to the user in their language, including its cost impact; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.
- Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Report

- Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
