# Global agent instructions

Harness-agnostic, user-wide rules for any AI coding tool (Claude Code, Grok, Cursor, Codex, GitHub Copilot, and others). A repository's own `AGENTS.md` or `README.md` overrides these rules inside that repository.

## Language

Two destinations, two rules.

- **Chat — the user's language.** Everything addressed to the user: summaries, what is running now, which agent you are spawning and why, questions, plan iteration, and the plan as presented for acceptance. Match the language the user writes in, and follow them if they switch. Spawn announcements stay in the user's language.
- **Disk — concise English by default.** Everything written into a repository: code, comments, commit messages, documentation, plan and stage files, briefs, implementation logs, and the prompts handed to subagents. Any one of these exceptions drops the English requirement:
  1. The user explicitly names another language.
  2. The task itself is translation — write in the translation's target language.
  3. The **working repository** is already in another language. Heuristic, in order: that repository's `AGENTS.md` / `README.md` prose; then the dominant language of comments and docs in the files being edited. If mixed or unclear, stay English. "Working repository" means the project being changed, not this config repo — `$HOME/.ai-tools` being English never forces English elsewhere.

When no exception applies, chat is translated to English on disk. When an exception applies, disk matches that language, not English. These exceptions override every later restatement (skills, README, future agents).

## Agent categories

Skills and workflows name **categories**, never model product names. The running harness maps each category to a concrete subagent or model.

| Category | Responsibility | Market-style aliases |
|----------|----------------|----------------------|
| **planner** | Decompose work, design approaches, own acceptance judgment, validate deliveries, decide retry vs escalate. Writes no production code while orchestrating. | planning agent, thinking model, orchestrator |
| **implementer** | Write and edit code, with local design judgment, for one **specified** task (a plan stage or a brief). May delegate pure boilerplate to **mechanical**. | executor, action model, coding agent |
| **mechanical** | Fully specified, low-ambiguity work: apply a known patch across files, rename, run builds/tests and return raw output, gather evidence. Makes no design decisions. | worker, utility agent, tool agent |

1. Never hard-code a vendor model name (Opus, Sonnet, Grok, GPT, …) as an agent identity.
2. Receiving a request assigns you no category. Your category is what your own model or agent type fits; a skill's required category is satisfied by the agent that **runs** it, never by the one that was asked. See **Category resolution** and **Skill entry gate** below.
3. Where the harness has no separate subagents, one model still **behaves** in the assigned category for that turn.
4. Match each piece of work to the lowest-responsibility category capable of it: **mechanical** for execution and evidence, **implementer** for code, **planner** for planning and validation. This is category selection, not model cost — see rule 5 for cost within a category.
5. Model selection within a category is a separate axis from category choice, and matters whenever the harness exposes more than one model for a role (a picker, several tiers, multiple models labeled for the same job) — never accept whatever the harness defaults to without checking it fits the rule below:
   - **planner** — pick the strongest model available for planning and analysis, regardless of its cost. Decomposition and acceptance-judgment mistakes made here propagate into every downstream stage, so this is not the place to economize, and a harness offering several "planning" models does not mean they are equally capable.
   - **implementer** — pick the model with the best code-quality-to-cost ratio, not automatically the most expensive or most capable option offered. Treat a flagship-tier model priced well above the next tier down as a prompt to check whether it buys a real jump in code quality for the task at hand, not as the default pick.
   - **mechanical** — pick the cheapest and fastest model that reliably completes fully specified, low-ambiguity work. Upgrade only when the current choice is actually failing at the task, never preemptively.
6. When a harness does not expose enough distinct models to differentiate categories by model choice (for example, a CLI that currently offers a single model), fulfill a category by invoking a specific skill or prompt-mode built for that role instead, if the harness supports invoking skills as a distinct execution context. This changes only the mechanism satisfying the category, never its responsibilities or boundaries from the table above.
7. Announce every spawn in chat, in the user's language, naming both the category and what the harness assigned it — a concrete model ("Planning with `<model>`", "Calling implementer `<model>`", "Dispatching mechanical `<model>`") or, when rule 6 applies, the skill invoked instead ("Planning via `<skill-name>` skill", "Calling implementer via `<skill-name>` skill", "Dispatching mechanical via `<skill-name>` skill"). Say this at the point of spawning, not buried in a later summary. This is chat-only disclosure — it never becomes a hard-coded model or skill name inside skills, prompts, or plan files, so it does not conflict with rule 1.

### Category resolution

Once per session, before the first categorized work — any skill invocation, any spawn, any change-flow step — resolve all three categories against what the harness actually exposes. Each resolves to a **model or a bundled skill**: rule 5 governs the choice within a category, rule 6 the case where a skill rather than a model carries the role. Resolve once, reuse it for the session, and re-resolve only if the roster changes mid-session.

The resolved map is context, never a file. Restate it **in full** inside every spawn prompt: a spawned planner needs it to spawn its own implementers and mechanicals, and it starts with none of your context.

A pure question that spawns nothing and invokes no skill does not trigger resolution. The entry gate below catches anything that slips through.

### Skill entry gate

A skill declares the category it requires. Before executing one, check yourself against that requirement:

1. **You satisfy it** — run the skill yourself, spawning the subagents it names. Being the best available option for the category means you are the one who runs it; never spawn a copy of yourself.
2. **You do not satisfy it** — spawn the required category and become a **relay layer** between it and the user. You do not execute the skill's workflow at all.
3. **You are the agent that was spawned to run the skill** — the gate is satisfied by construction. Go straight to the workflow, never re-run this gate, never delegate the skill onward.
4. **You cannot enumerate the roster and cannot spawn** — run the skill yourself and say so in chat, naming the requirement you could not resolve.

### Delegation targets

Whatever the resolution mapped the required category to:

