---
name: az-ai-tools
description: >
  Query or manage Azure via the Azure CLI (az). Use for /az-ai-tools or Azure
  resources,
  subscriptions, costs, or infrastructure. Impact: mutations can create
  billable resources and remove existing ones; neither is easy to undo.
  Reads run freely; each mutation needs an explicit yes for that action.
argument-hint: "[what to inspect or change in Azure]"
---

# Azure

Inventory, cost, and operations on Azure through the Azure CLI (`az`).

## Workflow

Use the Azure CLI (`az`) for inventory, cost, and operations on the request you were given, then stop.

### Rules

- Run **read-only / query** commands freely (list, show, describe, costs).
- Put each proposed mutation to the user as its own request — command, target, reason, and cost or blast impact — and run it only on an explicit yes for that action. Approval never carries over between actions. Never create, modify, or remove a resource without that yes.
- Every suggested mutation states its **cost impact**: SKU, ongoing cost, billable status.
- Keep the report concise: tables or summaries. Save full output to a file only if the request asked for it.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `az` discovery — commands, state, collected output. They return facts: command, exit code, output path.

### Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — resource inspection
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise output.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
