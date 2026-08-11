---
name: az-ai-tools
description: >
  Query and manage Azure resources via the Azure CLI (az). Use whenever the user asks about
  Azure resources, subscriptions, costs, or infrastructure, or wants something created,
  modified, or removed in Azure. Also use for /az-ai-tools.
---

# Azure CLI (az)

Use the `az` CLI for Azure inventory, cost, and operations work.

## Rules

- Freely use `az` for **read-only / query** operations (list, show, query costs, describe resources).
- You may **suggest** creating, modifying, or removing Azure resources; only the user decides.
- **NEVER** create, modify, or remove any Azure resource without **explicit** user authorization
  for that specific action. Prior approval does not carry over, and this gate holds even inside an
  unattended `/dev-ai-tools` run.
- Before any suggested mutating change, make **cost impact** clear (SKU, ongoing cost, billable or not).

## Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — inspect a resource
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise reports.
