# Plan: team-flow-hardening

Harden the `team-ai-tools` flow and fix the write-ownership conflicts it shares with `campaign-ai-tools`. Source review: `/tmp/ai-tools/team-ai-tools-review.md` (items H1-H5, M3, M4).

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Start plan | done | harness default subagent |
| 2 | Stage format in planning protocol | done | harness default subagent |
| 3 | Campaign write ownership | done | harness default subagent |
| 4 | Team delivery placeholders and retries | done | harness default subagent |
| 5 | Team baseline and plan sign-off | done | harness default subagent |
| 6 | Team final audit and CI report | done | harness default subagent |
| 7 | Documentation | done | harness default subagent |
| 8 | Close plan | pending | harness default subagent |

## Decisions

- D1 Branch: deliver on the current branch `plan/team-devops-reviewer`, extending open PR #33. Stage 1 creates no branch. The version stays `0.0.67-ALPHA` (already bumped against `master`).
- D2 Final audit: one `final-auditor` (`executor="inherited"`) replaces `docs-auditor`. It audits the integrated diff against `decisions.md` (acceptance, security regressions, docs) and runs the full test, lint, and build commands. One implementer fix stage applies its corrections. Anything left unresolved goes to the pull request body as follow-ups, with blockers highlighted, and does not block delivery.
- D3 CI: after the PR opens, the session runs `gh pr checks --watch` with a timeout of about 15 minutes. It reports the CI status in its final line and writes failure evidence to `{WORKDIR}/ci.md`. No automatic fix.
- D4 Stage format lives in USER-AGENTS `<planning_protocol>` as a new rule, so it applies to vibe, campaign, and team.
- D5 Write ownership in campaigns: implementers make every repository write. The session and the planners stay read-only on the repository (temp files are allowed). A bootstrap implementer creates the branch and the campaign record. Goal stage 1 writes the goal plan on the existing branch. The goal's last stage removes the goal plan and marks the goal done in the record, without pushing. A finish implementer removes the record, pushes, and opens the PR. On block, the same implementer records the block reason in the record and commits, without pushing. The goal planner returns its plan as content, or as a temp path when it can write there. Applies to `campaign-ai-tools` and `team-ai-tools`.
- D6 (PO decisions, from review M3/M4/H1/H5):
  - `{FOLLOWUPS}` is a separate placeholder, distinct from `{NOTES}`.
  - Test verdicts are written per stage.
  - Every retry passes every check that applies to the stage.
  - The retry brief says the previous attempt is staged and must be fixed in place.
  - The session defines every path and placeholder it substitutes.
  - Active reviewers sign off `plan.md` in one round, reporting blockers only, before approval is asked.
  - A `default-worker` records the baseline (test, lint, and build results) in step 1.

## Global constraints

- Edit only: `USER-AGENTS.md`, `README.md`, `docs/USAGE.md`, `skills/campaign-ai-tools/SKILL.md`, `skills/team-ai-tools/SKILL.md`, and `plans/team-flow-hardening.md`.
- Follow the README "Structure and authoring" rules and the "Semantic XML grammar":
  - backticked tag references must resolve;
  - every `{PLACEHOLDER}` a template uses is declared in its `<input>`, and every declared one is used;
  - every `<rule>` has a unique `id`;
  - extreme concision;
  - no README rule numbers in skills or USER-AGENTS;
  - only vocabulary tags;
  - a new `<signal>` is defined in `<return_protocol>`.
- `USER-AGENTS.md` stays at most 8,000 characters.
- Verification for every stage: `scripts/lint.sh` (0 warnings) and `scripts/lint.sh --base master` (0 warnings).

## Stage 1 - Start plan

- Scope: `plans/team-flow-hardening.md`.
- Out of scope: everything else. No branch creation.
- Acceptance: the plan file holds this whole plan with the status table; stage 1 is marked done; a report is appended.
- Tests: `scripts/lint.sh`.
- Commit: `chore(plans): start team-flow-hardening plan`.

## Stage 2 - Stage format in planning protocol

- Scope: `USER-AGENTS.md`, `README.md` (rule 23 sentence only).
- Out of scope: the skills.
- Change:
  - Add to `<planning_protocol>`, after `<rule id="short-stages">`: `<rule id="stage-format">Each stage lists files in scope, out-of-scope items, testable acceptance criteria, required tests, verification commands, and its Conventional Commit message.</rule>`. Wording may be tightened if the meaning stays the same.
  - In README rule 23, add the stage format to the list of what the planning protocol asks for.
