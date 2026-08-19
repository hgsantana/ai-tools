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
