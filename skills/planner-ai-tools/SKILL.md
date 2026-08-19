---
name: planner-ai-tools
description: >
  Run the planner-ai-tools work — explore the repository and write a multi-file implementation plan
  under plans/, then stop, never implementing — either by dispatching the planner-ai-tools agent or by
  running its base file in this session. Use for /planner-ai-tools or whenever a non-trivial change
  should be planned before implementation.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Planning

Designing a change: exploring the repository and writing a multi-file implementation plan under `plans/`, then stopping — never implementing.

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the model check, the route offer, and the route mechanics.

Your base file is `$HOME/.ai-tools/skills/planner-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
