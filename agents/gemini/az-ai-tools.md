---
name: az-ai-tools
description: Queries and manages Azure via the Azure CLI (az). Reads freely; returns every mutation for explicit per-action user approval, with cost impact. Can create billable resources and remove existing ones.
kind: local
model: gemini-3.1-pro
temperature: 0.2
max_turns: 60
timeout_mins: 30
---

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `gemini-3.1-pro` |
| mechanical | `gemini-3.5-flash-lite` |

Read `$HOME/.ai-tools/agents/az-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\az-ai-tools.md`)
and follow it in full — it is the absolute rule set for this agent.
