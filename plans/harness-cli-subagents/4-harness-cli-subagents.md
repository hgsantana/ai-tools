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
