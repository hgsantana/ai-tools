> Skill base, loaded by the wrapper at `skills/az-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Inventory, cost, and operations on Azure through the Azure CLI (`az`). Runs the `planner-ai-tools` role in the user's session. Run `az` only once the planner gate passes.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`). This session carries that role behind the contract's planner gate.

## Stake

Tell the user, in their language, before anything runs: this work touches Azure, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. A mutation runs only after their explicit approval for that specific action.

## Route A — run here

Read freely; put every mutation to the user as its own approval request, including its cost impact. Spawned workers reach the user through you.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.

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
