> Skill base, loaded by the wrapper at `skills/gc-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Inventory, cost, and operations on Google Cloud through the `gcloud` CLI. Dispatches `planner-ai-tools` to follow **Workflow**. Run `gcloud` only inside that dispatch.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

Tell the user, in their language, before anything runs: this work touches Google Cloud, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. A mutation runs only after their explicit approval for that specific action.

## Route A — dispatch

The agent reads freely and returns every mutation for approval, including its cost impact.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.

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
