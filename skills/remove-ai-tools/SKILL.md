---
name: remove-ai-tools
description: >
  Dispatch the maintainer-ai-tools agent to remove the ai-tools installation: unlink
  agents, skills, and (optionally) instructions from the harnesses, per the README's
  Removal procedure. Use for /remove-ai-tools or whenever the user asks to remove or
  uninstall ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Removal dispatch

This skill removes nothing itself. It dispatches the `maintainer-ai-tools` agent — whose harness wrapper pins its model — with the task `remove`, and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: this removes ai-tools agents, skills, and optionally the instructions link from the harnesses' config directories — those tools stop being available there. Removal unlinks; it does not delete `$HOME/.ai-tools` itself unless the user explicitly asks, as a separate approval. Destructive steps run only after explicit per-action approval relayed through this session. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `maintainer-ai-tools` agent with the task `remove` plus the user's instructions, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not run the procedure inline under this skill.

## Relay

- The agent cannot reach the user: it returns discovery results and asks the user to confirm the removal targets before touching anything, and returns every destructive step (deleting the clone, anything beyond unlinking) as its own request. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.

## Report

- Relay the agent's final summary in the user's language: what was unlinked or removed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.
