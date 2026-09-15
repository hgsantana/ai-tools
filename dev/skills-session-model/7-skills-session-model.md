# Stage 7: Documentation, version, final grep

## Objective

README and `docs/USAGE.md` describe how skills execute:

- Every skill runs on the session model.
- Mechanical work goes to the harness default subagent.
- Only vibe and campaign spawn implementers, after one model question. Vibe asks after the plan is on disk. Campaign asks at initialization, records the answer in `campaign.md`, and reuses it on resume.
- Campaign passes are fresh subagents on the session model.

The version is bumped once, and the repository-wide grep from the base plan passes.

## Files

- Create: none
- Modify:
  - `README.md`: version line, overview item 4, rule 24
  - `docs/USAGE.md`: new execution subsection, Delivery workflows, Continuous improvement campaign
- Remove: none

## Steps

### README.md

1. Version line: `0.0.48-ALPHA` → `0.0.49-ALPHA` (user answer 3).
2. Overview "How it operates", item 4: "**Session-first skills.** Skills provide session-directed workflows in semantic XML. The host session executes them on its own model, interacts with the user, and coordinates git delivery. Builds, tests, script runs, and bulk fact collection go to the harness's default subagent; only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers, on a model the user picks from one question."
3. Rule 24, the `campaign-ai-tools` sentence becomes: "`campaign-ai-tools` repeatedly invokes this sequence in campaign mode under user-defined priorities: a fresh subagent on the session model writes each user-directed multi-stage plan, a different fresh subagent on the session model executes and judges it with implementers on the model the user chose when the campaign started, and accepted commits accumulate locally on `improve/<campaign>` without a push or pull request."
4. Leave the rest unchanged. Stage 6 already updated rules 5, 6, and 9, the grammar, and Development checks. Check the anchors: `grep -oE '\]\(#[a-z0-9-]+\)' README.md docs/USAGE.md | sort -u` must match existing headings only.

### docs/USAGE.md

5. After the Skills table and before "### Delivery workflows", add:
   ```
   ### Who does the work

   Every skill runs on the session's model: the session plans, decides, reviews, and commits. Builds, test suites, script runs, and bulk fact collection go to the harness's default subagent. The skill offer's Agent column shows `session`, or `session + implementer (model asked once)` for the two skills below.

   `/vibe-ai-tools` and `/campaign-ai-tools` also spawn implementer subagents that write stage code. Before the first one, they ask one question: which model implements the stages, with one to three models the harness can use. `/vibe-ai-tools` asks after the plan is on disk. `/campaign-ai-tools` asks when the campaign starts, records the answer in `dev/improve/<campaign>/campaign.md`, and reuses it for every iteration and on resume. A harness that cannot choose a model per subagent skips the question and uses its default; the report says so.
   ```
6. Delivery workflows:
   - vibe paragraph: "…It follows `/plan-ai-tools` to align scope with the user interactively and writes the agreed plan to disk. It then asks which model implements the stages and follows `/dev-ai-tools` unattended, with implementer subagents writing stage code. Decisions are recorded in `dev/<slug>/vibe-decisions.md`."
   - dev paragraph: "…It implements each stage in the session, sends tests to the harness's default subagent, commits every accepted stage, archives the temporary work files, and opens a pull request or writes a local review patch when no host is available."
7. Continuous improvement campaign:
   - First paragraph: "`/campaign-ai-tools` uses a single initial gate, followed by one question about the implementer model. Choosing it authorizes…" (rest unchanged).
   - "The campaign creates or resumes local branch `improve/repository-hardening`, records the implementer model, and commits `dev/improve/repository-hardening/campaign.md` at start. Each iteration chains planning and execution passes in fresh subagents on the session model while keeping the orchestrating session lean:"
   - Step 1: "A fresh planning subagent evaluates the campaign branch and follows `plan-ai-tools`, saving one multi-stage plan under `dev/<slug>/`…" (rest unchanged).
   - Step 2: "A separate fresh execution subagent runs the `dev-ai-tools` stage loop against that plan, spawning implementers on the recorded model."
   - Paragraph after the steps: "…Planning decides in-scope questions under the initial gate; after the implementer-model question at start, the user is not interrupted." (rest unchanged).
   - Resume paragraph: add "A resumed campaign reuses its recorded implementer model." after the resume code block's lead sentence, or directly after the code block.
   - In the paragraph about the orchestrating session, after "Work needing remote mutation, an external write, or an unversioned destructive action blocks instead of expanding the authorization.", add: "Planning and execution passes must spawn their own implementer and default subagents. On a harness where they cannot, the first pass that needs one stops the campaign as blocked, with a report naming the missing capability. The pass does not do that work itself."

### Final grep and checks

8. Run the three commands from the base plan's "Final acceptance: repository-wide grep" and `test ! -e skills/models-ai-tools`. Record the output (expected empty) in the Implementation log.

## Tests

