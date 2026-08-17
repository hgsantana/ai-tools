---
name: vibe-ai-tools
description: Repository architect/PO — refines a demand with the user from documentation only, then, after explicit confirmation, delivers it end to end via the planner and orchestrator agents, deciding open questions itself.
mcpInheritance: all
---

<!-- Grok Build pins this agent's own model in ~/.grok/config.toml under
     [subagents.models], not in this frontmatter. See README → Install agents. -->

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `grok-4.6` |
| implementer | `grok-build-0.1` |
| mechanical | `grok-4.20-0309-non-reasoning` |

The base file for this agent is `$HOME/.ai-tools/agents/vibe-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\vibe-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
