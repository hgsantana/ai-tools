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

- Updated `skills/plan-ai-tools/SKILL.md`:
  - Refactored frontmatter description (319 chars) and `<overview>` to reflect structured grill-me inquiry along the design tree.
  - Refactored `<step id="2" name="user_alignment">` into an explicit Grill-me protocol assuming an adversarial, inquisitive stance probing unstated assumptions, edge cases, failure modes, harness compatibility, and architectural trade-offs; asking questions one at a time via USER-AGENTS `<user_interaction>` with technical rationales and recommended options; and concluding only when all design tree branches are resolved and no critical uncertainties remain.
  - Refactored `<rule id="design-interview">` to `<rule id="grill-me-interview">` in `<boundaries>` to mandate proactive grill-me stress-testing.
- Updated `skills/vibe-ai-tools/SKILL.md`:
  - Updated `<overview>` and `<step id="1" name="interactive_planning">` to cite `plan-ai-tools`'s grill-me planning workflow.
  - Refactored `<rule id="design-interview">` to `<rule id="grill-me-interview">` citing `plan-ai-tools` `<rule id="grill-me-interview">`.
- Updated documentation in `README.md` and `docs/USAGE.md`:
  - Documented `plan-ai-tools` structured grill-me design interview in `README.md` rule 23 and `docs/USAGE.md` delivery workflows.
  - Updated `vibe-ai-tools` documentation in `README.md` rule 24 and `docs/USAGE.md` to reference the grill-me protocol.
- Maintained all skill descriptions strictly <= 500 characters.
- Verification results:
  - `./scripts/lint.sh`: exit 0 (614 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (340 ok, 0 skipped, 0 warnings).
