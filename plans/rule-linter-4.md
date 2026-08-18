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
