# Stage 1: Single-file skills

## Objective

Each of the ten skills becomes exactly `skills/<name>/SKILL.md`: frontmatter (unchanged keys) plus the former base's workflow, with the new continue gate inlined into the seven planner-gated skills and the former `MAINTAINER.md` inlined into the three maintainer skills. Then delete every skill base, `skills/SKILL-CONTRACT.md`, and `skills/MAINTAINER.md`.

## Files

- Modify: `skills/agy-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/az-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/dev-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/gc-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/gh-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/plan-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/vibe-ai-tools/SKILL.md` — planner-gated single file
- Modify: `skills/update-ai-tools/SKILL.md` — maintainer single file, no gate
- Modify: `skills/remove-ai-tools/SKILL.md` — maintainer single file, no gate
- Modify: `skills/reinstall-ai-tools/SKILL.md` — maintainer single file, no gate
- Remove: `skills/agy-ai-tools.md`
- Remove: `skills/az-ai-tools.md`
- Remove: `skills/dev-ai-tools.md`
- Remove: `skills/gc-ai-tools.md`
- Remove: `skills/gh-ai-tools.md`
- Remove: `skills/plan-ai-tools.md`
- Remove: `skills/vibe-ai-tools.md`
- Remove: `skills/update-ai-tools.md`
- Remove: `skills/remove-ai-tools.md`
- Remove: `skills/reinstall-ai-tools.md`
- Remove: `skills/SKILL-CONTRACT.md`
- Remove: `skills/MAINTAINER.md`

Do not edit README, lint, verify, or tests in this stage.

## Steps

### 1. Planner-gated `SKILL.md` shape

Keep existing YAML frontmatter (`name`, `description`, `argument-hint`). Keep the H1 and the current one-sentence scope line.

Delete the contract paragraph and the "Your base file is …" paragraph.

Then, in this order:

1. The **Continue?** block below (identical in all seven files, except the skip sentence in plan and dev only).
2. **Stake** — the former base's Stake section, unchanged in meaning.
3. The rest of the former base from **Workflow** to the end (Boundaries included). Drop **Agent** and **Route A**. Keep **Report** where the base had it (place it after Workflow if the base had it before Workflow; do not invent a Report the base lacked). Fold any Route A mechanics that are still needed (approvals, spawning) into Workflow or Boundaries rather than leaving a Route A heading.

First line of the former bases (`> Skill base, loaded by the wrapper…`) is gone with the file; do not copy it.

### 2. Canonical **Continue?** block (copy verbatim)

```markdown
## Continue?

This skill expects this session to be the **planner** (`MODELS.md` planner cell for this harness).

Before anything is read, run, or changed, send **one** short message in the user's language:

1. The stake (**Stake** below).
2. Whether this session is the planner: read this harness's `planner` cell in `$HOME/.ai-tools/MODELS.md` and compare it with the session model.
   - They match — this session is the planner. Say so in one line.
   - They differ, or the session model is undetermined — this session is not the planner. Name the session model, or say it is undetermined, and name how to change the session model in this harness (`MODELS.md` last column).
3. Then ask: do you want to continue?
   - a) yes
   - b) no

Wait for an explicit answer. Never pick for the user.

- **No** (or anything that is not yes) — stop. Nothing is read, run, or changed.
- **Yes** — this session carries `planner-ai-tools` (base `$HOME/.ai-tools/agents/planner-ai-tools.md`; on Windows `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`) and follows **Workflow**. Announce every spawn in the user's language with the agent name. Spawn depth is one.

Proceeding on a non-planner session is the user's call. This skill never refuses over the session model.
```

**plan-ai-tools** and **dev-ai-tools** only — add this paragraph at the end of **Continue?**:

```markdown
Skip this whole section when another planner-gated skill that already passed Continue? tells you to skip this skill's gate and follow Workflow (today: vibe-ai-tools).
```

Do not add that paragraph to az, gc, gh, agy, or vibe.

### 3. Per-skill workflow edits

Take the current `skills/<name>.md` as the source. Besides dropping Agent / Route A / the source banner:

