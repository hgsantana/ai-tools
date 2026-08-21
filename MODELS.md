# Model map

Authoring and install lookup. Wrappers pin `model:` (and effort, when the cell has one) from this map; Grok's install writes `~/.grok/config.toml` from it; `tools/lint.sh` checks parity.

## How to write it

1. Identify the harness — the wrapper folder under `agents/<key>/` is the row key.
2. Columns (**planner**, **implementer**, **mechanical**) match `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools` in `USER-AGENTS.md` → *The three agents*.
3. Put the backticked model token in the harness's own syntax. When the cell has `` · effort ``, that is the official effort — pin it if this harness's wrapper form accepts effort. When the cell has no effort, leave effort off the wrapper.

The last column is how a human changes the *session* model in that harness. Spawned agents use the wrapper pin.

## Map

| Harness key | Harness | planner | implementer | mechanical | Change the session model |
|---|---|---|---|---|---|
| `claude-code` | Claude Code | `opus` · high | `sonnet` | `haiku` | `/model` in the session |
| `grok` | Grok Build | `grok-4.6` | `grok-4.5` | `grok-4.5` | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| `codex` | OpenAI Codex | `gpt-5.6-sol` · xhigh | `gpt-5.6-luna` · max | `gpt-5.6-luna` · low | `/model` in the session; `--model` at launch |
| `copilot` | GitHub Copilot | `Grok 4.6` | `Gemini 3.7 Flash` | `GPT-5.6 Luna` | `/model` in the session |
| `antigravity` | Google Antigravity | `flash` | `flash` | `flash` | model selector in the Agent panel |
| `cursor` | Cursor | `grok-4.6` | `gemini-3.7-flash` | `gpt-5.6-luna` | model picker under the chat input |

## Antigravity CLI slugs

The `antigravity` row above pins the wrapper frontmatter, whose `model:` is a **subagent tier** — `inherit`, `flash`, or `pro` ([Subagents](https://antigravity.google/docs/subagents/)). The `agy` CLI uses a different namespace: `--model` takes a **full slug**, and headless mode exits non-zero on an unknown one instead of falling back ([Headless mode](https://antigravity.google/docs/cli/headless)). Confirm the live set with `agy models` before pinning; this annotation is the authored intent.

Slugs accepted by `agy --model`, per those pages (retrieved 2026-08-21) — reasoning tier is baked into the slug, and `--effort low|medium|high` overrides it:

- `gemini-3.7-flash-{high,medium,low}`, `gemini-3.6-flash-{high,medium,low}`, `gemini-3.5-flash-{high,medium,low}`
- `gemini-3.1-pro-{high,low}`
- `claude-sonnet-4-6`, `claude-opus-4-6-thinking`
- `gpt-oss-120b-medium`

The map cell cannot carry a reasoning tier; the slug bakes one in, so the differentiation lives here. Rule 13's derivation, in three steps:

1. **Resolve** each category from the `antigravity` row and the selection pass behind it ([Choosing the models](README.md#choosing-the-models)).
2. **Translate** the resolved family + version and reasoning tier into the slug that names them; a cell naming no tier translates to the family's middle published slug.
3. **Tie-break** repeats: the implementer's slug is the base, the planner moves one published tier up and the mechanical one down; with no tier above or below, that category repeats the base.

Antigravity's models table names plan availability only, never an effort token, so the Flash family has no official effort and the row collapses to one candidate per category. All three resolve to the same tier-less cell — `flash` → Gemini 3.7 Flash — and collide three ways. That cell translates to the family's middle published slug, `gemini-3.7-flash-medium`, which is therefore the base: the planner rises to `high` and the mechanical falls to `low`.

3.7 over 3.6 and 3.5: it is the newest Flash and the only one with a complete AA row — Intelligence Index, Cost per Task, Time per Task — at all three tiers; 3.6 and 3.5 are measured at `high` alone. Antigravity publishes no per-token price and no per-model quota multiplier, its plans page tying rate limits only to the amount of work the agent does, so this table orders published reasoning tiers and claims no cost or quota figure.

| Agent | `agy --model` |
|---|---|
| planner-ai-tools | `gemini-3.7-flash-high` |
| implementer-ai-tools | `gemini-3.7-flash-medium` |
| mechanical-ai-tools | `gemini-3.7-flash-low` |
