# Stage 2: Upfront Model Tables & Dynamic Query Fallback

## Objective

Equip surviving CLI harness skills (`agy-ai-tools`, `claude-ai-tools`, `copilot-ai-tools`) with an explicit upfront supported models table and an intelligent fallback protocol that dynamically inspects the respective CLI before rejecting an unrecognized model request.

## Files

- **Modify**:
  - `skills/agy-ai-tools/SKILL.md`
  - `skills/claude-ai-tools/SKILL.md`
  - `skills/copilot-ai-tools/SKILL.md`

## Steps

1. In `skills/agy-ai-tools/SKILL.md`:
   - Incorporate a formal upfront supported model table:
     - `gemini-3.8-flash` (low, medium, high)
     - `gemini-3.7-flash` (low, medium, high)
     - `gemini-3.6-flash` (low, medium, high)
     - `gemini-3.1-pro` (low, high)
     - `claude-sonnet-4-6`
     - `claude-opus-4-6-thinking`
     - `gpt-oss-120b-medium`
   - In parameter resolution (`step id="1"`), add an explicit fallback rule: if the requested model does not match the static table or known aliases, execute `agy models` dynamically to inspect if the requested identifier is available before rejecting.
2. In `skills/claude-ai-tools/SKILL.md`:
   - Incorporate an upfront supported models table:
     - `sonnet` (`claude-sonnet-4-6`)
     - `opus` (`claude-opus-4-6-thinking`)
     - `haiku`
     - `fable`
   - In parameter resolution, define a CLI query fallback: when a model is not recognized in the table, inspect available CLI options/flags (`claude --help` or validation probe) to determine if it is recognized before rejecting.
3. In `skills/copilot-ai-tools/SKILL.md`:
   - Incorporate an upfront supported models table:
     - `gpt-5.4`
     - `claude-sonnet-4-6`
     - `claude-opus-4-6`
     - `o3`
     - `o1`
     - `gemini-2.5-pro`
     - `auto`
   - In parameter resolution, define a dynamic fallback: inspect `copilot --help` or probe flags before rejecting unrecognized model inputs.
4. Verify Semantic XML balancing, rule definitions, and character limits (all skill descriptions remain strictly <= 500 characters).

## Tests

- Run `./scripts/lint.sh` to confirm semantic XML integrity, cross-references, and description caps.

## Acceptance criteria

- `skills/agy-ai-tools/SKILL.md`, `skills/claude-ai-tools/SKILL.md`, and `skills/copilot-ai-tools/SKILL.md` all contain explicit upfront model reference tables.
- All three skills implement dynamic CLI inspection before rejecting unrecognized model requests.
- `./scripts/lint.sh` passes with 0 warnings.

## Commit message

```text
feat(harnesses): add static model tables and dynamic cli query fallback
```

## Dependencies

- Stage 1 (`1-ai-tools-evolution.md`)

## Implementation log

- Updated `skills/agy-ai-tools/SKILL.md`:
  - Added supported models table under parameter resolution step (`gemini-3.8-flash`, `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.1-pro`, `claude-sonnet-4-6`, `claude-opus-4-6-thinking`, `gpt-oss-120b-medium`).
  - Added dynamic query fallback rule executing `agy models` to check availability before rejecting unrecognized model inputs.
- Updated `skills/claude-ai-tools/SKILL.md`:
  - Added supported models table under parameter resolution step (`sonnet` / `claude-sonnet-4-6`, `opus` / `claude-opus-4-6-thinking`, `haiku`, `fable`).
  - Added dynamic CLI query fallback inspecting `claude --help` or validation probe before rejecting unrecognized model inputs.
- Updated `skills/copilot-ai-tools/SKILL.md`:
  - Added supported models table under parameter resolution step (`gpt-5.4`, `claude-sonnet-4-6`, `claude-opus-4-6`, `o3`, `o1`, `gemini-2.5-pro`, `auto`).
  - Added dynamic CLI query fallback inspecting `copilot --help` or probe flags before rejecting unrecognized model inputs.
- Verified description budgets (all <= 500 chars), XML tag balancing, and semantic XML rules.
- Test and verification results:
  - `./scripts/lint.sh`: exit 0 (585 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (340 ok, 0 skipped, 0 warnings).
