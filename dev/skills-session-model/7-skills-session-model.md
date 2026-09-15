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
