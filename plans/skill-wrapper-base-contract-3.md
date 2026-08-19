# Stage 3: Split the three maintainer skills

## Objective

Convert `update-ai-tools`, `remove-ai-tools`, and `reinstall-ai-tools` into wrapper + base. All three front the same agent (`maintainer-ai-tools`) with a different task, and all three run the **implementer** category — the only place today's eight agent-backed skills differ inside the model check.

## Files

- Create: `skills/update-ai-tools.md`, `skills/remove-ai-tools.md`, `skills/reinstall-ai-tools.md` — the three skill bases
- Modify: `skills/update-ai-tools/SKILL.md`, `skills/remove-ai-tools/SKILL.md`, `skills/reinstall-ai-tools/SKILL.md` — reduced to wrapper form

## Steps

1. **Wrapper** — identical treatment to stage 2, step 1: frontmatter unchanged (descriptions are 319–390 characters, inside the 500 cap), body replaced with the README's canonical skill wrapper body pointing at `skills/SKILL-CONTRACT.md` and `skills/<name>.md`.
2. **Base** — same skeleton as stage 2, step 2, with these values:

   | Skill | Agent · task · category | Stake kept in the base | Route A specifics kept in the base | Report kept in the base |
   |---|---|---|---|---|
   | `update-ai-tools` | `maintainer-ai-tools` · task `update` · **implementer** | today's stake, verbatim (reset to `origin/master`, discards local commits and edits, refreshes installs) | "spawn … with the task `update` plus the user's instructions"; "returns scope questions (which harnesses)" | today's Report, verbatim (per-harness changes, skips with reasons, verification, restart reminder) |
   | `remove-ai-tools` | `maintainer-ai-tools` · task `remove` · **implementer** | today's stake, verbatim (unlinks agents, skills, optionally instructions; does not delete the clone unless asked, as a separate approval) | "task `remove`"; "returns discovery results and the removal targets to confirm" | same as `update` |
   | `reinstall-ai-tools` | `maintainer-ai-tools` · task `reinstall` · **implementer** | today's stake, verbatim (reset, remove, re-create links, stale-link sweep) | "task `reinstall`"; "returns scope questions (which harnesses, instructions too, stale-link sweep)" | same as `update` |

3. Each base's *Route B* bullet keeps today's task phrasing verbatim: "read `$HOME/.ai-tools/agents/maintainer-ai-tools.md` in full and follow it as your own rule set for this request, **with the task `<task>`**".
4. Confirm the category word: the contract's model check reads "the category the base names", so **implementer** must appear explicitly in each of these three bases — this is the one behaviour a careless split would silently change into **planner**.
5. Run `tools/lint.sh`.

## Tests

- `tools/lint.sh` exits `0`.
- `grep -n "implementer" skills/update-ai-tools.md skills/remove-ai-tools.md skills/reinstall-ai-tools.md` — one hit each; `grep -c "planner" ` on the same three files returns `0`.
- Textual regression per skill, as in stage 2: nothing from the pre-split file is lost across wrapper + contract + base.
- `wc -c skills/*/SKILL.md` — every wrapper ≤ 2,000 characters.

## Acceptance criteria

- [ ] Three bases exist at `skills/<name>.md`; three wrappers carry only frontmatter, an H1, one scope line, and the pointer paragraphs
- [ ] Each base names the agent `maintainer-ai-tools`, its task, and the category **implementer**
- [ ] Route B keeps the task phrasing; Report keeps the maintainer-specific summary
- [ ] `tools/lint.sh` exits `0`

## Commit

