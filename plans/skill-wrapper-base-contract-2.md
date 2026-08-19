# Stage 2: Split the five single-agent skills

## Objective

Convert `az-ai-tools`, `gc-ai-tools`, `gh-ai-tools`, `planner-ai-tools`, and `orchestrator-ai-tools` from one file each into wrapper + base, with everything shared now coming from `skills/SKILL-CONTRACT.md`. Behaviour must be identical to today for a session that follows wrapper → contract → base.

## Files

- Create: `skills/az-ai-tools.md`, `skills/gc-ai-tools.md`, `skills/gh-ai-tools.md`, `skills/planner-ai-tools.md`, `skills/orchestrator-ai-tools.md` — the five skill bases
- Modify: `skills/az-ai-tools/SKILL.md`, `skills/gc-ai-tools/SKILL.md`, `skills/gh-ai-tools/SKILL.md`, `skills/planner-ai-tools/SKILL.md`, `skills/orchestrator-ai-tools/SKILL.md` — reduced to wrapper form

## Steps

1. **Wrapper**, for each of the five: keep the existing frontmatter unchanged (`name`, `description`, `argument-hint`; every current description is 281–342 characters, inside the 500 cap — do not rewrite them), then replace the whole body with the README's canonical skill wrapper body:

   ```markdown
   # <today's H1, unchanged>

   <one sentence: the first sentence of today's scope paragraph, ending at the first full stop>

   You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
   Read it and follow it — it governs the model check, the route offer, and the route mechanics.

   Your base file is `$HOME/.ai-tools/skills/<name>.md`.
   Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
   ```

   Verify each wrapper is ≤ 2,000 characters (rule 7).

2. **Base**, for each of the five — `skills/<name>.md`, in this order:

   ```markdown
   > Skill base, loaded by the wrapper at `skills/<name>/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

   <today's scope paragraph, verbatim — the one naming the agent base path and the two routes>

   ## Agent and category

   Agent: `<agent-name>`, base `$HOME/.ai-tools/agents/<agent-name>.md` (Windows: `%USERPROFILE%\.ai-tools\agents\<agent-name>.md`). Category for the contract's model check: **planner**.

   ## Stake

   <today's `## 1. Stake` body, verbatim>

   ## Route A — dispatch

   <today's `## Route A — dispatch` bullets, verbatim, minus anything the contract now states generically — see the mapping table below>

   ## Route B — run it here

   <today's first Route B bullet, verbatim; the other two bullets are the contract's>

   ## Report

   <today's `## Report` body, verbatim>
   ```

3. **Mapping** — what each base keeps, beyond the shared text now living in the contract:

   | Skill | Agent · category | Route A specifics kept in the base | Report kept in the base |
   |---|---|---|---|
   | `az-ai-tools` | `az-ai-tools` · planner | "The agent reads freely and returns every mutation for approval… **including its cost impact**" | one line, concise tables, output by path |
   | `gc-ai-tools` | `gc-ai-tools` · planner | same as `az`, Google Cloud wording | same as `az` |
   | `gh-ai-tools` | `gh-ai-tools` · planner | today's `gh` Route A bullets, verbatim | today's `gh` Report, verbatim |
   | `planner-ai-tools` | `planner-ai-tools` · planner | "returns open questions instead of asking them… resume the same agent with them" | three bullets: report plan paths, ask whether to implement (hand off to the `orchestrator-ai-tools` skill), never implement unaccepted work |
   | `orchestrator-ai-tools` | `orchestrator-ai-tools` · planner | "spawn … with the plan or brief file paths, never their contents" and the approval list (cloud mutations, pushes, destructive or shared-state operations, the archival question of a failed stage) | one line referencing logs, diffs, and updated plan files by path |

4. **Delete nothing else.** The `## 2. Model check` and `## 3. Offer, then ask` sections and the last two `Route B` bullets disappear from all five files — they are now the contract's, byte for byte. Diff one old file against the contract before deleting, to confirm no sentence is lost.
5. Run `tools/lint.sh`.

## Tests

