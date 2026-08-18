---
name: planner-ai-tools
description: Writes a multi-file implementation plan under plans/, then stops. Use for non-trivial changes — open questions, multi-file work, or unclear impact. Never implements code.
mcpInheritance: all
---

Category → model for this harness comes from `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`), row `grok`. Resolve every category through it — your own and any you spawn; never assume a model name.

You are a spawned subagent: the shared contract for that is `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md` (Windows: `%USERPROFILE%\.ai-tools\agents\SUBAGENT-CONTRACT.md`).
Read it and follow it — it governs your channel to the user and your report.

The base file for this agent is `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent; the contract above prevails only on your channel to the user.
