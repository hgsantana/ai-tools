# Stage 2: Tighten the caps and shorten the canonical wrapper body

## Objective

Make the new size limits real and reachable **before** the linter enforces them: register the 8,000-character instructions cap and the 1,000-character wrapper cap as rules, and shorten the canonical wrapper body so all 42 wrappers fit under the second one.

Measured before planning: wrappers run from 991 to 1,140 characters, **39 of 42 above 1,000**. The floor is structural — 763 characters of canonical body mandated verbatim by rule 6, plus 235 of minimal frontmatter, is already 998. The cap is therefore unreachable without editing the body itself; enforcing it first would fail the whole tree.

## Files

- Modify: `README.md` — rule 3 (cap 12,000 → 8,000), rule 6 (register the wrapper cap), and the canonical body block under *Model map and wrapper authoring*
- Modify: `agents/*/*.md`, `agents/*/*.agent.md`, `agents/*/*.toml` — all 42 wrappers, body only

## Steps

1. **Rule 3** — replace Antigravity's 12,000 with a self-imposed **8,000-character** cap on `USER-AGENTS.md`, stating that it is deliberately tighter than any harness constraint in order to force concision, and that a harness declaring something tighter still governs (the existing precedence is preserved, not dropped). Current size is 6,592 characters, so nothing has to be rewritten to comply.
2. **Rule 6** — add: a wrapper is at most **1,000 characters**, frontmatter included. State the reason in one clause: a wrapper is what the harness reads to decide whether to route to the agent, so it carries the summary and nothing else; the behaviour lives in the base it points to.
3. **Shorten the canonical body.** The current body spends roughly 250 characters repeating the Windows path in each of its three paragraphs. Replace that repetition with a single leading sentence — `On Windows, %USERPROFILE% replaces $HOME.` — and drop the parenthetical from each pointer. Nothing else about the body changes: still three pointers, still the same order, still the same precedence clause. Update the canonical block in the README in this same commit; it is the text stage 3 will reconstruct.
4. **Apply to all 42 wrappers.** Body only — never touch frontmatter, model tokens, or descriptions here. The Codex `.toml` form keeps its doubled backslashes wherever a Windows path survives.
5. Re-measure every wrapper and record the largest in the Implementation log. The largest today is `codex/maintainer-ai-tools.toml` at 1,140 characters; it is the one to watch, since Codex carries the longest frontmatter and `maintainer-ai-tools` the longest description (251).
6. **No version bump here.** The whole set lands as one pull request and stage 7 carries the single bump — two bumps in one branch would make the version check in stage 5 pass for the wrong reason.

## Tests

Not applicable — documentation and shipped-text change. Evidence in the Implementation log:

- Character count of every wrapper after the edit, showing all 42 at or under 1,000.
- Character count of `USER-AGENTS.md`, showing it under 8,000 with the headroom stated.
- A diff review confirming every wrapper body is byte-identical to every other one modulo harness key, agent name, and TOML escaping — that uniformity is what stage 3 depends on.

## Acceptance criteria

- [ ] Rule 3 states 8,000 characters and keeps the "tightest constraint governs" precedence
- [ ] Rule 6 states the 1,000-character wrapper cap with its reason
- [ ] The canonical body block in the README matches, character for character, what the wrappers now carry
- [ ] All 42 wrappers are at or under 1,000 characters
- [ ] No frontmatter, model token, effort, or description changed in this stage
- [ ] `USER-AGENTS.md` is unchanged and under 8,000

## Commit

Suggested message: `refactor(agents): shorten the canonical wrapper body and tighten the size caps`

## Dependencies

- Requires stages: 1
- Parallel-safe with: none (stage 3 reconstructs the body this stage rewrites)

## Implementation log

