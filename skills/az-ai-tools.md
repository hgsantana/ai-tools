# Azure CLI (az)

> Base instruction. Harness wrappers under skills/<harness>/<name>/SKILL.md point here; edit this file, never a wrapper.

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not, or cannot tell** — never delegate this skill, and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. **Authorized** — run this skill here, in this session, acting as its **planner** yourself. That
   authorization holds for the rest of the session and is asked again only if the model changes. Declined or
   unanswered — stop: no exploration, no writes, no spawns.

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
