# Stage 1: Skeleton, CLI contract, naming and coverage

## Objective

Create `tools/lint.sh` with its output and exit contract, and the first family of checks: every agent has a wrapper in every harness, and every installed name ends in `-ai-tools`.

## Files

- Create: `tools/lint.sh` — the linter; executable, LF, bash 3.2+ and BSD/GNU userlands, no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`

## Steps

1. Header comment: what the file is, that it is a **development check and not an installation process** (outside the contract of rules 23–25), and how to run it.
2. Resolve the repository root from the script's own location (`cd "$(dirname "$0")/.."`), export `AI_TOOLS` to that root, then source `scripts/shell/lib.sh`. Sourcing after the export is what makes `MODELS_MAP` resolve inside the checkout instead of `$HOME/.ai-tools` — CI checks out elsewhere.
3. Support `--help` (usage plus the check list) and `--version`-free minimalism; unknown flags exit `1` via `fatal`.
4. Report through `ok`/`warn`/`skip`/`info` and close with `finish` — this already yields exit `0` clean and `2` with findings. Never invent a second reporting style.
5. Discover the harness keys from `agents/*/` directories, and the agent names from `agents/*.md` excluding `SUBAGENT-CONTRACT.md`. Never hard-code either list — a new harness or agent must be picked up automatically.
6. **Check — wrapper coverage (rule 5)**: every agent name has exactly one wrapper in every harness directory, with that harness's extension (`.md`, `.agent.md` for copilot, `.toml` for codex). Report a missing wrapper and an orphan wrapper (a file matching no base) separately.
7. **Check — naming (rule 13)**: every agent base file, every wrapper, every `skills/*/` directory, and every `name:` in agent and skill frontmatter ends in `-ai-tools`.
8. **Check — skill frontmatter (rule 9)**: every `skills/*/SKILL.md` exists and its frontmatter keys are a subset of `name`, `description`, `argument-hint`.
9. **Check — skill name matches its directory**: `skills/<x>/SKILL.md` declares `name: <x>`.

## Tests

No test framework is introduced (roadmap story 2 owns that). Evidence instead, recorded in the Implementation log:

- Run against the tree: every check reports `ok`, exit code `0`.
- Negative evidence per check: copy the tree to a throwaway directory under the system temp dir, inject one violation (delete a wrapper; rename a skill directory without the suffix; add a `model:` key to a `SKILL.md`), run the linter there, and record the message and exit code `2`. Never inject a violation into the working tree.

## Acceptance criteria

- [ ] `tools/lint.sh` exits `0` on the current tree with no warning
- [ ] Each check above reports `2` with a message naming the offending path when its violation is injected into a throwaway copy
- [ ] Harness keys and agent names are derived from the tree, never hard-coded
- [ ] `lib.sh` is sourced, not copied: no duplicated reporting or model-lookup logic
- [ ] `--help` lists every check; an unknown flag exits `1`
- [ ] File is committed executable with LF endings

## Commit

Suggested message: `chore(tools): add a rule linter with naming and coverage checks`

## Dependencies

- Requires stages: none
- Parallel-safe with: none (stages 2–4 extend this same file)

## Implementation log
