---
name: reinstall-ai-tools
description: >
  Dispatch the maintainer-ai-tools agent to reinstall ai-tools: a full removal plus
  installation pass against a fresh origin/master, per the README's Reinstallation
  procedure. Use for /reinstall-ai-tools, whenever the user asks to reinstall ai-tools,
  or when an install is broken, stale, or the set of harnesses changed.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Reinstallation dispatch

This skill reinstalls nothing itself. It dispatches the `maintainer-ai-tools` agent — whose harness wrapper pins its model — with the task `reinstall`, and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: reinstallation **resets `$HOME/.ai-tools` to `origin/master`, discarding local commits and edits in that repo**, then removes and re-creates the ai-tools links across harness config directories (including a stale-link sweep, when confirmed). Destructive steps run only after explicit per-action approval relayed through this session. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `maintainer-ai-tools` agent with the task `reinstall` plus the user's instructions, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not run the procedure inline under this skill.

## Relay

- The agent cannot reach the user: it returns scope questions (which harnesses, instructions too, stale-link sweep) and approval requests (the reset, any conflicting path) instead of asking. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.

## Report

- Relay the agent's final summary in the user's language: what was removed and re-linked per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.
