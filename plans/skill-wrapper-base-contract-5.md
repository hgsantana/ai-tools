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