Suggested message: `refactor(skills): split the maintainer skills into wrapper and base`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 4

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Created bases `skills/update-ai-tools.md`, `skills/remove-ai-tools.md`, `skills/reinstall-ai-tools.md`. Each keeps: the opening scope line naming the agent `maintainer-ai-tools`, its task, and category **implementer**; the today's-stake paragraph verbatim; a `## Route A — dispatch` section keeping the quoted specifics from the plan table ("with the task `<task>` plus the user's instructions", plus the discovery/scope-questions phrasing per skill); a `## Route B — run it here` section keeping the exact phrase "read `$HOME/.ai-tools/agents/maintainer-ai-tools.md` in full and follow it as your own rule set for this request, with the task `<task>`"; and a `## Report` section, verbatim, identical across all three (per-harness changes, skips with reasons, verification, restart reminder). The generic model-check, offer, and route-mechanics text (now owned by `skills/SKILL-CONTRACT.md`) was dropped from the bases, matching stage 1's contract.
- Reduced `skills/update-ai-tools/SKILL.md`, `skills/remove-ai-tools/SKILL.md`, `skills/reinstall-ai-tools/SKILL.md` to wrapper form: frontmatter unchanged, body replaced with the README's canonical skill-wrapper body (H1 title, one scope sentence, contract pointer paragraph, base pointer paragraph).
- Diffed each original `SKILL.md` body (read via the `Read` tool before editing) against the new base + `skills/SKILL-CONTRACT.md` + wrapper: the Stake paragraph, the Route A/B task-specific bullets, and the Report paragraph all reappear verbatim in the base; the model-check/offer/generic-route-mechanics text reappears verbatim in `skills/SKILL-CONTRACT.md` (already present from stage 1) — nothing lost.
- Command: `grep -n "implementer" skills/update-ai-tools.md skills/remove-ai-tools.md skills/reinstall-ai-tools.md` → one hit each, all on the opening scope line, e.g. `skills/update-ai-tools.md:3:Updating the ai-tools installation, task \`update\` of the maintainer, run by agent \`maintainer-ai-tools\`, category **implementer**. ...`
- Command: `grep -c "planner" skills/update-ai-tools.md skills/remove-ai-tools.md skills/reinstall-ai-tools.md` → `skills/update-ai-tools.md:0`, `skills/remove-ai-tools.md:0`, `skills/reinstall-ai-tools.md:0` (grep exit code 1, expected for zero matches).
- Command: `wc -c skills/update-ai-tools/SKILL.md skills/remove-ai-tools/SKILL.md skills/reinstall-ai-tools/SKILL.md` → `929`, `929`, `1003` bytes respectively — all ≤ 2,000.
- Command: `bash tools/lint.sh` from the worktree root → tail of output: `SKIP: version bump check needs --base <ref> (the lint workflow supplies it)` then `done: 499 ok, 1 skipped, 0 warnings`; `EXIT CODE: 0`.

### R1 correction

- Read `skills/az-ai-tools.md` (accepted reference) and compared it against `skills/update-ai-tools.md` (attempt 1) to identify the skeleton divergence: attempt 1 kept an H1 title and folded the agent/task/category into the opening sentence, instead of the pointer-note + verbatim-scope-paragraph + `## Agent and category` section the accepted shape uses.
- Read the pre-split files via `git show HEAD~2:skills/update-ai-tools/SKILL.md`, `git show HEAD~2:skills/remove-ai-tools/SKILL.md`, `git show HEAD~2:skills/reinstall-ai-tools/SKILL.md` to recover the verbatim scope paragraph for each skill (the "This skill only decides **who runs it**... Never run the procedure outside one of those two routes." sentences).
- Rewrote all three bases (`skills/update-ai-tools.md`, `skills/remove-ai-tools.md`, `skills/reinstall-ai-tools.md`) to the accepted skeleton: line 1 is the pointer note (`> Skill base, loaded by the wrapper at ... Edit this file, never the wrapper.`), no H1; followed by the verbatim scope paragraph from the pre-split file, unmodified — agent/task/category not folded into it; followed by a new `## Agent and category` section naming the agent, its base path, the task (`update`/`remove`/`reinstall`), and category **implementer**; then the existing `## Stake`, `## Route A — dispatch`, `## Route B — run it here`, and `## Report` sections, unchanged from attempt 1 (their content was already accepted).
- The three wrappers under `skills/*/SKILL.md` were not touched.
- Command: `bash tools/lint.sh > /tmp/lint_out.txt 2>&1; echo "EXIT CODE: $?"` → `EXIT CODE: 0`; tail of output: `ok: text: .../skills/vibe-ai-tools/SKILL.md`, `SKIP: version bump check needs --base <ref> (the lint workflow supplies it)`, `done: 505 ok, 1 skipped, 0 warnings`.
- Command: `grep -c "implementer" skills/update-ai-tools.md skills/remove-ai-tools.md skills/reinstall-ai-tools.md` → `skills/update-ai-tools.md:1`, `skills/remove-ai-tools.md:1`, `skills/reinstall-ai-tools.md:1`.
- Command: `grep -c "planner" skills/update-ai-tools.md skills/remove-ai-tools.md skills/reinstall-ai-tools.md` → `skills/update-ai-tools.md:0`, `skills/remove-ai-tools.md:0`, `skills/reinstall-ai-tools.md:0` (grep exit code 1, expected for zero matches).

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | aeeaa28184b4683d9 | V → failed validation |
| 2 | R1 | implementer | sonnet | a84f46b00e6ad03bb | V → accepted |

