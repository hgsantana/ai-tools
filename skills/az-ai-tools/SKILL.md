---
name: az-ai-tools
description: >
  Query and manage Azure resources via the Azure CLI (az). Use whenever the user asks about
  Azure resources, subscriptions, costs, or infrastructure, or wants something created,
  modified, or removed in Azure. Also use for /az-ai-tools.
---

# Azure CLI (az)

Use the `az` CLI for Azure inventory, cost, and operations work.

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

- Freely use `az` for **read-only / query** operations (list, show, query costs, describe resources).
- You may **suggest** creating, modifying, or removing Azure resources; only the user decides.
- **NEVER** create, modify, or remove any Azure resource without **explicit** user authorization
  for that specific action. Prior approval does not carry over, and this gate holds even inside an
  unattended `/dev-ai-tools` run.
- Before any suggested mutating change, make **cost impact** clear (SKU, ongoing cost, billable or not).
- Keep chat replies concise: a short table or summary, not a raw dump. For long or raw output, summarize in chat and save the full result to a file only if the user wants it kept.

## Delegated exploration

The planner running this skill may spawn **mechanical** or **implementer** subagents to explore `az`: discover which commands exist, read current state, collect output.

- Strictly read-only. Query commands only — never create, modify, or remove anything.
- They return facts, never verdicts. They do not judge what should change.
- Only the planner decides on a mutating command and runs it, after presenting cost, risk, and reason, and getting explicit authorization for that specific action.
- When the planner is itself a spawned agent, that authorization request travels the relay verbatim. The relay never approves in the user's place.

## Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — inspect a resource
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise reports.
