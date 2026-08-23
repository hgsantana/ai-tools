# Stage 2: Rules and checks

## Objective

README, `USER-AGENTS.md`, `tools/lint.sh`, `verify_install`, and the update-test fixture describe and enforce the single-file skill layout from stage 1. After this stage, `tools/lint.sh` exits 0 on the tree and `tools/test.sh` stays green.

## Files

- Modify: `README.md` — inventory, rules 7–8, skill authoring, development checks, Installation verify step
- Modify: `USER-AGENTS.md` — one or two sentences on which skills carry the planner and that maintainer skills have no gate (stay ≤ 8,000 characters)
- Modify: `tools/lint.sh` — drop canonical skill-wrapper body and 2,000-character skill cap; new layout checks
- Modify: `scripts/shell/lib.sh` — `verify_install` no longer requires a skill contract or skill bases; still requires each `skills/<name>/SKILL.md` and that it is installed
- Modify: `tools/test/lib.sh` — `t_origin_commit` ships only `skills/<label>-ai-tools/SKILL.md`, no companion base

Do not bump the version line in `README.md`. Do not edit agent wrappers or `agents/SUBAGENT-CONTRACT.md`. Do not re-edit skill bodies except if a README example must match them (the authoring example is prose, not a byte-for-byte wrapper).

## Steps

### 1. README inventory (`What is inside`)

`skills/` row: ten skills, each the installed `skills/<name>/SKILL.md` (the whole skill). The three agents have no skill. Planner-gated skills carry the planner role in the user's session after Continue?; maintainer skills run in session with no gate.

Delete the inventory rows for `skills/SKILL-CONTRACT.md` and `skills/MAINTAINER.md`.

### 2. Rule 7

Replace the wrapper/base/contract split and the 2,000-character wrapper cap.

