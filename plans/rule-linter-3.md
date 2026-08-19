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

- Extended `tools/lint.sh` (only file touched) with: `category_for`, `base_has_category`, `canonical_body`, `wrapper_body_md`, `wrapper_body_toml`, `check_wrapper_body` (rule 6); `model_effort_for`, `check_model_parity`, `check_effort_pinning` (rules 11-12); `check_description_parity`; `check_models_row_coverage`. Reused existing `harnesses`, `agent_names`, `wrapper_ext`, `wrapper_path`, `in_list`, `yaml_frontmatter_keys/value`, `toml_field_value`, and `model_for` from stage 1/`lib.sh` — no parallel helpers added. No vendor model name appears in the file; every expected model/effort is read from `MODELS.md` via `model_for`/`model_effort_for`.
- `canonical_body` reconstructs the exact wrapper body (first "On Windows..." paragraph only when the agent's base file cites `**planner**`/`**implementer**`/`**mechanical**`, via `base_has_category`'s grep — never a hard-coded agent list) and is compared with an exact string comparison (`[ "$actual" = "$expected" ]`) against text extracted per form: `wrapper_body_md` (after the frontmatter's closing `---`, dropping the one blank separator line) for `.md`/`.agent.md`, and `wrapper_body_toml` (the `developer_instructions` `"""`-delimited value) for `.toml`.
- Clean-tree run: `./tools/lint.sh` on the unmodified working tree — `done: 337 ok, 0 skipped, 0 warnings`, exit `0`. All 42 wrappers passed `wrapper body matches canonical text`, `model parity`, effort pinning (claude-code + codex, 11 each), Grok "declares no model key" (6), description parity (42), and MODELS.md row coverage (7 rows, 7 directories).
- Injected-violation tests, run against a throwaway copy at `/tmp/claude-1000/-home-wsl--ai-tools/c881ae73-747e-40f3-a416-f996d4a11717/scratchpad/lint-test*` (never in the working tree):
  1. Reordered the "On Windows..." and "Category → model..." paragraphs in `agents/claude-code/gh-ai-tools.md` → `WARN: wrapper body does not match canonical text: .../agents/claude-code/gh-ai-tools.md`, exit `2`.
  2. Changed `agents/claude-code/gh-ai-tools.md` `model: opus` → `model: totally-made-up-model` (a value MODELS.md does not carry) → `WARN: model mismatch: .../agents/claude-code/gh-ai-tools.md (expected: opus, got: 'totally-made-up-model')`. Same run, dropped `effort: medium` from `agents/claude-code/gc-ai-tools.md` → `WARN: effort not pinned or mismatched: .../agents/claude-code/gc-ai-tools.md (expected: medium, got: '')`. Combined exit `2`.
  3. Added `model: some-grok-model` to `agents/grok/gh-ai-tools.md` → `WARN: grok wrapper declares model: (Grok ignores it; pinned via ~/.grok/config.toml at install time): .../agents/grok/gh-ai-tools.md`, exit `2`.
  4. Changed `agents/cursor/gh-ai-tools.md`'s `description:` to `A different description entirely.` → `WARN: description diverges across wrappers for gh-ai-tools: .../agents/cursor/gh-ai-tools.md`. Same run, deleted the `` `grok` `` row from `MODELS.md` → `WARN: agents/grok/ has no MODELS.md row` plus one `WARN: no usable MODELS.md row for grok/<category>: <wrapper>` per Grok wrapper (model parity check correctly refuses to guess a model when the row is gone). Combined exit `2`.
- Every finding above names the offending wrapper path and the run exits `2`, matching the acceptance criteria. No wrapper, README, or MODELS.md file in the working tree was modified — `git status --short` shows only `plans/rule-linter-3.md` and `tools/lint.sh` changed by this stage (plus untracked `plans/rule-linter-6.md`/`.github/` from the parallel stage 6 dispatch, not touched here).

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | a6cb483de6eafa588 | V -> failed validation |
| 2 | V | implementer | sonnet | a6cb483de6eafa588 | V -> fixed inverted hascat gating |

## Correction round R1

Verified against the tree: `./tools/lint.sh` exits `0` with `337 ok, 0 skipped, 0 warnings`; no vendor model name appears anywhere in the file; every expected model resolves through `model_for` and every effort through `MODELS_MAP`; the grok, copilot-array, codex, and frontmatter forms are each handled as the stage specifies. One defect blocks acceptance.

1. **The conditional paragraph in `canonical_body` is the wrong one.** Step 3 of this stage, and README rule 6, make **the `MODELS.md` pointer** the paragraph that exists only when the base cites a category — that pointer is meaningless for an agent with no category. `canonical_body` instead gates the `On Windows, %USERPROFILE% replaces $HOME.` line on `hascat` and emits the `MODELS.md` pointer unconditionally. That is inverted.

   It passes today only because every shipped agent cites a category, so `hascat` is always `1` and both forms coincide. The first agent shipped without one would be compared against a reconstruction that drops the Windows note it does carry and demands a `MODELS.md` pointer it must not carry — a false finding on a correct wrapper, and no finding on the drift this check exists to reject.

   Fix: emit the Windows note unconditionally, and wrap only the `Category → model comes from …` paragraph in the `hascat` test. `base_has_category` itself is correct — keep it.

2. Add negative evidence for exactly this case, in a throwaway copy only: give an agent base a body citing no category, and confirm the check then expects a body without the `MODELS.md` pointer.

3. Re-run against the tree and record the new count and exit code.

Nothing else changes. Set the status back to `V` when done.

## Correction round R1 — resolution

- Fixed `canonical_body` in `tools/lint.sh`: the `On Windows, %USERPROFILE% replaces $HOME.` line is now emitted unconditionally; only the `Category → model comes from ...` (`MODELS.md` pointer) paragraph is wrapped in the `hascat` test. `base_has_category` was already correct and untouched. Diff (conceptual): moved the `if [ "$hascat" = 1 ]; then ... fi` guard from around the Windows-note `printf` to around the Category-pointer `printf`.
- Clean-tree re-run: `./tools/lint.sh` — `done: 337 ok, 0 skipped, 0 warnings`, exit `0` (unchanged from before the fix, since every shipped base still cites a category).
- Negative evidence added in a throwaway copy at `/tmp/claude-1000/-home-wsl--ai-tools/c881ae73-747e-40f3-a416-f996d4a11717/scratchpad/lint-r1` (deleted after the run; never touched the working tree):
  1. Stripped the `**planner**`/`**implementer**`/`**mechanical**` category citation from `agents/gh-ai-tools.md`, so `base_has_category gh-ai-tools` is now false.
  2. Rewrote `agents/claude-code/gh-ai-tools.md`'s body to keep the `On Windows, %USERPROFILE% replaces $HOME.` line but drop the `Category → model comes from ...` paragraph — the body a correct, category-less wrapper must have under the fixed reconstruction.
  3. Ran `./tools/lint.sh`: `agents/claude-code/gh-ai-tools.md` reported `ok: wrapper body matches canonical text` — confirming the fixed check accepts a correct body that omits only the `MODELS.md` pointer while keeping the Windows note (the case the R1 defect would have gotten backwards).
  4. The other six `gh-ai-tools` wrappers (antigravity, codex, copilot, cursor, gemini, grok), left with their original bodies (still carrying the `MODELS.md` pointer), each reported `WARN: wrapper body does not match canonical text: <path>` — confirming the fix still rejects the pointer paragraph once the base is category-less. Run totals: `done: 331 ok, 0 skipped, 6 warnings`, exit `2`.
- No other check, helper, or file was touched. `git status --short` in the working tree shows only `plans/rule-linter-3.md` and `tools/lint.sh` changed by this stage (`plans/rule-linter-6.md`, `plans/rule-linter.md`, and untracked `.github/` belong to parallel dispatches, not touched here).