- All three final-acceptance grep commands print nothing (the third is the campaign no-fallback probe), and `test ! -e skills/models-ai-tools` succeeds.
- `grep -n 'stops the campaign as blocked' docs/USAGE.md` hits once, and `docs/USAGE.md` describes no in-pass fallback.
- `grep -n 'Version 0.0.49-ALPHA' README.md` hits line 3.
- `scripts/lint.sh` exits 0. `scripts/lint.sh --base plan/remove-agents` also exits 0, which confirms the version bump against the PR base.
- `scripts/test.sh` exits 0. The CI shellcheck command reports only the known `SC1071`.
- `git diff --quiet ee8596b -- USER-AGENTS.md .github scripts/shell scripts/test` succeeds.
- `grep -nE 'implementer|default subagent|session model' docs/USAGE.md` shows the new subsection, vibe, dev, and campaign text. No text names `planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`, or `models-ai-tools`.

## Acceptance criteria

- [ ] README overview and rule 24 describe session-model skills, default-worker mechanics, and the implementer question
- [ ] `docs/USAGE.md` explains who does the work, the one question and its timing for vibe and campaign, and resume reuse
- [ ] Version bumped once to `0.0.49-ALPHA`
- [ ] `docs/USAGE.md` states that a campaign on a harness without nested spawning stops as blocked, and describes no in-pass fallback
- [ ] Repository-wide grep passes with only `USER-AGENTS.md` and `dev/` allowlisted
- [ ] lint (with and without `--base plan/remove-agents`) and test exit 0; shellcheck shows no new finding; `USER-AGENTS.md` unchanged

## Commit message

`docs: describe session-model skills and the implementer model question`

## Dependencies

- Requires stages: 6

## Implementation log

`README.md`:
- Version line (line 3): `0.0.48-ALPHA` -> `0.0.49-ALPHA`.
- Overview item 4 ("Session-first skills"): appended "on its own model" to the first sentence and the new sentence "Builds, tests, script runs, and bulk fact collection go to the harness's default subagent; only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers, on a model the user picks from one question." after it.
- Rule 24, the `campaign-ai-tools` sentence: "a fresh planner writes ... a different fresh planner executes and judges it" -> "a fresh subagent on the session model writes ... a different fresh subagent on the session model executes and judges it with implementers on the model the user chose when the campaign started", rest unchanged.
- No other text touched. Anchor check below confirms no heading was added or renamed.

`docs/USAGE.md`:
- Inserted new "### Who does the work" subsection (two paragraphs, verbatim from the stage spec) between the Skills table and "### Delivery workflows".
- vibe paragraph: replaced the tail after "...writes the agreed plan to disk." with "It then asks which model implements the stages and follows `/dev-ai-tools` unattended, with implementer subagents writing stage code. Decisions are recorded in `dev/<slug>/vibe-decisions.md`."
- dev paragraph: replaced "It runs edits and tests, commits every accepted stage, ..." with "It implements each stage in the session, sends tests to the harness's default subagent, commits every accepted stage, ...".
- Campaign section: first paragraph now reads "...uses a single initial gate, followed by one question about the implementer model. Choosing it authorizes..." (rest unchanged); the branch/commit paragraph now says "...records the implementer model, and commits..." and "chains planning and execution passes in fresh subagents on the session model..."; step 1 now says "A fresh planning subagent evaluates ... follows `plan-ai-tools` ..." (second sentence unchanged); step 2 now reads "A separate fresh execution subagent runs the `dev-ai-tools` stage loop against that plan, spawning implementers on the recorded model."; steps 3-4 left untouched (not in scope); the orchestrating-session paragraph now reads "...after the implementer-model question at start, the user is not interrupted." and gained the new sentence "Planning and execution passes must spawn their own implementer and default subagents. On a harness where they cannot, the first pass that needs one stops the campaign as blocked, with a report naming the missing capability. The pass does not do that work itself." inserted before "Campaign delivery remains local: ..."; added "A resumed campaign reuses its recorded implementer model." directly after the resume code block.

Checks run from the repository root (working tree, before any stage-7 commit):

- `grep -oE '\]\(#[a-z0-9-]+\)' README.md docs/USAGE.md | sort -u`: 7 anchors (`#development-checks`, `#installation`, `#removal`, `#safety-rules`, `#scripts`, `#semantic-xml-grammar`, `#supported-harnesses`, `#update`), all matching existing `##`/`###` headings. No heading was added/renamed by this stage.
- `grep -n 'Version 0.0.49-ALPHA' README.md`: 1 hit, line 3.
- `grep -n 'stops the campaign as blocked' docs/USAGE.md`: 1 hit (the new sentence in the orchestrating-session paragraph). No in-pass fallback described elsewhere in the file.
- `grep -nE 'implementer|default subagent|session model' docs/USAGE.md`: hits in the new "Who does the work" subsection, the vibe/dev paragraphs, and all touched campaign text. `grep -nE 'planner-ai-tools|implementer-ai-tools|mechanical-ai-tools|models-ai-tools' docs/USAGE.md`: no hits.
- `test ! -e skills/models-ai-tools`: succeeds (already absent since stage 1).

