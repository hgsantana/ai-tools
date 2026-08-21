> Skill base, loaded by the wrapper at `skills/reinstall-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Reinstalling ai-tools, task `reinstall`. Dispatches `implementer-ai-tools` to follow **Workflow**. Run the procedure only inside that dispatch.

## Agent

Agent: `implementer-ai-tools`, base `$HOME/.ai-tools/agents/implementer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\implementer-ai-tools.md`). Task: `reinstall`.

## Stake

Tell the user, in their language, before anything runs: reinstallation **resets `$HOME/.ai-tools` to `origin/master`, discarding local commits and edits in that repo**, then removes and re-creates the ai-tools links across harness config directories (including a stale-link sweep, when confirmed). Destructive steps run only after their explicit approval for that specific action.

## Route A — dispatch

Spawn `implementer-ai-tools` with the task `reinstall` plus the user's instructions. The agent returns scope questions (which harnesses, instructions too, stale-link sweep) and approval requests instead of asking.

## Report

Relay the agent's final summary in the user's language: what changed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.

## Workflow

Follow `$HOME/.ai-tools/skills/MAINTAINER.md` (Windows: `%USERPROFILE%\.ai-tools\skills\MAINTAINER.md`) in full, with the task `reinstall`.
