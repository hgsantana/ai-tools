# Stage 2: Create claude-ai-tools skill

## Objective
Create the `skills/claude-ai-tools/SKILL.md` skill to dispatch autonomous coding, analysis, and execution tasks to Claude Code CLI (`claude`) subagents with model and reasoning effort control.

## Files
- Create: `skills/claude-ai-tools/SKILL.md`

## Steps
1. Create `skills/claude-ai-tools/SKILL.md` following the exact pattern of `agy-ai-tools`.
2. Define parameter resolution for Claude models (`sonnet`, `opus`, `haiku`, `fable`, full names) and effort tiers (`low`, `medium`, `high`, `xhigh`, `max`).
3. Construct the portable non-interactive CLI invocation:
   `claude -p "{CLEAN_PROMPT}" --model "{MODEL}" --effort "{EFFORT}" --dangerously-skip-permissions`
4. Implement XML sections: `<overview>`, `<session_workflow>`, `<dispatch_templates>`, `<boundaries>`.
5. Ensure frontmatter conforms to repository rule 6 (under 500 characters, states purpose, Impact:, Agent: session).

## Tests
- Run `./scripts/lint.sh` to check skill naming, frontmatter, XML vocabulary, and rules.

## Acceptance criteria
- `skills/claude-ai-tools/SKILL.md` exists and passes `./scripts/lint.sh`.
- Invocation uses `claude -p` with `--model` and `--effort`.

## Commit message
`feat(skills): add claude-ai-tools skill for claude cli subagents`

## Dependencies
Stage 1

## Implementation log
