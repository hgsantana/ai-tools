# Stage 4: High-Tier Task Judge Agent (dev/vibe)

## Objective

Introduce a dedicated high-tier judge agent (`senior` tier with high reasoning effort) in `dev-ai-tools` and `vibe-ai-tools`. The judge rigorously evaluates the working-tree diff, test logs, and acceptance criteria after implementation, commanding the retry cycle (R1..R3) via objective `ACCEPT` or `REWORK` verdict signals.

## Files

- **Modify**:
  - `skills/dev-ai-tools/SKILL.md`
  - `skills/vibe-ai-tools/SKILL.md`
  - `README.md`
  - `scripts/lint.sh`

## Steps

1. In `skills/dev-ai-tools/SKILL.md`:
   - In `<dispatch_templates>`, add `<template role="stage-judge" executor="senior">`:
     - `<job>`: High-tier judge: evaluate working-tree diff, test output, and acceptance criteria to deliver an objective verdict.
     - `<input>`: `{STAGE_FILE}`, `{SLUG}`, `{TOPIC}`.
     - `<instructions>`: Review working-tree changes against stage objectives, declared files, and criteria. Produce detailed feedback in `${TMPDIR:-/tmp}/ai-tools/{TOPIC}-verdict.md`. Return either `<signal code="ACCEPT">` or `<signal code="REWORK">`.
   - Update `<return_protocol>` to declare `<signal code="ACCEPT">` and `<signal code="REWORK">`.
   - Update `step id="3"` (`stage_loop`): after `stage-verifier` runs, spawn `stage-judge`.
     - On `<signal code="ACCEPT">`: stage path-by-path, commit, and set F.
     - On `<signal code="REWORK">`: append verdict corrections to stage log, set R1..R3, retry up to 3 times, then set E.
2. In `skills/vibe-ai-tools/SKILL.md`:
   - In `<dispatch_templates>`, add `<template role="stage-judge" executor="senior">` with equivalent evaluation instructions.
   - Update `step id="3"` (`unattended_execution`): delegate stage diff review to `stage-judge` before committing.
   - Retries (R1..R3) consume the judge's feedback log.
3. Update `README.md` rules and documentation to record the high-tier judge evaluation step in task delivery workflows.
4. Ensure `scripts/lint.sh` resolves all new template references, signals, and executors.

## Tests

- Run `./scripts/lint.sh` to confirm semantic XML references, balanced tags, and template placeholder parity.

## Acceptance criteria

- `dev-ai-tools` and `vibe-ai-tools` dispatch `stage-judge` on the senior model tier for every stage evaluation.
- Verdicts `ACCEPT` and `REWORK` govern the commit and retry loop.
- All skill descriptions stay <= 500 characters.
- `./scripts/lint.sh` passes with 0 warnings.

## Commit message

```text
feat(execution): introduce high-tier judge agent for dev and vibe task execution
```

## Dependencies

- Stage 3 (`3-ai-tools-evolution.md`)

## Implementation log

- Updated `skills/dev-ai-tools/SKILL.md`:
  - Added `<template role="stage-judge" executor="session-subagent">` in `<dispatch_templates>` to evaluate working-tree diff, test output, and acceptance criteria and write verdict to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}-verdict.md`.
  - Declared `<signal code="ACCEPT">` and `<signal code="REWORK">` in `<return_protocol>`.
  - Updated `<step id="3" name="stage_loop">`: spawns `stage-judge` after `stage-verifier` runs, committing on `ACCEPT` and retrying up to three times on `REWORK`.
  - Updated `<rule id="spawn-apis">` in `<boundaries>` to declare `stage-judge` as `session-subagent` on the session model.
- Updated `skills/vibe-ai-tools/SKILL.md`:
  - Added matching `<template role="stage-judge" executor="session-subagent">` in `<dispatch_templates>`.
  - Declared `<signal code="ACCEPT">` and `<signal code="REWORK">` in `<return_protocol>`.
  - Replaced informal session inspection in `<step id="3" name="unattended_execution">` with spawning `stage-judge` to review working-tree diff and test evidence before commit or rework.
  - Updated `<rule id="spawn-apis">` in `<boundaries>` to declare `stage-judge` as `session-subagent`.
- Preserved skill descriptions in both `dev-ai-tools` (407 chars) and `vibe-ai-tools` (429 chars) within the <= 500 characters cap matching rule 6.
- Updated `README.md`:
  - Documented high-tier judge task stage evaluation under Session-first skills overview.
  - Updated rule 24 documenting high-tier judge diff and evidence evaluation and `ACCEPT`/`REWORK` verdict loop in `dev-ai-tools` and `vibe-ai-tools`.
- Verification results:
  - `./scripts/lint.sh`: exit 0 (613 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (340 ok, 0 skipped, 0 warnings).
