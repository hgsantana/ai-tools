---
name: gc-ai-tools
description: >
  Query and manage Google Cloud resources via the Google Cloud CLI (gcloud). Use whenever the
  user asks about Google Cloud resources, projects, costs, or infrastructure, or wants something
  created, modified, or removed in Google Cloud. Also use for /gc-ai-tools.
---

# Google Cloud CLI (gcloud)

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not, or cannot tell** — never delegate this skill, and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. **Authorized** — run this skill here, in this session, acting as its **planner** yourself. That
   authorization holds for the rest of the session and is asked again only if the model changes. Declined or
   unanswered — stop: no exploration, no writes, no spawns.

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
