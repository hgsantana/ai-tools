---
name: remove-ai-tools
description: >
  Run the ai-tools removal — unlink agents, skills, and (optionally) instructions from the harnesses,
  per the README's Removal procedure — by dispatching implementer-ai-tools to follow this skill. Use
  for /remove-ai-tools or whenever the user asks to remove or uninstall ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Removal

Removing the ai-tools installation, task `remove`.

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the route offer and dispatch.

Your base file is `$HOME/.ai-tools/skills/remove-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