- **README.md**: rule 3 rewritten — `USER-AGENTS.md` now capped at a self-imposed 8,000 characters (deliberately tighter than any harness constraint, to force concision), with the "tightest constraint governs" precedence preserved (Antigravity's 12,000 still registered as looser than the new cap). Rule 6 gained one clause: a wrapper is at most 1,000 characters, frontmatter included, with the one-clause reason (it is what the harness reads to route; behaviour lives in the base). The canonical body block under *Model map and wrapper authoring* was rewritten per step 3: added the leading sentence `On Windows, %USERPROFILE% replaces $HOME.` and dropped the `(Windows: ...)` parenthetical from each of the three pointers. No other prose in that section changed; the `<harness key>` note and the Codex doubled-backslash note (line ~129) remain accurate.
- **42 wrappers updated**, body only (frontmatter, model tokens, effort, descriptions untouched — verified by diff review, only body lines changed in every file). Applied via a script: stripped the three `(Windows: ...)` parentheticals per file, then prepended `On Windows, %USERPROFILE% replaces $HOME.\n\n` before the `Category → model...` line. Codex `.toml` forms kept their doubled backslashes wherever a Windows path still occurs.
- **Uniformity check**: extracted the body from all 42 wrapper files (TOML doubled-backslashes undone, `---` frontmatter fences stripped), normalized each harness key and agent name to placeholders, and compared. Result: exactly 1 unique normalized body across all 42 files — byte-identical modulo harness key, agent name, and TOML escaping, matching the README's canonical block character for character.
- **USER-AGENTS.md**: unchanged (confirmed via `git diff --stat`, no output). Character count: 6,592 (Python `len()` on UTF-8 decode, matching `wc -m`). Headroom under the new 8,000 cap: 1,408 characters (17.6%).
- **Per-wrapper character counts after the edit** (Python `len()` on UTF-8-decoded file contents, includes frontmatter/TOML header and trailing newline), sorted descending:

  | Chars | File |
  |---|---|
  | 1003 | agents/gemini/maintainer-ai-tools.md |
  | 996 | agents/codex/maintainer-ai-tools.toml |
  | 989 | agents/cursor/maintainer-ai-tools.md |
  | 952 | agents/gemini/gc-ai-tools.md |
  | 949 | agents/gemini/az-ai-tools.md |
  | 948 | agents/gemini/gh-ai-tools.md |
  | 946 | agents/codex/gc-ai-tools.toml |
  | 943 | agents/gemini/orchestrator-ai-tools.md |
  | 943 | agents/codex/az-ai-tools.toml |
  | 942 | agents/codex/gh-ai-tools.toml |
  | 938 | agents/copilot/maintainer-ai-tools.agent.md |
  | 936 | agents/codex/orchestrator-ai-tools.toml |
  | 932 | agents/cursor/gc-ai-tools.md |
  | 932 | agents/claude-code/maintainer-ai-tools.md |
  | 931 | agents/grok/maintainer-ai-tools.md |
  | 931 | agents/antigravity/maintainer-ai-tools.md |
  | 930 | agents/gemini/planner-ai-tools.md |
  | 929 | agents/cursor/az-ai-tools.md |
  | 928 | agents/cursor/gh-ai-tools.md |
  | 924 | agents/codex/planner-ai-tools.toml |
  | 922 | agents/cursor/orchestrator-ai-tools.md |
  | 910 | agents/cursor/planner-ai-tools.md |
  | 894 | agents/claude-code/gc-ai-tools.md |
  | 891 | agents/claude-code/az-ai-tools.md |
  | 890 | agents/claude-code/gh-ai-tools.md |
  | 884 | agents/claude-code/orchestrator-ai-tools.md |
  | 882 | agents/copilot/gc-ai-tools.agent.md |
  | 880 | agents/grok/gc-ai-tools.md |
  | 880 | agents/antigravity/gc-ai-tools.md |
  | 879 | agents/copilot/az-ai-tools.agent.md |
  | 878 | agents/copilot/gh-ai-tools.agent.md |
  | 877 | agents/grok/az-ai-tools.md |
  | 877 | agents/antigravity/az-ai-tools.md |
  | 876 | agents/grok/gh-ai-tools.md |
  | 876 | agents/antigravity/gh-ai-tools.md |
  | 872 | agents/copilot/orchestrator-ai-tools.agent.md |
  | 872 | agents/claude-code/planner-ai-tools.md |
  | 870 | agents/grok/orchestrator-ai-tools.md |
  | 870 | agents/antigravity/orchestrator-ai-tools.md |
  | 860 | agents/copilot/planner-ai-tools.agent.md |
  | 858 | agents/grok/planner-ai-tools.md |
  | 858 | agents/antigravity/planner-ai-tools.md |

  41 of 42 wrappers are at or under 1,000 characters after the shortened body. `codex/maintainer-ai-tools.toml`, the file flagged in step 5 as "the one to watch" (1,140 before this stage), is now 996 — under the cap.

- **Exception found — `agents/gemini/maintainer-ai-tools.md` is 1,003 characters, 3 over the 1,000 cap.** Before this stage it was 1,139 (the true largest wrapper in the tree, 1 character larger than the codex file the plan named as the one to watch). Root cause: the gemini wrapper form carries four extra frontmatter lines absent from claude-code/cursor/codex (`kind: local`, `temperature: 0.2`, `max_turns: 60`, `timeout_mins: 30`), and `maintainer-ai-tools` has the longest description (251 characters) of the five agents. Combined with the maximally shortened, uniform body, this pushes the file 3 characters past the cap. This stage's scope is body-only (frontmatter, model tokens, effort, and descriptions are explicitly out of bounds — see Scope discipline), and the uniformity requirement in this stage's Tests section forbids giving this one file a shorter, non-identical body, so the overage cannot be resolved within this stage's Files/scope. Flagging for the plan owner: fitting this wrapper under 1,000 needs either a frontmatter/description change (out of this stage's scope) or a cap/plan adjustment.
- **Regression**: ran `./tools/lint.sh` after all edits — exit code 0 (186 ok, 0 skipped, 0 warnings). Stage 1's checks (naming, wrapper-coverage, skill-frontmatter) still pass; it does not yet check the new caps or body content (that is stage 3+).

