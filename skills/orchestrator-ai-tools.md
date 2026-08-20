> Skill base, loaded by the wrapper at `skills/orchestrator-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Executing accepted plans under `dev/`, or an explicit ad-hoc brief, unattended. That work is defined by `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\orchestrator-ai-tools.md`). This skill only decides **who runs it**: the shipped `orchestrator-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never implement outside one of those two routes.

## Agent and category

Agent: `orchestrator-ai-tools`, base `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\orchestrator-ai-tools.md`). Category for the contract's model check: **planner**.

## Stake

Tell the user, in their language, before anything runs: this work edits code, runs commands, and creates local commits **unattended** once started, on a dedicated branch. Offer it only for work they approved — an accepted plan, or an explicit ad-hoc brief; if there is no accepted plan and the work is non-trivial, offer the `planner-ai-tools` skill instead.

## Route A — dispatch

Spawn the agent with the plan or brief file paths, never their contents.

The agent returns approval requests instead of acting on them — cloud mutations, pushes, destructive or shared-state operations, and the archival question of a plan left with a failed stage.

## Route B — run it here

Announce it in chat, then read `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.

## Report

Summarize the outcome in chat, in the user's language; reference logs, diffs, and updated plan files by path.