- Acceptance:
  - The rule exists with a unique id.
  - `wc -c USER-AGENTS.md` is at most 8000.
  - README rule 23 mentions the stage fields.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`, `scripts/test.sh`.
- Commit: `feat(protocols): define stage format in planning protocol`.

## Stage 3 - Campaign write ownership

- Scope: `skills/campaign-ai-tools/SKILL.md`.
- Out of scope: the description, unless lint requires a change; the team skill.
- Change (D5):
  - Step 1: after `{IMPLEMENTER}` is resolved, the session spawns `<template role="stage-implementer">` with `{STAGE}` = bootstrap and `{PLAN}` = the campaign record content. The record holds the global objective, goals with status, priorities, exclusions, `{IMPLEMENTER}`, and an iteration log. The bootstrap implementer creates branch `campaign/{CAMPAIGN}` from the current branch, writes `plans/campaign/{CAMPAIGN}.md`, and commits `chore(plans): start campaign {CAMPAIGN}`. The session writes nothing to the repository.
  - Step 2: the goal planner plans per `<planning_protocol>` with these campaign adaptations:
    - stage 1 writes `plans/campaign/{N}-{SLUG}.md` on `campaign/{CAMPAIGN}` without creating a branch;
    - the last stage runs `git rm` on the goal plan, sets goal `{N}` done in the campaign record, and commits `chore(plans): complete goal {SLUG}`, without pushing or opening a PR.

    The planner returns the plan as content, or as a path under `${TMPDIR:-/tmp}/ai-tools/` when it can write there. Remove the session's own goal-closure commits.
  - Step 3: spawn the implementer with `{STAGE}` = finish. It removes the record, commits `chore(plans): complete campaign {CAMPAIGN}`, pushes, and opens the PR. On block, spawn it with `{STAGE}` = block. It records the reason and the evidence path in the record and commits `chore(plans): block campaign {CAMPAIGN}`, without pushing. The session writes the evidence to `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md` and reports in chat as today.
  - Template `stage-implementer`: handle bootstrap, numeric stages, finish, and block. Constraint: push only in finish.
  - `<rule id="campaign-lifecycle">`: restate to match. This resolves the current contradiction between step 2 (session removes the goal plan) and the rule (last stage removes it).
- Acceptance:
  - Every repository write (branch, record, goal plans, closure, push, PR, block commit) is assigned to an implementer.
  - The session and the goal planner are read-only on the repository.
  - No step tells the goal plan to create a `plan/` branch or to push.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`.
- Commit: `fix(campaign-ai-tools): delegate repository writes to implementers`.

## Stage 4 - Team delivery placeholders and retries

- Scope: `skills/team-ai-tools/SKILL.md`, step 5 and the templates `goal-planner`, `stage-implementer`, and `test-validator`.
- Out of scope: steps 1-4, reviewer templates, docs-auditor (stage 6 replaces it).
- Change:
  - Campaign mode follows the new campaign-ai-tools flow (D5): bootstrap, then goals, then finish or block, all run by team's `stage-implementer`. The team's `stage-implementer` supports bootstrap, finish, and block in campaign mode, matching campaign-ai-tools. Replace "run campaign-ai-tools step 1 from branch creation onward" accordingly.
  - Define in step 5 every value the session substitutes:
    - `{DECISIONS}` = `{WORKDIR}/decisions.md`;
    - `{BASE_BRANCH}` = the branch current before delivery, recorded at the start of step 5;
    - goal-planner receives `{CAMPAIGN}`, `{N}`, `{REPORT}`, `{DECISIONS}`, and `{FINDINGS_DIR}` = `{WORKDIR}`, and returns its plan as content or at `{WORKDIR}/goal-{N}.md`;
    - `{GOAL_SLUG}` is a real placeholder everywhere `{N}-slug` appears today.
  - goal-planner applies the campaign adaptations of stage 3 (no branch in stage 1; the last stage removes the goal plan and marks the goal done, without pushing). It reads the findings files in `{FINDINGS_DIR}`.
  - Verdicts per stage: `{VERDICTS}` = `{WORKDIR}/verdicts/{N}-{STAGE}.md`, with N = 0 in plan mode. On `TESTS_FIX`, `{NOTES}` = that stage's file only.
  - Add a `{FOLLOWUPS}` input to `stage-implementer`. The last plan stage, or the campaign finish, adds `{FOLLOWUPS}` to the PR body. `{NOTES}` carries only corrections from a failed check. Remove the overloaded `{NOTES}` follow-up wording.
  - Retries: every retry, whether after a failed test-validator or a failed planner check, passes the test-validator (when the stage changes code or tests) and then the planner check. A second failure blocks. The retry brief (`{NOTES}` handling in `stage-implementer`) says the previous attempt is staged after `git reset --soft HEAD~1` and must be fixed in place.
