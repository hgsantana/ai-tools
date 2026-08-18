# Stage 1: Skeleton, CLI contract, naming and coverage

## Objective

Create `tools/lint.sh` with its output and exit contract, and the first family of checks: every agent has a wrapper in every harness, and every installed name ends in `-ai-tools`.

## Files

- Create: `tools/lint.sh` — the linter; executable, LF, bash 3.2+ and BSD/GNU userlands, no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`

## Steps

1. Header comment: what the file is, that it is a **development check and not an installation process** (outside the contract of rules 23–25), and how to run it.
2. Resolve the repository root from the script's own location (`cd "$(dirname "$0")/.."`), export `AI_TOOLS` to that root, then source `scripts/shell/lib.sh`. Sourcing after the export is what makes `MODELS_MAP` resolve inside the checkout instead of `$HOME/.ai-tools` — CI checks out elsewhere.
3. Support `--help` (usage plus the check list) and `--version`-free minimalism; unknown flags exit `1` via `fatal`.
4. Report through `ok`/`warn`/`skip`/`info` and close with `finish` — this already yields exit `0` clean and `2` with findings. Never invent a second reporting style.
5. Discover the harness keys from `agents/*/` directories, and the agent names from `agents/*.md` excluding `SUBAGENT-CONTRACT.md`. Never hard-code either list — a new harness or agent must be picked up automatically.
6. **Check — wrapper coverage (rule 5)**: every agent name has exactly one wrapper in every harness directory, with that harness's extension (`.md`, `.agent.md` for copilot, `.toml` for codex). Report a missing wrapper and an orphan wrapper (a file matching no base) separately.
7. **Check — naming (rule 13)**: every agent base file, every wrapper, every `skills/*/` directory, and every `name:` in agent and skill frontmatter ends in `-ai-tools`.
8. **Check — skill frontmatter (rule 9)**: every `skills/*/SKILL.md` exists and its frontmatter keys are a subset of `name`, `description`, `argument-hint`.
9. **Check — skill name matches its directory**: `skills/<x>/SKILL.md` declares `name: <x>`.

## Tests

No test framework is introduced (roadmap story 2 owns that). Evidence instead, recorded in the Implementation log:

- Run against the tree: every check reports `ok`, exit code `0`.
- Negative evidence per check: copy the tree to a throwaway directory under the system temp dir, inject one violation (delete a wrapper; rename a skill directory without the suffix; add a `model:` key to a `SKILL.md`), run the linter there, and record the message and exit code `2`. Never inject a violation into the working tree.

## Acceptance criteria

- [ ] `tools/lint.sh` exits `0` on the current tree with no warning
- [ ] Each check above reports `2` with a message naming the offending path when its violation is injected into a throwaway copy
- [ ] Harness keys and agent names are derived from the tree, never hard-coded
- [ ] `lib.sh` is sourced, not copied: no duplicated reporting or model-lookup logic
- [ ] `--help` lists every check; an unknown flag exits `1`
- [ ] File is committed executable with LF endings

## Commit

Suggested message: `chore(tools): add a rule linter with naming and coverage checks`

## Dependencies

- Requires stages: none
- Parallel-safe with: none (stages 2–4 extend this same file)

## Implementation log

- Created `tools/lint.sh` (267 lines, executable, LF-only — verified `grep -c $'\r'` = 0). Sources `scripts/shell/lib.sh` after exporting `AI_TOOLS` to the repo root resolved from `$(dirname "$0")/..`. Reports via `ok`/`warn`/`skip`/`info`/`finish` from `lib.sh` only — no duplicate reporting or model-lookup logic.
- Discovery is tree-derived, never hard-coded: `harnesses()` lists `agents/*/` directory basenames; `agent_names()` lists `agents/*.md` basenames excluding `SUBAGENT-CONTRACT.md`. Wrapper extension per harness (`.toml` codex, `.agent.md` copilot, `.md` everyone else) is the one hard-coded mapping, taken from the README's "Supported harnesses" table (syntax, not a discovered list).
- Implemented checks: wrapper coverage (rule 5, missing + orphan wrapper), naming (rule 13: agent base files, wrapper files, skill directories, and every `name:`/`name =` in frontmatter), skill frontmatter keys subset of `name`/`description`/`argument-hint` (rule 9), and skill name matching its directory.
- `--help` (`bash tools/lint.sh --help`): prints usage plus all four checks, exit 0.
- Unknown flag (`bash tools/lint.sh --bogus`): `ERROR: unknown flag: --bogus (see --help)`, exit 1 (via `lib.sh`'s `fatal`).
- Full run against the working tree (`bash tools/lint.sh`): `done: 186 ok, 0 skipped, 0 warnings`, exit 0 — confirms the baseline is clean.
- Found and fixed a bug during testing: `agent_names()` output (newline-separated) fed directly into the space-padded `in_list` pattern caused every orphan check to false-positive (42 spurious warnings) because `case " $2 " in *" $1 "*)` needs space-separated haystacks, not newline-separated. Fixed by `agents=$(agent_names | tr '\n' ' ')` in `check_wrapper_coverage`. Re-run after fix: `done: 186 ok, 0 skipped, 0 warnings`, exit 0.
- Negative evidence, each run against a throwaway copy at `/tmp/.../scratchpad/lint-neg/tree` (never the working tree), restored/discarded after each case:
  - Deleted `agents/claude-code/az-ai-tools.md`: `WARN: missing wrapper: .../agents/claude-code/az-ai-tools.md`, exit 2.
  - Added `agents/claude-code/stray-ai-tools.md` (copy of an existing wrapper, name matching no agent): `WARN: orphan wrapper (matches no agent): .../agents/claude-code/stray-ai-tools.md`, exit 2.
  - Renamed `skills/az-ai-tools` to `skills/az`: `WARN: skill directory does not end in -ai-tools: .../skills/az/` and `WARN: skill name does not match its directory: .../skills/az/SKILL.md (name: 'az-ai-tools', directory: 'az')`, exit 2.
  - Inserted `model: opus` into `skills/az-ai-tools/SKILL.md` frontmatter: `WARN: skill frontmatter key not allowed by every harness: .../skills/az-ai-tools/SKILL.md (key: model)`, exit 2.
- `shellcheck` is not installed in this environment (`command -v shellcheck` → not found); CI (a later stage) runs it. `bash -n tools/lint.sh` passes.
- Working tree confirmed clean after all negative testing: `git status --short` shows only the pre-existing `plans/rule-linter-1.md`/`plans/rule-linter.md` modifications and the new untracked `tools/`.

## Correction round R1 — fix applied

- Replaced the top-level `for arg in "$@"; do ... done` flag loop with `while [ $# -gt 0 ]; do case "$1" in ... esac; shift; done`, matching `install.sh`/`update.sh`/`remove.sh`/`reinstall.sh`/`verify.sh`. Behaviour unchanged: `--help`/`-h` → `usage; exit 0`; anything else → `fatal "unknown flag: $1 (see --help)"` (exit `1`). No other line in `tools/lint.sh` touched; no other file touched.
- `bash -n tools/lint.sh`: syntax OK.
- No-argument run (`bash tools/lint.sh`): exit `0`, `done: 186 ok, 0 skipped, 0 warnings` — confirms the previous unbound-`$@` abort under `set -u` is gone.
- `bash tools/lint.sh --help`: exit `0`.
- `bash tools/lint.sh --bogus`: `ERROR: unknown flag: --bogus (see --help)`, exit `1`.
- `bash --version` in this environment is 5.3.9 (no 3.2 interpreter available to test directly); the fix reuses the exact `while [ $# -gt 0 ]`/`shift` construction already relied on as bash-3.2-safe by the repository's five existing shell scripts.
- `git status --short` after the fix: only `plans/rule-linter-1.md`/`plans/rule-linter.md` (pre-existing) and untracked `tools/` — no other file changed.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | a0998eecc1cf57bb1 | V -> failed validation |
| 2 | R1 | implementer | sonnet | a0998eecc1cf57bb1 | V -> accepted |

## Correction round R1

Validated against the tree: the run exits `0` with `186 ok, 0 warnings`; `--help` exits `0`; an unknown flag exits `1`. Every check family required by this stage is present and derives harness keys and agent names from the tree. One defect blocks acceptance.

1. **Flag parsing breaks the stage's own portability contract.** `for arg in "$@"` at the top level runs under `set -u` (inherited from `lib.sh`). In bash before 4.4 — which includes bash 3.2, the macOS default this file's header and `lib.sh` both claim compatibility with — `"$@"` with zero positional parameters is treated as an unbound variable, so the default no-argument invocation `tools/lint.sh` aborts before any check runs. It also diverges from this repository's established style: `install.sh`, `update.sh`, `remove.sh`, `reinstall.sh`, and `verify.sh` all parse flags with `while [ $# -gt 0 ]`.

   Replace the loop with the same `while [ $# -gt 0 ]` / `shift` form those five scripts use, keeping the behaviour identical: `--help`/`-h` prints usage and exits `0`, anything else goes to `fatal` (exit `1`). Later stages add `--base <ref>`, which takes a value — the `while`/`shift` form accommodates that, the `for` form does not.

2. Re-verify after the change and append the evidence: no-argument run exits `0`, `--help` exits `0`, unknown flag exits `1`.

Nothing else in the file needs to change. Do not extend the checks, do not touch other files, and set the status back to `V` when done.