**vibe-ai-tools**

- Replace the two path references:
  - `$HOME/.ai-tools/skills/plan-ai-tools.md` → `$HOME/.ai-tools/skills/plan-ai-tools/SKILL.md`
  - `$HOME/.ai-tools/skills/dev-ai-tools.md` → `$HOME/.ai-tools/skills/dev-ai-tools/SKILL.md`
- Keep "from the heading **Workflow** to the end".
- Change "Skip that skill's gate and route offer" to "Skip that skill's **Continue?** gate".
- Drop "behind the contract's planner gate" / "The gate yes is the user's yes to **Vibe Coding mode**" wording that names the contract. The continue yes *is* the yes to Vibe Coding; say that in Workflow without naming `SKILL-CONTRACT.md`.
- Writes still stay under `dev/tmp/vibe/` and `dev/<slug>/`. Product code still by spawned `implementer-ai-tools`.

**plan-ai-tools**

- Opening: "Plan only once Continue? has a yes. Never implement under this skill."
- Drop "behind the contract's planner gate".
- Report still asks whether to implement; **Yes** still says to invoke `dev-ai-tools` (that skill will present its own Continue?).

**dev-ai-tools**

- Opening: "Implement only once Continue? has a yes."
- Drop "behind the contract's planner gate".
- Unattended / push / PR behaviour unchanged. Vibe's continue yes still covers push and PR when vibe invoked this file and told you to skip Continue?.

**az-ai-tools, gc-ai-tools, gh-ai-tools, agy-ai-tools**

- Drop "Run … only once the planner gate passes" in the lead-in; Continue? already owns that.
- Keep Stake, Workflow (rules, commands, delegated exploration), Report, Boundaries as in the current bases.

### 4. Maintainer `SKILL.md` shape (update, remove, reinstall)

Keep YAML frontmatter. Edit `description` only to drop "by dispatching implementer-ai-tools to follow this skill" / "by dispatching implementer-ai-tools to follow this skill" — the skill no longer dispatches. Keep the 500-character cap. Keep `argument-hint`.

Keep the H1 and the one-sentence scope line.

Delete the contract paragraph and the base-file paragraph.

Then:

1. **Stake** — the former base's stake, plus: surface it in the user's language in the **same** message as the first scope question. No continue gate. No route offer.
2. **Workflow** — paste `skills/MAINTAINER.md` from its heading **Scope and approvals** through **Report**, with the task name, script, and flags already specialized (do not leave "the task you were given"). Drop MAINTAINER's banner and the "Drive the scripts…" lead-in in favour of the skill's own scope line. Keep the table row that applies; omit the other two tasks' rows, or keep the full three-row table (duplication is fine; pick the full table so the three files stay aligned — **use the full three-row table** in all three files).
3. Carry the task **in this session**. Do not dispatch an agent to start it. Spawn nothing unless the inlined workflow later needs a worker (it does not today).
4. Keep Boundaries from MAINTAINER (`$HOME/AGENTS.md` untouched, idempotent scripts, etc.).

Do not leave a pointer to `skills/MAINTAINER.md` or to `skills/<name>.md`.

### 5. Delete leftovers

After every `SKILL.md` is the complete skill, delete the 10 bases, `SKILL-CONTRACT.md`, and `MAINTAINER.md`. `skills/` must contain only the ten `*-ai-tools/` directories (plus nothing else at that level except files this repo already keeps, if any — today those two shared files and the bases are the only extra). `ls skills/*.md` must be empty.

### 6. Ban leftover pointers

Grep the ten `SKILL.md` files: no `SKILL-CONTRACT`, no `MAINTAINER.md`, no `skills/<name>.md` base path (the `/SKILL.md` paths in vibe are required). No "Your base file is".

## Tests

