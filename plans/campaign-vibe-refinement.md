# Plan: Campaign and Vibe Workflow Refinement

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Setup branch and write plan | done | Antigravity default |
| 2 | Update USER-AGENTS.md | done | Antigravity default |
| 3 | Update vibe-ai-tools skill | done | Antigravity default |
| 4 | Update campaign-ai-tools skill | done | Antigravity default |
| 5 | Update documentation in README.md | done | Antigravity default |
| 6 | Complete plan, push branch, and open PR | pending | Antigravity default |

## Overview
Refine `USER-AGENTS.md`, `vibe-ai-tools`, `campaign-ai-tools`, and `README.md`:
1. **USER-AGENTS.md**:
   - Remove `<rule id="planner-offer">`.
   - Update `<rule id="implementer-offer">`: immediately upon user approval to start implementation, the very first action without intermediate commands, checks, or tool calls is asking once via `<user_interaction>` who implements every stage ({IMPLEMENTER}): 1. `mid` or `senior` tier of harness skill (`mid` recommended); 2. subagent of session or harness default. Execution proceeds only after {IMPLEMENTER} is resolved.
   - Update `<rule id="stage-close">`: planner that created the plan ({PLANNER}) validates delivery by reviewing git diff and test results against the plan before starting the next stage.
2. **vibe-ai-tools**:
   - The session alone is the planner per `<planning_protocol>`.
   - Immediately upon briefing approval to proceed, ask {IMPLEMENTER} as the very first action without intermediate tools or checks; ask nothing else afterwards.
   - Session validates each stage delivery by reviewing git diff and test results against the plan and stage acceptance criteria.
3. **campaign-ai-tools**:
   - Grill-me with user structures a campaign with an achievable global objective and 3–5 concrete goals.
   - Immediately upon user approval to begin, ask {IMPLEMENTER} as the very first action without intermediate tools or checks.
   - Only after {IMPLEMENTER} is resolved, create branch `improve/{CAMPAIGN}`, commit `plans/improve/{CAMPAIGN}.md`, and run unattended until PR.
   - Loop: session dispatches a subagent inheriting session model and effort via native harness API per `<rule id="native-spawn">` to plan next goal into stages per `<planning_protocol>`.
   - Implementer delivers each stage; goal planner subagent validates delivery by reviewing git diff and test results against the plan.
   - Each goal removes its plan file in its last stage. Session updates goal status in campaign log and commits.
   - When all goals complete, remove `plans/improve/{CAMPAIGN}.md`, commit, push branch `improve/{CAMPAIGN}`, and open pull request.
4. **README.md**:
   - Update rules 4, 23, and 24 to reflect immediate implementer offer, diff + test validation, and campaign PR delivery.
   - Bump version to `0.0.64-ALPHA`.

## Stage 1: Setup branch and write plan
- Create branch `plan/campaign-vibe-refinement` from `master`.
- Write plan to `plans/campaign-vibe-refinement.md`.
- Mark Stage 1 as `done`.
- Commit: `chore(plans): initialize campaign-vibe-refinement plan`.

## Stage 2: Update USER-AGENTS.md
- Remove `<rule id="planner-offer">` from `<planning_protocol>`.
- Update `<rule id="implementer-offer">` with immediate ask on approval, no intermediate calls, and expanded options (`mid`/`senior` tier or subagent/default).
- Update `<rule id="stage-close">` to explicitly specify reviewing git diff and test results against the plan.
- Verify character count stays under 8,000 characters.
- Run `scripts/lint.sh`.
- Mark Stage 2 as `done` and append stage report.
- Commit: `feat(instructions): refine implementer offer timing and validation with diff and tests`.

## Stage 3: Update vibe-ai-tools skill
- In `skills/vibe-ai-tools/SKILL.md`:
  - Session alone plans per `<planning_protocol>`.
  - In Step 1: Immediately upon briefing approval to proceed, ask {IMPLEMENTER} as very first action without intermediate tools or checks.
  - In Step 2: Session validates delivery by reviewing git diff and test results against plan and acceptance criteria.
- Run `scripts/lint.sh`.
- Mark Stage 3 as `done` and append stage report.
- Commit: `feat(vibe): session-first planning with immediate implementer offer and diff test validation`.

## Stage 4: Update campaign-ai-tools skill
- In `skills/campaign-ai-tools/SKILL.md`:
  - Update frontmatter description (mentions creating branch, editing, committing, pushing, and opening PR unattended).
  - Step 1: Grill-me structures 3–5 goals. Immediately upon approval, ask {IMPLEMENTER} as very first action without intermediate tools or checks. Create `improve/{CAMPAIGN}`, commit `plans/improve/{CAMPAIGN}.md`, and run unattended until PR.
  - Step 2: Loop delegating each goal to an inherited planner subagent, implementer delivers each stage, goal planner validates git diff and test results.
  - Step 3: Remove `plans/improve/{CAMPAIGN}.md`, commit, push branch, and open PR.
  - Update boundaries per PR delivery.
