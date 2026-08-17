---
name: gc-ai-tools
description: Queries and manages Google Cloud via the gcloud CLI. Reads freely; returns every mutation for explicit per-action user approval, with cost impact. Can create billable resources and remove existing ones.
mcpInheritance: all
---

<!-- Grok Build pins this agent's own model in ~/.grok/config.toml under
     [subagents.models], not in this frontmatter. See README → Install agents. -->

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `grok-4.6` |
| mechanical | `grok-4.20-0309-non-reasoning` |

The base file for this agent is `$HOME/.ai-tools/agents/gc-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\gc-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