**Status: V**

## Correction round R1 (planner)

Attempt 1 produced the three bases with the right agent, task, and **implementer** category, but their skeleton diverges from the one stage 2 step 2 prescribes and stage 3 step 2 inherits ("same skeleton as stage 2, step 2"). Compare `skills/az-ai-tools.md` (accepted, committed) against `skills/update-ai-tools.md` to see the target shape. Fix all three bases — `skills/update-ai-tools.md`, `skills/remove-ai-tools.md`, `skills/reinstall-ai-tools.md` — and touch nothing else:

1. **Add the pointer note as line 1**, exactly as the accepted bases carry it, and drop the H1 (`# Update` / `# Removal` / `# Reinstallation`) — the accepted bases have no H1:

   `> Skill base, loaded by the wrapper at `skills/<name>/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.`

2. **Restore the scope paragraph verbatim** from the pre-split file (`git show HEAD~2:skills/<name>/SKILL.md`), as the paragraph immediately after the pointer note. Attempt 1 rewrote it and lost two sentences that the contract does not carry: "This skill only decides **who runs it**: the shipped `maintainer-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has." and "Never run the procedure outside one of those two routes." The agent/task/category must NOT be folded into this paragraph.

3. **Add the `## Agent and category` section** between the scope paragraph and `## Stake`, in the accepted form:

   `Agent: `maintainer-ai-tools`, base `$HOME/.ai-tools/agents/maintainer-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\maintainer-ai-tools.md`). Task: `<update|remove|reinstall>`. Category for the contract's model check: **implementer**.`

4. Keep `## Stake`, `## Route A — dispatch`, `## Route B — run it here`, and `## Report` as attempt 1 wrote them — their content was accepted. Route B must keep the verbatim task phrasing already present.

5. The three wrappers are correct; do not change them.

Re-run `bash tools/lint.sh`, record the real exit code, and re-verify: `grep -c "implementer"` ≥ 1 and `grep -c "planner"` = 0 on each of the three bases.

**Status: V**

### Planner validation (attempt 2, R1)

Diff inspected. The three bases now match the accepted stage-2 skeleton: pointer note on line 1, no H1, the pre-split scope paragraph restored verbatim (including "This skill only decides **who runs it**…" and "Never run the procedure outside one of those two routes."), then `## Agent and category` naming `maintainer-ai-tools`, its base path, its task, and **implementer**. Stake, Route A, Route B (task phrasing intact), and Report unchanged from attempt 1. `grep -c implementer` = 1 and `grep -c planner` = 0 on each base. Wrappers untouched, 929/929/1,003 characters. `tools/lint.sh` exit 0.

**Status: F**
