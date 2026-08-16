---
name: gh-ai-tools
description: Queries and manages GitHub via the GitHub CLI (gh). Reads freely; returns every mutation for explicit per-action user approval. Actions like merge, close, and push are visible to others immediately.
mcpInheritance: all
---

<!-- Grok Build pins this agent's own model in ~/.grok/config.toml under
     [subagents.models], not in this frontmatter. See README → Install agents. -->

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `grok-4.6` |
| mechanical | `grok-4.20-0309-non-reasoning` |

Read `$HOME/.ai-tools/agents/gh-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\gh-ai-tools.md`)
and follow it in full — it is the absolute rule set for this agent.
