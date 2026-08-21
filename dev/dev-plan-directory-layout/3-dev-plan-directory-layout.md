# Stage 3: Discovery, archival and Mode B in dev-ai-tools

## Objective

`skills/dev-ai-tools.md` is the heaviest consumer of the plan layout: routing,
intake, context isolation, fix files, archival, reentry and Mode B all name
paths. Update every one of them, and take the two simplifications the new layout
makes available — discovery stops being pattern subtraction, and archival
becomes a single directory move.

## Files

- Modify: `skills/dev-ai-tools.md` — *Routing*, *Branch per plan*, *Plan intake*, *Context isolation*, *Planner obligations*, *Plan archival*, *Mode A*, *Mode B*

## Steps

Work through the file in order. Every edit is a path or pattern change except
steps 4 and 7, which also simplify the rule the path expressed.

1. **Routing table** (lines 37–39):
   - Row 1 unchanged: all base plans under `dev/`.
   - Row 2: `dev/<file>.md …` becomes `dev/<slug>/ …` — a dispatch names plan
     directories now, not base files. Keep "Named base plans only".
   - Row 3: `dev/finished/<slug>/` becomes `dev/tmp/finished/<slug>/`.

2. **Branch per plan**, line 49. This is the pre-existing typo the rename makes
   dangerous — `dev/<slug>` is now a real plan directory, not an obviously wrong
   branch name. Correct it to the branch it means:

   > - Mode B: same rule per brief — create `plan/<slug>` before spawning `implementer-ai-tools`.

3. **Branch per plan**, line 52: the review patch path follows the rename —
   `dev/wip/<slug>-review.patch` becomes `dev/tmp/<slug>-review.patch`. Change
   only the path; the surrounding rule about how the patch is produced stays
   verbatim.

4. **Plan intake**, line 72. Replace the glob with the directory:

   > Before dispatching a plan, load its base file and every stage and fix file
   > of that plan (`dev/<slug>/`) in full — the whole plan directory is under
   > `dev/` (*Plan archival*).

   Line 75 becomes `Leave unrelated plans and dev/tmp/** unread`.

5. **Context isolation**, line 84:

   > 2. The single assigned stage file `dev/<slug>/<n>-<slug>.md` (or, for
   > decomposed corrections after `R1`, only the specific fix file
   > `dev/<slug>/F<m>-<slug>.md`).

6. **Planner obligations**, line 150: fix files become
   `dev/<slug>/F<m>-<slug>.md`. The rest of the bullet is unchanged.

7. **Plan archival** (lines 156–166) — the largest edit:

   - Line 156, the set definition. A plan's set *is* its directory now, which is
     what makes "the set travels as one" structural rather than a discipline:

     > A plan's **set** is its directory `dev/<slug>/` — the base plan
     > `0-<slug>.md` plus every `<n>-<slug>.md` stage and `F<m>-<slug>.md` fix
     > file in it. The set is one unit and travels as one directory, whatever
     > its stages' statuses, until the plan is over. Move a plan only when every
     > stage is terminal (`F` or `E`).

   - Line 159: `dev/finished/` → `dev/tmp/finished/`. Meaning unchanged — the
     destination is ignored, so the move is a deletion from version control.
   - Line 160: replace the multi-file move with the directory move:

     > Move the plan directory in one operation to `dev/tmp/finished/<slug>/`;
     > nothing of that plan is left under `dev/`.

     A single `git mv dev/<slug> dev/tmp/finished/<slug>` is now atomic by
     construction; note that.
   - Line 161: unchanged (no path).
   - Line 162: unchanged (its `dev/` mention stays true).
   - Line 163: `dev/finished/**` → `dev/tmp/finished/**`.
   - Line 164: the reentry resolution becomes exactly
     `dev/tmp/finished/<slug>/0-<slug>.md`.
   - Line 165: unchanged — the restore still moves the set back into `dev/`,
     now as a directory.
   - Line 166: the one-set-per-slug refusal keys on the directory:
     "Refuse the same way when `dev/<slug>/` already exists — one set per slug."

8. **Mode A**, step 2 (line 172). The whole exclusion list collapses:

   > 2. Discover base plans: `dev/*/0-*.md` (every directory under `dev/` except
   > `dev/tmp/`). Execute a stage or fix only with its base.

9. **Mode A**, step 3 (line 173). Restate the ignore policy as the single rule:

   > 3. Stop if no plans exist. Preserve the plan ignore policy: a plan
   > directory `dev/<slug>/` stays trackable, and `dev/tmp/` — the one root for
   > generated state, holding `finished/`, `vibe/` and ad-hoc briefs — stays
   > ignored. Outside a git repository, plans live in `$HOME/.ai-tools-plans`
   > (Windows: `%USERPROFILE%\.ai-tools-plans`).

10. **Mode B** (lines 189, 191) and the ledger note (line 222): all three name
    `dev/wip/<slug>-…` and follow the rename to `dev/tmp/<slug>-…`. Line 187
    (deriving the slug) names no path — leave it. Change paths only; the rules
    themselves are unaffected.

11. Leave line 3 (`Executing accepted plans under dev/`) alone. It stays true,
    and it is duplicated verbatim as the one-sentence description in
    `skills/dev-ai-tools/SKILL.md`; editing one without the other desyncs the
    pair for no gain.

## Tests

No automated test covers skill prose. Verification is mechanical:

```bash
cd "$HOME/.ai-tools"
grep -nE 'dev/<slug>\.md|dev/<slug>-|dev/finished|dev/vibe|dev/wip|dev/\*\.md' skills/dev-ai-tools.md \
  && echo "STALE REFERENCE (bad)" || echo "clean (good)"
grep -n 'create `dev/<slug>`' skills/dev-ai-tools.md && echo "TYPO REMAINS (bad)" || echo "typo fixed (good)"
tools/lint.sh
```

## Acceptance criteria

- [ ] Routing row 2 names plan directories; row 3 points at `dev/tmp/finished/<slug>/`
- [ ] Line 49 says `plan/<slug>`, not `dev/<slug>`
- [ ] Intake and context isolation name `dev/<slug>/` and `dev/<slug>/<n>-<slug>.md`
- [ ] Fix files are `dev/<slug>/F<m>-<slug>.md` in both places that name them
- [ ] *Plan archival* defines the set as the directory and the archive as one directory move to `dev/tmp/finished/<slug>/`
- [ ] Reentry resolves to exactly `dev/tmp/finished/<slug>/0-<slug>.md`; the refusal keys on `dev/<slug>/`
- [ ] Mode A step 2 discovers `dev/*/0-*.md` excluding `dev/tmp/`, with no other exclusions
- [ ] Mode A step 3 states the ignore policy as `dev/tmp/` alone
- [ ] Mode B paths and the review patch path all read `dev/tmp/`
- [ ] No occurrence of `dev/wip` remains in the file
- [ ] `tools/lint.sh` reports no new finding

## Commit

Suggested message: `docs(skills): discover and archive plans by directory`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 4

## Implementation log

(Append-only log added by implementers and planner during execution.)

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
