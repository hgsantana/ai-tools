> Skill base, loaded by the wrapper at `skills/remove-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Removing the ai-tools installation, task `remove` of the maintainer. That work is defined by `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`). This skill only decides **who runs it**: the shipped `maintainer-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never run the procedure outside one of those two routes.

## Agent and category

Agent: `maintainer-ai-tools`, base `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`). Task: `remove`. Category for the contract's model check: **implementer**.

## Stake

Tell the user, in their language, before anything runs: this unlinks ai-tools agents, skills, and optionally the instructions link from the harnesses' config directories — those tools stop being available there. Removal unlinks; it does not delete `$HOME/.ai-tools` itself unless the user explicitly asks, as a separate approval. Destructive steps run only after their explicit approval for that specific action — whichever route they pick.

## Route A — dispatch

Spawn the `maintainer-ai-tools` agent with the task `remove` plus the user's instructions. The agent cannot reach the user: it returns discovery results and the removal targets to confirm, and approval requests, instead of asking.

## Route B — run it here

Read `$HOME/.ai-tools/agents/maintainer-ai-tools.md` in full and follow it as your own rule set for this request, with the task `remove`.

## Report

Relay the agent's final summary in the user's language: what changed per harness, skips with reasons, verification results, and the reminder to restart harnesses that cache agents or skills.
