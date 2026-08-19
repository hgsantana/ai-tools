---
name: gh-ai-tools
description: >
  Run the gh-ai-tools work — query or manage GitHub via the GitHub CLI (gh) — either by dispatching
  the gh-ai-tools agent or by running its base file in this session. Use for /gh-ai-tools or whenever
  the user asks about GitHub repositories, pull requests, issues, releases, or workflows, or wants
  something created, changed, or removed there.
argument-hint: "[what to inspect or change on GitHub]"
---

# GitHub

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`).

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the model check, the route offer, and the route mechanics.

Your base file is `$HOME/.ai-tools/skills/gh-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
