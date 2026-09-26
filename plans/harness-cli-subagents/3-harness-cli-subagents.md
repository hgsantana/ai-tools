# Stage 3: Create codex-ai-tools skill

## Objective
Create the `skills/codex-ai-tools/SKILL.md` skill to dispatch autonomous coding, analysis, and execution tasks to OpenAI Codex CLI (`codex`) subagents with model and reasoning effort control.

## Files
- Create: `skills/codex-ai-tools/SKILL.md`

## Steps
1. Create `skills/codex-ai-tools/SKILL.md` following the established `agy-ai-tools` pattern.
2. Define parameter resolution for Codex models (`gpt-6-astra`, `o3`, `o1`, `gpt-4o`, `gpt-5`) and effort tiers (`low`, `medium`, `high`).
3. Construct the portable non-interactive CLI invocation:
   `codex exec --dangerously-bypass-approvals-and-sandbox -m "{MODEL}" -c model_reasoning_effort="{EFFORT}" "{CLEAN_PROMPT}"`
4. Implement XML sections: `<overview>`, `<session_workflow>`, `<dispatch_templates>`, `<boundaries>`.
5. Ensure frontmatter conforms to repository rule 6 (under 500 characters, states purpose, Impact:, Agent: session).

## Tests
- Run `./scripts/lint.sh` to check skill naming, frontmatter, XML vocabulary, and rules.

## Acceptance criteria
- `skills/codex-ai-tools/SKILL.md` exists and passes `./scripts/lint.sh`.
- Invocation uses `codex exec` with model and reasoning effort configuration.

## Commit message
`feat(skills): add codex-ai-tools skill for codex cli subagents`

## Dependencies
Stage 2

## Implementation log
