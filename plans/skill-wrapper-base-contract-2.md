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
