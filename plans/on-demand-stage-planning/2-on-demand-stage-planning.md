# Stage 2: Update vibe-ai-tools and campaign-ai-tools

## Objective

Adopt the on-demand stage planning workflow in `skills/vibe-ai-tools/SKILL.md` and `skills/campaign-ai-tools/SKILL.md`. Both skills will execute base plans with succinct stage outlines and dispatch detailed stage planning immediately prior to implementing each stage.

## Decisions

- In `vibe-ai-tools`, reuse `dev-ai-tools` `<template role="stage-planner">` via standard cross-skill reference. The session sets `P`, spawns `stage-planner` to write `{STAGE_FILE}`, verifies `PF`, sets `W`, and proceeds with `stage-implementer`.
- In `campaign-ai-tools`, extend `<template role="campaign-planner">` with mode `STAGE-PLAN` to detail `{STAGE_FILE}` on demand, mark `PF`, and return `PLANNED`. The initial `PLAN` mode writes only base `0-<slug>.md` with succinct stage outlines.
- Keep user interaction out of per-stage planning across both skills: decisions are derived from codebase state and recorded in stage file header/log.

## Files

- Modify `skills/vibe-ai-tools/SKILL.md`
- Modify `skills/campaign-ai-tools/SKILL.md`

## Steps

1. In `skills/vibe-ai-tools/SKILL.md`:
   - In `<step id="3" name="unattended_execution">`, add dispatch of `dev-ai-tools` `<template role="stage-planner">` (`P` -> planner -> `PF`) prior to setting `W` and spawning `stage-implementer`.
   - Update `<boundaries>` (`spawn-apis` and `no-implementer-fallback` rules) to include `stage-planner`.
2. In `skills/campaign-ai-tools/SKILL.md`:
   - In `<step id="2" name="plan">` and `<template role="campaign-planner">`, update `PLAN` mode to write base `0-<slug>.md` with succinct stage outlines rather than full stage files upfront.
   - In `<template role="campaign-planner">`, add `STAGE-PLAN` mode to write detailed `{STAGE_FILE}`, set `PF` in base plan, and return `<signal code="PLANNED">`.
   - In `<return_protocol>`, add `<signal code="PLANNED">`.
   - In `<step id="3" name="stage_loop">`, add stage planning dispatch (`P` -> `STAGE-PLAN` -> `PF`) before setting `W` and spawning `stage-implementer`.
3. Verify all changes with `./scripts/lint.sh`.

## Tests

- Run `./scripts/lint.sh` to ensure all XML tags, references, and placeholders resolve cleanly.

## Acceptance Criteria

- `vibe-ai-tools` references and spawns `stage-planner` for uncompleted stages before setting `W`.
- `campaign-ai-tools` defines `STAGE-PLAN` mode in `campaign-planner` and dispatches it in `stage_loop`.
- `./scripts/lint.sh` exits 0 with 0 warnings.

## Commit Message

`feat(skills): adopt on-demand stage planning in vibe and campaign skills`

## Dependencies

- Stage 1 completed (defines `stage-planner` and `dev-ai-tools` `<status_protocol>` with `P`/`PF`).

## Implementation Log

- Updated `skills/vibe-ai-tools/SKILL.md`:
  - In `<session_workflow>` `<step id="3" name="unattended_execution">`, updated the stage loop to spawn `dev-ai-tools` `<template role="stage-planner">` as `executor="session-subagent"` for unplanned stages (`P` -> `stage-planner` -> `PF`) prior to setting `W` and spawning `stage-implementer`.
  - In `<boundaries>`, updated `spawn-apis` to include `dev-ai-tools` `<template role="stage-planner">` as `executor="session-subagent"`, and updated `no-implementer-fallback` to handle both `stage-planner` and `stage-implementer`.
- Updated `skills/campaign-ai-tools/SKILL.md`:
  - In `<session_workflow>` `<step id="3" name="stage_loop">`, updated the stage loop to spawn `<template role="campaign-planner">` as `executor="session-subagent"` with `MODE` set to `STAGE-PLAN` for unplanned stages (`P` -> `STAGE-PLAN` -> `PF`) before setting `W` and spawning `stage-implementer`.
  - In `<dispatch_templates>` `<template role="campaign-planner">`, updated the job description and instructions to add `STAGE-PLAN` mode for detailing `{STAGE_FILE}` on demand and setting `PF` in the base plan, and updated `PLAN` mode to write base `0-<slug>.md` with succinct stage outlines.
  - In `<return_protocol>`, added `<signal code="PLANNED">PLANNED {STAGE_FILE}</signal>`.
- Verified with `./scripts/lint.sh` (exit code 0, 0 warnings).
