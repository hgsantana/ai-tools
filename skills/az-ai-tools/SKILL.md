---
name: az-ai-tools
description: >
  Query and manage Azure resources via the Azure CLI (az). Use whenever the user asks about
  Azure resources, subscriptions, costs, or infrastructure, or wants something created,
  modified, or removed in Azure. Also use for /az-ai-tools.
---

# Azure CLI (az)

## Entry gate — required category: planner

This skill must run on a **planner** model. Before anything else:

1. Decide whether you are one (*Agent categories*, in the global agent instructions).
2. **You are** — run the skill here, spawning the subagents it names.
3. **You are not, or cannot tell** — do not start it and do not delegate it. Send one short chat message in
   the user's language: name the model running this session (or say the harness does not expose it); say how
   to get a planner here — switch this session to the harness's strongest model, or start the work over from
   the `planner-ai-tools` agent, which is pinned to one; then ask whether to run anyway. Wait for the answer.
4. **Yes** — run the skill here, as its planner, for the rest of the session; ask again only if the model
   changes. **No, or no answer** — stop here: no exploration, no writes, no spawns.

Name the stake in that message, so the answer is an informed one: this skill can create billable Azure resources and remove existing ones, and neither is easy to undo.

## Rules

Use `az` CLI for Azure inventory, cost, and operations.

- Freely run **read-only / query** commands (list, show, costs, describe).
- You may **suggest** mutations; only the user decides.
- **NEVER** create, modify, or remove any Azure resource without **explicit** user authorization for that specific action. Approval never carries over, even inside unattended `/dev-ai-tools`.
- Before suggesting mutations, state clear **cost impact** (SKU, ongoing cost, billable status).
- Keep chat replies concise: tables or summaries. Save full output to a file only if requested.

## Delegated exploration

Planner may spawn **mechanical** or **implementer** subagents to explore `az` (discover commands, read state, collect output):
- Strictly read-only query commands.
- Return facts, never verdicts or change proposals.
- Planner alone decides and executes mutating commands after presenting cost/risk/reason and receiving explicit per-action approval.
- Entry-gate authorization does not authorize mutations.

## Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — resource inspection
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise output.
