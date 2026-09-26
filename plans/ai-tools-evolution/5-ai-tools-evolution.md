# Stage 5: Structured Grill-me Protocol in plan-ai-tools

## Objective

Formalize an inquisitive, structured "Grill-me" design interview protocol in `plan-ai-tools` (and reflected in `vibe-ai-tools`). Before writing plan files, the session proactively interrogates requirements, unstated assumptions, failure scenarios, harness compatibility, and architectural trade-offs, proceeding only when open risks are resolved.

## Files

- **Modify**:
  - `skills/plan-ai-tools/SKILL.md`
  - `skills/vibe-ai-tools/SKILL.md`
  - `README.md`
  - `docs/USAGE.md`

## Steps

1. In `skills/plan-ai-tools/SKILL.md`:
   - Refactor `step id="2"` (`user_alignment`) into an explicit Grill-me protocol:
     - Assume an adversarial, critical inquiry stance in service of technical excellence.
     - Probe unstated assumptions, scope boundaries, edge cases, backwards compatibility, and testing strategies.
     - Ask questions one at a time via USER-AGENTS `<user_interaction>` with technical rationales and recommended options.
     - Continue grilling until no critical architectural uncertainties remain or the user confirms alignment.
   - Refactor `rule id="design-interview"` into `rule id="grill-me-interview"`.
2. In `skills/vibe-ai-tools/SKILL.md`:
   - Update `step id="1"` to cite the formal grill-me planning workflow from `plan-ai-tools`.
3. In `README.md` and `docs/USAGE.md`:
   - Update documentation for `plan-ai-tools` to describe the mandatory grill-me alignment phase.
4. Verify Semantic XML balancing and ensure skill descriptions remain strictly under 500 characters.

## Tests

- Run `./scripts/lint.sh` to ensure all XML tags, references, and description size constraints pass.

## Acceptance criteria

- `plan-ai-tools/SKILL.md` defines the formal grill-me interview protocol.
- `vibe-ai-tools` correctly references the updated planning step.
- `./scripts/lint.sh` passes with 0 warnings.

## Commit message

```text
feat(planning): incorporate structured grill-me protocol into plan-ai-tools
```

## Dependencies

- Stage 3 (`3-ai-tools-evolution.md`)

## Implementation log

