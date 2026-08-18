# Stage 3: Wrapper body and model parity

## Objective

Enforce the two rules most likely to drift silently: a wrapper body is exactly the canonical text (rule 6), and its pinned model is exactly the `MODELS.md` cell for that harness and category (rules 11–12).

## Files

- Modify: `tools/lint.sh` — add both checks

## Steps

1. **Reconstruct, do not pattern-match.** Given a harness key and an agent name, the canonical body is fully determined (README → *Model map and wrapper authoring*): the `MODELS.md` pointer naming that row, the `SUBAGENT-CONTRACT.md` pointer, and the base pointer — in the shortened form stage 2 leaves in the README, with the Windows note stated once instead of per pointer. Build the expected string and compare it against the wrapper's body with an exact string comparison. A regex would accept the drift this check exists to reject.
2. Body extraction per form: after the closing `---` of YAML frontmatter for `.md` and `.agent.md`; the value of `developer_instructions` for `.toml`, whose Windows paths carry **doubled** backslashes.
3. The first paragraph (the `MODELS.md` pointer) is present only when the base cites a category (rule 6). Decide its presence by grepping the base for `**planner**`, `**implementer**`, or `**mechanical**` — never from a hard-coded list of agents.
4. **Check — model parity (rule 12).** The expected model is `model_for <harness key> <category>`, where the category is `implementer` for `maintainer-ai-tools` and `planner` for every other shipped agent. Compare it against the model declared in the wrapper header, per form:
   - `claude-code`, `antigravity`, `cursor`, `gemini`: frontmatter `model:`
   - `copilot`: frontmatter `model:`, which must be a **string**, never the array form
   - `codex`: `model = "…"`
   - `grok`: **exempt** — Grok ignores `model:` in frontmatter and is pinned from `~/.grok/config.toml` at install time. Assert the wrapper has **no** `model:` key, and report a `model:` there as a finding.
5. **Check — effort pinning.** When the `MODELS.md` cell carries ` · effort`, the wrapper must pin that effort where its form can hold one, in the vendor's spelling: `effort:` (claude-code), `model_reasoning_effort` (codex), the bracketed parameter inside the model token (cursor). Where the form cannot hold effort, assert nothing — a missing effort there is correct, not a finding.
6. **Check — description parity**: the same agent's `description` is identical across all seven wrappers. They are today, and a divergence is drift nobody would otherwise notice.
7. **Check — row coverage (rule 12)**: every `agents/<key>/` directory has a `MODELS.md` row, and every `MODELS.md` row has a directory. A row without a directory is a harness half-added.

## Tests

Same approach as stage 1: throwaway copy, one injected violation per check, evidence in the Implementation log.

- Reorder two paragraphs of a wrapper body; add a sentence to one.
- Change a wrapper's `model:` to a value the map does not carry; drop an `effort:` whose cell has one.
- Add a `model:` key to a Grok wrapper.
- Change one wrapper's `description`; delete a `MODELS.md` row.

## Acceptance criteria

- [ ] The body check compares reconstructed text exactly and passes on all 42 current wrappers
- [ ] Model parity passes on all wrappers, resolving every value through `model_for`, with no vendor model name written into `tools/lint.sh`
- [ ] Grok wrappers pass while declaring no model, and fail when one is added
- [ ] Effort is asserted only for the three forms that can pin it, and only when the cell carries one
- [ ] Every injected violation above produces a message naming the wrapper and exit `2`

## Commit

Suggested message: `chore(tools): check wrapper bodies and model-map parity`

## Dependencies

- Requires stages: 2
- Parallel-safe with: none

## Implementation log
