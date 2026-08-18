# Model map

Single source of truth for every vendor model name in this toolkit: which concrete model each **agent category** resolves to in each supported harness, and how to change the model of a running session.

Agents, skills, and the installation scripts read this file instead of carrying their own table. It is installed nowhere — it is read in place, at `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`).

## How to read it

1. Identify the harness you are running in — an agent wrapper names its own harness key; otherwise infer it from the running CLI or IDE and its configuration directory. When you cannot tell, say so instead of guessing a row.
2. Take that row's column for the category you need. Categories (**planner**, **implementer**, **mechanical**) are defined in `USER-AGENTS.md` → *Agent categories*.
3. Use the value verbatim, in the harness's own syntax.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-build-0.1` | `grok-4.20-0309-non-reasoning` | `/model` in the session; `default_model` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` | `gpt-5.6-terra` | `gpt-5.6-luna` | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Claude Opus 5` | `Claude Sonnet 5` | `Claude Haiku 4.5` | `/model` in the session |
| `antigravity` | Google Antigravity | `pro` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `claude-opus-5[effort=high]` | `composer-2.5` | `composer-2.5[fast=true]` | model picker under the chat input |
| `gemini` | Gemini CLI | `gemini-3.1-pro` | `gemini-3.7-flash` | `gemini-3.5-flash-lite` | `/model` in the session; `-m` at launch |

Assignment principle: **planner** takes the strongest model regardless of cost, **implementer** the best code-quality-to-cost ratio, **mechanical** the cheapest that reliably finishes. Verified against vendor documentation in August 2026 — re-check at each model release.

Notes:

- **Gemini CLI**: the Pro line is frozen at 3.1 while Flash has moved to 3.7, so planner and implementer come from different generations.
- **Antigravity**: `model:` accepts only tiers (`inherit`, `flash`, `pro`), not model IDs — `pro` is its strongest tier and there is nothing cheaper than `flash`, so mechanical also runs `flash`.
- **Grok Build**: ignores `model:` in agent frontmatter — the install script pins subagent models in `~/.grok/config.toml` from this table (README → Installation).
- A harness whose model pinning is ignored falls back to the session's model; the strong-model guarantee is lost, not the behaviour.

## Editing

This file is user-editable: change a value to run the categories on different models on this machine. It is shipped content, so an [update](README.md#update) resets it to `origin/master` and discards local edits — re-apply them after updating.

Contract for anyone editing it — the scripts parse this table:

- Keep the column order and the one-row-per-harness shape; the harness key in column 1 is backticked and matches the wrapper folder name under `agents/`.
- Model values are backticked; the parser strips backticks and surrounding spaces.
- Adding a harness means adding its row here, its wrapper folder, and its entry in the README's [Supported harnesses](README.md#supported-harnesses) table, in the same commit.
