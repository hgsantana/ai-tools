# Remove agents

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |

## Goal

First phase of making ai-tools 100% skills-focused: remove everything that exists only because of the three agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`). That covers build and scripts, tests, lint, and documentation. After this plan, install, update, remove, and verify handle only global instructions and skills. The repository ships no agent bases, subagent contract, harness wrappers, wrapper templates, `MODELS.csv`, or model-fetch scripts. Lint drops every agent, wrapper, model-pin, and Grok check but keeps structural skill validation. README, `docs/USAGE.md`, and `ROADMAP.md` no longer describe agents. Skills are reworked in a later phase.

## Base branch

`master` (analysed at `9c6e801`).

## Binding decisions (from the user)

1. `skills/**/SKILL.md` stays byte-identical, including `Agent:` in descriptions, `agent="..."` on `<template>`, and dispatch text. Temporary inconsistency is accepted.
2. `USER-AGENTS.md` stays byte-identical, including `<agents>`, `<dispatch_protocol>`, and the Agent column. It is still installed as global instructions.
3. `MODELS.csv`, `scripts/aa-metrics.sh`, and `scripts/harness-models.sh` are removed now. `skills/models-ai-tools` stays in the tree, broken, until the skills phase.
4. No legacy-migration code. The transition is verified and recorded under Risks (see [Transition analysis](#transition-analysis-decision-4)).
5. Every lint and CI check tied to agents is removed, and structural skill validation is kept. Lint and tests pass against the untouched skills and `USER-AGENTS.md`.

## Execution graph

Strictly sequential: 1 → 2 → 3 → 4 → 5. Run one stage at a time.

- 1 before 2: master lint is red. A green baseline is needed before "lint passes" can mean anything.
- 2 before 3: `scripts/lint.sh` calls `category_for`, `model_for`, and `model_effort_for` from `scripts/shell/lib.sh`, and stage 3 deletes them.
- 3 before 4: `ensure_clone`/`require_clone` require `MODELS.csv` and `agents/`. Tests stage fixtures from `agents/claude-code/*`. Both must stop depending on those files before stage 4 deletes them.
- 4 before 5: stage 5 renumbers README rules and cites the final file set.

## Stages

1. [Green lint baseline](./1-remove-agents.md): register the `USER-AGENTS.md` tags missing from `XML_VOCAB` and split compound backticked references. Only `lint.sh` and the README vocabulary table change.
2. [Lint without agents](./2-remove-agents.md): drop wrapper, agent-base, contract, model-pin, Grok, `Agent:`, and `<template agent>` checks, plus agent-only vocabulary. Updates the README Development checks and Semantic XML grammar sections.
3. [Scripts without agents](./3-remove-agents.md): install, update, remove, and verify stop handling agents and the Grok models block. Tests move to skill fixtures. Updates the README process, safety, harness, and troubleshooting sections.
4. [Delete agent sources](./4-remove-agents.md): delete `agents/`, `templates/`, `MODELS.csv`, and the two model-fetch scripts, and change clone validation to `USER-AGENTS.md` plus `skills/`. Removes the README model and wrapper sections.
5. [Documentation without agents](./5-remove-agents.md): README overview and rules (with renumbering and citation updates), `docs/USAGE.md`, `ROADMAP.md`, version bump, and the final repository-wide grep.

## Baseline (measured on master `9c6e801`)

- `scripts/lint.sh`: exit 2, `562 ok, 1 skipped, 6 warnings`. All six warnings come from the untouched `USER-AGENTS.md`:
  - tags outside the vocabulary: `<skill_question>` (line 32), `<skill_options>` (line 35), `<default>` (line 73)
  - bare references outside the vocabulary: `<skill_question>`, `<skill_options>`
  - unresolved reference parsed from the compound span `` `<session_workflow> <step>` `` (line 57)
- `scripts/test.sh`: exit 0, `361 ok, 0 skipped, 0 warnings`.
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`: exit 1, with the single finding `SC1071` on `scripts/shell/install-zsh.sh`. It is pre-existing and not agent-related (see Risks).

## Invariants for every stage

- `scripts/lint.sh` exits 0 (the version-bump check SKIPs without `--base`; a SKIP does not fail).
- `scripts/test.sh` exits 0.
- shellcheck (CI command above) reports nothing beyond the pre-existing `SC1071` on `scripts/shell/install-zsh.sh`.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds: both stay byte-identical.
- No code that detects or cleans up agent-era artifacts (decision 4).
- `.github/workflows/ci.yml` stays unchanged. It has no agent-specific step, and its shellcheck glob and `test-shell` job stay valid after the deletions.

## Final acceptance: repository-wide agent grep

Run from the repository root after stage 5. It must print nothing (the final `grep` exits 1). Hits are allowed only in `skills/`, `USER-AGENTS.md`, and `dev/`, which are excluded. Four tokens are stripped because they are legitimate non-agent names or registrations of the untouched `USER-AGENTS.md` vocabulary:

- `AGENTS.md`, `USER-AGENTS.md`, `AGENTS.override.md` (instruction file names)
- `$HOME/.agents` (a shared discovery root the scripts report and never touch)
- `` `<agents>` `` (README vocabulary row for the `USER-AGENTS.md` section)
- the `XML_VOCAB=` line in `scripts/lint.sh`

```bash
TERMS='(planner|implementer|mechanical)-ai-tools|subagent|wrapper|MODELS\.csv|model_for|model_effort_for|models_csv_field|category_for|MODEL_TABLE|grok_models|GROK_(TOML|BEGIN|END)|subagents\.models|harness-models|aa-metrics|agent_base|agents_root|templates/wrappers|\bagents?\b'
git ls-files --cached --others --exclude-standard -- . ':!skills' ':!USER-AGENTS.md' ':!dev' \
  | xargs -d '\n' grep -HnIiE "$TERMS" \
  | grep -vE '^scripts/lint\.sh:[0-9]+:XML_VOCAB=' \
  | sed -E 's/(USER-)?AGENTS(\.override)?\.md//g; s/\$HOME\/\.agents//g; s/`<agents>`//g' \
  | grep -iE "$TERMS"
```

Also required: `test ! -e agents && test ! -e templates && test ! -e MODELS.csv && test ! -e scripts/aa-metrics.sh && test ! -e scripts/harness-models.sh`.

On master this exact command reports hits in README.md (105), ROADMAP.md (4), docs/USAGE.md (16), scripts/lint.sh (147), scripts/shell/lib.sh (99), install.sh (2), update.sh (3), remove.sh (2), and the scripts/test files (145), besides every file that stage 4 deletes.

## Transition analysis (decision 4)

**Claim to verify.** `update.sh` runs `uninstall_agents` and `remove_grok_models` from the pre-reset clone, so users updating from an agent-bearing version lose their agents and Grok block through the old code.

**Method.** A sandbox (fake `HOME`, local bare origin) was built from the master tree. The old `install.sh` ran for `claude-code,grok`, and one agent copy was then edited locally. Next, a commit was pushed to origin that deletes `agents/`, `templates/`, `MODELS.csv`, and both model scripts. It also removes the agent and Grok calls from `update.sh`, changes its final info text, and changes one `lib.sh` message. Finally, the clone's old `update.sh` was run.

**Observed.**

- `git reset --hard` replaced `scripts/shell/update.sh` with a new inode (75834 → 75996). Bash kept reading the old, unlinked file through its open descriptor, so the old script body ran to the end (old info text printed, the new text never appeared). The `lib.sh` functions sourced before the reset stayed in memory, and the changed `lib.sh` message never appeared. The claim holds, including after the reset.
- Before the reset (old code): unmodified agent copies were removed from `~/.claude/agents` and `~/.grok/agents`, and the managed Grok block was removed. The locally edited agent copy was skipped as user work, as designed.
- After the reset, the old in-memory functions ran against the new tree:
  - `install_agents` printed `SKIP: no wrapper folder` once per harness.
  - `install_grok_models` appended a new managed block holding only the `[subagents.models]` header. With no bases left, `grok_models_toml` still succeeds, emitting the header with no entries. The new code never removes this block.
  - `verify_install` warned `missing model table`, `missing subagent contract`, `missing agent base: .../agents/*-ai-tools.md`, and `orphan agent present` (the edited copy).
  - Result: `done: 85 ok, 3 skipped, 4 warnings`, exit 2.
- With `--overwrite`, the old post-reset `prune_orphan_agents` also deletes locally modified agent copies. This matches `--overwrite` semantics.
- The next update runs only new code and no longer touches agent roots or `~/.grok/config.toml`.

These findings are recorded as risks R1–R3 below. No code is added for them.

## Planner decisions (in scope, recorded)

- Stage 1 is a prerequisite fix, not agent removal: the "every stage passes lint" rule cannot hold on a red master. It edits `lint.sh` and the README vocabulary table only. `USER-AGENTS.md` stays untouched (open question 1).
- README process sections are updated in the same stage as the script behaviour they describe (README rule 26). The lint check list and the vocabulary table are updated in the same stage as `lint.sh` (README Development checks and Semantic XML grammar). Rule-list edits and renumbering happen once, in stage 5.
- `templates/` is deleted entirely: it contains only `templates/wrappers/`.
- `in_scope` in `lib.sh` is removed. Its only callers are the Grok pinning functions.
- `sweep_stale_links` loses its whole-directory agent-root links and the retired `$HOME/.gemini/agents` root. The skills-root sweep and the retired `$HOME/.gemini/skills` root stay.
- `refresh_copies`/`refresh_one_copy`/`same_as_revision` have no caller today. Only the agent loop is removed. Deleting the unused helpers is out of scope.
- The `$HOME/.agents` discovery report stays: it is a shared skills discovery root.
- The README "Change the session model" table is removed. It exists to contrast the session model with wrapper pins.
- Version: `0.0.47-ALPHA` → `0.0.48-ALPHA`, bumped once in stage 5. The PR lint job checks the bump against the PR base.
- `ROADMAP.md` and `docs/USAGE.md` edits follow the recommendations in open questions 5 and 6. The implementer applies them unless the user decides otherwise.

## Risks

- **R1: Transitional Grok residue.** After the one transitional update, `~/.grok/config.toml` keeps an ai-tools marker block holding an empty `[subagents.models]` table, and no later ai-tools run removes it. It is harmless as-is. If the user later adds their own `[subagents.models]` table, TOML rejects the duplicate table and Grok may fail to parse its config. Mitigation without code: say so in the PR description or release note (manual deletion of the marker-delimited block). See open question 2.
- **R2: One-time exit 2 on the transitional update.** Old `verify_install` warns about the missing model table, contract, and agent bases. `/update-ai-tools` and CI-like wrappers may report the update as failed even though skills and instructions are correct. A second update is clean.
- **R3: Locally modified agent copies stay behind.** They remain in `~/.claude/agents`, `~/.grok/agents`, `~/.codex/agents`, `~/.copilot/agents`, `~/.cursor/agents`, and `~/.gemini/config/agents` (the old code skips them without `--overwrite`/`--force`). New scripts never look there, so users delete them by hand. Old stale agent symlinks are swept by the old code only when the transitional update runs without `--no-sweep`.
- **R4: Skills dispatch to agents that are no longer installed.** Untouched skills still name `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools` in `<template agent>`, and `USER-AGENTS.md` still tells the session to spawn them. Once this lands on `master` and users update, harness spawns fail or fall back to the `<dispatch_protocol>` "carry the work yourself" path until the skills phase ships. See open question 3.
- **R5: `/models-ai-tools` is broken but still installed and offered.** It cites `MODELS.csv`, wrapper headers, both deleted scripts, and the README anchor `#model-selection-and-wrapper-authoring`, which stage 4 removes (decision 3).
- **R6: Rule renumbering churn.** Removing rules 5, 6, 8, and 10–13 shifts every later rule number cited in the README, `.gitattributes`, `scripts/lint.sh`, `scripts/test.sh`, and `scripts/test/*.sh`. A missed citation is silent (no lint check). Stage 5 lists every citation and requires a manual check against the mapping. Skills and `USER-AGENTS.md` cite no rule numbers (verified by grep).
- **R7: Pre-existing shellcheck failure.** `SC1071` on `scripts/shell/install-zsh.sh` makes the CI `lint` job's shellcheck step fail on master today, independent of this plan. Out of scope; fix it separately (open question 7).
- **R8: The acceptance grep uses GNU `\b`.** It is written for GNU grep (Linux/WSL, the development environment). BSD grep on macOS may need `[[:<:]]agents?[[:>:]]`.
- **R9: Temporarily stale README.** Between stages 2 and 5, the README rule list still names agents, wrappers, and `MODELS.csv`, and after stage 4 it cites deleted files. This is accepted within one PR; stage 5 closes it.

## Open questions

1. **Lint baseline.** Master lint is already red because of six `USER-AGENTS.md` vocabulary and reference warnings. Stage 1 fixes this in `scripts/lint.sh` and the README vocabulary table only: it registers `skill_question`, `skill_options`, and `default`, and splits compound backticked references. Accept? Recommended: yes. The alternative, accepting exactly those six warnings as the baseline, would make "lint passes" unverifiable in every stage.
2. **Transitional Grok residue (R1) and one-time exit 2 (R2).** Accept both as documented risks and mention manual cleanup in the PR description or release note? Recommended: yes. Alternatives: add a README Troubleshooting line, which needs a grep allowlist entry, or relax decision 4 for a one-shot cleanup.
3. **Merge timing (R4).** Once merged to `master`, updating users lose the agents that the untouched skills still dispatch to. Merge this phase alone, or keep it on its branch until the skills phase is ready and merge both together? Recommended: hold the PR, or merge only alongside the skills phase.
4. **Rule renumbering (R6).** Renumber the README rules after deleting 5, 6, 8, and 10–13, and update every rule-number citation in the README, `.gitattributes`, and `scripts/`? Recommended: yes. Markdown ordered lists cannot keep gaps, so the only other option is placeholder "retired" rules, which would keep agent text in the README.
5. **`/models-ai-tools` in docs/USAGE.md (R5).** Drop its table row and its Maintenance paragraph now, while the skill stays installed and broken? Recommended: yes. Keeping them requires an allowlist entry for `MODELS.csv` and wrapper text outside `skills/`.
6. **ROADMAP.md.** Delete story 13 (cost visibility in the dispatch ledger, tied to the model behind each agent attempt), and rewrite stories 4, 9, 11, and 12 without agent, wrapper, or `MODELS.csv` terms? Recommended: yes.
7. **Pre-existing shellcheck `SC1071` (R7).** Leave it for a separate change? Recommended: yes. Alternative: add a stage that excludes `install-zsh.sh` from the CI shellcheck glob.

## User answers (all recommendations accepted)

1. Stage 1 fixes the six existing lint warnings by editing only `scripts/lint.sh` and the README vocabulary table. `USER-AGENTS.md` stays untouched.
2. The empty Grok `[subagents.models]` block (R1), the one-time update exit 2 (R2), and leftover locally edited agent copies (R3) are accepted as documented risks. The PR description explains the manual cleanup. No new code.
3. Hold the merge until the skills phase: push and open the PR, but do not merge it. The PR description states clearly that it must not be merged before the skills phase is ready.
4. Renumber the README rules and update every citation (README, `.gitattributes`, `scripts/`).
5. Remove `/models-ai-tools` from `docs/USAGE.md` now.
6. Delete ROADMAP story 13 and rewrite stories 4, 9, 11, and 12 without agent terms.
7. Leave shellcheck `SC1071` on `scripts/shell/install-zsh.sh` for a separate change; it is a known failure on master, not a regression.
