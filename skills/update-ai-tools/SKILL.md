---
name: update-ai-tools
description: >
  Run the ai-tools update — reset $HOME/.ai-tools to origin/master, refresh copies, and link anything
  newly shipped, per the README's Update procedure — by dispatching implementer-ai-tools to follow
  this skill. Use for /update-ai-tools or whenever the user asks to update ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Update

Updating the ai-tools installation, task `update`.

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the route offer and dispatch.

Your base file is `$HOME/.ai-tools/skills/update-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
