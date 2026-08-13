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
3. **You do not, or cannot tell** — never delegate this skill and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. Run here only if the user authorizes it. That authorization holds for the rest of the session and is
   asked again only if the model changes. Declined or unanswered — stop: no exploration, no writes, no
   spawns.

## Rules

Use the `gcloud` CLI for Google Cloud inventory, cost, and operations work.

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
- An entry-gate authorization to run this skill is not authorization to mutate anything. Every mutating action still needs its own explicit approval.

## Useful commands

- `gcloud config list` / `gcloud projects list` — project context
- `gcloud projects describe <project>` — inspect a project
- `gcloud <service> list` / `gcloud <service> describe` — inspect a resource
- `gcloud billing accounts list` / `gcloud billing projects describe` — billing
- `gcloud logging read` / `gcloud monitoring` — logs and metrics
- `gcloud asset search-all-resources` — inventory across project/org

Prefer `--format="table(...)"` or JSON piped through `jq` for concise reports.
