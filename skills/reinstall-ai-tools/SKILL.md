---
name: reinstall-ai-tools
description: >
  Run the ai-tools reinstallation — a full removal plus installation pass against a fresh origin/master,
  per the README's Reinstallation procedure — either by dispatching the maintainer-ai-tools agent or by
  running its base file in this session. Use for /reinstall-ai-tools, whenever the user asks to reinstall
  ai-tools, or when an install is broken, stale, or the set of harnesses changed.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Reinstallation

Reinstalling ai-tools, task `reinstall` of the maintainer.

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the model check, the route offer, and the route mechanics.

Your base file is `$HOME/.ai-tools/skills/reinstall-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