- **A model** — spawn a fresh agent on it with the skill invocation.
- **A bundled skill of the harness** — invoke that skill with the user's request **and** the requirements of the skill being delegated. The bundled skill follows its own rules and those requirements together; ours never replace its own.

Either target starts with zero context. The delegation prompt carries the user's request **in full and never summarized**, the working directory or repository, the resolved category map, every decision already settled with the user, and the language the user writes in — so what comes back is ready to relay unchanged.

### Relay layer

A spawned agent has no channel to the user. While delegating, you are that channel and nothing else.

- Pass its questions, drafts, and authorization requests to the user **verbatim**; pass the user's answers back **verbatim**. Never summarize, reorder, rewrite, answer, or approve on either side's behalf — an approval the Security rules require is the user's to give, never the relay's.
- Resume the same agent when the harness supports it. When it does not, spawn a new one with the original request, the path to its context file, and the accumulated question-and-answer history.
- The specialist keeps its working context in `<plans-root>/dev/<slug>-planning.md` — what it explored, what it found, what is settled, the current draft. Relay the path, never the contents.
- Add nothing of your own beyond the spawn announcements rule 7 requires.

## Change flow

### Scope

Apply the flow to any request that changes product code, tests guarding product behavior, or project docs describing behavior or structure. Never skip it because the request looks "clear", "fully specified", "small", or "just a UI move".

**Skip the flow only** when the request is exactly one of:

- A question or explanation with no repository write
- A single-file, single-hunk edit with no new file, no new module, no test change, and no design choice (typo, one-line constant, rename of an identifier the user already named)
- A documentation-only edit that does not accompany a behavior or structure change
- Conversation or process meta, including editing this file or the skills themselves

**Use the flow** whenever any of these holds: more than one file; a new component, module, or package; shell, navigation, layout, or routing; i18n keys; API or data model; security-sensitive code; anything that needs test changes; behavior and docs together; partial work on disk that still needs a plan to finish or re-validate.

**When in doubt, plan.** Do not invent an exception beyond the list above.

### Steps

1. Run `/plan-ai-tools`. Its own entry gate decides who executes it — you may end up relaying between the user and a spawned planner instead of planning yourself. It owns planning detail — source of truth, per-type tests, docs, commit boundaries, execution graph, multi-file stage layout, `.gitignore`. Do not restate that machinery here and do not touch product code while planning.
2. That skill iterates the plan with the user and saves it. **Plan acceptance is this flow's single approval point**: the acceptance request must state that accepting starts implementation immediately, and name the plans the run will cover.
3. If the user does not accept, stop — the saved plan is the deliverable.
4. On acceptance, run `/dev-ai-tools` (bare form) right away: no second confirmation, no hand-implementing outside the skill. Its entry gate decides who executes it, the same way.
5. `/dev-ai-tools` owns implementation, validation, correction rounds, plan status updates, and moving finished files to `plans/finished/`. Do not re-validate its work or duplicate its logic.

Continuity between plan and implementation exists **only here**. A direct `/plan-ai-tools` invocation always ends with the plan on disk and never implements.

### Interaction contract

- Every question, clarification, and choice belongs to the planning phase, before implementation starts.
- Once implementation starts, run to completion unattended. Record blockers on the plan (status `E`) and report them at the end instead of stopping to ask.
- The security gates below always override this contract. A plan needing one must surface it during planning.

### Output discipline

- Detail belongs in the plan files — stage steps, implementation logs, validation notes, diffs, command output, failure reports. Never paste them into chat.
- Chat gets a short summary plus the paths to read: a few lines, no stage-by-stage narration, no progress commentary while implementing.
- Only one exception: while iterating a plan with the user, give the detail needed to judge and accept it.

## Tools

| Skill | Use for |
|-------|---------|
| `/az-ai-tools` | Azure resources via the Azure CLI (`az`) |
| `/gc-ai-tools` | Google Cloud resources via the Google Cloud CLI (`gcloud`) |
| `/gh-ai-tools` | GitHub resources via the GitHub CLI (`gh`) |

## Security

- No secrets (API keys, connection strings, OAuth tokens, session tokens) in source, versioned config, or pipeline YAML.
- Treat all external input (user, AI output, webhooks) as untrusted before passing it downstream.
- Never create, change, or delete a cloud resource without explicit user approval for that specific action. Approval never carries over to the next action.
- Prefer reversible local work; confirm before destructive or shared-state operations (force-push, dropping tables, production deploys).

## Plans location

- Plans live in the repository's `plans/` directory: local working state, kept out of git unless the project says otherwise. `<plans-root>` elsewhere in this file means that directory, or the user-level fallback below when there is no repository.
- `<plans-root>/dev/` holds `/dev-ai-tools` ad-hoc briefs and correction feedback (Mode B), plus the `<slug>-planning.md` working context a delegated specialist keeps while a relay layer is in place; never treated as plan-queue input.
- Finished base and stage files move to `plans/finished/`.
- Never commit `plans/` unless the project explicitly tracks it.
- When the current working directory is not inside a git repository, save plans to a user-level directory outside any project instead — `$HOME/.ai-tools-plans` on Linux/Mac, or the equivalent user-level location on Windows (e.g. `%USERPROFILE%\.ai-tools-plans`) — creating it if it does not exist.

## User-specific overrides

After reading this file, also read `$HOME/AGENTS.md` if it exists (Windows: `%USERPROFILE%\AGENTS.md`). That file is written by the user, not by this repository.

- When the two conflict, `$HOME/AGENTS.md` wins over this file.
- It does not override a repository's own `AGENTS.md` or `README.md` inside that repository.
- If `$HOME/AGENTS.md` is missing, continue with this file only. Do not create or edit it unless the user asked directly, or an install/update step is creating the empty file.
