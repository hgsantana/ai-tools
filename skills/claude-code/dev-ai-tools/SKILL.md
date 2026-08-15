---
name: dev-ai-tools
description: >
  Implement plans or ad-hoc work using harness-agnostic agent categories. Use when the user runs
  "/dev-ai-tools". With no argument, or an argument starting with "plans", process base plans at
  plans/*.md (not stage files, not finished/). Any other argument is an ad-hoc implementation
  request. Planner validates; implementer codes; mechanical gathers evidence. Runs unattended.
argument-hint: "[plans [path…] | implementation request]"
---

# Dev

Read `$HOME/.ai-tools/skills/dev-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\skills\dev-ai-tools.md`)
and follow it in full before doing anything else — including its entry gate. That file is the complete
instruction for this skill; this file only registers it with Claude Code.
