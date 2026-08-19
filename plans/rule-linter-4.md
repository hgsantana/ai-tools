# Stage 4: File format checks

## Objective

Enforce the size caps and the constraints that break an installation silently on someone else's machine: the 8,000-character instructions cap, the 1,000-character wrapper cap, PowerShell BOM, ASCII CMD shims, line endings, and executable bits.

## Files

- Modify: `tools/lint.sh` — add the format checks

## Steps

1. **Check — instructions cap (rule 3)**: `USER-AGENTS.md` is at most **8,000 characters** — the self-imposed limit set in stage 2, tighter than any harness constraint. Count characters (`wc -m` under a UTF-8 locale), not bytes: the file holds em dashes and accented text, and `wc -c` overcounts by roughly 34 bytes today, which would eventually reject a legal file. Report the current count and the headroom on success, so the number is visible before it becomes a problem.
2. **Check — wrapper cap (rule 6)**: every file under `agents/<harness>/` is at most **1,000 characters**, frontmatter included. Report the largest wrapper and its headroom on success; it is the one that will breach first when a description grows.
3. **Check — PowerShell BOM (rule 26)**: every `scripts/powershell/*.ps1` starts with `ef bb bf`. Windows PowerShell 5.1 reads a BOM-less file as ANSI, where a single em dash closes a string and breaks the script.
4. **Check — CMD is pure ASCII (rule 26)**: `tr -d '\000-\177' < f | wc -c` returns `0` for every `scripts/cmd/*.cmd`. A BOM there is executed as a command. Use this byte-class form rather than a locale-dependent `grep`, which behaves differently on BSD and GNU.
5. **Check — line endings (rule 26)**: read `git ls-files --eol` rather than reimplementing the `.gitattributes` resolution — the index side must be `lf` for every text file, and the working-tree side must match the declared `eol=` attribute. Assert that `.cmd` files declare `eol=crlf` and shell/PowerShell files declare `eol=lf`.
6. **Check — executable bits (rule 26)**: `git ls-files -s` reports mode `100755` for `scripts/shell/*.sh`, `scripts/powershell/*.ps1`, and `tools/lint.sh`. `.cmd` shims are not required to be executable and must not be reported.
7. **Check — no secrets or binaries in shipped paths**: no file under `agents/`, `skills/`, `scripts/`, or `tools/` is non-text. Cheap, and it guards the one thing a review would miss.

## Tests

Throwaway copy, one injected violation per check, evidence in the Implementation log: pad `USER-AGENTS.md` past the cap; strip a BOM; add an em dash to a `.cmd`; clear an executable bit.

## Acceptance criteria

- [ ] The instructions check counts characters, reports count and headroom, and fails only above 8,000
- [ ] The wrapper check reports the largest wrapper and fails only above 1,000
- [ ] BOM, ASCII, EOL, and mode checks pass on the current tree and fail on each injected violation
- [ ] The EOL check reads `git ls-files --eol` instead of parsing `.gitattributes`
- [ ] `.cmd` files are never reported for a missing executable bit

## Commit

Suggested message: `chore(tools): check size caps, encodings and line endings`

## Dependencies

- Requires stages: 3
- Parallel-safe with: none

## Implementation log

Added to `tools/lint.sh`: `utf8_locale`/`char_count` helpers and seven checks —
`check_instructions_cap`, `check_wrapper_cap`, `check_powershell_bom`,
`check_cmd_ascii`, `check_line_endings`, `check_executable_bits`,
`check_no_binaries` — wired into the Run section and documented in `--help`.

Baseline (current tree, run from the repo root): `done: 498 ok, 0 skipped, 0
warnings`, exit `0` (up from 337 ok before this stage's checks; +161 ok lines,
one per file/wrapper newly evaluated). Reported cap numbers on the clean tree:

- `ok: USER-AGENTS.md within cap: 6592/8000 chars (headroom 1408)`
- `ok: largest wrapper: agents/gemini/maintainer-ai-tools.md (964/1000, headroom 36)`

All negative-evidence tests below ran in a throwaway clone (`git clone
/home/wsl/.ai-tools <scratch>/lintcheck`, then the updated `tools/lint.sh`
copied in and committed there so `git ls-files`-based checks read that
repo's own index) under
`/tmp/claude-1000/-home-wsl--ai-tools/c881ae73-747e-40f3-a416-f996d4a11717/scratchpad`.
Each violation was injected, checked, then reverted before the next; the
clone ended back at `498 ok, 0 skipped, 0 warnings`, exit `0`, with a clean
`git status`/`git diff` before being deleted.

1. **Instructions cap**: appended 2000 `x` characters to `USER-AGENTS.md`
   (6592 -> 8592 chars). Produced `WARN: USER-AGENTS.md exceeds 8000 chars:
   8592 (over by 592)`; run totals `497 ok, 0 skipped, 1 warnings`, exit `2`.
2. **PowerShell BOM**: stripped the leading 3 bytes from
   `scripts/powershell/lib.ps1`. Produced `WARN: PowerShell file missing BOM
   (ef bb bf): .../scripts/powershell/lib.ps1`; other five `.ps1` files still
   `ok`; totals `497 ok, 0 skipped, 1 warnings`, exit `2`.
3. **CMD ASCII**: appended a UTF-8 em dash (`\xe2\x80\x94`) plus CRLF to
   `scripts/cmd/install.cmd`. Produced `WARN: CMD file has non-ASCII byte(s):
   .../scripts/cmd/install.cmd (3)`; other four `.cmd` files still `ok`;
   totals `497 ok, 0 skipped, 1 warnings`, exit `2`.
4. **Executable bit**: `chmod -x scripts/shell/lib.sh` then `git add` (mode
   only registers in `git ls-files -s` once staged — a bare filesystem chmod
   without staging left the index mode unchanged, confirming the check reads
   the git-tracked mode as specified, not raw `stat`). Produced `WARN:
   executable bit missing (mode: 100644): .../scripts/shell/lib.sh`; totals
   `497 ok, 0 skipped, 1 warnings`, exit `2`. `.cmd` files never appear in
   this check's file list, confirmed by grepping its output.
5. **Line endings**: converted `scripts/shell/verify.sh` to CRLF in place and
   staged it. `git ls-files --eol` showed `i/lf w/crlf attr/text eol=lf`.
   Produced `WARN: working-tree line endings mismatch: scripts/shell/verify.sh
   (w/crlf, wants eol=lf)`; totals `497 ok, 0 skipped, 1 warnings`, exit `2`.
6. **Wrapper cap** (stage's own extra check, exercised alongside the required
   four): appended 100 `x` characters to `agents/gemini/maintainer-ai-tools.md`
   (964 -> 1064 chars). Produced `WARN: wrapper exceeds 1000 chars:
   .../agents/gemini/maintainer-ai-tools.md (1064)` and `ok: largest wrapper:
   ... (1064/1000, headroom -64)`; also tripped the pre-existing wrapper-body
   check as an expected side effect of editing wrapper text; totals `495 ok,
   0 skipped, 3 warnings`, exit `2`.

`bash -n tools/lint.sh` passes. `shellcheck` is not installed in this
environment, so it could not be run locally; CI runs it per the base plan.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | a1ca452ce6a576bc1 | V -> accepted |
