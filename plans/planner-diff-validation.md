# Plan: Planner Diff Validation Protocol

Status table:

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Setup branch and write plan | done | Antigravity default |
| 2 | Update USER-AGENTS.md | done | Antigravity default |
| 3 | Update vibe-ai-tools skill | done | Antigravity default |
| 4 | Update campaign-ai-tools skill | done | Antigravity default |
| 5 | Update documentation in README.md | pending | Antigravity default |
| 6 | Final validation, remove plan, and open PR | pending | Antigravity default |

## Context and Goals
Refine `USER-AGENTS.md`, `skills/vibe-ai-tools/SKILL.md`, `skills/campaign-ai-tools/SKILL.md`, and `README.md`:
1. Implementer's role is strictly execution: write code/tests in stage scope, run tests reporting only a concise summary of coverage and execution, append stage report to `plans/{SLUG}.md`, and commit locally. Prohibit implementer from validating delivery against the base plan or deciding macro acceptance.
2. The original planner ({PLANNER}) is the sole authority to validate the stage: directly reviews the `git diff` of the commit and the concise test summary against the base plan and acceptance criteria.
3. In `campaign-ai-tools`, the session avoids context bloat by not loading the diff into its own context; instead, the goal planner subagent directly inspects the git diff and test output in the repository against `plans/{SLUG}.md` and returns only the approval verdict or corrections.
4. On check failure / rejection, the session runs `git reset --soft HEAD~1` before respawning the implementer with corrective instructions, preserving `<rule id="stage-commit">Each delivered stage ends with one Conventional Commit.`
5. Update `README.md` rule 24.
6. Run `./scripts/lint.sh` and ensure all checks pass and character limits are respected.

## Stages

### Stage 1: Setup branch and write plan
- Create and switch to branch `plan/planner-diff-validation` from `master`.
- Write this plan to `plans/planner-diff-validation.md` with status table.
- Commit `chore(plans): initialize planner-diff-validation plan`.

### Stage 2: Update USER-AGENTS.md
- Refine `<rule id="stage-close">` in `USER-AGENTS.md`:
  - Clearly state implementer runs tests (reporting concise summary of coverage/execution), appends report, and commits locally without validating delivery against the plan.
  - Establish that the original planner ({PLANNER}) inspects the `git diff` and test summary against the plan to determine acceptance.
  - On check failure, session runs `git reset --soft HEAD~1` before respawning the implementer with corrections.
- Update character count and ensure <= 8000 characters.
- Run `./scripts/lint.sh` to verify syntax and citations.
- Update status to done for Stage 2 in `plans/planner-diff-validation.md`, append stage report, and commit `feat(instructions): establish planner diff validation and implementer boundary`.

### Stage 3: Update vibe-ai-tools skill
- In `skills/vibe-ai-tools/SKILL.md`:
  - Update `<session_workflow>` step 2: session (planner) reviews git diff and test results; on check failure, session runs `git reset --soft HEAD~1` before respawn.
  - Update `<implementer_job>`: clarify implementer executes code and tests without evaluating delivery against the macro plan.
  - Update `<template role="stage-implementer">`: in `<constraints>`, add constraint prohibiting evaluation/validation against the plan; in `<instructions>`, specify running tests and reporting concise coverage/execution summary.
- Run `./scripts/lint.sh`.
- Update status to done for Stage 3 in `plans/planner-diff-validation.md`, append stage report, and commit `feat(vibe): session diff validation with implementer boundaries and soft reset`.

### Stage 4: Update campaign-ai-tools skill
- In `skills/campaign-ai-tools/SKILL.md`:
  - Update `<session_workflow>` step 2: session orchestrates without loading diffs into session context (avoiding context bloat); goal planner subagent directly inspects the git diff and test summary in the repo against `plans/{SLUG}.md`; on failure, session runs `git reset --soft HEAD~1` before respawn.
  - Update `<implementer_job>`: match non-validation constraint.
  - Update `<template role="stage-implementer">`: match non-validation constraint and concise test summary instruction.
- Run `./scripts/lint.sh`.
- Update status to done for Stage 4 in `plans/planner-diff-validation.md`, append stage report, and commit `feat(campaign): delegate goal diff validation to goal planner without session bloat`.

### Stage 5: Update documentation in README.md
- Update rule 24 in `README.md` to reflect the refined stage lifecycle, implementer test summary and non-validation constraint, planner diff validation, and soft reset on retry.
- Run `./scripts/lint.sh`.
- Update status to done for Stage 5 in `plans/planner-diff-validation.md`, append stage report, and commit `docs: document planner diff validation and implementer boundary`.

### Stage 6: Final validation, remove plan, and open PR
- Run full `./scripts/lint.sh` suite.
- Remove `plans/planner-diff-validation.md`.
- Commit `chore(plans): complete planner-diff-validation plan`.
- Push branch `plan/planner-diff-validation` to remote.
- Open pull request against `master`.

## Stage Reports

### Stage 1: Setup branch and write plan
- Created and checked out branch `plan/planner-diff-validation` from `master`.
- Wrote initial plan to `plans/planner-diff-validation.md` with status table.
- Marked Stage 1 as done.

### Stage 2: Update USER-AGENTS.md
- Refined `<rule id="stage-close">` in `USER-AGENTS.md`:
  - Established implementer execution boundaries: executes within stage scope, runs tests reporting only a concise summary of coverage and execution, appends stage report to `plans/{SLUG}.md`, sets status to done, and commits locally without validating delivery against macro plan.
  - Specified that the planner that created the plan ({PLANNER}) validates delivery by reviewing git diff and test summary against plan and acceptance criteria.
  - Clarified soft reset (`git reset --soft HEAD~1`) on check failure before respawning implementer once with corrections.
- Verified character count (6158 <= 8000 chars) and passed all `./scripts/lint.sh` checks (398 ok).
- Marked Stage 2 as done.

### Stage 3: Update vibe-ai-tools skill
- In `skills/vibe-ai-tools/SKILL.md`:
  - Updated `<session_workflow>` step 2: session validates implementer delivery by reviewing git diff and concise test summary against the plan and stage acceptance criteria; on failed check, runs `git reset --soft HEAD~1` before respawning once with corrections.
  - Updated `<implementer_job>`: clarified implementer executes within scope, runs tests reporting only a concise summary of coverage and execution, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan.
  - Updated `<dispatch_templates>` `<template role="stage-implementer">`: specified running tests reporting only a concise summary of coverage and execution in `<instructions>`, returning one-line outcome with commit hash, test summary, and changed paths; added `<constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>` in `<constraints>`.
- Verified all checks passed via `./scripts/lint.sh` (398 ok).
- Marked Stage 3 as done.

### Stage 4: Update campaign-ai-tools skill
- In `skills/campaign-ai-tools/SKILL.md`:
  - Updated `<session_workflow>` step 2: session orchestrates stage delivery without loading the diff into session context (avoiding context bloat); goal planner subagent directly inspects git diff and concise test summary in the repository against `plans/{SLUG}.md`, returning only the approval verdict or corrections; on failed check, runs `git reset --soft HEAD~1` before respawning implementer once with corrections in the brief.
  - Updated `<implementer_job>`: clarified implementer executes within scope, runs tests reporting only a concise summary of coverage and execution, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan.
  - Updated `<dispatch_templates>` `<template role="stage-implementer">`: specified writing and running tests reporting only a concise summary of coverage and execution in `<instructions>`, returning one-line outcome with commit hash, test summary, and changed paths; added `<constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>` in `<constraints>`.
- Verified all checks passed via `./scripts/lint.sh` (398 ok).
- Marked Stage 4 as done.