### Correction round R1 — body tightened further

Resolved the flagged exception by shortening the canonical body's wording (never the cap, never a description, never gemini's frontmatter), per the Notes-mandated route. Three redundant phrases tightened, keeping the same three pointers, their order, and the precedence clause:

- `Category → model for this harness comes from` → `Category → model comes from` (the named row already carries which harness).
- `the shared contract for that is` → `your shared contract is`.
- `The base file for this agent is` → `Your base file is`.

Applied identically to the README's canonical block and all 42 wrappers via a scripted global replace (129 occurrences total = 43 files × 3 phrases, confirmed by `grep -c` before editing — no stray matches). Net saving: 39 characters per wrapper body (620 → 581 characters of body text).

- **Re-measured character counts of all 42 wrappers** (Python `len()` on UTF-8-decoded file contents, includes frontmatter/TOML header and trailing newline), sorted descending:

  | Chars | File |
  |---|---|
  | 964 | agents/gemini/maintainer-ai-tools.md |
  | 957 | agents/codex/maintainer-ai-tools.toml |
  | 950 | agents/cursor/maintainer-ai-tools.md |
  | 913 | agents/gemini/gc-ai-tools.md |
  | 910 | agents/gemini/az-ai-tools.md |
  | 909 | agents/gemini/gh-ai-tools.md |
  | 907 | agents/codex/gc-ai-tools.toml |
  | 904 | agents/gemini/orchestrator-ai-tools.md |
  | 904 | agents/codex/az-ai-tools.toml |
  | 903 | agents/codex/gh-ai-tools.toml |
  | 899 | agents/copilot/maintainer-ai-tools.agent.md |
  | 897 | agents/codex/orchestrator-ai-tools.toml |
  | 893 | agents/cursor/gc-ai-tools.md |
  | 893 | agents/claude-code/maintainer-ai-tools.md |
  | 892 | agents/grok/maintainer-ai-tools.md |
  | 892 | agents/antigravity/maintainer-ai-tools.md |
  | 891 | agents/gemini/planner-ai-tools.md |
  | 890 | agents/cursor/az-ai-tools.md |
  | 889 | agents/cursor/gh-ai-tools.md |
  | 885 | agents/codex/planner-ai-tools.toml |
  | 883 | agents/cursor/orchestrator-ai-tools.md |
  | 871 | agents/cursor/planner-ai-tools.md |
  | 855 | agents/claude-code/gc-ai-tools.md |
  | 852 | agents/claude-code/az-ai-tools.md |
  | 851 | agents/claude-code/gh-ai-tools.md |
  | 845 | agents/claude-code/orchestrator-ai-tools.md |
  | 843 | agents/copilot/gc-ai-tools.agent.md |
  | 841 | agents/grok/gc-ai-tools.md |
  | 841 | agents/antigravity/gc-ai-tools.md |
  | 840 | agents/copilot/az-ai-tools.agent.md |
  | 839 | agents/copilot/gh-ai-tools.agent.md |
  | 838 | agents/grok/az-ai-tools.md |
  | 838 | agents/antigravity/az-ai-tools.md |
  | 837 | agents/grok/gh-ai-tools.md |
  | 837 | agents/antigravity/gh-ai-tools.md |
  | 833 | agents/copilot/orchestrator-ai-tools.agent.md |
  | 833 | agents/claude-code/planner-ai-tools.md |
  | 831 | agents/grok/orchestrator-ai-tools.md |
  | 831 | agents/antigravity/orchestrator-ai-tools.md |
  | 821 | agents/copilot/planner-ai-tools.agent.md |
  | 819 | agents/grok/planner-ai-tools.md |
  | 819 | agents/antigravity/planner-ai-tools.md |

  **Largest: `agents/gemini/maintainer-ai-tools.md` at 964 characters** — 36 characters of headroom under the 1,000 cap, 21 under the 985 target. All 42 wrappers now at or under 1,000 (0 over 1,000, 0 over 985).