- Acceptance:
  - Every placeholder used in step 5 or in a template is defined, and lint placeholder parity passes.
  - No `{NOTES}` dual meaning remains.
  - Campaign mode contains no session repository write.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`.
- Commit: `fix(team-ai-tools): define delivery placeholders and harden retries`.

## Stage 5 - Team baseline and plan sign-off

- Scope: `skills/team-ai-tools/SKILL.md`, steps 1 and 4, a new template, and test-validator.
- Out of scope: step 5 audit (stage 6), reviewer focus text.
- Change:
  - Step 1: spawn a new `<template role="baseline-runner" executor="default-worker">` with `{BASELINE}` = `{WORKDIR}/baseline.md`. It discovers and runs the repository's existing test, lint, and build commands, read-only on the repository, and writes the commands, exit codes, and known failures. The PO summarises the baseline in `po-report.md`.
  - Step 4: `plan.md` follows `<rule id="stage-format">` and includes a baseline section. Before asking for approval, send `plan.md` to the active reviewers for one sign-off round that reports blockers only. The PO folds blockers into the plan. A blocker that stays unresolved goes into the approval question with the PO recommendation.
  - test-validator reads `{BASELINE}` and does not attribute baseline failures to the stage.
- Acceptance:
  - The baseline template has `role` and `executor` and declares and uses all its placeholders.
  - Step 4 contains the sign-off round before approval.
  - test-validator declares and uses `{BASELINE}`.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`.
- Commit: `feat(team-ai-tools): add baseline check and plan sign-off`.

## Stage 6 - Team final audit and CI report

- Scope: `skills/team-ai-tools/SKILL.md`, step 5, the docs-auditor template, and `<return_protocol>`.
- Out of scope: steps 1-4.
- Change (D2, D3):
  - Replace `docs-auditor` with `<template role="final-auditor" executor="inherited">`. Inputs: `{BASE_BRANCH}`, `{DECISIONS}`, `{BASELINE}`, `{AUDIT}`. It reads the repository rules, the plan files, `{DECISIONS}`, `{BASELINE}`, the diff from `{BASE_BRANCH}` to HEAD, and the documentation tree. It runs the full test, lint, and build commands. It validates:
    - acceptance criteria across stages;
    - security regressions;
    - the existing documentation criteria (organization, separation, structure, duplication, accuracy, terminology).

    It writes `{AUDIT}`: for each correction, the path, the exact change, the severity (blocker/high/medium/low), and the rationale. It never modifies the repository.
  - Signals: `AUDIT_OK` and `AUDIT_FIX` replace `DOCS_OK` and `DOCS_FIX`.
  - On `AUDIT_FIX`: one `stage-implementer` with `{STAGE}` = final-audit and `{NOTES}` = `{AUDIT}` applies the corrections and commits `fix: apply final audit` (or a more fitting Conventional Commit type). The session validates the diff against `{AUDIT}` once. Unresolved items go to `{WORKDIR}/followups.md`, blockers first and highlighted. That file is passed as `{FOLLOWUPS}` to the last plan stage or to the campaign finish. Delivery never blocks on it.
  - Timing: before the last plan stage; in campaign mode, once before finish.
  - CI: after the PR opens, the session runs `gh pr checks --watch` with a timeout of about 15 minutes. It reports the CI status in the closing chat line and writes failure output to `{WORKDIR}/ci.md`. No automatic fix.
  - Rename every docs-audit mention in step 5 and in `stage-implementer` to final-audit.
