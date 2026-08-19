# Stage 6: Linter checks

## Objective

Make the new layout mechanically verifiable, as the README requires of any rule that can be ("When a rule in this README becomes mechanically verifiable, add its check to `tools/lint.sh` and its rule number to the list above in the same commit"). Four checks: the skill wrapper body against canonical text, the skill wrapper cap, the description cap, and the presence of the contract and every base.

## Files

- Modify: `tools/lint.sh` — four new check functions plus their calls in the run list and their lines in the `--help` check-family block
- Modify: `README.md` — the version line (`0.0.24-ALPHA` → `0.0.25-ALPHA`, the branch's single bump, rule 4) and the *Development checks* bullet list: new entries with their rule numbers (7, 9)

## Steps

1. **`check_skill_wrapper_body` (rule 7)** — mirror `check_wrapper_body`/`canonical_body`, which reconstruct the exact text rather than matching a regex ("A regex would accept the drift this check exists to reject"). For each `skills/*-ai-tools/SKILL.md`:
   - reuse `wrapper_body_md` to strip frontmatter;
   - expect: an H1 line, one blank line, one scope line, one blank line, the contract paragraph (two lines) when the skill is agent-backed, a blank line, then the base paragraph (two lines);
   - the H1 and the scope line are per-skill, so compare only the fixed lines and the line count — reject any extra section, heading, or list;
   - agent-backed is decided by the presence of `skills/<name>.md` naming an agent base under `$HOME/.ai-tools/agents/`, never by a hard-coded skill list (same principle as `base_has_category`).
2. **`check_skill_wrapper_cap` (rule 7)** — copy `check_wrapper_cap` with `cap=2000` over `skills/*-ai-tools/SKILL.md`, including the "largest wrapper" headroom line.
3. **`check_skill_description_cap` (rule 9)** — character count of the `description` value (folded `>` block included, whitespace collapsed as the harness sees it) against `cap=500`, one line per skill plus a largest-description headroom line.
4. **`check_skill_base_coverage` (rule 7)** — `skills/SKILL-CONTRACT.md` exists; every `skills/*-ai-tools/` directory has a `skills/<name>.md`; and every `skills/*.md` at the skills root has a matching directory (no orphan bases). Mirrors `check_wrapper_coverage`'s two-way form.
5. Register the four functions in the run list at the bottom of the file, next to the existing skill checks, and add their families to the `--help` text block near the top (`wrapper cap`, `skill frontmatter`, … stay as they are).
6. **README *Development checks*** — add bullets:
   - **skill wrapper body** — every `skills/*/SKILL.md` matches this README's canonical skill wrapper body (rule 7)
   - **skill layout** — `skills/SKILL-CONTRACT.md` exists, and every skill has exactly one base at `skills/<name>.md`, with no orphans (rule 7)
   - **size caps** — extend the existing bullet: every skill wrapper at most 2,000 characters and every skill `description` at most 500 (rules 7, 9)
7. **Version** — bump the README header to `0.0.25-ALPHA`: the branch's one bump, landing last so the version covers content already committed rather than letting the version-bump check pass on an empty change. Re-pin the number against `origin/master` first if the story-2 branch has not merged (base plan, *Notes*).
8. Run `tools/lint.sh` and `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh`.

## Tests

- `"$HOME/.ai-tools/tools/lint.sh"` — exits `0` on the finished tree, with one `ok` line per skill for each new check.
- Mutation checks, each reverted afterwards: append a stray `## Extra` section to one wrapper → *skill wrapper body* warning and exit `2`; pad a description past 500 characters → *description cap* warning; `git mv skills/az-ai-tools.md /tmp/` → *skill layout* warning naming the missing base.
- `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` — clean.
- `tools/lint.sh --base origin/master` — the version-bump check passes on the branch (stage 1 bumped it once).

## Acceptance criteria

- [ ] Four new checks exist, are called in the run list, and appear in `--help`
- [ ] Each new check reports per file and warns (exit `2`) rather than aborting (exit `1`)
- [ ] No vendor model name, skill name, or agent name is hard-coded in the new checks
- [ ] README *Development checks* lists the new families with rule numbers 7 and 9, and the version line reads `0.0.25-ALPHA`
- [ ] `tools/lint.sh` exits `0`; `tools/lint.sh --base origin/master` exits `0`; `shellcheck` clean

## Commit

Suggested message: `feat(lint): check the skill wrapper body, caps, and base coverage`

This commit also carries the branch's single version bump (rule 4).

## Dependencies

- Requires stages: 5
- Parallel-safe with: none

## Implementation log

(Append-only log added by implementers and planner during execution.)
