# Task: user-agents-skills-only

| Field | Value |
|---|---|
| Base branch | plan/skills-session-model (PR #22) |
| Work branch | plan/user-agents-skills-only |
| PR target | plan/skills-session-model; do not merge |
| Status | F |
| Executor | planner-ai-tools (coordinator); implementer-ai-tools x2 (A: USER-AGENTS.md + docs; B: skills + lint + tests) |

## Objective

Rewrite `USER-AGENTS.md` for the skills-only model, and make it the single source of the subagent spawn protocol that the skills currently duplicate.

## User decisions (binding)

1. Centralize in `USER-AGENTS.md` the default-worker rule and the list of harness native subagent APIs (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent). The 9 skills drop their duplicated `<rule id="default-worker">` text and the API list from vibe and campaign `spawn-apis`, and cite the USER-AGENTS section instead. Skill-specific behaviour stays in the skills:
   - campaign `no-nested-fallback` and its "passes never take the fallback" clause;
   - the vibe and campaign implementer model question and the recorded model;
   - session-subagent passes on the session model;
   - `one-model-question`.
2. Rename the offer table column `Agent` to `Execution`, translated at render like the other columns. It is still filled from the skills' `Agent:` description field, which keeps its name.
3. `<system_overview>` gives no skill count ("The ai-tools skills are the user entry points.").

## Files

- Modify: `USER-AGENTS.md`
- Modify: `skills/*/SKILL.md` (all 9)
- Modify: `scripts/lint.sh`, and `scripts/test/*.sh` / `scripts/test.sh` where they assert the changed text or vocabulary
- Modify: `README.md`, `docs/USAGE.md` where they describe USER-AGENTS sections, dispatch, the spawn rule, or the offer table
- Modify: version string per repository rules (bump the ALPHA patch if CI's version check requires it against the base)

## Steps

1. `USER-AGENTS.md`:
   - **Intro (line 5):** drop "agent wrappers" from what is installed.
   - **`<system_overview>`:** remove the count. Keep "Each description states purpose, Impact:, and Agent:" and the commits and delivery bypass sentence.
   - **Rule `memory-only`:** remove "wrappers, MODELS.csv"; keep "harness config, or the repository".
   - **`<offer_message>`:** column `Agent` → `Execution`, filled from `Agent:`. "Run it here" description: "this session, without ai-tools skills".
   - **`<handling>` `run_it_here` and `single-gate`:** "skills and agents" → "skills".
   - **Replace `<dispatch_protocol>` with an execution protocol** (e.g. `<execution_protocol>`) that says:
     - the host session executes the selected skill's `<session_workflow>` on the session model;
     - a `<template>` is spawned only through the harness's native subagent API (list above), with the populated payload and file paths, never conversation context or raw skill text;
     - how each executor spawns: `executor="default-worker"` uses the harness default agent type and model; `executor="implementer"` uses the implementer model the skill resolved; `executor="session-subagent"` uses the session's own model where the API accepts a model;
     - announce each spawn in the user's language with the template role and model;
     - builds, test suites, script runs, and bulk fact collection go to default workers; a single pinpoint command the session needs for its next decision runs in the session;
     - if a default-worker spawn fails, the session runs the payload itself and states that in the report, unless the skill forbids that fallback (campaign passes);
     - code-writing subagents run in parallel only on separate files; read-only exploration, builds, and tests may always run concurrently.

     Give every rule a unique `id` so skills can cite them.
   - **Delete the `<agents>` section entirely.**
   - **Keep unchanged in meaning:** `<language_rules>`, `<user_interaction>`, and `<security_guardrails>`.
2. Skills:
   - In each of the 9 SKILL.md files, replace the full default-worker rule text with a short citation of the USER-AGENTS execution protocol.
   - In vibe and campaign, trim `spawn-apis` to the skill-specific model mapping, citing USER-AGENTS for the API list and payload rules.
   - Keep the campaign-specific no-fallback wording, the implementer job blocks, and the model question steps.
   - Do not change descriptions, `Impact:`, or `Agent:` values.
3. `scripts/lint.sh`:
   - Update the XML vocabulary: drop `dispatch_protocol`, `agents`, `worker` if unused; add the new tag names.
   - Replace any USER-AGENTS checks for removed sections with checks for the new execution protocol, the `Execution` column, and no leftover agent-section tags.
   - If lint validated skill text for the duplicated API list, change it to require the citation instead.
   - Keep structural skill validation and placeholder parity.
4. Tests and docs: update the assertions, README, and USAGE text that describe the old sections, the column name, or the duplicated rule.

## Tests

- `scripts/lint.sh` exits 0 with 0 warnings. Also run it with `--base plan/skills-session-model` if the version check applies.
- `scripts/test.sh` exits 0.
- `shellcheck` shows only the known SC1071 on `scripts/shell/install-zsh.sh`.
- Negative probes on a scratch copy:
  - lint warns when `<agents>` or `<dispatch_protocol>` is reintroduced in USER-AGENTS.md;
  - lint warns when a skill template has an `executor` that the protocol does not define.
- Grep: `grep -rn 'Claude Code Agent, Copilot runSubagent' skills/` prints nothing (the API list lives only in USER-AGENTS.md).
- Grep: `grep -rnE 'planner-ai-tools|implementer-ai-tools|mechanical-ai-tools|MODELS\.csv|wrapper' USER-AGENTS.md` prints nothing.

## Acceptance criteria

- USER-AGENTS.md has no `<agents>` section, no agent names, no wrapper or MODELS.csv mentions, and no skill count.
- USER-AGENTS.md defines the execution protocol for all three executors, the native API list, the spawn-failure fallback with its skill-level opt-out, and the parallelism rule.
- The offer table column is `Execution`; the skills' `Agent:` field is unchanged.
- The harness API list appears only in USER-AGENTS.md. Every skill with a template cites the execution protocol. Campaign still forbids the fallback inside passes.
- Lint, tests, and docs are consistent; the checks in Tests pass.

## Commit message

```
refactor!: centralize spawn protocol in USER-AGENTS and drop agent sections
```

## Implementation log

- W: two implementers split by files (A: USER-AGENTS.md, README.md, docs/USAGE.md; B: skills/*/SKILL.md, scripts/lint.sh). First background dispatch overlapped with a foreground re-dispatch; B removed a duplicated `check_spawn_protocol_citation` and fixed a `valid_executors()` sed bug from that overlap. Notes: dev/tmp/user-agents-skills-only-impl-a.md, dev/tmp/user-agents-skills-only-impl-b.md.
- USER-AGENTS.md: `<dispatch_protocol>` and `<agents>` replaced by `<execution_protocol>` (rules session-model, native-spawn, default-worker, implementer, session-subagent, spawn-announce, spawn-fallback, parallel-spawns); column `Execution`; no skill count; ~7.5k chars.
- Skills: default-worker rule cites USER-AGENTS `<execution_protocol>`; vibe/campaign `spawn-apis` keep only the model mapping; campaign `no-nested-fallback` cites `spawn-fallback` and forbids it in passes.
- Lint: vocab updated; USER-AGENTS layout checks; executor validity derived from `<execution_protocol>` rule ids; new `check_spawn_protocol_citation`. No test-script changes needed.
- README version 0.0.49-ALPHA -> 0.0.50-ALPHA.
- V: coordinator diff review passed against objective, files, and acceptance criteria.
- T: verifier PASS (dev/tmp/user-agents-skills-only-output.log): lint 0 warnings, lint --base 0 warnings, test.sh 305 ok, shellcheck only SC1071, both greps empty, all three negative probes warn.
- F: committed.
