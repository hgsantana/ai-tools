# Antigravity CLI slug tie-break

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools (sonnet) |

## Goal

Make the `MODELS.md` → *Antigravity CLI slugs* table reproducible: state how a
category becomes an `agy --model` slug, add the tie-break that spreads repeated
slugs across the reasoning tiers the CLI publishes, and apply it — planner
`gemini-3.7-flash-high`, implementer `-medium`, mechanical `-low`. README rule 13
gains the normative tie-break so a later pass can re-derive the table.

## Execution graph

Stage 1 only. `MODELS.md` and `README.md` change together (rule 12), so they are
one stage and one commit.

## Stages

1. [Derivation rule and tiered table](./agy-slug-tie-break-1.md) — rewrite the annotation's closing section and extend README rule 13

## Notes

- **Out of scope**: the `antigravity` map row stays `flash` for all three
  categories; the Score formula, the *Choosing the models* steps, every other
  harness row, and every wrapper are untouched. No README version bump (rule 4).
- **Dirty tree**: `README.md` and `MODELS.md` already carry the uncommitted
  introduction of rule 13, its renumbering, and a `0.0.27 → 0.0.28` bump. Those
  hunks travel with this commit; the other thirteen dirty files stay untouched
  (`dev/vibe/decisions-agy-slug-tie-break.md`, decision 2).
- **No cost or quota claim** for Antigravity — the vendor publishes none.
- Commit boundary: one `docs:` commit covering `MODELS.md` and `README.md`.
