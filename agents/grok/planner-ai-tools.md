---
name: planner-ai-tools
description: Writes a multi-file implementation plan under plans/, then stops. Use for non-trivial changes — open questions, multi-file work, or unclear impact. Never implements code.
mcpInheritance: all
---

<!-- Grok Build pins this agent's own model in ~/.grok/config.toml under
     [subagents.models], not in this frontmatter. See README → Install agents. -->

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `grok-4.6` |
| mechanical | `grok-4.20-0309-non-reasoning` |

The base file for this agent is `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
