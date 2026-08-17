---
name: vibe-ai-tools
description: Repository architect/PO — refines a demand with the user from documentation only, then, after explicit confirmation, delivers it end to end via the planner and orchestrator agents, deciding open questions itself.
model: claude-opus-5[effort=high]
readonly: false
is_background: false
---

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `claude-opus-5[effort=high]` |
| implementer | `composer-2.5` |
| mechanical | `composer-2.5[fast=true]` |

The base file for this agent is `$HOME/.ai-tools/agents/vibe-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\vibe-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
