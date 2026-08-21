> Skill base, loaded by the wrapper at `skills/remove-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Removing the ai-tools installation, task `remove`. Dispatches `implementer-ai-tools` to follow **Workflow**. Run the procedure only inside that dispatch.

## Agent

Agent: `implementer-ai-tools`, base `$HOME/.ai-tools/agents/implementer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\implementer-ai-tools.md`). Task: `remove`.

## Stake

Tell the user, in their language, before anything runs: this unlinks ai-tools agents, skills, and optionally the instructions link from the harnesses' config directories — those tools stop being available there. Removal unlinks; it does not delete `$HOME/.ai-tools` itself unless the user explicitly asks, as a separate approval. Destructive steps run only after their explicit approval for that specific action.

## Route A — dispatch

Spawn `implementer-ai-tools` with the task `remove` plus the user's instructions. The agent returns discovery results and the removal targets to confirm, and approval requests, instead of asking.

## Report

Relay the agent's final summary in the user's language: what changed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.

## Workflow

Follow `$HOME/.ai-tools/skills/MAINTAINER.md` (Windows: `%USERPROFILE%\.ai-tools\skills\MAINTAINER.md`) in full, with the task `remove`.