- Acceptance:
  - No `docs-auditor`, `DOCS_OK`, `DOCS_FIX`, or docs-audit stage remains in the team skill.
  - The new signals are defined in `<return_protocol>`.
  - Step 5 contains the CI report.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`.
- Commit: `feat(team-ai-tools): replace docs audit with final audit and CI report`.

## Stage 7 - Documentation

- Scope: `README.md` ("How it operates" item 4 and any team or campaign description), `docs/USAGE.md` (team paragraph and campaign paragraph).
- Out of scope: README rule 23 (stage 2), the skills.
- Change:
  - Describe the baseline check, the plan sign-off, the stage format, the final audit (replacing the documentation audit), the per-stage test validator with retries passing all checks, and the CI report.
  - For campaigns, describe that implementers own every repository write (bootstrap, goal closure, finish).
  - Keep it concise and in English.
- Acceptance:
  - No mention of "documentation audit" or "documentation auditor" remains for team.
  - USAGE and README agree with the skills.
  - Lint is clean.
- Tests: `scripts/lint.sh`, `scripts/lint.sh --base master`.
- Commit: `docs: document team flow hardening and campaign write ownership`.

## Stage 8 - Close plan

- Scope: `plans/team-flow-hardening.md` and the remote branch.
- Change:
  - `git rm plans/team-flow-hardening.md`, then commit.
  - `git push` to `origin plan/team-devops-reviewer`.
  - PR #33 already exists, so no new PR. Append a "Flow hardening" section to its body with `gh pr edit 33`, summarising stages 2-7.
- Acceptance: the plan file is removed in its own commit, the branch is pushed, and the PR #33 body is updated.
- Tests: `scripts/lint.sh --base master`.
- Commit: `chore(plans): complete team-flow-hardening plan`.

## Deferred (not in this plan)

Review items M1, M2, M5-M9, and L1-L6.

## Stage 1 report

- Wrote the whole plan to `plans/team-flow-hardening.md` on the existing branch `plan/team-devops-reviewer`; no branch created.
- Status table: Implementer set to `harness default subagent`; stage 1 marked done.
- Tests: `scripts/lint.sh` exit 0 — 469 ok, 1 skipped (version bump needs --base), 0 warnings.

## Stage 2 report

- Added `<rule id="stage-format">` to `<planning_protocol>` in `USER-AGENTS.md` after `short-stages` (file now 6464 characters).
- README rule 23 now lists the stage format fields.
- Tests: `scripts/lint.sh` 469 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 470 ok, 0 warnings; `scripts/test.sh` 352 ok, 0 warnings.

## Stage 3 report

- `skills/campaign-ai-tools/SKILL.md`: steps 1-3 now spawn `stage-implementer` for bootstrap, goal stages, finish, and block; the session and goal planner are read-only on the repository (temp files only). Session goal-closure commits removed; the goal's last stage removes its plan, marks the goal done, and commits without pushing.
- `stage-implementer` handles bootstrap, numeric stages, finish, and block; push and PR only in finish. `campaign-lifecycle` restated with write ownership.
- Choices: the campaign record holds the base branch so the clean-context finish implementer knows the PR target; the goal's last stage also logs the iteration in the record; block reads the reason from `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md` (no new placeholder) and is skipped when the implementer cannot be spawned; `<implementer_job>` mentions bootstrap, finish, and block. Description unchanged.
- Tests: `scripts/lint.sh` 471 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 472 ok, 0 warnings.
- Retry fix: `campaign-lifecycle` now names the failed-check `git reset --soft HEAD~1` as the session's only repository write, matching step 2.

## Stage 4 report

- `skills/team-ai-tools/SKILL.md` step 5: records `{BASE_BRANCH}` and `{DECISIONS}`; states write ownership (implementers write; the session only runs `git reset --soft HEAD~1`; planners read-only; temp files under `${TMPDIR:-/tmp}/ai-tools/`). Campaign mode runs bootstrap, goals, finish, and block through team's `stage-implementer`, citing campaign-ai-tools `campaign-lifecycle`. Verdicts per stage at `{WORKDIR}/verdicts/{N}-{STAGE}.md` (N = 0 in plan mode). Every retry passes the test-validator (when applicable) then the planner check; a second failure blocks. Docs-audit follow-ups go to `{FOLLOWUPS}` (plan last stage or campaign finish); the session no longer edits the PR body.
- `goal-planner`: inputs `{GOAL_SLUG}` and `{FINDINGS_DIR}`; applies the campaign adaptations; returns its plan as content or at `{FINDINGS_DIR}/goal-{N}.md`.
- `stage-implementer`: inputs `{CAMPAIGN}` and `{FOLLOWUPS}`; handles bootstrap, numbered stages, docs-audit, finish, and block; `{NOTES}` is only failed-check corrections, with an in-place retry brief. `test-validator`: per-stage verdicts file.
- Choices: the session derives each `{GOAL_SLUG}` and lists it in the campaign record, so the planner receives it as a declared input; `{CAMPAIGN}` added to `stage-implementer` for the branch, commit messages, and block evidence path; planner-check corrections are written by the session to `{WORKDIR}/corrections/{N}-{STAGE}.md` and passed as `{NOTES}`; block evidence path `${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md` matches vibe and campaign since `{CAMPAIGN}` = `{SLUG}`; `<implementer_job>` left unchanged (out of scope).
- Tests: `scripts/lint.sh` 468 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 469 ok, 0 warnings.

## Stage 5 report

- `skills/team-ai-tools/SKILL.md` step 1 spawns the new `baseline-runner` (`executor="default-worker"`) with `{BASELINE}` = `{WORKDIR}/baseline.md`; `po-report.md` carries a baseline summary. Step 4: stages per `stage-format`, a baseline section, and one blockers-only reviewer sign-off round before approval, with unresolved blockers in the approval question plus the PO recommendation. `test-validator` declares and reads `{BASELINE}` and attributes recorded failures to the baseline; step 5 passes `{BASELINE}` = `{WORKDIR}/baseline.md`.
- Choices: `baseline-runner` discovers commands from repository rules, scripts, and CI files, records a missing command as absent, and leaves tracked files, index, and history untouched (writing only `{BASELINE}`); spawning is covered by the existing `spawn-apis` rule, so no new boundary rule.
- Tests: `scripts/lint.sh` 470 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 471 ok, 0 warnings.

## Stage 6 report

- `skills/team-ai-tools/SKILL.md`: `final-auditor` (`executor="inherited"`, inputs `{BASE_BRANCH}`, `{DECISIONS}`, `{BASELINE}`, `{AUDIT}`) replaces `docs-auditor`; it runs the full test, lint, and build commands, validates acceptance, security regressions, and the documentation criteria, and writes corrections with blocker/high/medium/low severity. `AUDIT_OK`/`AUDIT_FIX` replace `DOCS_OK`/`DOCS_FIX`. Step 5 runs the final audit before the last plan stage or once before campaign finish, with `{AUDIT}` = `{WORKDIR}/final-audit.md`; unresolved items go to `{WORKDIR}/followups.md`, blockers first. The CI report runs after the last plan stage or the campaign finish returns: `gh pr checks --watch` (~15 min), failures to `{WORKDIR}/ci.md`, status in the closing chat line, no automatic fix. `stage-implementer` has a final-audit branch committing `fix: apply final audit` or a more fitting type.
- Choices: final-audit stays in the test-validator skip list, as docs-audit was; the final-audit implementer also runs tests; the auditor writes only `{AUDIT}` and attributes baseline failures to the baseline; CI status values named passed, failed, or pending at timeout.
- Tests: `scripts/lint.sh` 470 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 471 ok, 0 warnings; no `docs-audit`, `docs-auditor`, or `DOCS_` match remains.

## Stage 7 report

- `README.md` "How it operates" item 4: team records a baseline, gets reviewer sign-off before user approval, and delivers with a per-stage test validator, a final audit, and a CI report; in campaigns implementers make every repository write. No other README team or campaign sentence was stale (rule 23 left to stage 2).
- `docs/USAGE.md` team paragraph: baseline by a default worker, stage format, blockers-only sign-off, retries passing every applicable check with a second failure blocking, final audit (acceptance, security regressions, docs; full test/lint/build; one fix stage; follow-ups with blockers highlighted, non-blocking), and CI watch of about 15 minutes. Campaign paragraph: bootstrap, goal closure, finish, and block owned by implementers; the session only resets on a failed check; goal planners read-only.
- Tests: `scripts/lint.sh` 470 ok, 1 skipped, 0 warnings; `scripts/lint.sh --base master` 471 ok, 0 warnings; no `documentation audit` match in README or USAGE.
