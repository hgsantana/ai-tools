# Stage 6: CI workflow

## Objective

Run the linter and `shellcheck` on every push and pull request, so a drifting wrapper or an oversized instructions file fails before it reaches anyone's machine.

## Files

- Create: `.github/workflows/lint.yml` — one job on `ubuntu-latest`

## Steps

1. Triggers: `push` and `pull_request`. No schedule, no matrix, no cache — the whole run is a few seconds of shell.
2. `actions/checkout` with `fetch-depth: 0`: the version-bump check needs the base ref's history, and a shallow clone cannot serve it.
3. Run `tools/lint.sh --base <ref>`, where the ref is the pull request's base ref on a pull request and the push's `before` commit on a push. When neither resolves — a first push, an empty `before` — omit the flag rather than inventing a ref; stage 4 makes the check skip cleanly.
4. Run `shellcheck` over `scripts/shell/*.sh` and `tools/*.sh` as a second step, from the runner's preinstalled binary (no action dependency, nothing to pin or trust). Keep it a separate step so a `shellcheck` finding is distinguishable from a rule finding in the log.
5. Exit-code mapping: the linter's `2` must fail the job. Confirm this is the default (any non-zero fails) and do not swallow it with `|| true` anywhere.
6. No write permissions: declare `permissions: contents: read`. Nothing in this job needs more.

## Tests

Evidence in the Implementation log: the workflow file parses (`actionlint` if available, otherwise a YAML parse), and a local rehearsal of both commands with the same arguments the workflow passes, showing exit `0` on the current tree.

Full verification is the first CI run on the pull request — record its result in the log once available.

## Acceptance criteria

- [ ] The workflow runs the linter and `shellcheck` as two separate steps on push and pull request
- [ ] `fetch-depth: 0` is set and the base ref is derived from the event, never hard-coded
- [ ] Permissions are read-only and no step masks a non-zero exit
- [ ] The job passes on the current tree

## Commit

Suggested message: `ci: run the rule linter and shellcheck on push and pull request`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 3, 4, 5 (touches only `.github/`)

## Implementation log
