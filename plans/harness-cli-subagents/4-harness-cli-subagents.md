# Stage 4: Create copilot-ai-tools skill

## Objective
Create the `skills/copilot-ai-tools/SKILL.md` skill to dispatch autonomous coding, analysis, and execution tasks to GitHub Copilot CLI (`copilot`) subagents with model and reasoning effort control.

## Files
- Create: `skills/copilot-ai-tools/SKILL.md`

## Steps
1. Create `skills/copilot-ai-tools/SKILL.md` following the established `agy-ai-tools` pattern.
2. Define parameter resolution for Copilot models (Claude, GPT, Gemini, and others) and effort tiers (`none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`).
3. Construct the portable non-interactive CLI invocation:
   `copilot -p "{CLEAN_PROMPT}" --model "{MODEL}" --effort "{EFFORT}" --yolo`
4. Implement XML sections: `<overview>`, `<session_workflow>`, `<dispatch_templates>`, `<boundaries>`.
5. Ensure frontmatter conforms to repository rule 6 (under 500 characters, states purpose, Impact:, Agent: session).

## Tests
- Run `./scripts/lint.sh` to check skill naming, frontmatter, XML vocabulary, and rules.

## Acceptance criteria
- `skills/copilot-ai-tools/SKILL.md` exists and passes `./scripts/lint.sh`.
- Invocation uses `copilot -p` with `--model` and `--effort`.

## Commit message
`feat(skills): add copilot-ai-tools skill for copilot cli subagents`

## Dependencies
Stage 3

## Implementation log
- Created `skills/copilot-ai-tools/SKILL.md` adhering to the structure, XML vocabulary, and conventions of `skills/agy-ai-tools/SKILL.md`, `skills/claude-ai-tools/SKILL.md`, and `skills/codex-ai-tools/SKILL.md`.
- Added frontmatter with `name: copilot-ai-tools`, `argument-hint`, and a concise `description` under 500 characters (372 characters folded) stating purpose, citing `/copilot-ai-tools`, specifying `Impact:`, and setting `Agent: session`.
- Defined model parameter resolution (Claude, GPT, Gemini, `auto`, full model names) and effort tiers (`none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max`) in `<session_workflow>`.
- Configured portable non-interactive CLI command invocation: `copilot -p "{CLEAN_PROMPT}" --model "{MODEL}" --effort "{EFFORT}" --yolo`.
- Added `<overview>`, `<session_workflow>`, `<dispatch_templates>` (`mechanical-discovery` default worker), and `<boundaries>`.
- Ran `./scripts/lint.sh` and verified all repository checks pass cleanly (606 ok, 1 skipped, 0 warnings).
