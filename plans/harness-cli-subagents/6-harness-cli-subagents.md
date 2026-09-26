# Stage 6: Lint, verify, and test suite

## Objective
Execute `./scripts/lint.sh` and relevant verification tests to validate all newly created and updated skills, harness removals, frontmatter rules, and semantic XML boundaries.

## Files
- Modify: `plans/harness-cli-subagents/0-harness-cli-subagents.md`

## Steps
1. Run `./scripts/lint.sh` and ensure 0 warnings and 0 failures.
2. Run `./scripts/test.sh` or targeted test scenarios for install/remove/update.
3. Validate character caps on `USER-AGENTS.md` and skill frontmatters.

## Tests
- `./scripts/lint.sh`

## Acceptance criteria
- `./scripts/lint.sh` exits 0 with 0 warnings.

## Commit message
`test(ci): verify harness-cli-subagents skills and harness constraints`

## Dependencies
Stage 5

## Implementation log
