# Stage 2: Process, script, and check descriptions match the code

## Objective

Correct the README sections that describe scripts, lint, tests, and CI so that they match `scripts/shell/*`, `scripts/lint.sh`, `scripts/test.sh`, `scripts/test/*`, and `.github/workflows/ci.yml`. Base plan findings: 2, 3, 4, 5, 28-37, 39-43.

## Files

- Create: none
- Modify: `README.md` (Contents, Quick start, Scripts, Development checks, Installation, Removal, Update, Troubleshooting)
- Remove: none

## Steps

1. **Contents.**
   - USER-AGENTS row: "skill-offer gate, execution protocol, language, native question tool, and security".
   - scripts row: "`scripts/shell/` install processes ([Scripts](#scripts); rules 18–21); `lint.sh`, `test.sh`, and its sourced `scripts/test/` case files ([Development checks](#development-checks)). Windows: WSL or Git Bash".
   - Add two rows. `` [`ROADMAP.md`](ROADMAP.md) ``: "Advisory story backlog; this README stays the source of truth". `` `dev/` ``: "Plans, tasks, and campaigns in progress, plus untracked `dev/tmp/` (rule 22)".
2. **Quick start**, line 39: "`install.sh`, `remove.sh`, and `update.sh` take `--dry-run`; those three and `verify.sh` take `--help`."
3. **Scripts, Scope bullet:** after "Omit the flag to select detected harnesses", add "(the script aborts with exit `1` when none is detected)".
4. **Development checks, intro.**
   - "Development checks live under `scripts/` beside `scripts/shell/` (rules 18–20)" becomes "Development checks live under `scripts/` beside `scripts/shell/`, outside the contract of rules 18–20".
   - Dependency list: "`git`, `grep`, `awk`, `sed`, `wc`, `tr`" (drop `od`), matching the `lint.sh` header.
5. **Check families.**
   - **skill layout** becomes: "no `skills/*.md` at the skills root and no `skills/SKILL-CONTRACT.md` or `skills/MAINTAINER.md`; the nine shipped skills `lint.sh` names are present; every `skills/*/` has a `SKILL.md` with a root `<skill name>`, `<session_workflow>`, and `<dispatch_templates>`, and no `## Continue?` or `## Stake` heading or mention of `SKILL-CONTRACT`/`MAINTAINER.md`; `USER-AGENTS.md` contains `<routing_gate>` and `<execution_protocol>` with rules `default-worker`, `implementer`, and `session-subagent`, its offer table uses the `Execution` column, and it has no `<agents>`, `<dispatch_protocol>`, or `<worker>` tag (rules 5, 11)".
   - Replace **encodings and endings** with two bullets. "**line endings and modes** — every tracked `scripts/` file resolves to `eol=lf` with LF in index and working tree, and `scripts/*.sh` and `scripts/shell/*.sh` are mode `100755` (rule 21)". "**no binaries** — every tracked file under `skills/` and `scripts/` is text".
   - **version bump:** "only with `--base <ref>`: when `skills/`, `scripts/`, or `USER-AGENTS.md` changed between `<ref>` and `HEAD`, the README version line must differ from `<ref>`'s (rule 4)".
   - **size caps** and the other families: no change in this stage.
6. **CI sentence:** "CI (`.github/workflows/ci.yml`) runs two jobs on `ubuntu-latest` for every push and pull request. `lint` runs `scripts/lint.sh`, adding `--base` with the pull request's base SHA on pull requests, then `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`. `test-shell` runs `scripts/test.sh`." Do not claim the shellcheck step passes (open question 3).
7. **test.sh paragraph.**
   - "asserts the installation and script contract (rules 12–20)" → "asserts rules 12–15, 17, and 20".
   - Add: "Every `scripts/test/*.sh` other than `lib.sh` is a case file defining `case_*` functions, discovered by glob; `--case` takes a case-file basename or one function name."
   - Fixture sentence: "Each case builds its own fixture: a harness layout for all six harnesses and a local `origin` git remote so no run reaches the network, plus, per case, a foreign skill or instructions file, a locally modified copy, a stale link from an older layout, or a symlink pointing outside the clone."
   - Keep the assertion bullets.
8. **Installation.**
   - Bootstrap paragraph: after "exits without changing anything", add "; a path that exists but is not a clone aborts with exit `1`".
   - Step 1: "the clone at `$HOME/.ai-tools` exists and validates; `install.sh` clones it when missing, except under `--dry-run` (rule 16; ...)".
   - Step 4: append "With `--overwrite`, orphan `*-ai-tools` skills no longer in the tree are pruned from the scoped roots."
   - Step 5: add "an orphan `*-ai-tools` skill" to the findings. Keep "8,000-character cap" (open question 5).
9. **Removal.**
   - Step 2: append "Orphan `*-ai-tools` skills no longer in the tree are removed only with `--force`."
   - Step 5 becomes: "**Verify** — report any link in the scoped roots that still resolves into the clone; expect none."
   - After the list, add: "When `$HOME/.ai-tools` is missing, copies cannot be compared: the script warns and removes only ai-tools links."
10. **Update:** replace the default-branch sentence with "The scripts target `master` only and abort when `origin/master` is missing; a renamed default branch needs a script change, never a guessed branch."
11. **Troubleshooting**, `--force` entry: "The flag affects only known artifact destinations and orphan `*-ai-tools` skills in that scope."

## Tests

Follow the verification protocol in the base plan, with declared files `README.md`.

- `grep -nE '`od`|verify\.sh. take .--dry-run|rules 12–20\)|scripts follow only after|names no longer in the tree are not destinations|encodings and endings' README.md` prints nothing.
- Each changed claim still holds against the code:
  - `"$V/scripts/shell/verify.sh" --dry-run` exits 1;
  - `grep -n 'prune_orphan_skills' scripts/shell/lib.sh` shows the calls from `install_skills` and `remove_skills`;
  - `grep -n 'od ' scripts/lint.sh` prints nothing.
- Scratch clone: `scripts/lint.sh` exits 0 with 0 warnings; `scripts/test.sh` exits 0.

## Acceptance criteria

- Every action in base plan findings 2-5, 28-37, and 39-43 is present in README.
- Every flag, exit code, dependency, and check scope README states matches the code it names.
- Rule numbers and Repository rules text from stage 1 are unchanged.
- No file outside `README.md` changes.

## Commit message

```
docs(readme): correct script, process, and development-check descriptions
```

## Dependencies

Stage 1.

## Implementation log
