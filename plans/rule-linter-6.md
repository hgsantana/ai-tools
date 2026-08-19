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

- Created `.github/workflows/lint.yml`: `push`/`pull_request` triggers, `actions/checkout@v4` with `fetch-depth: 0`, `permissions: contents: read`, two steps (rule linter, then `shellcheck`), no `|| true` anywhere.
- Base ref derivation: on `pull_request`, `github.event.pull_request.base.ref`; on `push`, `github.event.before` unless empty/all-zero (first push); otherwise `tools/lint.sh` runs with no `--base`. `tools/lint.sh` in this working copy does not yet implement `--base` (confirmed via `--help`, another implementer is adding it concurrently per stage brief) — no local rehearsal of the `--base` branch was possible for that reason; the flag-omitted branch was rehearsed instead.
- YAML parse: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/lint.yml'))"` — succeeded (`YAML parse OK`).
- `actionlint`: not installed in this environment (`command -v actionlint` found nothing) and could not be installed (no passwordless sudo). Not run.
- `shellcheck`: not installed in this environment and could not be installed (`sudo apt-get install -y shellcheck` requires interactive auth, unavailable here). The workflow step could not be rehearsed locally for that reason.
- Local rehearsal of the linter step without `--base` (the flag-omitted branch, matching what the workflow does when neither event field resolves): `./tools/lint.sh` → exit `0` (186 ok, 0 skipped, 0 warnings) on the current tree.
- Full verification (both workflow steps under actual GitHub Actions, including the `--base`-flag branch and `shellcheck`) is pending the first CI run on the pull request.

### R1 correction

- Fixed the pull-request base ref: replaced `github.event.pull_request.base.ref` (a bare branch name, unresolvable after `actions/checkout` only populates `origin/*` remote refs) with `github.event.pull_request.base.sha` (a commit SHA already present in the fetched history, needing no ref resolution).
- Left the push branch untouched: `github.event.before` is already a SHA and its all-zero guard is unchanged.
- Stopped interpolating `${{ }}` directly into the shell script for the event values: added `env: PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}` and `PUSH_BEFORE_SHA: ${{ github.event.before }}` to the "Run rule linter" step, and the script now reads `$PR_BASE_SHA` / `$PUSH_BEFORE_SHA` instead of embedding the expressions inline. `${{ github.event_name }}` is still interpolated directly since it is a controlled, non-attacker-influenced GitHub-provided enum value with no shell metacharacter risk — the correction only called out the two event payload values.
- Re-verified YAML parse: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/lint.yml'))"` → `YAML parse OK`.
- Re-ran the local rehearsal (still the flag-omitted branch, matching what the workflow does when neither event field resolves — `tools/lint.sh --base` still not implemented in this working copy): `./tools/lint.sh` → exit `0` (337 ok, 0 skipped, 0 warnings; check count grew because the concurrent implementer landed more checks since attempt 1).
- `shellcheck`/`actionlint` remain unavailable in this environment (no passwordless sudo); unchanged from attempt 1. Full verification, including the corrected `--base` branch under real GitHub Actions, remains pending the first CI run on the pull request.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | af8b2fcca11674983 | V -> failed validation |
| 2 | V | implementer | sonnet | af8b2fcca11674983 | R1 fixed: PR base ref -> base.sha; event values moved to env: instead of inline `${{ }}`; YAML re-parsed OK; rehearsal exit 0 (337 ok) |

## Correction round R1

Verified: triggers, `fetch-depth: 0`, `permissions: contents: read`, two separate steps, and no `|| true` anywhere — all as specified. The YAML parses. One defect blocks acceptance.

1. **The pull-request base ref does not resolve inside the checkout.** The step passes `github.event.pull_request.base.ref`, a bare branch name such as `master`. `actions/checkout` with `fetch-depth: 0` fetches `+refs/heads/*:refs/remotes/origin/*`, so the runner has `origin/master` but no local `master` branch — `git diff --name-only master...HEAD`, which is what the linter runs, fails with `unknown revision` and the step exits non-zero. Every pull request would fail the job for a reason that has nothing to do with a rule.

   Fix: pass `github.event.pull_request.base.sha`. It is a commit SHA present in the fetched history, needs no ref resolution, and is exactly the merge-base side the check wants. The push branch already passes `github.event.before`, a SHA, and is correct as written — leave it, including its all-zero guard.

2. **Do not interpolate `${{ }}` directly into the shell.** Pass the two event values through the step's `env:` and read them as `$VAR` in the script. The workflow expansion is textual substitution into the shell source; going through `env` is this repository's kind of defensive default and costs nothing here.

3. Re-verify that the file parses, and re-record the rehearsal.

Nothing else changes. Set the status back to `V` when done.
