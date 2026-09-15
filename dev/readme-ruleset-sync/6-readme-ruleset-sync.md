# Stage 6: Cross-check rule citations and bump the version

## Objective

Verify that every `rule N` citation in the repository names the rule text it means, using the final README from stages 1-5. Fix the known wrong citations (base plan findings 46-48) and any that stages 1-5 introduced. Bump the version once for the branch (finding 45).

## Files

- Create: none tracked. The evidence goes to untracked `dev/tmp/readme-ruleset-sync-citations.md`.
- Modify:
  - `README.md`: version line, plus any citation the cross-check finds wrong
  - `scripts/test/install.sh`: comments only
  - `scripts/test/update.sh`: comments only
  - `scripts/lint.sh`: usage or comment citations only, if the cross-check finds one wrong
  - `.gitattributes` or `ROADMAP.md`: only if the cross-check finds a wrong citation
- Remove: none

## Steps

1. **Inventory.** In a scratch clone of the committed branch tip, run:

   ```bash
   git -C "$V" grep -nE '[Rr]ules? [0-9]+([–-][0-9]+)?(, [0-9]+([–-][0-9]+)?)*' -- README.md ROADMAP.md docs .gitattributes scripts
   ```

   Also confirm that `git -C "$V" grep -nE '[Rr]ules? [0-9]' -- skills USER-AGENTS.md` prints nothing.
2. **Cross-check.** Write `dev/tmp/readme-ruleset-sync-citations.md` as a table with columns path:line, citation, claim at that line, cited rule's topic (from the final README), and verdict (ok or wrong, with the replacement). Expand every range and list. Rule topics:
   - 1 source of truth; 2 README precedence; 3 USER-AGENTS artifact and cap; 4 version and alpha policy;
   - 5 skill layout; 6 frontmatter and description; 7 `-ai-tools` naming; 8 concision; 9 XML grammar and citations; 10 language; 11 impact disclosure;
   - 12 physical copies; 13 no overwrite; 14 no foreign removal; 15 idempotent skip and report; 16 clone location; 17 `$HOME/AGENTS.md`;
   - 18 platform and `lib.sh`; 19 `scripts/shell` canonical; 20 run to completion, flags, dry-run, exit codes; 21 modes and LF;
   - 22 `dev/` work state; 23 plan-ai-tools; 24 dev, vibe, campaign sequence; 25 substance on disk.
3. **Apply known fixes.**
   - `scripts/test/install.sh:38`: "Rule 13: running install.sh twice changes nothing" → "Rule 15: ...".
   - `scripts/test/install.sh:59`: "Rules 13, 15, 18:" → "Rules 13, 15, 20:".
   - `scripts/test/update.sh:145`: "Newly shipped content (rule 13)" → "Newly shipped content (README Update, step 4)". Keep the dashed comment ruler's width.
4. Apply every other "wrong" verdict from step 2, in comments or prose only. A wrong citation inside `skills/` becomes an open question, and that file is not edited.
5. **Version.** In `README.md` line 3, change `0.0.50-ALPHA` to `0.0.51-ALPHA`, unless the branch base already moved past 0.0.50. In that case use the base version's next patch.

## Tests

Follow the verification protocol in the base plan, with declared files `README.md`, `scripts/test/install.sh`, `scripts/test/update.sh`, and any other file changed in step 4.

- Scratch clone: `scripts/lint.sh` exits 0 with 0 warnings, and the stage 4 rule-citations check is ok.
- Scratch clone, after the probe commit: `scripts/lint.sh --base "$(git -C /home/wsl/.ai-tools rev-parse plan/user-agents-skills-only)"` exits 0 and prints "version bumped for shipped content change: 0.0.50-ALPHA -> 0.0.51-ALPHA".
- `scripts/test.sh` exits 0 with the same case count as the baseline (305 ok). The test changes are comments only.
- `git diff --stat` for the stage shows only comment and prose lines. `git diff -G'^[^#]' -- scripts/test` shows no code change: only lines starting with `#` changed.
- shellcheck shows only SC1071.
- Every row in `dev/tmp/readme-ruleset-sync-citations.md` has verdict "ok" after the fixes.

## Acceptance criteria

- Every `rule N` citation in `README.md`, `ROADMAP.md`, `docs/`, `.gitattributes`, and `scripts/` names the rule whose text covers its claim. The evidence table is on disk.
- Base plan findings 45-48 are applied.
- No citation to a rule number exists in `skills/` or `USER-AGENTS.md`.
- The README version is bumped exactly once on the branch, and `lint.sh --base` against the base branch passes.
- No change under `skills/`. No behaviour change in any script.

## Commit message

```
docs: fix rule citations and bump version to 0.0.51-ALPHA
```

## Dependencies

Stage 5, or stage 4 if stage 5 is dropped.

## Implementation log

- Version bump: `README.md:3` `0.0.50-ALPHA` -> `0.0.51-ALPHA` (finding 45; first bump on this branch, base branch is also at 0.0.50-ALPHA).
- Known-wrong citations fixed exactly as specified (findings 46-48):
  - `scripts/test/install.sh:38`: "Rule 13: running install.sh twice changes nothing on the second run." -> "Rule 15: ...".
  - `scripts/test/install.sh:59`: "Rules 13, 15, 18: a foreign directory..." -> "Rules 13, 15, 20: ...".
  - `scripts/test/update.sh:145`: section header `# --- Newly shipped content (rule 13) ---` -> `# --- Newly shipped content (README Update, step 4) ---`; dashed ruler width kept at 81 columns (confirmed identical length before/after).
- One additional wrong citation found by the cross-check (not in the base plan's known list): `scripts/lint.sh:46`, the skill-layout check's usage-text citation "(rule 5)" -> "(rules 5, 11)", to match the equivalent check description at `README.md:156` (rule 11 is the one naming the offer table's "Description"/"Execution" column pair that this check tests).
- Evidence table written to `dev/tmp/readme-ruleset-sync-citations.md`: every citation hit from the inventory command cross-checked path:line by path:line against the final README rule text (topics 1-25), verdict "ok" or "wrong" with replacement.
- Coverage check: re-ran the stage's inventory command (`git grep -nE '[Rr]ules? [0-9]+([–-][0-9]+)?(, [0-9]+([–-][0-9]+)?)*' -- README.md ROADMAP.md docs .gitattributes scripts`, 127 hit lines) and diffed its path:line set (grouped table rows expanded, e.g. `scripts/lint.sh:351,367,371,376` -> 4 entries) against the evidence table's path:line column: every current hit is covered by a table row, with zero uncovered lines. The only entry present in the table but absent from the current grep output is `scripts/test/update.sh:145`, which is expected: that citation was rewritten from a rule number to "README Update, step 4" and no longer matches the rule-number pattern, so it correctly drops out of the live inventory while the table still documents the before/after fix.
  - Confirmed `git grep -nE '[Rr]ules? [0-9]' -- skills USER-AGENTS.md` prints nothing (exit 1): no rule-number citation outside README/ROADMAP/docs/.gitattributes/scripts.
- Confirmed `git diff -- scripts/test` changes only comment-line content (both hunks in `scripts/test/install.sh` and the header line in `scripts/test/update.sh` touch only `#`-prefixed text; surrounding code is unchanged context).
- No change under `.gitattributes`, `ROADMAP.md`, or `docs/`: the cross-check found their existing citations already correct.
- Set base plan Status table row 6 to `V`.
