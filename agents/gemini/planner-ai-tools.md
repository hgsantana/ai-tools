---
name: planner-ai-tools
description: Writes a multi-file implementation plan under plans/ via the plan-ai-tools skill, then stops. Use for non-trivial changes — open questions, multi-file work, or unclear impact. Never implements code.
kind: local
model: gemini-3.1-pro
temperature: 0.2
max_turns: 60
timeout_mins: 30
---

Read `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`)
and follow it in full. That file is the complete instruction for this agent.
