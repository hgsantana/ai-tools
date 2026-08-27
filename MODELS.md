# Model map

Authoring and installation lookup. Wrappers take `model:` and, when present, effort from this map. Grok installation writes `~/.grok/config.toml` from it, and `tools/lint.sh` checks parity.

## How to write it

1. Identify the harness — the wrapper folder under `agents/<key>/` is the row key.
2. Columns (**planner**, **implementer**, **mechanical**) match `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools` in `USER-AGENTS.md` → *The three agents*.
3. Write the backticked model token in the harness's syntax. A following `` · effort `` is the official effort; include it when the wrapper supports effort.

The last column shows how a human changes the *session* model. Spawned agents use the wrapper pin; `USER-AGENTS.md` compares the session model with the cell at the skill's **Min. role** and every higher-role cell to its left.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · high | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` · xhigh | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Grok 4.6` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `grok-4.6` | `gemini-3.7-flash` | `gpt-5.6-luna` | model picker under the chat input |
