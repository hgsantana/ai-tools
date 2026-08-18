# Stage 2: Tighten the caps and shorten the canonical wrapper body

## Objective

Make the new size limits real and reachable **before** the linter enforces them: register the 8,000-character instructions cap and the 1,000-character wrapper cap as rules, and shorten the canonical wrapper body so all 42 wrappers fit under the second one.

Measured before planning: wrappers run from 991 to 1,140 characters, **39 of 42 above 1,000**. The floor is structural — 763 characters of canonical body mandated verbatim by rule 6, plus 235 of minimal frontmatter, is already 998. The cap is therefore unreachable without editing the body itself; enforcing it first would fail the whole tree.

## Files

- Modify: `README.md` — rule 3 (cap 12,000 → 8,000), rule 6 (register the wrapper cap), and the canonical body block under *Model map and wrapper authoring*
- Modify: `agents/*/*.md`, `agents/*/*.agent.md`, `agents/*/*.toml` — all 42 wrappers, body only

## Steps

1. **Rule 3** — replace Antigravity's 12,000 with a self-imposed **8,000-character** cap on `USER-AGENTS.md`, stating that it is deliberately tighter than any harness constraint in order to force concision, and that a harness declaring something tighter still governs (the existing precedence is preserved, not dropped). Current size is 6,592 characters, so nothing has to be rewritten to comply.
2. **Rule 6** — add: a wrapper is at most **1,000 characters**, frontmatter included. State the reason in one clause: a wrapper is what the harness reads to decide whether to route to the agent, so it carries the summary and nothing else; the behaviour lives in the base it points to.
3. **Shorten the canonical body.** The current body spends roughly 250 characters repeating the Windows path in each of its three paragraphs. Replace that repetition with a single leading sentence — `On Windows, %USERPROFILE% replaces $HOME.` — and drop the parenthetical from each pointer. Nothing else about the body changes: still three pointers, still the same order, still the same precedence clause. Update the canonical block in the README in this same commit; it is the text stage 3 will reconstruct.
4. **Apply to all 42 wrappers.** Body only — never touch frontmatter, model tokens, or descriptions here. The Codex `.toml` form keeps its doubled backslashes wherever a Windows path survives.
5. Re-measure every wrapper and record the largest in the Implementation log. The largest today is `codex/maintainer-ai-tools.toml` at 1,140 characters; it is the one to watch, since Codex carries the longest frontmatter and `maintainer-ai-tools` the longest description (251).
6. **No version bump here.** The whole set lands as one pull request and stage 7 carries the single bump — two bumps in one branch would make the version check in stage 5 pass for the wrong reason.

## Tests

Not applicable — documentation and shipped-text change. Evidence in the Implementation log:

- Character count of every wrapper after the edit, showing all 42 at or under 1,000.
- Character count of `USER-AGENTS.md`, showing it under 8,000 with the headroom stated.
- A diff review confirming every wrapper body is byte-identical to every other one modulo harness key, agent name, and TOML escaping — that uniformity is what stage 3 depends on.

## Acceptance criteria

- [ ] Rule 3 states 8,000 characters and keeps the "tightest constraint governs" precedence
- [ ] Rule 6 states the 1,000-character wrapper cap with its reason
- [ ] The canonical body block in the README matches, character for character, what the wrappers now carry
- [ ] All 42 wrappers are at or under 1,000 characters
- [ ] No frontmatter, model token, effort, or description changed in this stage
- [ ] `USER-AGENTS.md` is unchanged and under 8,000

## Commit

Suggested message: `refactor(agents): shorten the canonical wrapper body and tighten the size caps`

## Dependencies

- Requires stages: 1
- Parallel-safe with: none (stage 3 reconstructs the body this stage rewrites)

## Implementation log
