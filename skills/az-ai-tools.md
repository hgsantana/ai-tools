> Skill base, loaded by the wrapper at `skills/az-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Inventory, cost, and operations on Azure through the Azure CLI (`az`). Dispatches `planner-ai-tools` to follow **Workflow**. Never run `az` outside that dispatch.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

Tell the user, in their language, before anything runs: this work touches Azure, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. A mutation runs only after their explicit approval for that specific action.

## Route A — dispatch

The agent reads freely and returns every mutation for approval, including its cost impact.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.

## Workflow

Use the Azure CLI (`az`) for inventory, cost, and operations on the request you were given, then stop.

### Approvals

Never create, modify, or remove a resource without explicit user approval for that specific action. Put each proposed mutation to the user as its own request — command, target, reason, and cost or blast impact — and run it only on an explicit yes for it. Approval never carries over between actions.

### Rules

- Freely run **read-only / query** commands (list, show, describe, costs).
- You may **suggest** mutations; only the user decides. **NEVER** create, modify, or remove any Azure resource without explicit user approval for that specific action.
- Every suggested mutation states its **cost impact**: SKU, ongoing cost, billable status.
- Keep the report concise: tables or summaries. Save full output to a file only if the request asked for it.

### Delegated exploration

You may spawn `mechanical-ai-tools` to explore `az` — discover commands, read state, collect output:

- Strictly read-only query commands.
- They return facts, never verdicts or change proposals.

### Useful commands

- `az account show` / `az account list` — subscription context
- `az resource list` / `az group list` — inventory
- `az <service> list` / `az <service> show` — resource inspection
- `az consumption usage list` / `az costmanagement query` — cost and usage
- `az monitor` — logs, metrics, alerts

Prefer `--output table` or `--query` (JMESPath) for concise output.
