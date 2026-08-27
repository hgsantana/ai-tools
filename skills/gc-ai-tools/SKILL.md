---
name: gc-ai-tools
description: >
  Query or manage Google Cloud via the gcloud CLI. Use for /gc-ai-tools or
  Google Cloud
  resources, projects, costs, or infrastructure. Impact: mutations can
  create billable resources and remove existing ones; neither is easy to
  undo. Reads run freely; each mutation needs an explicit yes for that
  action.
argument-hint: "[what to inspect or change in Google Cloud]"
---

# Google Cloud

Inventory, cost, and operations on Google Cloud through the `gcloud` CLI.

## Workflow

Use the Google Cloud CLI (`gcloud`) for inventory, cost, and operations on the request you were given, then stop.

### Rules

- Run **read-only / query** commands freely (list, describe, query costs).
- Put each proposed mutation to the user as its own request — command, target, reason, and cost or blast impact — and run it only on an explicit yes for that action. Approval never carries over between actions. Never create, modify, or remove a resource without that yes.
- Every suggested mutation states its **cost impact**: SKU, ongoing cost, billable status.
- Collected output — inventories, cost breakdowns, logs, listings — goes to a file under `dev/tmp/` and is handed over as a path. Chat carries the direct answer to what was asked; a result that genuinely fits in a line or two needs no file.

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

Write the findings to `dev/tmp/<topic>.md` and give the user its path — opened in their editor where the harness can. Chat carries, in the user's language, the direct answer to what was asked and any mutation still awaiting a yes.
