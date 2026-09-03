---
name: az-ai-tools
description: >
  Query or manage Azure resources, subscriptions, costs, and infrastructure
  through the Azure CLI (az). Use for /az-ai-tools. Impact: mutations may
  create billable resources or remove resources and can be hard to reverse.
  Reads run freely; each mutation requires explicit approval. Min. role:
  implementer.
argument-hint: "[what to inspect or change in Azure]"
---

# Azure

Inventory, cost, and operations on Azure through the Azure CLI (`az`).

## Workflow

Use `az` for the requested inventory, cost analysis, or operation, then stop.

### Rules

- Run **read-only queries** freely: list, show, describe, and cost queries.
- Present each mutation as a separate approval request with its command, target, reason, and cost or blast impact. Execute it only after an explicit yes for that action; approval never carries over.
- State each proposed mutation's **cost impact**: SKU, ongoing cost, and billable status.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `az` discovery — commands, state, and collected output. It returns facts: command, exit code, and output path.

### Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — resource inspection
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise output.

## Report

Write inventories, cost breakdowns, logs, and listings to `dev/tmp/<topic>.md`, then give the user its path—opened in their editor where supported. In the user's language, chat carries the direct answer and any mutation awaiting approval. A one- or two-line result may stay in chat alone.
