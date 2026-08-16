---
name: gc-ai-tools
description: >
  Query and manage Google Cloud resources via the Google Cloud CLI (gcloud). Use whenever the
  user asks about Google Cloud resources, projects, costs, or infrastructure, or wants something
  created, modified, or removed in Google Cloud. Also use for /gc-ai-tools.
---

# Google Cloud CLI (gcloud)

## Entry gate — required category: planner

This skill must run on a **planner** model. Before anything else:

1. Decide whether you are one (*Agent categories*, in the global agent instructions).
2. **You are** — run the skill here, spawning the subagents it names.
3. **You are not, or cannot tell** — do not start it and do not delegate it. Send one short chat message in
   the user's language: name the model running this session (or say the harness does not expose it); say how
   to get a planner here — switch this session to the harness's strongest model, or start the work over from
   the `planner-ai-tools` agent, which is pinned to one; then ask whether to run anyway. Wait for the answer.
4. **Yes** — run the skill here, as its planner, for the rest of the session; ask again only if the model
   changes. **No, or no answer** — stop here: no exploration, no writes, no spawns.

Name the stake in that message, so the answer is an informed one: this skill can create billable Google Cloud resources and remove existing ones, and neither is easy to undo.

## Rules

Use `gcloud` CLI for Google Cloud inventory, cost, and operations.

- Freely run **read-only / query** commands (list, describe, query costs).
- You may **suggest** mutations; only the user decides.
- **NEVER** create, modify, or remove any Google Cloud resource without **explicit** user authorization for that specific action. Approval never carries over, even inside unattended `/dev-ai-tools`.
- Before suggesting mutations, state clear **cost impact** (SKU, ongoing cost, billable status).
- Keep chat replies concise: tables or summaries. Save full output to a file only if requested.

## Delegated exploration

Planner may spawn **mechanical** or **implementer** subagents to explore `gcloud` (discover commands, read state, collect output):
- Strictly read-only query commands.
- Return facts, never verdicts or change proposals.
- Planner alone decides and executes mutating commands after presenting cost/risk/reason and receiving explicit per-action approval.
- Entry-gate authorization does not authorize mutations.

## Useful commands

- `gcloud config list` / `gcloud projects list` — project context
- `gcloud projects describe <project>` — inspect project
- `gcloud <service> list` / `gcloud <service> describe` — resource inspection
- `gcloud billing accounts list` / `gcloud billing projects describe` — billing
- `gcloud logging read` / `gcloud monitoring` — logs and metrics
- `gcloud asset search-all-resources` — inventory across project/org

Prefer `--format="table(...)"` or JSON piped through `jq` for concise output.
