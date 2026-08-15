---
name: plan-ai-tools
description: >
  Restricted-invocation skill — invoke only when (a) the user runs "/plan-ai-tools",
  (b) another skill's documented workflow calls it by name, or (c) the global AGENTS.md
  change flow calls it for a non-trivial change. Explores the repository and writes a
  multi-file implementation plan under plans/, then stops. Never implements code.
disable-model-invocation: false
---

# Plan

Read `$HOME/.ai-tools/skills/plan-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\skills\plan-ai-tools.md`)
and follow it in full before doing anything else — including its entry gate. That file is the complete
instruction for this skill; this file only registers it with Cursor.
