---
name: gc-ai-tools
description: >
  Run the gc-ai-tools work — query or manage Google Cloud via the gcloud CLI — carried in this session under the planner-ai-tools role. Use for /gc-ai-tools or whenever the user asks about Google
  Cloud resources, projects, costs, or infrastructure, or wants something created, modified, or
  removed there.
argument-hint: "[what to inspect or change in Google Cloud]"
---

# Google Cloud

Inventory, cost, and operations on Google Cloud through the `gcloud` CLI.

## Continue?

This skill expects this session to be the **planner** (`MODELS.md` planner cell for this harness).

Before anything is read, run, or changed, send **one** short message in the user's language:

1. The stake (**Stake** below).
2. Whether this session is the planner: read this harness's `planner` cell in `$HOME/.ai-tools/MODELS.md` and compare it with the session model.
   - They match — this session is the planner. Say so in one line.
   - They differ, or the session model is undetermined — this session is not the planner. Name the session model, or say it is undetermined, and name how to change the session model in this harness (`MODELS.md` last column).
3. Then ask: do you want to continue?
   - a) yes
   - b) no

Wait for an explicit answer. Never pick for the user.

- **No** (or anything that is not yes) — stop. Nothing is read, run, or changed.
- **Yes** — this session carries `planner-ai-tools` (base `$HOME/.ai-tools/agents/planner-ai-tools.md`; on Windows `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`) and follows **Workflow**. Announce every spawn in the user's language with the agent name. Spawn depth is one.

Proceeding on a non-planner session is the user's call. This skill never refuses over the session model.

## Stake

Tell the user, in their language, before anything runs: this work touches Google Cloud, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. A mutation runs only after their explicit approval for that specific action.

## Workflow

Use the Google Cloud CLI (`gcloud`) for inventory, cost, and operations on the request you were given, then stop.

### Rules

- Run **read-only / query** commands freely (list, describe, query costs).
- Put each proposed mutation to the user as its own request — command, target, reason, and cost or blast impact — and run it only on an explicit yes for that action. Approval never carries over between actions. Never create, modify, or remove a resource without that yes.
- Every suggested mutation states its **cost impact**: SKU, ongoing cost, billable status.
- Keep the report concise: tables or summaries. Save full output to a file only if the request asked for it.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `gcloud` discovery — commands, state, collected output. They return facts: command, exit code, output path.

### Useful commands

- `gcloud config list` / `gcloud projects list` — project context
- `gcloud projects describe <project>` — inspect project
- `gcloud <service> list` / `gcloud <service> describe` — resource inspection
- `gcloud billing accounts list` / `gcloud billing projects describe` — billing
- `gcloud logging read` / `gcloud monitoring` — logs and metrics
- `gcloud asset search-all-resources` — inventory across project/org

Prefer `--format="table(...)"` or JSON piped through `jq` for concise output.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
