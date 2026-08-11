# Global agent instructions

Harness-agnostic, user-wide rules for any AI coding tool (Claude Code, Grok, Cursor, Codex, and others). A repository's own `AGENTS.md` or `README.md` overrides these rules inside that repository.

## Language

Two destinations, two rules.

- **Chat — the user's language.** Everything addressed to the user: summaries, what is running now, which agent you are spawning and why, questions, plan iteration, and the plan as presented for acceptance. Match the language the user writes in, and follow them if they switch.
- **Disk — concise English.** Everything written into a repository: code, comments, commit messages, documentation, plan and stage files, briefs, implementation logs, and the prompts handed to subagents. Use another language only when the user explicitly asks, or when the task itself is translation.

So a plan is discussed in the user's language and stored in English. Translating for the chat is expected and never changes what lands on disk.

## Agent categories

Skills and workflows name **categories**, never model product names. The running harness maps each category to a concrete subagent or model.

| Category | Responsibility | Market-style aliases |
|----------|----------------|----------------------|
| **planner** | Decompose work, design approaches, own acceptance judgment, validate deliveries, decide retry vs escalate. Writes no production code while orchestrating. | planning agent, thinking model, orchestrator |
| **implementer** | Write and edit code, with local design judgment, for one **specified** task (a plan stage or a brief). May delegate pure boilerplate to **mechanical**. | executor, action model, coding agent |
| **mechanical** | Fully specified, low-ambiguity work: apply a known patch across files, rename, run builds/tests and return raw output, gather evidence. Makes no design decisions. | worker, utility agent, tool agent |

1. Never hard-code a vendor model name (Opus, Sonnet, Grok, GPT, …) as an agent identity.
2. The current session acts as **planner** while running `/plan-ai-tools` or `/dev-ai-tools`.
3. Where the harness has no separate subagents, one model still **behaves** in the assigned category for that turn.
4. Use the cheapest capable category for the work itself: **mechanical** for execution and evidence, **implementer** for code, **planner** for planning and validation.
5. Model selection within a category is a separate axis from category choice, and matters whenever the harness exposes more than one model for a role (a picker, several tiers, multiple models labeled for the same job) — never accept whatever the harness defaults to without checking it fits the rule below:
   - **planner** — pick the strongest model available for planning and analysis, regardless of its cost. Decomposition and acceptance-judgment mistakes made here propagate into every downstream stage, so this is not the place to economize, and a harness offering several "planning" models does not mean they are equally capable.
   - **implementer** — pick the model with the best code-quality-to-cost ratio, not automatically the most expensive or most capable option offered. Treat a flagship-tier model priced well above the next tier down as a prompt to check whether it buys a real jump in code quality for the task at hand, not as the default pick.
   - **mechanical** — pick the cheapest and fastest model that reliably completes fully specified, low-ambiguity work. Upgrade only when the current choice is actually failing at the task, never preemptively.

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

1. Run `/plan-ai-tools`. It owns planning detail — source of truth, per-type tests, docs, commit boundaries, execution graph, multi-file stage layout, `.gitignore`. Do not restate that machinery here and do not touch product code while planning.
2. That skill iterates the plan with the user and saves it. **Plan acceptance is this flow's single approval point**: the acceptance request must state that accepting starts implementation immediately, and name the plans the run will cover.
3. If the user does not accept, stop — the saved plan is the deliverable.
4. On acceptance, run `/dev-ai-tools` (bare form) right away: no second confirmation, no hand-implementing outside the skill.
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

- Plans live in the repository's `plans/` directory: local working state, kept out of git unless the project says otherwise.
- Finished base and stage files move to `plans/finished/`.
- Never commit `plans/` unless the project explicitly tracks it.
