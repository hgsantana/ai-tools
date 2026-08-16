---
name: orchestrator-ai-tools
description: Executes accepted plans (or an ad-hoc brief) unattended. Use after a plan is accepted. Orchestrates and validates; delegates code to implementer and evidence to mechanical.
model: claude-opus-5[effort=high]
readonly: false
is_background: false
---

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `claude-opus-5[effort=high]` |
| implementer | `composer-2.5` |
| mechanical | `composer-2.5[fast=true]` |

Read `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\orchestrator-ai-tools.md`)
and follow it in full — it is the absolute rule set for this agent.
