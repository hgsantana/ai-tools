---
name: gh-ai-tools
description: Queries and manages GitHub via the GitHub CLI (gh). Reads freely; returns every mutation for explicit per-action user approval. Actions like merge, close, and push are visible to others immediately.
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

The base file for this agent is `$HOME/.ai-tools/agents/gh-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\gh-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
