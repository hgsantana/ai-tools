> Skill base, loaded by the wrapper at `skills/update-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Updating the ai-tools installation, task `update` of the maintainer. That work is defined by `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`). This skill only decides **who runs it**: the shipped `maintainer-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never run the procedure outside one of those two routes.

## Agent and category

Agent: `maintainer-ai-tools`, base `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`). Task: `update`. Category for the contract's model check: **implementer**.

## Stake

Tell the user, in their language, before anything runs: the update **resets `$HOME/.ai-tools` to `origin/master`, discarding local commits and edits in that repo**, and refreshes what is installed across harness config directories. Destructive steps run only after their explicit approval for that specific action — whichever route they pick.

## Route A — dispatch

Spawn the `maintainer-ai-tools` agent with the task `update` plus the user's instructions. The agent cannot reach the user: it returns scope questions (which harnesses) and approval requests instead of asking.

## Route B — run it here

Read `$HOME/.ai-tools/agents/maintainer-ai-tools.md` in full and follow it as your own rule set for this request, with the task `update`.

## Report

Relay the agent's final summary in the user's language: what changed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.
