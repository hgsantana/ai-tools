---
name: update-ai-tools
description: >
  Dispatch the maintainer-ai-tools agent to update the ai-tools installation: reset
  $HOME/.ai-tools to origin/master, refresh copies, and link anything newly shipped,
  per the README's Update procedure. Use for /update-ai-tools or whenever the user asks
  to update ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Update dispatch

This skill updates nothing itself. It dispatches the `maintainer-ai-tools` agent — whose harness wrapper pins its model — with the task `update`, and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: the update **resets `$HOME/.ai-tools` to `origin/master`, discarding local commits and edits in that repo**, and refreshes what is installed across harness config directories. Destructive steps run only after explicit per-action approval relayed through this session. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `maintainer-ai-tools` agent with the task `update` plus the user's instructions, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not run the procedure inline under this skill.

## Relay

- The agent cannot reach the user: it returns scope questions (which harnesses) and approval requests (the reset, any conflicting path) instead of asking. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.

## Report

- Relay the agent's final summary in the user's language: what was refreshed or linked per harness, skips with reasons, tree state, and the reminder to restart harnesses that cache agents or skills.
