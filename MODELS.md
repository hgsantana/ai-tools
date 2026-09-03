# Model table

Authoring and installation lookup. Harnesses do not load this file after install: each wrapper pins `model:` (Grok: the managed `[subagents.models]` block in `~/.grok/config.toml`).

Fill each cell with the [selection method](README.md#choosing-the-models). Installation reads this table to pin wrappers and that Grok block. `tools/lint.sh` checks wrappers against it.

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · high | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` · xhigh | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Grok 4.6` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `grok-4.6` | `gemini-3.7-flash` | `gpt-5.6-luna` | model picker under the chat input |
