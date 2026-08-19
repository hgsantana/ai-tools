# Stage 5: Installation scripts and process docs

## Objective

Teach `verify` about the new files: `skills/SKILL-CONTRACT.md` and one base per skill must exist in the clone, exactly as it already checks `agents/SUBAGENT-CONTRACT.md` and every agent base. A wrapper whose pointers dangle is a silently broken skill, and today nothing would report it. Shell is canonical, PowerShell mirrors it, and the README process sections change in the same commit (rule 24).

## Files

- Modify: `scripts/shell/lib.sh` — `verify_install()`: add the skill contract and skill base checks
- Modify: `scripts/powershell/lib.ps1` — the mirrored checks in the verification function (around the existing `SUBAGENT-CONTRACT` / `agent base` block)
- Modify: `README.md` — Installation step 8 (*Verify*), which Update step 5 and Reinstallation step 4 inherit by reference

## Steps

1. **`scripts/shell/lib.sh`, `verify_install()`** — directly after the existing `agents/SUBAGENT-CONTRACT.md` and agent-base loop, add the symmetric pair:

   ```sh
   if [ -f "$AI_TOOLS/skills/SKILL-CONTRACT.md" ]; then ok "skill contract: $AI_TOOLS/skills/SKILL-CONTRACT.md"
   else warn "missing skill contract: $AI_TOOLS/skills/SKILL-CONTRACT.md — agent-backed skill wrappers point at it before their base"; fi

   for p in "$AI_TOOLS/skills"/*-ai-tools; do
     [ -d "$p" ] || continue
     name=$(basename "$p")
     if [ -f "$AI_TOOLS/skills/$name.md" ]; then ok "skill base: $AI_TOOLS/skills/$name.md"
     else warn "missing skill base: $AI_TOOLS/skills/$name.md — the wrapper $p/SKILL.md points at it"; fi
   done
   ```

   `p` and `name` are already declared in the function's `local` list — reuse them, declare nothing new. Keep it in the clone-side block (before the per-harness loop): these files live in `$AI_TOOLS` and are never installed.
2. **`scripts/powershell/lib.ps1`** — the same two checks, in the same position, in the file's own idiom (`Test-Path`, `Ok`, `Warn`, `Get-ChildItem -Directory -Filter '*-ai-tools'`). UTF-8 **with BOM** must survive the edit (rule 26).
3. **Do not touch** `install_skills` / `Install-Skills`, `remove_skills` / `Remove-Skills`, or the per-harness verify loop. Their globs are `skills/*-ai-tools` with a directory guard (`[ -d ]`, `-Directory`), so the new `skills/<name>.md` and `skills/SKILL-CONTRACT.md` are excluded already — the wrapper directory stays the only installed unit, and the base is reached through the hardcoded `$HOME/.ai-tools` path (rule 21). Record this in the stage log rather than "fixing" anything.
4. **`scripts/cmd/*.cmd`** — no change: the shims only delegate to PowerShell (rule 23). Confirm and log it.
5. **README Installation step 8** — extend the *Verify* sentence to: "…`agents/SUBAGENT-CONTRACT.md`, `skills/SKILL-CONTRACT.md`, and every agent and skill base exist at the pinned path…". Update steps 5–6 wording only if it still implies a skill is one file.
6. Run `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` and `scripts/shell/verify.sh --dry-run`, then `scripts/shell/verify.sh` on this machine.

## Tests

