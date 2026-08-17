---
name: maintainer-ai-tools
description: Maintains the ai-tools installation — runs the README's Update, Removal, or Reinstallation procedure on request. Rewires harness links and can reset the config repo; destructive steps require per-action approval. Never the first install.
mcpInheritance: all
---

<!-- Grok Build pins this agent's own model in ~/.grok/config.toml under
     [subagents.models], not in this frontmatter. See README → Install agents. -->

When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| implementer | `grok-build-0.1` |

The base file for this agent is `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
