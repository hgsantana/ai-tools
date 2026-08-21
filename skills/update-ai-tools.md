> Skill base, loaded by the wrapper at `skills/update-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Updating the ai-tools installation, task `update`. Dispatches `implementer-ai-tools` to follow **Workflow**. Never run the procedure outside that dispatch.

## Agent and category

Agent: `implementer-ai-tools`, base `$HOME/.ai-tools/agents/implementer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\implementer-ai-tools.md`). Task: `update`. Category for the contract's model check: **implementer**.

## Stake

Tell the user, in their language, before anything runs: the update **resets `$HOME/.ai-tools` to `origin/master`, discarding local commits and edits in that repo**, and refreshes what is installed across harness config directories. Destructive steps run only after their explicit approval for that specific action.

## Route A — dispatch

Spawn `implementer-ai-tools` with the task `update` plus the user's instructions. The agent cannot reach the user: it returns scope questions (which harnesses) and approval requests instead of asking.

## Report

Relay the agent's final summary in the user's language: what changed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.

## Workflow

Follow `$HOME/.ai-tools/skills/MAINTAINER.md` (Windows: `%USERPROFILE%\.ai-tools\skills\MAINTAINER.md`) in full, with the task `update`.
