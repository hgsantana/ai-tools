---
name: orchestrator-ai-tools
description: Executes accepted plans (or an ad-hoc brief) unattended. Use after a plan is accepted. Orchestrates and validates; delegates code to implementer and evidence to mechanical.
kind: local
model: gemini-3.1-pro
temperature: 0.2
max_turns: 120
timeout_mins: 60
---

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `gemini-3.1-pro` |
| implementer | `gemini-3.7-flash` |
| mechanical | `gemini-3.5-flash-lite` |

The base file for this agent is `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\orchestrator-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
