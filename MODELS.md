# Model map

Which model each agent category uses in each harness. Agents, skills, and the installation scripts read this file in place at `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`).

## How to read it

1. Identify the harness — the wrapper names its row key; otherwise infer it from the running CLI or IDE. When you cannot tell, say so instead of guessing a row.
2. Take that row's column for the category you need. Categories (**planner**, **implementer**, **mechanical**) are defined in `USER-AGENTS.md` → *Agent categories*.
3. Use the backticked model token in the harness's own syntax. When the cell has `` · effort ``, that is the official effort for this category — pin it if this harness's wrapper form accepts effort. When the cell has no effort, leave effort to the harness or the session.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `fable` · max | `opus` · max | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-build-0.1` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.5` · xhigh | `gpt-5.6-terra` | `gpt-5.6-luna` | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `GPT-5.5` | `Grok 4.6` | `Grok 4.5` | `/model` in the session |
| `antigravity` | Google Antigravity | `pro` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `gpt-5.6-sol` | `gemini-3.7-flash[effort=high]` · high | `gemini-3.7-flash[effort=high]` · high | model picker under the chat input |

## Provenance

Selected by the README's [selection method](README.md#choosing-the-models) from LiveBench release **2026-06-25** (`tools/models.sh`), joined to each harness's official model documentation, retrieved **2026-08-20**.

Three cells are not measured selections, and say so here rather than pretending otherwise:

- **`claude-code` mechanical** — `documented fallback`. LiveBench does not measure Claude Haiku 4.5, so the band saw only Fable, Opus, and Sonnet and returned Fable — the most expensive row in the release — for the cheapest category. `haiku` comes from Anthropic's own task guidance instead.
- **`antigravity` planner / implementer / mechanical** — `tier exception`. The subagent `model:` field accepts `inherit`, `flash`, or `pro`: tiers, not model identifiers. There is nothing for a band to rank, so these follow Google's documented tier guidance.
- **`copilot`** — the model tokens are display names because GitHub documents the `model:` field's meaning but publishes no enum of accepted strings. The selection itself is measured; only the spelling is unverifiable.

Two efforts are deliberately absent. Codex rows won at LiveBench's *Max Effort*, but `model_reasoning_effort` documents only up to `xhigh`, so no effort is pinned for `gpt-5.6-terra` and `gpt-5.6-luna`. Cursor documents `[effort=…]` without publishing the per-model options; `high` is the one value confirmed by an official example, so it is the only one pinned.