- `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` — clean (CI runs exactly this).
- `"$HOME/.ai-tools/scripts/shell/verify.sh"` — reports `skill contract: …` once and `skill base: …` once per skill directory, and exits `0` on an intact install.
- Negative check, without mutating the tree: `AI_TOOLS=<copy of the clone with skills/az-ai-tools.md removed> scripts/shell/verify.sh` (or a temporary `git stash` of that one file) must emit `missing skill base` and exit `2`.
- PowerShell parity is reviewed by reading, not executed (no Windows host in this repository's CI); `file scripts/powershell/lib.ps1` still reports a BOM.

## Acceptance criteria

- [ ] `verify` reports the skill contract and one skill base per skill directory, on both shell and PowerShell
- [ ] A missing skill base or contract produces a warning and exit `2`, never a hard failure (rule 25)
- [ ] `install`/`remove` behaviour is unchanged and no new file is installed into a harness root
- [ ] README Installation step 8 names the two new checks
- [ ] `shellcheck` clean; `tools/lint.sh` exits `0`

## Commit

Suggested message: `feat(scripts): verify the skill contract and every skill base`

## Dependencies

- Requires stages: 2, 3, 4 (the files it verifies must exist)
- Parallel-safe with: none

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Edited `scripts/shell/lib.sh`, `verify_install()`: inserted the skill-contract check and the per-skill `skills/$name.md` base loop directly after the existing `agents/SUBAGENT-CONTRACT.md` + agent-base loop, before the user-overlay check. Reused the already-`local`-declared `p`/`name`; no new locals added.
- Edited `scripts/powershell/lib.ps1`, `Verify-Install`: inserted the mirrored `SKILL-CONTRACT.md` `Test-Path` check and a `Get-ChildItem -Directory -Filter '*-ai-tools'` loop over `skills/<name>.md`, same position, same idiom as the existing agent-base block. Not executed (no `pwsh`/`powershell` on this machine — confirmed absent again before editing); reviewed by reading only.
  - BOM check after edit: `od -c scripts/powershell/lib.ps1 | head -1` → `0000000 357 273 277   #       a   i   -   t   o   o   l   s       s   h` — BOM (357 273 277 = EF BB BF) intact.
- Step 3 (install/remove skills untouched): read `install_skills`/`remove_skills` in `scripts/shell/lib.sh` (lines 353-358, 513-518) and `Install-Skills`/`Remove-Skills` in `scripts/powershell/lib.ps1` (lines 334-339, 484-489). Both glob `skills/*-ai-tools` with a directory guard (`[ -d ]` / `-Directory`), so `skills/SKILL-CONTRACT.md` and every `skills/<name>.md` are excluded by construction. No change made, per the stage's "confirm and log, change nothing" instruction.
- Step 4 (`scripts/cmd/*.cmd`): read `install.cmd`, `reinstall.cmd`, `remove.cmd`, `update.cmd`, `verify.cmd`. Each is a thin shim that only locates `pwsh`/`powershell` and delegates to the matching `scripts\powershell\*.ps1` — no skill/agent logic of its own. No change made.
- Edited `README.md` line 245 (Installation step 8, *Verify*): added `skills/SKILL-CONTRACT.md` and generalized "every agent base" to "every agent and skill base". Reviewed Installation steps 5-6 (lines 242-243): step 6 already describes skills as a directory (`skills/*-ai-tools` directory link), so no wording implying "one file" was present; left unchanged. Update step 5 and Reinstallation step 4 both reference the Installation checks by pointer (`## Update` step 5 "Verify — the Installation checks", `## Reinstallation` step 4/5 similarly), so they inherit the updated wording without separate edits.
- Did not touch the README version line or `tools/lint.sh` (reserved for stage 6).

### Test evidence

- `shellcheck` is not installed on this machine (`which shellcheck` → exit 1). The stage's shellcheck run (`shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh`) could not be executed here; it remains pending in CI, which runs this exact command per the stage note.
- `bash -n scripts/shell/lib.sh` → syntax OK. `bash -n scripts/shell/verify.sh` → syntax OK.
- `scripts/shell/verify.sh --dry-run`: verify.sh has no `--dry-run` option (`DRY_RUN` is only set by `install.sh`/`update.sh`/`remove.sh`/`reinstall.sh`; verify.sh's own DRY_RUN-gated branch in `verify_install()` would just skip all checks, which is not useful here and not exposed as a flag on this script). Ran `scripts/shell/verify.sh --dry-run` literally and got `ERROR: unknown option: --dry-run`, exit 1 — recorded here rather than silently substituted.
- Isolated positive/negative runs, without mutating the tracked worktree: copied the worktree (excluding `.git`) into `/tmp/claude-1000/-home-wsl--ai-tools/3b6488c4-9b6b-48b5-9e1d-dddabc81c766/scratchpad/ai-tools-test`, added a stub `.git/` directory so `require_clone` accepts it, then ran `AI_TOOLS=<scratch> <scratch>/scripts/shell/verify.sh`.
  - Intact copy: printed `ok: skill contract: <scratch>/skills/SKILL-CONTRACT.md` once and `ok: skill base: <scratch>/skills/<name>.md` once per skill directory (9 skills: az, gc, gh, orchestrator, planner, reinstall, remove, update, vibe-ai-tools). Summary line `done: 125 ok, 0 skipped, 6 warnings`, exit 2 — the 6 warnings are pre-existing `instructions link points elsewhere` findings (the real harness links on this machine point at `$HOME/.ai-tools`, not the scratch copy), unrelated to this stage's checks.
  - Negative check 1: removed `skills/az-ai-tools.md` from the scratch copy, re-ran with `--harnesses claude-code`: emitted `WARN: missing skill base: <scratch>/skills/az-ai-tools.md — the wrapper <scratch>/skills/az-ai-tools/SKILL.md points at it`, all other skill bases still `ok`, exit 2.
  - Negative check 2: also removed `skills/SKILL-CONTRACT.md`, re-ran: emitted `WARN: missing skill contract: <scratch>/skills/SKILL-CONTRACT.md — agent-backed skill wrappers point at it before their base`.
  - Scratch dir removed after the runs (`rm -rf <scratch>/ai-tools-test`); the tracked worktree was never touched by these runs (`AI_TOOLS` pointed only at the scratch copy).
- `bash tools/lint.sh` (run against the real worktree, read-only lint, not the install/remove scripts): `done: 508 ok, 1 skipped, 0 warnings`, exit 0. The one skip is the pre-existing `SKIP: version bump check needs --base <ref> (the lint workflow supplies it)`, unrelated to this stage.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | a49c56dbda22bf0f0 | V → accepted |

**Status: V**

### Planner validation (attempt 1)

Diff inspected. `verify_install()` gains the skill-contract check and the per-skill-directory base loop, placed in the clone-side block right after the agent-base loop and before the user-overlay check; `p` and `name` reuse the function's existing `local` list, nothing new declared. `scripts/powershell/lib.ps1` mirrors both checks in the same position and the file's own idiom (`Test-Path -LiteralPath`, `Ok`/`Warn`, `Get-ChildItem -Directory -Filter '*-ai-tools'`); BOM intact (`od -c` first bytes `357 273 277`). Both use `warn`, so a miss yields exit 2, never a hard failure. `install`/`remove` globs untouched, `scripts/cmd/*.cmd` untouched. README Installation step 8 names both contracts and "every agent and skill base". `tools/lint.sh` exit 0.

Not verified here, and stated as such rather than claimed: **PowerShell was not executed** (no `pwsh`/`powershell` runtime on this host) — the mirror is reviewed by reading only; and **`shellcheck` is not installed on this host**, so `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` is pending CI. `bash -n` on both edited shell files is clean, and the shell verify was exercised positively and negatively against a scratch copy.

**Status: F**
