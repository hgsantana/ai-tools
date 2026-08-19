# Stage 4: Split `vibe-ai-tools`

## Objective

Give the one skill that fronts no agent the same wrapper + base shape, without pointing it at the shared contract. `skills/vibe-ai-tools/SKILL.md` is the largest shipped file (8,962 characters) and none of it is shared route text: the entry gate, the six phases, and the boundaries are all its own.

**Settled (base plan, *Decisions taken* 1).** The split covers this skill too, for symmetry. Its entry gate — the model check and the Vibe Coding gate — stays in **this skill's base** and never moves into `skills/SKILL-CONTRACT.md`: the contract carries only what the agent-backed skills repeat verbatim, and nothing in this skill is shared with them.

## Files

- Create: `skills/vibe-ai-tools.md` — the vibe skill base (entry gate, phases 1–6, boundaries)
- Modify: `skills/vibe-ai-tools/SKILL.md` — reduced to wrapper form, with no contract pointer

## Steps

1. **Wrapper**: keep the frontmatter unchanged (description is 339 characters, inside the 500 cap). Body:

   ```markdown
   # Vibe Coding

   Refining a demand into a story and delivering it end to end through the shipped `planner-ai-tools` and `orchestrator-ai-tools` agents, in this session, on whatever model it provides.

   Your base file is `$HOME/.ai-tools/skills/vibe-ai-tools.md`.
   Read it and follow it in full — it is the absolute rule set for this skill.
   ```

   No contract paragraph: this skill fronts no agent, offers no three routes, and its entry gate is its own (README rule 7 makes the contract pointer conditional).

2. **Base** `skills/vibe-ai-tools.md`: the whole of today's body, verbatim, from "You run this workflow yourself…" through *Boundaries*, prefixed with the pointer note used by every base:

   ```markdown
   > Skill base, loaded by the wrapper at `skills/vibe-ai-tools/SKILL.md`. This skill fronts no agent and loads no shared contract. Edit this file, never the wrapper.
   ```

3. **Never move the entry gate into `skills/SKILL-CONTRACT.md`, and never rewrite it as the contract's model check.** They differ deliberately: the contract offers *dispatch · run here · stop*; the vibe gate offers *switch model and re-invoke · continue on the current model · stop*, and its stake covers unattended end-to-end delivery. Reuse would change behaviour.
4. Run `tools/lint.sh`.

## Tests

- `tools/lint.sh` exits `0`.
- `diff <(git show HEAD:skills/vibe-ai-tools/SKILL.md | sed -n '/^# Vibe Coding/,$p') <(sed -n '/^You run this workflow yourself/,$p' skills/vibe-ai-tools.md)` — only the H1 and the new scope line differ; every phase, gate item, and boundary is byte-identical.
- `grep -c "SKILL-CONTRACT" skills/vibe-ai-tools/SKILL.md skills/vibe-ai-tools.md` — `0` in both.
- `wc -c skills/vibe-ai-tools/SKILL.md` — ≤ 2,000 characters.

## Acceptance criteria

- [ ] `skills/vibe-ai-tools.md` holds the full workflow, unchanged in substance
- [ ] The wrapper carries frontmatter, an H1, one scope line, and the base pointer only — and no contract pointer
- [ ] The entry gate is untouched and lives only in this base: three answers, its own stake, no reuse of the contract's model check, nothing added to the contract by this stage
- [ ] `tools/lint.sh` exits `0`

## Commit

Suggested message: `refactor(skills): split vibe-ai-tools into wrapper and base`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 3

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Created `skills/vibe-ai-tools.md`: pointer note (`> Skill base, loaded by the wrapper at ...`) followed by the full body of the former `skills/vibe-ai-tools/SKILL.md`, from `You run this workflow yourself…` through *Boundaries*, verbatim except the leading `# Vibe Coding` H1 which is not part of the base body.
- Reduced `skills/vibe-ai-tools/SKILL.md` to frontmatter (unchanged) plus the wrapper body specified in Step 1 (H1 + scope line + base pointer), with no contract paragraph.
- Ran the diff regression:
  ```
  $ diff <(git show HEAD:skills/vibe-ai-tools/SKILL.md | sed -n '/^# Vibe Coding/,$p') <(sed -n '/^You run this workflow yourself/,$p' skills/vibe-ai-tools.md)
  1,2d0
  < # Vibe Coding
  < 
  exit:1
  ```
  Only the old file's `# Vibe Coding` H1 and blank line are removed; every phase, gate item, and boundary line onward is identical (no other diff hunks reported).
- Ran the grep evidence:
  ```
  $ grep -c "SKILL-CONTRACT" skills/vibe-ai-tools/SKILL.md skills/vibe-ai-tools.md
  skills/vibe-ai-tools/SKILL.md:0
  skills/vibe-ai-tools.md:0
  ```
- Ran the wc evidence:
  ```
  $ wc -c skills/vibe-ai-tools/SKILL.md
  782 skills/vibe-ai-tools/SKILL.md
  ```
  782 ≤ 2,000-character cap.
- Ran `bash tools/lint.sh` from the worktree root: `done: 499 ok, 1 skipped, 0 warnings`, `EXIT:0`. The 1 skip is the version-bump check, which needs `--base <ref>` supplied by the lint workflow (unrelated to this stage; stage 6 owns the version bump).

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | a5e447c8578cd5fcf | V → accepted |

**Status: V**

### Planner validation (attempt 1)

Diff inspected. `skills/vibe-ai-tools.md` carries the prescribed pointer note plus the body verbatim; the line-level regression sweep of the pre-split file against wrapper + base reported zero missing lines. The wrapper holds frontmatter (unchanged), H1, one scope line, and the base pointer only — 782 characters, no `SKILL-CONTRACT` reference in either file. The entry gate stays in the base and nothing was added to the contract. `tools/lint.sh` exit 0.

**Status: F**
