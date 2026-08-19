> Skill base, loaded by the wrapper at `skills/az-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Inventory, cost, and operations on Azure through the Azure CLI (`az`). That work is defined by `$HOME/.ai-tools/agents/az-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\az-ai-tools.md`). This skill only decides **who runs it**: the shipped `az-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never run `az` outside one of those two routes.

## Agent and category

Agent: `az-ai-tools`, base `$HOME/.ai-tools/agents/az-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\az-ai-tools.md`). Category for the contract's model check: **planner**.

## Stake

Tell the user, in their language, before anything runs: this work touches Azure, where actions can create **billable** resources and **remove** existing ones, and neither is easy to undo. A mutation runs only after their explicit approval for that specific action — whichever route they pick.

## Route A — dispatch

The agent reads freely and returns every mutation for approval, including its cost impact.

## Route B — run it here

Announce it in chat, then read `$HOME/.ai-tools/agents/az-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