- None that run `tools/lint.sh` (it still encodes the old wrapper). File-level:
  - `test -f skills/<name>/SKILL.md` for all ten names
  - `test ! -e skills/<name>.md` for all ten names
  - `test ! -e skills/SKILL-CONTRACT.md`
  - `test ! -e skills/MAINTAINER.md`
  - each of the seven planner-gated files contains the heading `## Continue?`
  - `update-ai-tools`, `remove-ai-tools`, `reinstall-ai-tools` do **not** contain `## Continue?`
  - `plan-ai-tools/SKILL.md` and `dev-ai-tools/SKILL.md` contain the skip-when-vibe sentence
  - `vibe-ai-tools/SKILL.md` references `skills/plan-ai-tools/SKILL.md` and `skills/dev-ai-tools/SKILL.md`

## Acceptance criteria

- [x] Ten skills, each exactly one `SKILL.md`; no skill-root `*.md`
- [x] Seven planner-gated skills share the canonical Continue? block; plan and dev also have the skip sentence
- [x] Three maintainer skills have no continue gate, inline the maintainer workflow, and do not dispatch to start
- [x] No remaining pointer at `SKILL-CONTRACT.md`, `MAINTAINER.md`, or a skill base
- [x] Frontmatter keys still a subset of `name` / `description` / `argument-hint`; descriptions still ≤ 500 characters
- [x] Former workflow rules, stakes, reports, and boundaries are present (moved, not dropped)

## Commit

Suggested message: `feat(skills): collapse each skill into a single SKILL.md`

## Dependencies

- Requires stages: none
- Parallel-safe with: none

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | gemini-3.7-flash-high | b6639e16-b7ce-400e-b15d-e3ce565d5976 | V → accepted |

## Implementation log

- Recorded session ID `b6639e16-b7ce-400e-b15d-e3ce565d5976` in the Dispatch log.
- Rewrote the 7 planner-gated skills (`skills/{agy,az,dev,gc,gh,plan,vibe}-ai-tools/SKILL.md`):
  - Preserved YAML frontmatter (`name`, `description`, `argument-hint`), H1, and initial scope lines.
  - Removed pointers to `SKILL-CONTRACT.md` and old base `.md` files.
  - Inserted canonical `## Continue?` block into all 7 skills.
  - Added the skip-when-vibe paragraph to `plan-ai-tools` and `dev-ai-tools` `Continue?` blocks.
  - Inlined Stake, Workflow, Report, and Boundaries from former bases into each `SKILL.md`.
  - In `vibe-ai-tools`, updated target paths to `skills/plan-ai-tools/SKILL.md` and `skills/dev-ai-tools/SKILL.md`, skipping `Continue?` without mentioning `SKILL-CONTRACT.md`.
- Rewrote the 3 maintainer skills (`skills/{update,remove,reinstall}-ai-tools/SKILL.md`):
  - Inlined `Stake`, `Scope and approvals`, `Source of truth` (with full 3-row task/script table), task-specialized `Workflow`, `Boundaries`, and `Report`.
  - Removed dispatching instructions, carrying tasks in this session without a continue gate or route offer.
  - Adjusted frontmatter descriptions to drop dispatch phrasing (all description lengths <= 300 characters, within 500 cap).
- Removed obsolete files: `skills/SKILL-CONTRACT.md`, `skills/MAINTAINER.md`, and all 10 `skills/<name>.md` bases. Confirmed `skills/` contains only the 10 skill subdirectories.
- Ran grep checks across all `skills/*/SKILL.md` files: 0 matches for `SKILL-CONTRACT`, `MAINTAINER.md`, `Your base file is`, or old base `.md` paths.
- Executed verification test script: all 10 `SKILL.md` files present, all 12 root `.md` files removed, `Continue?` headings present in 7 planner skills and absent in 3 maintainer skills, skip sentence verified in `plan`/`dev`, single-file skill paths verified in `vibe`, and YAML frontmatter keys/lengths validated.
- Base plan status updated to `V`.
- Planner validation: `agy` envelope status was `ERROR` (`write_to_file` artifact path after the edits). Verdict is from the tree: ten `SKILL.md` files, no skill-root `*.md`, Continue? identical across the seven (skip sentence only on plan/dev), maintainer skills have no gate, no leftover contract/base pointers. Accepted. Status `F`.
