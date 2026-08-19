# Stage 1: Sandbox harness and assertions (shell)

## Objective

Create the shell test runner and its shared library: a fixture builder that stages a disposable fake `HOME`, a sandboxed way to run one of the five scripts and capture its stdout and exit code, assertion helpers, glob-based case discovery, and the suite's own `0`/`1`/`2` exit contract. Ships with one smoke case so the harness is proven before any contract case is written.

## Files

- Create: `tools/test.sh` — suite entry point; executable, LF, bash 3.2+, BSD/GNU userlands, no dependency beyond `git`, `grep`, `awk`, `sed`, `cmp`, `diff`, `find`, `tar`
- Create: `tools/test/lib.sh` — fixture builder, sandbox runner, assertions; sourced, not executed (`# shellcheck shell=bash` header, like `scripts/shell/lib.sh`)
- Create: `tools/test/smoke.sh` — one case proving the fixture and the runner work end to end

## Steps

1. **Header and contract.** `tools/test.sh` opens with what it is: a development check, not an installation process (outside rules 23–25), same standing as `tools/lint.sh`. Resolve the repository root from `$(dirname "$0")/..`, export `AI_TOOLS` to it, source `scripts/shell/lib.sh`, then source `tools/test/lib.sh`. Report only through `ok`/`skip`/`warn`/`info`/`fatal` and close with `finish` — that already yields `0` clean, `1` aborted on a precondition, `2` finished with failures. Never invent a second reporting style.
2. **CLI.** `while [ $# -gt 0 ]` / `shift` parsing, matching the five scripts and `tools/lint.sh` (a `for arg in "$@"` loop breaks under `set -u` on bash 3.2). Flags: `--help`/`-h` (usage plus the list of discovered cases, exit `0`), `--case <name>` (run only the named case file, repeatable), `--keep` (do not delete sandboxes, print their paths). Unknown flag → `fatal`, exit `1`.
3. **Case discovery by glob.** Every `tools/test/*.sh` other than `lib.sh` is a case file. It defines one or more functions named `case_*`; the runner sources it and calls each in turn. Nothing registers a case in a central list — later stages must be able to add case files without editing this one.
4. **Test helpers are `t_`-prefixed.** `lib.sh` from `scripts/shell` is already in scope and owns names like `same_content`, `safe_link`, `warn`. Every helper this stage adds is `t_*` (`t_fixture`, `t_run`, `t_assert_exit`, …) so nothing shadows the code under test.
5. **`t_fixture`** — builds a sandbox under `${TMPDIR:-/tmp}` via `mktemp -d` and echoes its root. Contents:
   - `home/` — the fake `HOME`, with the config directory of every harness pre-created so `harness_detected` reports all seven without touching the machine: `.claude/agents`, `.claude/skills`, `.grok/agents`, `.grok/skills`, `.codex/agents`, `.codex/skills`, `.copilot/agents`, `.copilot/skills`, `.copilot/instructions`, `.cursor/agents`, `.cursor/skills`, `.gemini/agents`, `.gemini/skills`, `.gemini/config/agents`, `.gemini/config/skills`.
   - `origin.git` — a bare repository. Build it by `tar`-ing the working tree excluding `.git` and `plans/` into a scratch directory, `git init` with `-b master` (fall back to `git checkout -b master` for older git), one commit, `git push` to the bare repo. Preserve executable bits — `install.sh` and friends must stay runnable. The tree under test is the *working* tree, so an uncommitted change to `scripts/` is what the suite exercises.
   - `home/.ai-tools` — `git clone origin.git`, so `origin/master`, a real `HEAD`, and `.git` all exist.
   - `home/.gitconfig` — `user.name`/`user.email` (commits are made inside the sandbox), and `[url "file://<sandbox>/origin.git"] insteadOf = https://github.com/hgsantana/ai-tools.git` so the fresh-clone path in `ensure_clone` runs offline against the fixture.
