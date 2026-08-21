# Model map

Which model each of the three agents uses in each harness. Agents, skills, and the installation scripts read this file in place at `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`).

## How to read it

1. Identify the harness — the wrapper names its row key; otherwise infer it from the running CLI or IDE. When you cannot tell, say so instead of guessing a row.
2. Take that row's column for the agent you are spawning. Columns (**planner**, **implementer**, **mechanical**) match `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools` in `USER-AGENTS.md` → *The three agents*.
3. Use the backticked model token in the harness's own syntax. When the cell has `` · effort ``, that is the official effort for this category — pin it if this harness's wrapper form accepts effort. When the cell has no effort, leave effort to the harness or the session.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · high | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` · xhigh | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Grok 4.6` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `grok-4.6` | `gemini-3.7-flash` | `gpt-5.6-luna` | model picker under the chat input |