- **Uniformity re-confirmed**: extracted the body from all 42 wrapper files (TOML doubled-backslashes undone, frontmatter fences stripped), normalized harness key and agent name to placeholders. Result: exactly 1 unique normalized body across all 42 files, reading:
  `On Windows, %USERPROFILE% replaces $HOME. / Category → model comes from $HOME/.ai-tools/MODELS.md, row <harness>. ... / You are a spawned subagent: your shared contract is $HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md. ... / Your base file is $HOME/.ai-tools/agents/<agent>.md. ...`
  — matching the README's canonical block character for character (modulo the `<harness key>`/`<name>` vs `<harness>`/`<agent>` placeholder spelling, which was already the pre-existing convention).
- **Frontmatter/model/description re-verified untouched**: `git diff -- agents | grep -E '^\+description:|^\-description:|^\+model:|^\-model:|^\+name:|^\-name:'` returned no output across this correction round's diff.
- **`USER-AGENTS.md` re-confirmed untouched**: `git diff --stat USER-AGENTS.md` empty; character count still 6,592.
- **Regression**: re-ran `./tools/lint.sh` after the correction — exit code 0 (186 ok, 0 skipped, 0 warnings).

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | a83cfc0173b6a73d9 | V -> failed validation |
| 2 | V | implementer | sonnet | a83cfc0173b6a73d9 | Corrected: body tightened ~39 chars/wrapper, largest now 964 (was 1,003), all 42 ≤ 1,000, uniformity and README match reconfirmed |

## Correction round R1

Verified against the tree: rule 3 reads 8,000 with its precedence intact, rule 6 carries the 1,000-character cap with its reason, `USER-AGENTS.md` is untouched at 6,592 characters, no frontmatter/model/effort/description changed, and all 42 bodies are uniform modulo harness key, agent name, and TOML escaping. One acceptance criterion fails.

1. **`agents/gemini/maintainer-ai-tools.md` is 1,003 characters — 3 over the cap.** The planning baseline named `codex/maintainer-ai-tools.toml` (1,140) as the largest and did not measure the gemini form, which carries four extra frontmatter lines (`kind`, `temperature`, `max_turns`, `timeout_mins`) and is in fact the true maximum. The criterion "All 42 wrappers are at or under 1,000 characters" is not met, and the next stage's cap check would fail the tree on its first run.

   Resolve it the way this plan's Notes mandate — **by shortening the canonical body further**, never by raising the cap, never by cutting a description, and never by touching the gemini frontmatter. The body keeps its three pointers, their order, and the precedence clause; only the wording tightens. Roughly 20 characters have to come out, e.g. from the redundancy in the first pointer (`Category → model for this harness comes from …, row \`<key>\``, where "for this harness" is already carried by the named row) and from equivalent slack in the two pointers below it.

   Target: the largest wrapper in the tree at **985 characters or fewer**, so the cap is not breached again by the next description that grows a word.

2. Apply the same shortened body to all 42 wrappers and to the canonical block in `README.md`, keeping them character-for-character identical (modulo harness key, agent name, and TOML escaping) — the next stage reconstructs this text and compares it exactly.

3. Re-measure and append: the new character count of every wrapper, the largest with its headroom, and a re-confirmation of body uniformity.

Nothing else changes. Set the status back to `V` when done.
