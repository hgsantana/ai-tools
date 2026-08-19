> Skill base, loaded by the wrapper at `skills/gh-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`). That work is defined by `$HOME/.ai-tools/agents/gh-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\gh-ai-tools.md`). This skill only decides **who runs it**: the shipped `gh-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never run `gh` outside one of those two routes.

## Agent and category

Agent: `gh-ai-tools`, base `$HOME/.ai-tools/agents/gh-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\gh-ai-tools.md`). Category for the contract's model check: **planner**.

## Stake

Tell the user, in their language, before anything runs: this work touches GitHub, where actions can merge, close, comment, push, and delete — visible to other people immediately and often irreversible. A mutation runs only after their explicit approval for that specific action — whichever route they pick.

## Route A — dispatch

- Announce the spawn in chat, in the user's language, then spawn the `gh-ai-tools` agent with the user's request, passing context as file paths, not contents.
- The agent reads freely and returns every mutation for approval. Relay each request to the user in their language, including its blast impact; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions.
- Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Route B — run it here

Announce it in chat, then read `$HOME/.ai-tools/agents/gh-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
