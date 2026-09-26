# Stage 3: Update documentation and verify compliance

## Objective

Update normative rules in `README.md` (rules 23 and 24) to formally specify the on-demand stage planning lifecycle across `plan-ai-tools`, `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`. Run `./scripts/lint.sh` to ensure complete compliance.

## Decisions

- Clarify in Rule 23 that `plan-ai-tools` produces `0-<slug>.md` with succinct stage outlines as its deliverable, and detailed stage files are authored on demand during execution.
- Clarify in Rule 24 the `P` -> stage-planner -> `PF` -> `W` -> implementer lifecycle across `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`.

## Files

- Modify `README.md`

## Steps

1. In `README.md`:
   - Update rule 23 to reflect base plan with succinct outlines and on-demand stage planning.
   - Update rule 24 to describe on-demand stage planning in `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`.
2. Run `./scripts/lint.sh` and ensure all checks pass with 0 warnings.

## Tests

- Run `./scripts/lint.sh` to confirm rule citations, XML grammar, cross-references, and vocab consistency.

## Acceptance Criteria

- `README.md` accurately documents on-demand stage planning across all affected skills.
- `./scripts/lint.sh` passes with 0 warnings.

## Commit Message

`docs(readme): document on-demand stage planning lifecycle`

## Dependencies

- Stage 1 and Stage 2 completed.

## Implementation Log

- Updated Rule 23 in `README.md` to document that `plan-ai-tools` produces base file `0-<slug>.md` with succinct stage outlines and that stage files `<n>-<slug>.md` are planned on demand during execution immediately before implementation.
- Updated Rule 24 in `README.md` to specify the on-demand stage planning protocol (`P` -> stage planner -> `PF` -> `W` -> implementer) across `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`.
- Ran `./scripts/lint.sh` and confirmed 0 warnings and exit code 0.