- Run `scripts/lint.sh`.
- Mark Stage 4 as `done` and append stage report.
- Commit: `feat(campaign): 3-5 goal campaign workflow with inherited planner subagent and PR delivery`.

## Stage 5: Update README.md
- In `README.md`:
  - Update bullet 4 (session-first skills), rule 23 (planning protocol), and rule 24 (implementation protocol).
  - Bump version to `0.0.64-ALPHA`.
- Run `./scripts/lint.sh --base master`.
- Mark Stage 5 as `done` and append stage report.
- Commit: `docs: document refined campaign and vibe lifecycle`.

## Stage 6: Complete plan, push branch, and open PR
- Run full verification (`./scripts/lint.sh --base master`).
- Remove `plans/campaign-vibe-refinement.md`.
- Commit removal: `chore(plans): complete campaign-vibe-refinement plan`.
- Push branch `plan/campaign-vibe-refinement` to origin.
- Open PR using `gh pr create`.

## Reports

### Stage 1: Setup branch and write plan
- Created branch `plan/campaign-vibe-refinement` from `master`.
- Initialized plan in `plans/campaign-vibe-refinement.md` with status table tracking all 6 stages.
- Ready for Stage 2.

### Stage 2: Update USER-AGENTS.md
- Removed `<rule id="planner-offer">` from `<planning_protocol>`.
- Updated `<rule id="implementer-offer">` in `<implementation_protocol>`: immediately asks once upon user approval who implements every stage, without intermediate commands or checks, with expanded options (`mid`/`senior` tier or subagent/default).
- Updated `<rule id="stage-close">` in `<implementation_protocol>`: planner validates stage delivery by reviewing git diff and test results against the plan.
- Verified character count: 5,805 characters (well below the 8,000-character cap).
- Tested with `./scripts/lint.sh`: all checks on `USER-AGENTS.md` passed cleanly. 2 expected interim warnings on unresolved `<rule id="planner-offer">` in `skills/vibe-ai-tools/SKILL.md` and `skills/campaign-ai-tools/SKILL.md` will resolve in Stage 3 and Stage 4 respectively.

### Stage 3: Update vibe-ai-tools skill
- Updated `skills/vibe-ai-tools/SKILL.md` `<step id="1" name="plan">`: session directly plans per `<planning_protocol>` and immediately offers {IMPLEMENTER} upon briefing approval as the very first action without intermediate tools or checks.
- Updated `skills/vibe-ai-tools/SKILL.md` `<step id="2" name="deliver">`: session validates delivery by reviewing git diff and test results against the plan and stage acceptance criteria.
- Verified frontmatter description length (410 characters, under the 500-character limit) and format (`Agent: session + implementer (model asked once).`).
- Tested with `./scripts/lint.sh` and `./scripts/test.sh`: `vibe-ai-tools` passed cleanly with 0 warnings; remaining interim warning on `campaign-ai-tools` will resolve in Stage 4; all 349 regression tests in `test.sh` passed.

### Stage 4: Update campaign-ai-tools skill
- Updated `skills/campaign-ai-tools/SKILL.md` frontmatter description to reflect 3–5 goal campaign workflow, inherited planner subagent, and PR delivery (443 characters, under the 500-character limit, matching `Agent: session + implementer (model asked once)`).
- Updated `<overview>` and `<session_workflow>`: step 1 resolves 3–5 goals with user and immediately asks {IMPLEMENTER} upon approval as very first action; step 2 iterates each goal via inherited planner subagent, spawning {IMPLEMENTER} for each stage and validating delivery against git diff and test results; step 3 completes campaign by removing plan, pushing branch, and opening PR.
- Updated template constraints to work locally on `improve/{CAMPAIGN}` without push or remote mutation, and added `<campaign>{CAMPAIGN}</campaign>` to template input to satisfy placeholder parity.
- Replaced `<rule id="local-lifecycle">` with `<rule id="campaign-lifecycle">` and `<rule id="strictly-local">` with `<rule id="stay-in-repo">`.
- Tested with `./scripts/lint.sh`: 398 checks ok, 0 warnings (unresolved `planner-offer` warning resolved).
- Tested with `./scripts/test.sh`: 349 tests passed with 0 warnings.

### Stage 5: Update documentation in README.md
- Bumped version to `0.0.64-ALPHA` in `README.md`.
- Updated bullet 4 in `README.md` to state that `vibe-ai-tools` plans with the user and `campaign-ai-tools` plans 3–5 goals via an inherited subagent, with both delivering each stage in a fresh implementer (`mid` recommended or `senior` tier, or subagent/default of the session) asked once.
- Updated rule 23 in `README.md` to remove the planner selection offer sentence.
- Updated rule 24 in `README.md` to specify immediate implementer offer upon approval without intermediate commands or checks, validation of deliveries by planner reviewing git diff and test results, and PR delivery for both `vibe-ai-tools` and `campaign-ai-tools`.
- Tested with `./scripts/lint.sh`: 398 ok, 0 warnings.
- Tested with `./scripts/test.sh`: 349 tests passed with 0 warnings.


