# Stage 1: Update plan-ai-tools and dev-ai-tools

## Objective

Adapt `plan-ai-tools` to generate only `0-{SLUG}.md` with succinct stage outlines at base planning time, and extend `dev-ai-tools` with `P` (Planning) and `PF` (Planning Finished) states, on-demand stage planning via `<template role="stage-planner">`, and resume semantics.

## Decisions

- Retain user grill-me interview exclusively in `plan-ai-tools` initial planning.
- `stage-planner` in `dev-ai-tools` runs as `executor="session-subagent"` on the session model, inspects recent repo state, writes `<N>-{SLUG}.md` with decisions recorded in its header/log, and sets `PF`.
- Session marks `P` before spawning `stage-planner`. On resume, stages at `P` re-invoke `stage-planner`.

## Files

- Modify `skills/plan-ai-tools/SKILL.md`
- Modify `skills/dev-ai-tools/SKILL.md`

## Steps

1. In `skills/plan-ai-tools/SKILL.md`:
   - In `<step id="3" name="plan_writing">`, update instructions to write `0-{SLUG}.md` containing base plan and succinct outlines for all stages, deferring detailed `<N>-{SLUG}.md` creation to execution time.
   - In `<plan_file_format>`, update `<structure>` and description to note that `0-{SLUG}.md` is the initial deliverable and stage files are planned on demand.
2. In `skills/dev-ai-tools/SKILL.md`:
   - In `<status_protocol>`, add `P` and `PF` states and document session/planner ownership and resume behaviour.
   - In `<dispatch_templates>`, add `<template role="stage-planner" executor="session-subagent">`.
   - In `<return_protocol>`, add `<signal code="PLANNED">`.
   - In `<step id="3" name="stage_loop">`, add stage planning dispatch (`P` -> `stage-planner` -> `PF`) prior to setting `W` and spawning the implementer.
   - In `<boundaries>`, update `spawn-apis` and `no-implementer-fallback` rules to include `stage-planner`.

## Tests

- Run `./scripts/lint.sh` to ensure all XML tags, references, and placeholders resolve cleanly.

## Acceptance Criteria

- `plan-ai-tools` specifies writing only `0-{SLUG}.md` initially with succinct stage outlines.
- `dev-ai-tools` defines states `P` and `PF` in `<status_protocol>`.
- `dev-ai-tools` specifies spawning `stage-planner` before implementation and handling interrupted `P` stages on resume.
- `./scripts/lint.sh` passes without errors or warnings for both skills.

## Commit Message

`feat(skills): add on-demand stage planning to plan and dev skills`

## Dependencies

- None

## Implementation Log

- Updated `skills/plan-ai-tools/SKILL.md`:
  - In `<step id="3" name="plan_writing">`, specified that initial planning splits delivery into isolated stages with one Conventional Commit per stage, writing `plans/{SLUG}/0-{SLUG}.md` with succinct outlines and deferring detailed stage files to execution time.
  - In `<plan_file_format>`, updated `<structure>` annotations to reflect on-demand stage planning and updated section listings for base plan and stage files.
- Updated `skills/dev-ai-tools/SKILL.md`:
  - In `<session_workflow>` `<step id="3" name="stage_loop">`, added step 1 to spawn `<template role="stage-planner">` for unplanned stages (`P` -> `stage-planner` -> `PF`) before implementation.
  - In `<dispatch_templates>`, added `<template role="stage-planner" executor="session-subagent">` to expand stage outlines into detailed stage files.
  - In `<return_protocol>`, added `<signal code="PLANNED">`.
  - In `<status_protocol>`, added `P` and `PF` states, session/planner ownership, and resume semantics.
  - In `<boundaries>`, updated `no-implementer-fallback` and `spawn-apis` rules to include `stage-planner`.
- Verified with `./scripts/lint.sh` (exit code 0, 0 warnings) and `./scripts/test.sh` (exit code 0, 0 warnings).
