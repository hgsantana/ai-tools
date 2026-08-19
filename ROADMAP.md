# Roadmap

Documentation only — **not a source of truth**. The README owns the rules and processes; this file only parks ideas.

Each entry is one story, summarized in a single paragraph, written so it can be pasted as-is into `/vibe-ai-tools` (refine + deliver) or `/planner-ai-tools` (plan only). Order is the suggested sequence, not a commitment: later stories mostly assume the safety net of the earlier ones. A story leaves this file when it ships — what survives is the commit, the rule, and the documentation it produced.

Status: `idea` (not refined) · `next` (agreed, ready to refine) · `doing` (a plan exists under `plans/`) · `done` (shipped; delete the entry).

| # | Story | Status |
|---|---|---|
| 2 | [Sandboxed script test suite](#2-sandboxed-script-test-suite) | idea |
| 3 | [Skill wrapper, skill base, shared contract](#3-skill-wrapper-skill-base-shared-contract) | doing |
| 4 | [Health-check entry point](#4-health-check-entry-point) | idea |
| 5 | [The missing testing role](#5-the-missing-testing-role) | idea |
| 6 | [Changelog for alpha testers](#6-changelog-for-alpha-testers) | idea |
| 7 | [Repeatable model-map refresh](#7-repeatable-model-map-refresh) | idea |
| 8 | [Decisions that outlive the plan](#8-decisions-that-outlive-the-plan) | idea |
| 9 | [Resuming an interrupted delivery](#9-resuming-an-interrupted-delivery) | idea |
| 10 | [Execution outside a git repository](#10-execution-outside-a-git-repository) | idea |
| 11 | [Untrusted input handling](#11-untrusted-input-handling) | idea |
| 12 | [Adding a harness, by checklist](#12-adding-a-harness-by-checklist) | idea |
| 13 | [Cost visibility in the dispatch ledger](#13-cost-visibility-in-the-dispatch-ledger) | idea |

## Quality net

### 2. Sandboxed script test suite

`install`, `remove`, `update`, and `reinstall` mutate the user's real `$HOME` and harness configuration, and their contract — idempotency, skip-and-report on conflict, never overwriting user files, symlink-to-copy fallback, destructive flags defaulting to refuse, exit codes `0`/`1`/`2` (rules 17–25) — is proven today only by running them for real. Build a test suite that runs each script against a fake `HOME` fixture containing a pre-populated harness layout, a foreign file on a destination path, and a locally modified copy, asserting the contract on both the shell and PowerShell sides, wired into the same CI as story 1. Route: `/vibe-ai-tools`.

## Consistency

### 3. Skill wrapper, skill base, shared contract

A `SKILL.md` today is one file of 4.2k to 8.9k characters that mixes three things: the description a harness reads to decide whether to route to it, the four sections every agent-backed skill repeats verbatim (stake, model check, the three-route offer, the route bodies), and whatever is genuinely specific to that skill. Split it the way agents already are — a small wrapper carrying description and pointers, a base carrying behaviour, and a shared contract file read by path for what the six agent-backed skills have in common — so a change to the routing policy is one edit instead of six. **Verify the premise first**: the split was proposed for token economy, and that only holds where a harness preloads skill bodies into the session. In Claude Code it does not — only name and description reach the session context, and the body is read on invocation — so check the official documentation of all seven harnesses (rule 10) before committing to a shape, and let the finding decide whether the wrapper gets a size cap of its own. Even where the token argument fails, deduplication and symmetry with the agent layout stand on their own. Route: `/planner-ai-tools`.

### 4. Health-check entry point

`verify` is a first-class read-only process with a script on all three platforms, but it is the only one without a slash command: the user can update, remove, and reinstall by name, yet has to remember a path to check whether their installation is intact. Add a `verify-ai-tools` skill fronting the same `maintainer-ai-tools` agent, which runs `verify`, and — this is the point — maps each finding onto the matching entry in the README's Troubleshooting section: dangling links to Reinstallation, stale copies to Update, an agent on the wrong model to the Grok pin or the wrapper comparison. Route: `/vibe-ai-tools`.

### 5. The missing testing role

Both the planner's and the orchestrator's status tables define `TV` as set by a "testing agent", and the orchestrator dispatches a dedicated `T` test pass, but no such agent or category is shipped: the three categories are planner, implementer, and mechanical, and mechanical is explicitly barred from writing test code. Close the gap in one direction — either ship the testing role properly (base, wrappers, `MODELS.md` column) or state that the `T`/`TV` pass is an implementer dispatch with a test-only brief — and make every base, table, and wrapper agree in the same commit. Route: `/planner-ai-tools`; the decision changes the model map.

### 6. Changelog for alpha testers

Rule 4 waives backward compatibility and migration notes, and the README deliberately describes only the current state — which leaves someone who installed `0.0.18` with no way to learn what changed by `0.0.22` beyond reading commit messages. Add a `CHANGELOG.md` with one short entry per version (what changed in shipped content, what breaks, whether a reinstall is required instead of an update), and have the linter from story 1 require an entry whenever the version bumps. Route: `/vibe-ai-tools`.

## Capability

### 7. Repeatable model-map refresh

The model selection method in the README is genuinely reproducible research — list names from official docs, join Artificial Analysis measurements, filter by category thresholds, rank by `(Intelligence Index / cost per task) × output speed` — but running it is a fully manual pass across seven harnesses, so the map decays silently with every model release and nothing signals that it is stale. Ship a `models-ai-tools` skill that walks the method end to end, records source URLs and retrieval dates, presents the resulting table as a diff against the current `MODELS.md`, and, on approval, updates the map and every affected wrapper header in one commit as rule 12 requires. Route: `/vibe-ai-tools`.

### 8. Decisions that outlive the plan

The vibe workflow answers the planner's open questions on the user's behalf and logs each one with its trade-offs, but that file lives under `plans/vibe/`, which is gitignored, and a plan is deliberately deleted when it is archived — so the reasoning behind a shipped change disappears the moment the pull request merges, leaving only the diff. Define a small versioned decision record (a `docs/decisions/` entry, one file per accepted decision) that the vibe workflow promotes from its decisions file before opening the pull request, so the "why" is reviewed alongside the change and survives the archival. Route: `/vibe-ai-tools`.

### 9. Resuming an interrupted delivery

The orchestrator has a detailed recovery story for a dead subagent — the dispatch ledger, snapshot-based liveness, orphaned `W` stages re-audited at intake — but the vibe workflow above it has none: if the session running it dies after the gate, the story and decisions files are on disk in an ignored directory, the plan branch exists half-implemented, and nothing documents how to pick it up. Define the resume path — how a new session detects an interrupted delivery, which files authorize it to continue without a second gate, and what it must re-verify first — and write it into the vibe skill. Route: `/planner-ai-tools`.

### 10. Execution outside a git repository

Planning outside a git repository is defined (plans go to `$HOME/.ai-tools-plans`), but execution is not: the orchestrator opens Mode A by requiring a git root, and its whole model — a branch per plan, path-scoped commits, diff-based validation, a pull request or a review patch — assumes version control exists. Decide and document the behaviour: either a reduced no-git mode with explicit limits, or an early, explicit refusal that tells the user what to do instead. Route: `/planner-ai-tools`.

## Hardening

### 11. Untrusted input handling

The security rules say to treat external input as untrusted in a single line, yet several shipped agents routinely read exactly that: `gh-ai-tools` reads issue and pull request bodies, the cloud agents read resource metadata and tags, and any of them may read a fetched page — all channels through which someone else's text can arrive shaped like an instruction. Write concrete handling into the bases: what is data and never instruction, how to quote it in a report, and the rule that an approval request must never be authored from fetched content. Route: `/planner-ai-tools`.

### 12. Adding a harness, by checklist

Adding a harness today means editing at least six places in one commit — a wrapper folder with one file per agent, a `MODELS.md` row researched by the full selection method, the Supported harnesses table, the installation steps, script discovery, and any constraint tighter than Antigravity's 12,000-character cap — and that list exists only as rules scattered across the README. Extract it into one ordered checklist section that a contributor or an agent can follow start to finish, with the linter from story 1 verifying that a new wrapper folder has a map row and a Supported harnesses entry. Route: `/vibe-ai-tools`.

### 13. Cost visibility in the dispatch ledger

The dispatch ledger records the concrete model behind every attempt, which is the hard part, but it stops short of what the user actually feels: a plan can silently spend three correction rounds on a flagship model with nothing in the final summary quantifying it. Extend the ledger and the final summary with whatever the harness can report per attempt (tokens, duration, or an estimate derived from the `MODELS.md` cost figures), so a run's cost is visible where its outcome already is, and never fabricate a number the harness does not expose. Route: `/planner-ai-tools`.