Skills are harness-agnostic — no per-harness copies. One file: `skills/<name>/SKILL.md` (frontmatter per rule 9, then the whole skill). No skill contract, no skill base, no `skills/<name>.md`, no `skills/SKILL-CONTRACT.md`, no `skills/MAINTAINER.md`. Duplicated gate or maintainer text is required, not drift. `description` at most 500 characters (rule 9). No character cap on the skill body; rule 15 still forbids fluff. Planner-gated skills (`vibe-ai-tools`, `plan-ai-tools`, `dev-ai-tools`, `az-ai-tools`, `gc-ai-tools`, `gh-ai-tools`, `agy-ai-tools`) open with **Continue?** (stake, planner match against this harness's `MODELS.md` planner cell, how to change the session model when they differ, then yes/no). The other three skills are the task, with no continue gate.

### 3. Rule 8

Keep spawn depth is one, planner not dispatched, workers dispatched.

Replace the four-route contract offer:

- A planner-gated skill (the seven names in rule 7) gates with **Continue?**. After yes, this session carries `planner-ai-tools` and follows that file's Workflow. The skill never refuses over the session model; proceeding on a non-planner is the user's call.
- Every other shipped skill has no gate: the file is the task, carried in this session.
- Drop "run it here / change the session model / stop" as named routes. Drop skill-entry dispatch of `implementer-ai-tools`.

### 4. Skill authoring (the "A skill wrapper carries…" block)

Delete the canonical thin wrapper that points at `SKILL-CONTRACT.md` and `skills/<name>.md`.

State: frontmatter (rule 9), H1, one-sentence scope, then either **Continue?** + Stake + Workflow (planner-gated) or Stake-in-first-message + Workflow (maintainer). Point at `agents/<name>.md` only as the planner base the continue-yes loads, never as a skill base. Windows: `%USERPROFILE%` replaces `$HOME`.

### 5. Development checks list

- Drop **skill wrapper body** (canonical reconstruction).
- Drop the 2,000-character skill-wrapper cap from **size caps** (keep description 500, agent wrapper 1,000, USER-AGENTS 8,000).
- **skill layout** becomes: no `skills/*.md` at the skills root; every `skills/*-ai-tools/SKILL.md` exists; the seven planner-gated files contain `## Continue?`; the three maintainer files do not; no `SKILL.md` mentions `SKILL-CONTRACT` or `MAINTAINER.md`.

### 6. Installation verify step (README process §8)

Require `agents/SUBAGENT-CONTRACT.md` and every agent base still. Drop `skills/SKILL-CONTRACT.md` and "every … skill base". Require every shipped `skills/<name>/SKILL.md` exists, and every installed skill is a link or unmodified copy of that directory.

### 7. `USER-AGENTS.md`

Replace "Each skill runs on one of the three agents below by name: the planner role is carried by this session, every other role is dispatched."

With: a skill is the entry point; offer skills; agents are spawn-only. The seven planner-gated skills carry `planner-ai-tools` in this session after Continue?. The three maintainer skills run the task here, with no gate. Every other role is dispatched.

Keep the skills table. Stay under 8,000 characters. Do not mention `SKILL-CONTRACT.md`.

### 8. `tools/lint.sh`

- Usage/help: drop "skill wrapper body", "skill wrapper cap", and the old "skill layout" wording; describe the new layout check.
- Delete `skill_has_agent_base`, `canonical_skill_body`, `check_skill_wrapper_body`, `check_skill_wrapper_cap` (and their calls).
- Keep `check_skill_frontmatter`, `check_skill_name_match`, `check_skill_description_cap`.
- Replace `check_skill_base_coverage` with a layout check:
  - `skills/SKILL-CONTRACT.md` and `skills/MAINTAINER.md` must **not** exist
  - `skills/*.md` must be empty (no files)
  - every `skills/*-ai-tools/` directory has `SKILL.md`
  - planner-gated names (hard-code the seven from rule 7; this is the same list the README names — do not invent a detector) contain the heading `## Continue?`
  - `update-ai-tools`, `remove-ai-tools`, `reinstall-ai-tools` do **not** contain `## Continue?`
  - no `skills/*/SKILL.md` contains `SKILL-CONTRACT` or `MAINTAINER.md`
- Still never hard-code a *vendor model* name. Hard-coding these ten directory names is required so the gate cannot silently vanish.
- Size-caps family in the header comment: drop the 2,000 skill-wrapper cap.

### 9. `scripts/shell/lib.sh` `verify_install`

Delete the block that ok/warns on `skills/SKILL-CONTRACT.md` and on `skills/$name.md` bases.

Keep the loop that confirms each `skills/*-ai-tools` directory and that `$root/$name/SKILL.md` is installed.

Optional extra (yes, add it): in the clone, `ok` when `$AI_TOOLS/skills/$name/SKILL.md` exists, `warn` when it is missing. Do not warn about a missing base.

### 10. `tools/test/lib.sh` `t_origin_commit`

Stop creating `skills/<label>-ai-tools.md`. Create only `skills/<label>-ai-tools/SKILL.md`. Rewrite the comment: the repo ships a directory with `SKILL.md`, nothing else. Drop the "Base: …" sentence from the generated SKILL.md body (it would be a lie). Keep the frontmatter `name` / `description` so install still links the new skill.

### 11. Verify the machinery

Run `tools/lint.sh` (exit 0). Run `tools/test.sh` (exit 0). If `shellcheck` is available, `shellcheck -x -P scripts/shell -P tools/test scripts/shell/lib.sh tools/lint.sh tools/test/lib.sh`. Fix only failures this stage introduced.

## Tests

- `tools/lint.sh` exit 0; no WARN about skill wrapper body, skill bases, or a 2,000-character cap
- `tools/test.sh` exit 0, including `update` (new origin skill is directory-only) and `verify` (clean install has no WARN about a skill contract or skill base)
- `USER-AGENTS.md` character count ≤ 8,000
- README no longer mentions `SKILL-CONTRACT.md` or `skills/MAINTAINER.md` except if a historical sentence remains — there must be none; grep both names and they must not appear in `README.md`, `USER-AGENTS.md`, `tools/lint.sh`, `scripts/shell/lib.sh` except as "must not exist" / "do not mention" in the linter itself

## Acceptance criteria

- [ ] Rules 7 and 8, inventory, authoring, verify, and the development-check list match the single-file layout
- [ ] `USER-AGENTS.md` names the continue gate for the seven and no gate for maintainer skills, and stays under the cap
- [ ] Lint enforces: no skill-root markdown, Continue? present/absent on the right skills, no pointers at the deleted files, no 2,000-character skill cap, description cap kept
- [ ] `verify_install` does not require a skill contract or skill bases
- [ ] Origin-commit fixture no longer adds a skill base
- [ ] `tools/lint.sh` and `tools/test.sh` exit 0
- [ ] README version line unchanged

## Commit

Suggested message: `docs: drop skill contracts and bases from rules and checks`

## Dependencies

- Requires stages: 1
- Parallel-safe with: none

## Implementation log

(Append-only log added by implementers and planner during execution.)