6. **Fixture options.** `t_fixture` accepts flags so cases stage their own conflicts without hand-rolling paths, each defaulting to off: a foreign file on a destination path (a regular file with known content at a harness agents-root destination, and one at an instructions destination); a locally modified copy (a real file copy of a wrapper into an agents root, then appended to, so it matches neither revision); an unmanaged `[subagents.models]` block in `home/.grok/config.toml`; a stale link from an older layout (a symlink into `$AI_TOOLS` under a name no current wrapper uses); a symlink pointing outside `$AI_TOOLS` on a destination path. Each option records the paths it created in shell variables the case can read.
7. **`t_run`** — runs one script in the sandbox: `env -i` with only `PATH`, `HOME=<sandbox>/home`, `USERPROFILE=<sandbox>/home`, `AI_TOOLS=<sandbox>/home/.ai-tools`, `GIT_TERMINAL_PROMPT=0`, `GIT_CONFIG_NOSYSTEM=1`, `TERM`, `LANG`. Captures stdout+stderr to a file and the exit code to a variable the assertions read. **Before executing anything**, assert that `HOME` and `AI_TOOLS` both start with the sandbox root and that the sandbox root is non-empty and not `/`; otherwise `fatal` (exit `1`). This guard is the reason the suite is safe to run on a maintainer's machine.
8. **`t_run_stdin`** — same as `t_run` but feeds a given string on stdin, for `purge_clone`'s confirmation prompt.
9. **`t_run_no_symlink`** — same as `t_run` with a shim directory prepended to `PATH` containing an `ln` that exits non-zero, forcing `safe_link` to return `2` and `link_or_copy` to fall back to a copy.
10. **Assertions**, each reporting through `ok`/`warn` with the case name and the offending value, never aborting the suite: `t_assert_exit <expected>`; `t_assert_line <pattern>` and `t_assert_no_line <pattern>` (fixed-string `grep -F` over the captured output); `t_assert_symlink <path> <target-prefix>`; `t_assert_regular_file <path>`; `t_assert_absent <path>`; `t_assert_content <path> <expected-string>`; `t_snapshot <dir>` / `t_assert_unchanged <dir>` (a sorted `find` listing plus per-file checksums, for the `--dry-run` cases).
11. **Cleanup.** Each case ends by removing its sandbox unless `--keep`; the removal target must be under `${TMPDIR:-/tmp}` and be the exact path `t_fixture` returned.
12. **Smoke case** (`tools/test/smoke.sh`): build a fixture, assert every harness config directory exists and `home/.ai-tools/.git` is a real clone whose `origin/master` resolves, run `scripts/shell/verify.sh --harnesses claude-code` and assert exit `2` with `WARN: agent absent:` (nothing is installed yet — this proves the sandbox is genuinely empty and that `verify` reports rather than fails), then assert the real `$HOME` was never written: no file in the caller's own home changed (compare a `find $HOME -maxdepth 1 -newer <marker>` listing taken around the run).

## Tests

The stage *is* test code. Evidence to record in the Implementation log:

- `bash tools/test.sh --help` → exit `0`, lists the discovered cases.
- `bash tools/test.sh --bogus` → exit `1`.
- `bash tools/test.sh` → exit `0`, smoke case passes.
- Deliberate sabotage of `t_run`'s guard (temporarily point `HOME` outside the sandbox in a scratch copy of the file, never in the working tree) → exit `1` before any script runs.
- `shellcheck -x -P scripts/shell -P tools/test tools/test.sh tools/test/*.sh` → clean. `shellcheck` is not installed in the planning environment; if it is unavailable to the implementer, record that and rely on the CI job from stage 7.

## Acceptance criteria

- [ ] `tools/test.sh` runs from any working directory and exits `0` on a clean tree
- [ ] Unknown flag exits `1`; `--help` exits `0` and lists cases discovered by glob
- [ ] A new case file needs no edit to `tools/test.sh`
- [ ] Every child run is confined to the sandbox, and the guard aborts with exit `1` otherwise
- [ ] No network access: git operations resolve through the fixture's `insteadOf` rewrite
- [ ] `scripts/shell/lib.sh` is sourced for reporting — no duplicated `ok`/`warn`/`finish`
- [ ] Helper names are `t_`-prefixed and shadow nothing in `lib.sh`
- [ ] Files committed executable (`tools/test.sh`) with LF endings; `shellcheck`-clean

## Commit

Suggested message: `chore(tools): add a sandboxed test harness for the scripts`

## Dependencies

- Requires stages: none
- Parallel-safe with: none (stages 2–4 build on this file)

## Implementation log

(Append-only.)
