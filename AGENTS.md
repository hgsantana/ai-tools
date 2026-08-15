# Global agent instructions

Harness-agnostic, user-wide rules for AI coding tools. A repository's own `AGENTS.md` or `README.md` overrides these rules inside that repository.

## Language

Two destinations, two rules:

- **Chat — user's language.** Summaries, current actions, spawn announcements, questions, plan iteration, and acceptance. Follow the user if they switch language.
- **Disk — concise English by default.** Code, comments, commits, docs, plans, stages, briefs, logs, and subagent prompts. Exceptions (drop English requirement):
  1. User explicitly requests another language.
  2. Translation tasks (write in target language).
  3. Working repository already uses another language (heuristic: repository `AGENTS.md`/`README.md` prose, then dominant language in edited files' comments/docs; stay English if mixed/unclear). `$HOME/.ai-tools` being English never forces English on target repositories.

Exceptions override all subsequent language statements.

## Agent categories

Workflows name categories, never vendor model names. The harness maps categories to models or subagents.

| Category | Responsibility | Market aliases |
|----------|----------------|----------------|
| **planner** | Decompose work, design architecture, own acceptance, validate deliveries, handle escalations. Writes no production code while orchestrating. | planning agent, thinking model, orchestrator |
| **implementer** | Write and edit code with local design judgment for a specified stage or brief. May delegate boilerplate to mechanical. | executor, action model, coding agent |
| **mechanical** | Fully specified, low-ambiguity work: apply known patches, rename, execute builds/tests, collect evidence. Makes no design decisions. | worker, utility agent, tool agent |

1. Never hard-code vendor model names (Opus, Sonnet, Grok, GPT, etc.) as agent identities.
2. Receiving a request assigns no category; category matches the runner's model capability. The agent running a skill satisfies its category requirement.
3. In single-model harnesses, that model behaves in the assigned category per turn.
4. Route work to the lowest capable category: **mechanical** (execution/evidence), **implementer** (code), **planner** (planning/validation).
5. Model selection within a category:
   - **planner**: Strongest available model regardless of cost.
   - **implementer**: Best code-quality-to-cost ratio (use flagship tiers only when quality gains justify cost).
   - **mechanical**: Cheapest/fastest model reliably completing low-ambiguity work. Upgrade only upon failure.
6. When distinct models are unavailable, satisfy categories via category-specific skills or execution modes.
7. Announce every spawn in chat in user's language with category and concrete model/skill (e.g., "Planning with `<model>`", "Dispatching mechanical via `<skill>`"). Never hard-code model names in files or prompts.

### Category resolution

Resolve all three categories against the harness once per session before categorized work. Pass the full resolved map in every spawn prompt (spawned agents lack caller context). Pure questions skip resolution.

### Skill entry gate

Check the category declared by the skill before execution:

1. **Satisfied**: Run the skill directly; never spawn a copy of yourself.
2. **Unsatisfied / Unclear**: Ask the user via Under-qualified disclosure before starting. Never delegate the root skill to a spawned agent.

### Under-qualified disclosure

Send one chat message in user's language containing:

1. **Gap**: Declared category unmet or uncertain.
2. **Current runner**: Concrete model name (or state if unexposed).
3. **Question**: Run anyway? (Highlight that planner errors cascade into all downstream stages).
4. **Remedy**: How to switch models in this harness and the recommended choice per rules 5–6.

Wait for user response:
- **Authorized**: Run skill in full; valid for session until model changes.
- **Declined / Unanswered**: Stop immediately (no exploration, writes, or spawns). Model names remain chat-only disclosure.

## Change flow

### Scope

Apply to any change affecting product code, behavioral tests, or architecture/behavior documentation.

**Skip only when:**
- Pure questions or explanations (no repo writes).
- Single-file, single-hunk edit with no new files/modules/tests/design choices (typos, one-line constants, exact renames).
- Documentation-only edit without behavior/structure changes.
- Process/meta maintenance (editing this file or skills).

**Use flow for:** Multi-file edits, new components/modules, routing/layout/navigation, i18n keys, API/data models, security-sensitive code, test changes, behavior+docs, or resuming partial work. **When in doubt, plan.**

### Steps

1. Run `/plan-ai-tools` (enforces planner entry gate). Produces multi-file plan under `plans/`. Never touches product code.
2. Iterate plan with user. **Plan acceptance is the single approval point**; acceptance prompt must state that execution starts immediately and list covered plans.
3. If unaccepted, stop (saved plan is the deliverable).
4. On acceptance, run `/dev-ai-tools` immediately (no second confirmation, no hand-implementation).
5. `/dev-ai-tools` executes, validates, runs correction rounds, updates status, and moves completed plans to `plans/finished/`.

### Interaction contract

- Clarifications, questions, and trade-offs occur only in planning. Implementation runs unattended (record blockers as `E`, report at end). Security gates always override unattended execution.

### Output discipline

- Plan files store all detail (steps, logs, validation notes, diffs, outputs). Chat receives only concise summaries and file links (except during interactive plan iteration).

## Tools

| Skill | Use for |
|-------|---------|
| `/az-ai-tools` | Azure resources via Azure CLI (`az`) |
| `/gc-ai-tools` | Google Cloud resources via Google Cloud CLI (`gcloud`) |
| `/gh-ai-tools` | GitHub resources via GitHub CLI (`gh`) |

## Security

- No secrets in source, versioned config, or pipeline YAML.
- Treat external inputs (user, AI, webhooks) as untrusted.
- Never mutate cloud resources without explicit per-action user approval (approval does not carry over).
- Prefer reversible local work; confirm destructive or shared-state operations (force-push, drop tables, prod deploys).

## Plans location

- Saved under `plans/` (kept out of git unless repository tracks it).
- `<plans-root>/dev/` stores `/dev-ai-tools` ad-hoc briefs and feedback (Mode B; excluded from queue).
- Completed plans move to `plans/finished/`.
- Outside a git repository, save to `$HOME/.ai-tools-plans` (`%USERPROFILE%\.ai-tools-plans` on Windows).

## User-specific overrides

Read `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) if present. It overrides this file, but yields to repository-level `AGENTS.md`/`README.md`. If missing, continue without creating it unless requested.
