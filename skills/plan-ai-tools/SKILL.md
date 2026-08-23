---
name: plan-ai-tools
description: >
  Run the plan-ai-tools work — explore the repository and write a multi-file implementation plan
  under dev/, then stop — carried in this session under the planner-ai-tools role.
  Use for /plan-ai-tools or whenever a non-trivial change should be planned before implementation.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Planning

Designing a change: exploring the repository and writing a multi-file implementation plan under `dev/`, then stopping.

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the planner gate, the route offer, and the dispatch.

Your base file is `$HOME/.ai-tools/skills/plan-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
