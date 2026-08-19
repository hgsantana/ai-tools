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

- Created `tools/test.sh` (executable, LF), `tools/test/lib.sh` (sourced, `# shellcheck shell=bash` header), `tools/test/smoke.sh`. Followed `tools/lib.sh`/`tools/lint.sh`'s shape: resolve repo root from `$(dirname "$0")/..`, export `AI_TOOLS`, source `scripts/shell/lib.sh` then `tools/test/lib.sh`, report only via `ok`/`skip`/`warn`/`info`/`fatal`, close with `finish`.
- Case discovery is by glob (`tools/test/*.sh` minus `lib.sh`), each defining `case_*` functions found via `declare -F`; nothing registers a case in a central list.
- `t_fixture` builds `${TMPDIR:-/tmp}/ai-tools-test.XXXXXX` with all 15 harness config directories, a bare `origin.git` built by tarring the working tree (`--exclude=./.git --exclude=./plans`, `tar -cpf`/`-xpf` to preserve executable bits) into a scratch commit and pushing to the bare repo, a `git clone` of that bare repo into `home/.ai-tools`, and a `home/.gitconfig` with the `insteadOf` rewrite plus test identity. Six fixture options (`--foreign-agent`, `--foreign-instructions`, `--modified-copy`, `--unmanaged-grok-block`, `--stale-link`, `--external-symlink`) stage the conflicts stages 2-5 will need, each recording its path(s) in a `T_*` global. **Design correction during implementation**: `t_fixture` originally echoed its root for `root=$(t_fixture ...)` capture, which runs the whole function in a subshell and silently drops every `T_*` option variable it sets. Fixed by having `t_fixture` set global `T_ROOT` instead of echoing, called plainly (`t_fixture ...; root="$T_ROOT"`) — verified by a throwaway probe case exercising all six options plus `t_run_no_symlink`, all `T_*` variables read back correctly afterward.
- `t_run`/`t_run_stdin`/`t_run_no_symlink` all call `t_sandbox_guard <root> <home> <ai_tools>` before touching `env -i`, which `fatal`s (exit 1) unless the sandbox root is non-empty, not `/`, and both `home` and `ai_tools` are prefixed by it. Confined env for the child: `PATH HOME USERPROFILE AI_TOOLS GIT_TERMINAL_PROMPT=0 GIT_CONFIG_NOSYSTEM=1 TERM LANG`, exactly per spec. `t_run_stdin` feeds `<input>\n` (a trailing newline is required — `remove.sh`'s `read -r answer || answer=""` treats a no-newline EOF as read failure and discards the answer; discovered via a probe case against `remove.sh --purge`, which reported "purge not confirmed" until the newline was added). `t_run_no_symlink` prepends a shim `ln` that exits 1; verified against `install.sh` under `--no-symlink`-style shimming, output contained `copied (will not track updates)` and exit 2.
- Ten `t_assert_*`/`t_snapshot`/`t_assert_unchanged` helpers implemented; none aborts the suite, all report through `ok`/`warn` with `$T_CASE` and the offending value. `t_snapshot`/`t_assert_unchanged` use a sorted `find` listing plus concatenated file content compared via `cmp -s` (no md5sum/cksum dependency) — verified against `install.sh --dry-run`, confirming the sandbox tree is byte-identical before and after.
- `t_cleanup` only removes a path matching `${TMPDIR:-/tmp}/ai-tools-test.*` (the exact pattern `t_fixture` creates via `mktemp -d`), otherwise warns and refuses.
- Evidence:
  - `bash tools/test.sh --help` → exit 0, lists `case_smoke`.
  - `bash tools/test.sh --bogus` → `ERROR: unknown flag: --bogus (see --help)`, exit 1.
  - `bash tools/test.sh` → `case_smoke` passes all 20 assertions (harness dirs, `.git`/`origin/master` in the fixture clone, `verify.sh --harnesses claude-code` exits 2 with `WARN: agent absent:` against the empty fixture, and a `find $HOME -maxdepth 1 -newer <marker>` check confirms the real `$HOME` was never touched), exit 0. Re-run twice more with identical results (idempotent, no leaked state).
  - Deliberate sandbox-guard sabotage, done in a scratch copy at `/tmp/ai-tools-sabotage-check` (`cp -R` of the working tree, never edited in place): patched `t_run`'s `home="$root/home"` line to a hardcoded out-of-sandbox path (`/tmp/escaped-outside-sandbox-DO-NOT-USE`), ran a probe case that calls `t_fixture` then `t_run`, with an `echo "REACHED_AFTER_T_RUN"` immediately after the `t_run` call. Result: `ERROR: t_sandbox_guard: HOME escaped the sandbox: /tmp/escaped-outside-sandbox-DO-NOT-USE (root: /tmp/ai-tools-test.64FrQo)`, exit 1, and `REACHED_AFTER_T_RUN` never printed — `fatal` aborted the entire process before any script ran. Scratch copy and all `/tmp/ai-tools-test.*` sandboxes deleted afterward; `git status --porcelain` in the real working tree confirmed only the intended new files were added.
  - `shellcheck` is not installed in this environment (`command -v shellcheck` fails); could not run `shellcheck -x -P scripts/shell -P tools/test tools/test.sh tools/test/*.sh` here. Relying on the CI job from stage 7 per the plan's fallback.
- Files touched: `tools/test.sh` (new, executable, LF), `tools/test/lib.sh` (new), `tools/test/smoke.sh` (new). Nothing under `scripts/`, `agents/`, `skills/`, `README.md`, `ROADMAP.md`, `.github/`, or `plans/skill-wrapper-base-contract*` was touched.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | agent aa52b8201186e1588 | V -> failed validation (--case selects by function name, not case file) |
| 2 | R1 | implementer | sonnet | agent aa52b8201186e1588 | V -> accepted |

## Correction round 1 (planner)

Validated attempt 1: the harness, the fixture, the sandbox guard and the smoke case are accepted. The guard was re-verified independently by the orchestrator (`t_sandbox_guard` with an out-of-sandbox `HOME` -> `ERROR: ... HOME escaped the sandbox`, exit 1). One blocking defect:

1. **`--case <name>` must select a case *file*, not a `case_*` function.** This stage's step 2 specifies "run only the named case file, repeatable", and the later stages of this plan invoke the suite as `tools/test.sh --case install --case verify`, `--case remove --case reinstall`, and `--case update` -- i.e. the basename of `tools/test/<name>.sh`. Today `--case smoke` fails with `unknown case: smoke` and only `--case case_smoke` works, which will break every later stage.
   - Make `--case <name>` accept the case-file basename (with or without the `.sh` suffix) and run every `case_*` function that file defines, in sorted order.
   - Keep accepting an individual `case_*` function name as well, so a single case can still be isolated during development. Resolve a name as a file first, then as a function; an argument matching neither is still `fatal` + exit `1`.
   - `--case` remains repeatable, and the order of execution stays deterministic.
2. **Update `--help` accordingly**: say that `--case` takes a case-file name (or a single `case_*` function), and keep listing the discovered cases. Consider grouping the listing by file so the accepted names are visible.
3. Re-run the evidence afterwards and append it: `--help` (exit 0), `--bogus` (exit 1), `--case smoke` (exit 0, runs the smoke case), `--case case_smoke` (exit 0), `--case nope` (exit 1), and the full `tools/test.sh` run (exit 0).

Do not change anything else: no new fixture options, no assertion changes, no edits outside `tools/test.sh` (and `tools/test/lib.sh` only if the selection logic genuinely belongs there).

## Correction round 1 — implementation

- Change confined to `tools/test.sh`; `tools/test/lib.sh` untouched — the case-file/function selection logic is the runner's own CLI concern, not a helper other consumers need.
- `t_source_case_files` now also builds `T_CASE_MAP`: for each discovered case file it snapshots `declare -F`'s `case_*` names before and after sourcing that one file (`grep -vFxf` against the "before" set via process substitution), sorts the new names, and records `"<file-basename-without-.sh>: <fn1> <fn2> ..."`. One line per file, in glob-discovery order.
- Added `t_case_functions_for_file <base>` (an `awk -F': '` lookup into `T_CASE_MAP`) and `t_resolve_case <name>`, which strips a trailing `.sh`, tries the file map first, and falls back to an exact match against `$ALL_CASES` (a single `case_*` function name) — anything matching neither returns 1 with no output, which the caller turns into `fatal "unknown case: $c"` (exit 1).
- The `--case` CLI loop no longer collects raw case names into `RUN_CASES` directly: each `--case <name>` argument is resolved via `t_resolve_case` at the point it's read (after `t_source_case_files`/`$ALL_CASES` are populated), and unresolved names abort immediately. Multiple `--case` arguments still accumulate, each contributing the function(s) it resolves to, in the order given; functions within one file run in sorted order (per `T_CASE_MAP`'s construction).
- `usage()`/`--help` rewritten: describes `<name>` as "a case-file basename under tools/test/ (with or without \".sh\"), running every case_* function that file defines, or a single case_* function name, to isolate one case", and the discovered-cases listing is now grouped by file (`t_source_case_files` then dumps `T_CASE_MAP`, e.g. `  smoke: case_smoke`).
- Verified with a throwaway two-function probe file (`tools/test/zz_multi.sh`, defining `case_multi_a`/`case_multi_b`, removed before finishing — never left in the tree) that `--case zz_multi` runs both functions in sorted order, and that `--case zz_multi --case smoke` (a case-file name mixed with an existing case-file name) runs all three in argument order. `git status --porcelain` after cleanup showed only the intended `tools/test.sh` (modified) and `tools/test/` (new, untracked) — no probe leftovers.
- Evidence (re-run after the fix):
  - `bash tools/test.sh --help` → exit 0; "Discovered cases (file: functions):" now lists `  smoke: case_smoke`.
  - `bash tools/test.sh --bogus` → `ERROR: unknown flag: --bogus (see --help)`, exit 1.
  - `bash tools/test.sh --case smoke` → resolves the file, runs `case_smoke`, 20/20 ok, exit 0.
  - `bash tools/test.sh --case case_smoke` → resolves the bare function name (file lookup misses, function fallback hits), same result, exit 0.
  - `bash tools/test.sh --case nope` → `ERROR: unknown case: nope (see --help)`, exit 1.
  - `bash tools/test.sh --case smoke.sh` (extension included) → same as `--case smoke`, exit 0.
  - `bash tools/test.sh` (no `--case`, full run) → `case_smoke` passes 20/20, exit 0.
  - All `/tmp/ai-tools-test.*` sandboxes from this round's runs were removed afterward.
- Nothing outside `tools/test.sh` was changed; no new fixture options or assertions were added, per the correction's scope.

Status: V
