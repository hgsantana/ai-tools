---
name: gc-ai-tools
description: >
  Query and manage Google Cloud resources via the Google Cloud CLI (gcloud). Use whenever the
  user asks about Google Cloud resources, projects, costs, or infrastructure, or wants something
  created, modified, or removed in Google Cloud. Also use for /gc-ai-tools.
---

# Google Cloud CLI (gcloud)

Use the `gcloud` CLI for Google Cloud inventory, cost, and operations work.

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not** — spawn the harness's planner (a model, or a bundled skill invoked with this skill's
   requirements added to its own rules), hand it this skill and the user's request in full, and become a
   relay layer: pass messages verbatim in both directions, summarizing nothing, approving nothing.
4. **You are the agent spawned to run this skill** — the gate is already satisfied. Go straight to the
   workflow and never delegate this skill onward.
5. **Roster not enumerable and no spawning available** — run here and say so in chat.

## Rules

- Freely use `gcloud` for **read-only / query** operations (list, describe, query costs).
- You may **suggest** creating, modifying, or removing resources; only the user decides.
- **NEVER** create, modify, or remove any Google Cloud resource without **explicit** user
  authorization for that specific action. Prior approval does not carry over, and this gate holds
  even inside an unattended `/dev-ai-tools` run.
- Before any suggested mutating change, make **cost impact** clear (SKU, ongoing cost, billable or not).
- Keep chat replies concise: a short table or summary, not a raw dump. For long or raw output, summarize in chat and save the full result to a file only if the user wants it kept.

## Delegated exploration

The planner running this skill may spawn **mechanical** or **implementer** subagents to explore `gcloud`: discover which commands exist, read current state, collect output.

- Strictly read-only. Query commands only — never create, modify, or remove anything.
- They return facts, never verdicts. They do not judge what should change.
- Only the planner decides on a mutating command and runs it, after presenting cost, risk, and reason, and getting explicit authorization for that specific action.
- When the planner is itself a spawned agent, that authorization request travels the relay verbatim. The relay never approves in the user's place.

## Useful commands

- `gcloud config list` / `gcloud projects list` — project context
- `gcloud projects describe <project>` — inspect a project
- `gcloud <service> list` / `gcloud <service> describe` — inspect a resource
- `gcloud billing accounts list` / `gcloud billing projects describe` — billing
- `gcloud logging read` / `gcloud monitoring` — logs and metrics
- `gcloud asset search-all-resources` — inventory across project/org

Prefer `--format="table(...)"` or JSON piped through `jq` for concise reports.
