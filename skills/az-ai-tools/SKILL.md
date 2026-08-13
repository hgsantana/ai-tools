---
name: az-ai-tools
description: >
  Query and manage Azure resources via the Azure CLI (az). Use whenever the user asks about
  Azure resources, subscriptions, costs, or infrastructure, or wants something created,
  modified, or removed in Azure. Also use for /az-ai-tools.
---

# Azure CLI (az)

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

Use the `az` CLI for Azure inventory, cost, and operations work.

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
- An entry-gate authorization to run this skill is not authorization to mutate anything. Every mutating action still needs its own explicit approval.

## Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — inspect a resource
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise reports.
