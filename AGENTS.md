# Global agent instructions

Harness-agnostic user-wide rules for any AI coding tool (Claude Code, Grok, Cursor, Codex, and others). Repository-local `AGENTS.md` / `README.md` files override these for that project.

## Agent categories

Every skill and workflow in this repository refers to **categories**, not model product names. The harness that is running decides which concrete subagent or model to launch for each category.

| Category | Responsibility | Market-style aliases (map as you prefer) |
|----------|----------------|------------------------------------------|
| **planner** | High-reasoning work: decompose work, design approaches, own acceptance judgment, validate deliveries, decide whether to retry or escalate. Does **not** write production code while orchestrating `/dev`. | planning agent, thinking model, orchestrator |
| **implementer** | Write and edit code with local design judgment for a **specified** task (a plan stage or a brief). May spawn **mechanical** for pure boilerplate. | executor, implementer, action model, coding agent |
| **mechanical** | Fully specified, low-ambiguity work: apply a known patch in many files, rename, run builds/tests and return raw output, draft mechanical feedback text, gather evidence. No design decisions. | worker, utility agent, tool agent |

**Rules for category use**

1. Skills name only these categories (`planner`, `implementer`, `mechanical`). Never hard-code vendor model names (Opus, Sonnet, Haiku, etc.) as the agent identity.
2. The **current session** is usually the **planner** when running `/plan` or orchestrating `/dev`.
3. If the harness has no separate subagent types, the same model still **behaves** in the assigned category for that turn (planner vs implementer vs mechanical discipline).
4. Prefer the cheapest capable category that can do the job: **mechanical** for pure execution and evidence, **implementer** for code with judgment, **planner** for planning and validation.

---

## Mandatory steps

1. Use concise **English** for everything inside any repository you work on — code, comments, commit messages, documentation, and any other repository file — even if the user writes in another language. Never use other languages in repository files unless the user explicitly asks, or the task is translation. This does **not** apply to conversation: reply in the language the user uses.
2. Skip the following steps for genuinely simple tasks: direct questions, one-line edits, fully specified tasks, documentation-only changes, and similar cases.
3. For non-trivial code change requests, use `/plan` to draft and save the plan. That skill owns planning detail (source of truth, per-type tests, docs, commit boundaries, execution graph, multi-file stage layout, `.gitignore`). Do not restate that machinery here.
4. **ALWAYS ASK** whether to implement the plan now or leave it documented. If the user chooses to leave it, stop.
5. If the user chooses to implement, use `/dev` (bare form) to execute. Warn first: bare `/dev` processes **every** plan currently at the root of `plans/*.md` (base plan files), not only the one just created.
6. `/dev` owns implementation, validation, correction rounds, status updates on the plan table, and moving finished stage/base files to `plans/finished/`. Do not re-validate its work or duplicate its logic outside the skill.

## Tools

Use the `/az` skill for Azure resources with the Azure CLI.

Use the `/gh` skill for GitHub resources with the GitHub CLI.

Use the `/gc` skill for Google Cloud resources with the Google Cloud CLI.

## Security (user-wide defaults)

- No secrets (API keys, connection strings, OAuth tokens, session tokens) in source, versioned config, or pipeline YAML.
- Treat all external input (user, AI output, webhooks) as untrusted before passing it downstream.
- Never create, change, or delete cloud resources without explicit user approval for that specific action.
- Prefer reversible local work; confirm before destructive or shared-state operations (force-push, drop tables, production deploys).

## Plans location

- Working plans live under the repository's `plans/` directory (git-ignored local working state unless the project says otherwise).
- Finished stage files and completed base plans move to `plans/finished/`.
- Do not commit `plans/` unless the project explicitly tracks it.
