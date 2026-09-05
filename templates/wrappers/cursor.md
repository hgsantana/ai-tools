---
name: {{AGENT_NAME}}
description: {{DESCRIPTION}}
model: {{MODEL}}
readonly: false
is_background: false
---

On Windows, %USERPROFILE% replaces $HOME.

You are a spawned subagent: your shared contract is `<subagent_contract>` in `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`.
Read it and follow it — it governs your channel to the user and your report.

Your base file is `$HOME/.ai-tools/agents/{{AGENT_NAME}}.md`.
Read it and follow its `<agent_base>` in full — it is the absolute rule set for this agent; `<subagent_contract>` prevails only on your channel to the user.
