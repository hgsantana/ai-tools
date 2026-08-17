---
name: planner-ai-tools
description: Writes a multi-file implementation plan under plans/, then stops. Use for non-trivial changes — open questions, multi-file work, or unclear impact. Never implements code.
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

The base file for this agent is `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