Final-acceptance repository-wide grep (base plan, run as-is; `--exclude-standard` already excludes untracked `dev/tmp`):
1. `TERMS='(planner|implementer|mechanical)-ai-tools|models-ai-tools|MODELS\.csv|harness-models|aa-metrics|selection_method|agent="'` over `git ls-files --cached --others --exclude-standard -- . ':!USER-AGENTS.md' ':!dev' | xargs -d '\n' grep -HnIE "$TERMS"`: **one hit**, `scripts/lint.sh:532: if (tok ~ / agent="/) print "<template> with retired agent attribute at line " NR`. This is the linter's own detection pattern for the retired `agent="..."` attribute (added in stage 6, undeclared for stage 7), not a live `agent="` usage; `scripts/lint.sh` is outside this stage's declared files (README.md, docs/USAGE.md only), so it is reported here rather than edited.
2. `git grep -niE '\bagents?\b|coordinator|sub-dispatch|high-reasoning' -- skills | sed -E 's/(USER-)?AGENTS(\.md)?//g; s/Agent://g' | grep -iE '\bagents?\b|coordinator|sub-dispatch|high-reasoning'`: **not empty** — 10 hits, all pre-existing `default-worker`/`spawn-apis` rule text in `skills/{az,campaign,dev,gc,gh,plan,remove,update,vibe}-ai-tools/SKILL.md` matching on the phrase "default agent type and model" (from stages 2-6, none touched by this stage), plus one incidental hit on the word "Agent" in `plan-ai-tools/SKILL.md:38` ("its Impact and Agent from the skill description"). The sed strip only removes literal `AGENTS`/`USER-AGENTS`/`Agent:`, so lowercase "agent" inside "agent type" survives and matches `\bagents?\b`. These files are outside this stage's declared scope (README.md, docs/USAGE.md), so they are reported here rather than edited.
3. No-fallback probe over `skills/campaign-ai-tools`: **empty** (exit 1 from grep, i.e. no match) — clean.
4. `git grep -n 'nested-spawn capability' -- skills/campaign-ai-tools`: 3 hits (the rule and one constraint per pass template), as required.
5. `test ! -e skills/models-ai-tools`: succeeds.

`scripts/lint.sh` (no `--base`): exit 0, `335 ok, 1 skipped, 0 warnings` (skip: version bump check needs `--base`).

`scripts/lint.sh --base plan/remove-agents`: exit 2, `335 ok, 0 skipped, 1 warnings` — `WARN: shipped content changed without a README version bump (still 0.0.48-ALPHA, was 0.0.48-ALPHA): scripts/lint.sh skills/*/SKILL.md ...`. `check_version_bump` diffs `git show <base>:README.md` against `git show HEAD:README.md`, i.e. committed content only; this stage's version bump (README.md now 0.0.49-ALPHA in the working tree) is not yet committed, so HEAD still reads 0.0.48-ALPHA. This is expected pre-commit and matches how stage 6 deferred the same check (it ran lint without `--base`); it should read `ok: version bumped ...` and exit 0 once this stage's changes land in a commit on top of stages 1-6.

`scripts/test.sh`: exit 0, `305 ok, 0 skipped, 0 warnings`.

CI shellcheck command `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`: only the known `SC1071` on `scripts/shell/install-zsh.sh` (exit 1 from that error, no other finding).

`git diff --quiet ee8596b -- USER-AGENTS.md .github scripts/shell scripts/test`: exit 0 (no diff); `USER-AGENTS.md` unchanged.

Net: README.md and docs/USAGE.md changes match the stage spec and their targeted greps/anchors all pass. Two of the three base-plan final-acceptance greps do not currently print nothing: grep 1 flags `scripts/lint.sh`'s own retired-attribute detection string, and grep 2 flags pre-existing "agent type" phrasing in the `default-worker`/`spawn-apis` rules shipped by stages 2, 3, and 6, plus one "Impact and Agent" mention in plan-ai-tools. Both are outside `README.md`/`docs/USAGE.md`, so no edit was made for them per this stage's constraints; they are reported here for the orchestrating session to resolve (regex refinement in the final-acceptance grep, or rule-text rewording, whichever the base plan intends) before treating stage 7 as fully closed. The `--base` lint warning is expected to clear on commit and is not a defect.

Coordinator acceptance note: accepted. Verifier log: dev/tmp/skills-session-model-stage7-output.log (lint 0, test 0, shellcheck only SC1071, invariants 0, lint --base plan/remove-agents 0 on a snapshot commit). All README/USAGE anchors resolve (re-checked in session; the verifier's 8 "missing" anchors were a slug-computation error). Final-acceptance grep 3 prints nothing and `test ! -e skills/models-ai-tools` succeeds. Greps 1 and 2 keep only mandated or pre-existing text, accepted as documented exceptions, none naming a retired agent:
- grep 1: `scripts/lint.sh` detector line `tok ~ / agent="/` (stage 6 mandated code that enforces the retirement).
- grep 2: "default agent type and model" in the default-worker/spawn-apis rules of nine skills (stage 2 shared rule accepted verbatim by the user, user answer 1; stage 4/5 targets); plan-ai-tools step 2 "stating its Impact and Agent from the skill description" (pre-existing, kept byte for byte by stage 3; names the description `Agent:` field); update/remove rule id `home-agents-untouched` (pre-existing; names `$HOME/AGENTS.md`).
