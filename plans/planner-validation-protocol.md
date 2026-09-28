# Plan: Planner Offer and Diff Validation Protocol

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Setup branch and write plan | done | Antigravity default |
| 2 | Update USER-AGENTS.md with planner/implementer offer and diff validation | done | Antigravity default |
| 3 | Update vibe-ai-tools skill | done | Antigravity default |
| 4 | Update campaign-ai-tools skill | done | Antigravity default |
| 5 | Update documentation in README.md | done | Antigravity default |
| 6 | Complete plan, push branch, and open PR | pending | Antigravity default |

## Overview
Implement protocol updates across user-wide instructions (`USER-AGENTS.md`), planning skills (`vibe-ai-tools`, `campaign-ai-tools`), and documentation (`README.md`):
1. **Planner Offer ({PLANNER})**: Skills that plan offer:
   - Senior tier of the current harness CLI skill (`agy-ai-tools`, `claude-ai-tools`, `copilot-ai-tools`) dispatched via skill (Recommended).
   - The host session.
2. **Implementer Offer ({IMPLEMENTER})**: Skills offer:
   - Mid tier of current harness CLI skill dispatched via skill (Recommended).
   - Harness default.
3. **Relay Interaction**:
   - If a senior planner needs user interaction, the session acts as relay per `<user_interaction>` ("A subagent asks directly when it holds that tool; else relays via session").
4. **Validation Principle**:
   - The entity that planned ({PLANNER}) validates each stage delivery by reviewing the `git diff` against the plan before advancing to the next stage.
5. **Campaign Orchestration**:
   - In `campaign-ai-tools`, the session orchestrates campaign goals, delegating each goal to {PLANNER}, dispatching {IMPLEMENTER} for each stage, and having {PLANNER} validate deliveries via git diff.

## Stage 1: Setup branch and write plan
- Create branch `plan/planner-validation-protocol` from `master`.
- Write the plan file to `plans/planner-validation-protocol.md`.
- Mark Stage 1 as `done`.
- Commit: `chore(plans): initialize planner-validation-protocol plan`.

## Stage 2: Update USER-AGENTS.md
- Add `<rule id="planner-offer">` in `<planning_protocol>` offering the senior tier of current harness skill (recommended) or the session.
- Update `<rule id="implementer-offer">` in `<implementation_protocol>` to recommend mid tier of harness skill over harness default.
- Update `<rule id="stage-close">` in `<implementation_protocol>` to formalize that {PLANNER} validates stage delivery by reviewing git diff against the plan.
- Ensure `USER-AGENTS.md` remains strictly within its 8,000-character cap.
- Run `scripts/lint.sh`.
- Mark Stage 2 as `done` and append stage report.
- Commit: `feat(instructions): add planner offer and diff-based validation to stage lifecycle`.

## Stage 3: Update vibe-ai-tools skill
- In `skills/vibe-ai-tools/SKILL.md`:
  - Update Step 1 to offer `{PLANNER}` and `{IMPLEMENTER}` at start, note relay mechanism for questions.
  - Update Step 2 (`deliver`) so that `{PLANNER}` validates deliveries by reviewing git diff against the plan.
- Run `scripts/lint.sh`.
- Mark Stage 3 as `done` and append stage report.
- Commit: `feat(vibe): integrate planner offer relay and diff validation`.

## Stage 4: Update campaign-ai-tools skill
- In `skills/campaign-ai-tools/SKILL.md`:
  - Update Step 1 to resolve `{PLANNER}` and `{IMPLEMENTER}` for campaign goals.
  - Update Step 2 (`iterate`) to orchestrate goal delegation to `{PLANNER}`, stage implementation by `{IMPLEMENTER}`, and diff validation by `{PLANNER}`.
- Run `scripts/lint.sh`.
- Mark Stage 4 as `done` and append stage report.
- Commit: `feat(campaign): orchestrate goal planning and diff validation via planner`.

## Stage 5: Update documentation in README.md
- In `README.md`:
  - Update protocol descriptions (rules 23 and 24) to reflect `{PLANNER}` and `{IMPLEMENTER}` offers and git diff validation.
  - Update skill summaries and ensure vocabulary and cross-references stay aligned.
- Run `scripts/lint.sh`.
- Mark Stage 5 as `done` and append stage report.
- Commit: `docs: document planner offer and diff validation protocol`.

## Stage 6: Complete plan, push branch, and open PR
- Run full verification (`./scripts/lint.sh`).
- Remove `plans/planner-validation-protocol.md`.
- Commit removal: `chore(plans): complete planner-validation-protocol plan`.
- Push branch `plan/planner-validation-protocol` to origin.
- Open PR using `gh pr create`.

## Reports

### Stage 1: Setup branch and write plan
- Created and checked out branch `plan/planner-validation-protocol`.
- Initialized plan file at `plans/planner-validation-protocol.md`.
- Updated status table with Stage 1 marked as `done`.

### Stage 2: Update USER-AGENTS.md with planner/implementer offer and diff validation
- Added `<rule id="planner-offer">` to `<planning_protocol>` with recommended senior tier harness skill or host session, noting question relay via session.
- Updated `<rule id="implementer-offer">` in `<implementation_protocol>` to recommend mid tier harness skill over harness default.
- Updated `<rule id="stage-close">` in `<implementation_protocol>` specifying that {PLANNER} validates stage delivery by reviewing the git diff against the plan.
- Verified character count (5,991 characters, well below the 8,000-character cap) and verified lint passes cleanly.

### Stage 3: Update vibe-ai-tools skill
- Updated `<step id="1" name="plan">` in `skills/vibe-ai-tools/SKILL.md` to resolve {PLANNER} per `<rule id="planner-offer">` and relay subagent planner questions via session per `<user_interaction>`.
- Updated `<step id="2" name="deliver">` in `skills/vibe-ai-tools/SKILL.md` to specify that {PLANNER} validates the implementer's delivery by reviewing the git diff against the plan and stage acceptance criteria.
- Verified frontmatter description remains under 500 characters and valid per rule 6.
- Ran `scripts/lint.sh` and verified all checks pass (401 ok, 0 warnings).

### Stage 4: Update campaign-ai-tools skill
- Updated `<step id="1" name="initialize">` in `skills/campaign-ai-tools/SKILL.md` to resolve {PLANNER} alongside {IMPLEMENTER} and record both in `plans/improve/{CAMPAIGN}.md`.
- Updated `<step id="2" name="iterate">` in `skills/campaign-ai-tools/SKILL.md` to delegate goal planning to {PLANNER} per `<planning_protocol>`, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, and validate stage deliveries via git diff review by {PLANNER}.
- Maintained frontmatter description within 500 characters and valid per rule 6.
- Ran `scripts/lint.sh` and verified all checks pass (403 ok, 0 warnings).

### Stage 5: Update documentation in README.md
- Bumped version to `0.0.63-ALPHA` on line 3 of `README.md`.
- Updated line 16 (bullet 4) to describe the planner offer (senior recommended or session) and implementer offer (mid recommended or harness default).
- Updated line 118 (rule 23) to state that skills offering planner selection ask once who plans: the senior tier of the current harness skill (recommended) or the session, relaying user questions via session.
- Updated line 119 (rule 24) to reflect that mid tier is recommended for implementer, and that the planner that created the plan validates each stage delivery by reviewing the git diff against the plan before starting the next stage.
- Verified `./scripts/lint.sh --base master` passes cleanly with 0 warnings.
