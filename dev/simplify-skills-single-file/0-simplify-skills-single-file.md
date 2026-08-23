# Collapse every skill into a single SKILL.md

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools · gemini-3.7-flash-high |
| 2 | | |

## Goal

Every skill is one installed file, `skills/<name>/SKILL.md`. Skill contracts, skill bases, and the shared maintainer file go away. Planner-gated skills open with a short continue gate; maintainer skills are the task, with no gate.

## Execution graph

Stage 1 before stage 2. Not parallel-safe: stage 2's lint and verify encode the layout stage 1 produces, and README rules 7–8 must match both.

## Stages

1. [Single-file skills](./1-simplify-skills-single-file.md) — rewrite the ten `SKILL.md` files; delete bases, `SKILL-CONTRACT.md`, and `MAINTAINER.md`
2. [Rules and checks](./2-simplify-skills-single-file.md) — README, `USER-AGENTS.md`, `tools/lint.sh`, `verify_install`, test fixture

## Notes

**Commit strategy.** One Conventional Commit per stage, path-scoped. Do not `git add -A`. Do not bump the README version (rule 4: only on `master`).

**Lint is green only after stage 2.** Stage 1's `SKILL.md` files will fail today's canonical-wrapper check; that is expected. Do not run `tools/lint.sh` as stage 1 acceptance.

**Out of scope.** Agent bases, harness wrappers, `agents/SUBAGENT-CONTRACT.md`, install directory linking, plan-file format, `MODELS.md`, version bump.

**Story / decisions.** `dev/tmp/vibe/story-simplify-skills-single-file.md` and `dev/tmp/vibe/decisions-simplify-skills-single-file.md` (gitignored).
