---
name: vibe-ai-tools
description: Repository architect/PO — refines a demand with the user from documentation only, then, after explicit confirmation, delivers it end to end via the planner and orchestrator agents, deciding open questions itself.
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

The base file for this agent is `$HOME/.ai-tools/agents/vibe-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\vibe-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
