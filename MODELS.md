# Model map

Which model each agent category uses in each harness. Agents, skills, and the installation scripts read this file in place at `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`).

## How to read it

1. Identify the harness — the wrapper names its row key; otherwise infer it from the running CLI or IDE. When you cannot tell, say so instead of guessing a row.
2. Take that row's column for the category you need. Categories (**planner**, **implementer**, **mechanical**) are defined in `USER-AGENTS.md` → *Agent categories*.
3. Use the backticked model token in the harness's own syntax. When the cell has `` · effort ``, that is the official effort for this category — pin it if this harness's wrapper form accepts effort. When the cell has no effort, leave effort to the harness or the session.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · medium | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-terra` · max | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `GPT-5.6 Sol` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `gpt-5.6-sol[effort=xhigh]` · xhigh | `gemini-3.7-flash[effort=medium]` · medium | `gpt-5.6-luna[effort=low]` · low | model picker under the chat input |
| `gemini` | Gemini CLI | `gemini-3.1-pro-preview` | `gemini-3.1-pro-preview` | `gemma-4-31b-it` | `/model` in the session; `-m` at launch |
