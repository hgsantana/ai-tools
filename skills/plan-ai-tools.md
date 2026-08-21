> Skill base, loaded by the wrapper at `skills/plan-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Designing a change: exploring the repository and writing a multi-file implementation plan under `dev/`, then stopping — never implementing. That work is defined by `$HOME/.ai-tools/agents/plan-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\plan-ai-tools.md`). This skill only decides **who runs it**: the shipped `plan-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never plan outside one of those two routes, and never implement under this skill.

## Agent and category

Agent: `plan-ai-tools`, base `$HOME/.ai-tools/agents/plan-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\plan-ai-tools.md`). Category for the contract's model check: **planner**.

## Stake

No destructive stake: planning writes only under `dev/` and changes no product code. Say so in one line — the user is choosing a route, not accepting a risk.

## Route A — dispatch

The agent cannot reach the user, so it returns open questions instead of asking them. Relay them in the user's language, collect the answers, and resume the same agent with them — reusing its context where the harness allows.

## Route B — run it here

Announce it in chat, then read `$HOME/.ai-tools/agents/plan-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.

## Report

- Report in chat, in the user's language: a few lines on what the plan does plus the plan file paths.
- Ask whether to implement. **Yes** — invoke the `dev-ai-tools` skill against those plans, which offers its own routes and surfaces its stake. **No** — stop; the saved plan is the deliverable.
- Never implement a plan the user has not accepted.
