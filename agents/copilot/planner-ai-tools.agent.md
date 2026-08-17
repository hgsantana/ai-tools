---
name: planner-ai-tools
description: Writes a multi-file implementation plan under plans/, then stops. Use for non-trivial changes — open questions, multi-file work, or unclear impact. Never implements code.
model: Claude Opus 5
---

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `Claude Opus 5` |
| mechanical | `Claude Haiku 4.5` |

The base file for this agent is `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
