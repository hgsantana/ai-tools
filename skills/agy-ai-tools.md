> Skill base, loaded by the wrapper at `skills/agy-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Non-interactive runs of the Antigravity CLI (`agy`) on that harness's planner, implementer, or mechanical model. That work is defined by `$HOME/.ai-tools/agents/agy-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\agy-ai-tools.md`). This skill only decides **who runs it**: the shipped `agy-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never run `agy` outside one of those two routes.

## Agent and category

Agent: `agy-ai-tools`, base `$HOME/.ai-tools/agents/agy-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\agy-ai-tools.md`). Category for the contract's model check: **planner**.

## Stake

Tell the user, in their language, before anything runs: this work runs the Antigravity CLI (`agy`), which can edit files, execute commands, and incur **model cost** in that harness. A work run — and `--dangerously-skip-permissions` — execute only after their explicit approval for that specific command — whichever route they pick.

## Route A — dispatch

The agent discovers `agy` read-only, then returns every work run for approval, including the exact command, category, model, and agent.

## Route B — run it here

Announce it in chat, then read `$HOME/.ai-tools/agents/agy-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.

## Report

Summarize the outcome in chat, in the user's language — status, the response path, category and model used; reference any saved envelope by path.
