---
name: gc-ai-tools
description: >
  Query or manage Google Cloud through the gcloud CLI. Use for /gc-ai-tools or
  Google Cloud resources, projects, costs, and infrastructure. Impact:
  mutations may create billable resources or remove existing ones and can be
  hard to reverse. Reads run freely; each mutation requires an explicit yes.
  Min. role: implementer.
argument-hint: "[what to inspect or change in Google Cloud]"
---

# Google Cloud

Inventory, cost, and operations on Google Cloud through the `gcloud` CLI.

## Workflow

Use `gcloud` for the requested inventory, cost analysis, or operation, then stop.

### Rules

- Run **read-only queries** freely: list, describe, and costs.
- Present each mutation as a separate approval request with its command, target, reason, and cost or blast impact. Execute it only after an explicit yes for that action; approval never carries over.
- State each proposed mutation's **cost impact**: SKU, ongoing cost, and billable status.

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

Write inventories, cost breakdowns, logs, and listings to `dev/tmp/<topic>.md`, then give the user its path—opened in their editor where supported. In the user's language, chat carries the direct answer and any mutation awaiting approval. A one- or two-line result may stay in chat alone.
