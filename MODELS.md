# Model map

Which model each of the three agents uses in each harness. This file is the **authoring and install** lookup — not a runtime dispatch table. Wrappers pin `model:` (and effort, when the cell has one) from this map; Grok's install writes `~/.grok/config.toml` from it; `tools/lint.sh` checks parity. Agents, skills, and spawn do not read this file to pick a model.

## How to write it

1. Identify the harness — the wrapper folder under `agents/<key>/` is the row key.
2. Columns (**planner**, **implementer**, **mechanical**) match `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools` in `USER-AGENTS.md` → *The three agents*.
3. Put the backticked model token in the harness's own syntax. When the cell has `` · effort ``, that is the official effort — pin it if this harness's wrapper form accepts effort. When the cell has no effort, leave effort off the wrapper.

The last column is how a human changes the *session* model in that harness. It is not used at spawn: spawned agents use the wrapper pin.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · high | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` · xhigh | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Grok 4.6` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `grok-4.6` | `gemini-3.7-flash` | `gpt-5.6-luna` | model picker under the chat input |