- `tools/lint.sh` exits `0`; specifically no *skill frontmatter*, *skill name match*, or *naming* finding.
- Textual regression, per skill: `git show HEAD:skills/<name>/SKILL.md` compared against the concatenation of the new wrapper, `skills/SKILL-CONTRACT.md`, and the new base — every instruction present before must be present in exactly one of the three, and the only intended losses are the eight duplicate copies.
- `wc -c skills/*/SKILL.md` — every wrapper ≤ 2,000 characters.
- `ls -d skills/*-ai-tools` still lists exactly the nine skill directories (the installer's glob must not pick up the new `skills/<name>.md` files).

## Acceptance criteria

- [ ] Five bases exist at `skills/<name>.md` and five wrappers carry only frontmatter, an H1, one scope line, and the two pointer paragraphs
- [ ] No wrapper exceeds 2,000 characters; no description exceeds 500
- [ ] No sentence from the pre-split files is lost: each lives in the wrapper, the contract, or the base
- [ ] Every base names its agent, its agent base path, and its category (**planner**)
- [ ] `tools/lint.sh` exits `0`

## Commit

Suggested message: `refactor(skills): split the five single-agent skills into wrapper and base`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 3, 4

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Read `skills/SKILL-CONTRACT.md`, README.md rule 7 (`### Structure and authoring`), the "Model map and wrapper authoring" section (canonical skill wrapper body, lines 132-146), and all five pre-split `skills/<name>/SKILL.md` files.
- Created five bases at `skills/az-ai-tools.md`, `skills/gc-ai-tools.md`, `skills/gh-ai-tools.md`, `skills/planner-ai-tools.md`, `skills/orchestrator-ai-tools.md`, each carrying: the top-of-file wrapper/edit-here note, the verbatim scope paragraph, an `## Agent and category` section naming the agent, its base path, and category **planner**, the verbatim `## Stake` body, a `## Route A — dispatch` section holding only the skill-specific remainder per the Files/Steps mapping table (single kept sentence for `az`/`gc`/`planner`, all three original bullets for `gh`, two kept fragments for `orchestrator`), a `## Route B — run it here` section holding only the original first bullet verbatim, and the verbatim `## Report` body.
- Rewrote the five wrappers (`skills/az-ai-tools/SKILL.md`, `skills/gc-ai-tools/SKILL.md`, `skills/gh-ai-tools/SKILL.md`, `skills/planner-ai-tools/SKILL.md`, `skills/orchestrator-ai-tools/SKILL.md`) to the README's canonical body: unchanged frontmatter, unchanged H1, one scope sentence (first sentence of the old scope paragraph, verbatim through the first full stop), then the two pointer paragraphs (`SKILL-CONTRACT.md`, then `skills/<name>.md`), verbatim per the README template.
- `## 2. Model check`, `## 3. Offer, then ask`, and the last two `Route B` bullets were removed from all five files without rewording — confirmed byte-identical against `skills/SKILL-CONTRACT.md` sections 2, 3, and 5 (bullets 2-3) before deletion.
- Ran `wc -c` on all ten new/modified files:
  ```
  919 skills/az-ai-tools/SKILL.md
  938 skills/gc-ai-tools/SKILL.md
  947 skills/gh-ai-tools/SKILL.md
  1026 skills/planner-ai-tools/SKILL.md
  895 skills/orchestrator-ai-tools/SKILL.md
  1538 skills/az-ai-tools.md
  1552 skills/gc-ai-tools.md
  2016 skills/gh-ai-tools.md
  1926 skills/planner-ai-tools.md
  1859 skills/orchestrator-ai-tools.md
  ```
  All five wrappers are well under the 2,000-character cap (max 1,026, `planner-ai-tools/SKILL.md`); no description was touched.
- Textual regression, per skill: diffed `git show HEAD:skills/<name>/SKILL.md` against the concatenation of the new wrapper + `skills/SKILL-CONTRACT.md` + new base (word-set diff plus targeted `grep`). Every surviving mismatch traced to either (a) tokenization punctuation artifacts (e.g. `impact;` vs `impact.`) or (b) the intended, plan-mandated rewording of the model-check "row's **planner** column" line into the contract's generic "row's column for the category the base names" plus the base's explicit `**planner**` category statement, and the Route A "reusing the same agent..." fragment folding into the contract's "Reuse the same agent and its context..." sentence. No instruction was lost; every one now lives in exactly one of the three files.
- `ls -d skills/*-ai-tools` still lists exactly nine skill directories (`az-ai-tools gc-ai-tools gh-ai-tools orchestrator-ai-tools planner-ai-tools reinstall-ai-tools remove-ai-tools update-ai-tools vibe-ai-tools`); the new `skills/<name>.md` base files are plain files, not directories, so the installer's glob does not pick them up.
- Ran `bash tools/lint.sh` from the worktree root: exit code `0`. Summary line: `done: 499 ok, 1 skipped, 0 warnings` (the one skip is `SKIP: version bump check needs --base <ref> (the lint workflow supplies it)`, unrelated to this stage). No *skill frontmatter*, *skill name match*, or *naming* finding failed; all five touched skills show `ok: skill frontmatter key: name/description/argument-hint` and `ok: skill name matches directory`.
- Files outside this stage's scope (`skills/reinstall-ai-tools.md`, `skills/remove-ai-tools.md`, `skills/update-ai-tools.md`, `skills/vibe-ai-tools.md` and their wrappers) appeared modified/untracked in `git status` — these belong to sibling stages 3/4 running in parallel in the same worktree and were left untouched.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | ac20482fc5ee142ff | V → accepted |

**Status: V**

### Planner validation (attempt 1)

Diff inspected. Five bases carry the pointer note, the verbatim scope paragraph, `## Agent and category` naming the agent, its base path, and **planner**, the verbatim stake, the mapped Route A/Route B specifics, and the Report. Five wrappers hold frontmatter (unchanged), H1, one scope line, two pointer paragraphs; sizes 895–1,026 characters, all ≤ 2,000. `ls -d skills/*-ai-tools` still lists nine directories. A line-level regression sweep of every pre-split file against wrapper + contract + base found no lost instruction: each reported line-level mismatch is text the contract now states generically (model check category, spawn announcement, question relay, agent-context reuse) or a bullet-marker difference. `tools/lint.sh` exit 0.

**Status: F**
