# Skills on the session model

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools |
| 2 | F | implementer-ai-tools |
| 3 | F | implementer-ai-tools |
| 4 | F | implementer-ai-tools |
| 5 | F | implementer-ai-tools |
| 6 | | |
| 7 | | |

## Goal

This is the skills phase of the ai-tools restructure. `plan/remove-agents` already deleted the named agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`), their wrappers, `MODELS.csv`, and the model scripts. This phase reworks `skills/**` so that no skill depends on those agents:

- Every skill runs on the session model. The session plans, decides, accepts, commits, and delivers.
- Mechanical work (builds, test suites, script runs, bulk fact collection) goes to the harness's default subagent. It never runs on a named agent. It runs in the session only as a documented fallback outside campaign passes. A campaign pass that cannot spawn ends BLOCKED instead.
- Only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers. Before the first spawn they ask the user exactly one question: which implementer model to use, with 1-3 options. The session picks the options from the models its harness offers, guided by an `<implementer_job>` block in each of the two SKILL.md files.
- `campaign-ai-tools` keeps a clean context by running each planning pass and each execution pass in a fresh subagent on the session model.
- `skills/models-ai-tools` is deleted.
- The description `Agent:` field is rewritten, and lint enforces the new template `executor` convention and the `Agent:` field.
- README and `docs/USAGE.md` describe the new execution model. `USER-AGENTS.md` stays untouched.

## Base branch

`plan/remove-agents` (unmerged PR #21), analysed at `ee8596b`.

## Binding decisions (from the user)

1. **Coordination.** `vibe-ai-tools` plans and coordinates inline in the session: plan writing, stage acceptance, commits, archival, and the PR. `campaign-ai-tools` spawns a fresh subagent on the session model for each planning pass and each execution pass. Execution passes spawn implementers on the chosen model and send mechanical work to default workers.
2. **Job description location.** A self-contained `<implementer_job>` block lives inside the vibe SKILL.md and inside the campaign SKILL.md. There is no shared file and no installer change.
3. **Mechanical delegation.** Every skill may send mechanical work to the harness default worker. Only vibe and campaign spawn implementers and ask the model question.
4. **Description field.** The description order stays what, then `Impact:`, then `Agent:`. The value is `Agent: session.` for skills that never spawn implementers, and `Agent: session + implementer (model asked once).` for vibe and campaign.

Defaults applied (stated to the user; rationale recorded under Planner decisions):

- Delete `skills/models-ai-tools` entirely.
- Ask the implementer question once per run. Vibe asks after the plan is on disk and before unattended execution. Campaign asks at initialization, records the answer in `dev/improve/{CAMPAIGN}/campaign.md`, and reuses it for every iteration and on resume.
- If the harness cannot select a model per spawn, skip the question, use the harness default implementer, and say so in the report.

## Convention: template `executor` attribute

Every `<template>` keeps its functional `role`. The retired `agent="..."` attribute is replaced by `executor`, which takes one of three values:

| `executor` | Where the payload runs | Used by |
|---|---|---|
| `default-worker` | The harness's native subagent API with its default agent type and model | az, gc, gh (`mechanical-discovery`), update and remove (`script-runner`), dev (`stage-verifier`), plan (`repo-discovery`) |
| `implementer` | The native subagent API with the model the user chose through `<implementer_job>` | vibe and campaign (`stage-implementer`) |
| `session-subagent` | A fresh subagent with clean context on the session's own model | campaign (`campaign-planner`, `campaign-executor`) |

Why this convention:

- **It names where the payload runs, not an installed artifact.** Nothing needs installing, so the attribute cannot go stale the way `agent` did.
- **It covers the target model.** The three values correspond one-to-one to the user's three execution targets. The user's example value `session` is not used: inline session work never uses a template, and campaign passes run in a *spawned* context. `session-subagent` makes that difference explicit.
- **References stay stable.** `role` is unchanged, so references such as `` `<template role="stage-implementer">` `` still resolve.
- **Lint can check it.** The new name makes a leftover `agent=` attribute detectable, and the closed value set can be validated.

Work the session does itself (planning, implementation in dev, acceptance, commits) is written as `<session_workflow>` steps, never as templates.

## Reuse between skills (checked)

- `plan-ai-tools <plan_file_format>` stays the single plan format. It gains the base-plan and stage-file section lists that used to live in the deleted `plan-author` template. Vibe and the campaign planning pass cite it.
- `dev-ai-tools` becomes session-inline with explicit steps: branch and record (2), stage loop (3), and archive and deliver (4). Vibe runs dev steps 2-4 with one substitution: stage implementation goes to its `stage-implementer`. The campaign execution pass runs dev step 3 as its accepting context. Both reuse `dev-ai-tools <template role="stage-verifier">` for tests, so neither keeps its own verifier.
- `dev-ai-tools <status_protocol>` loses the words "coordinator" and "implementer dispatch". The accepting context owns every state except V. That context is the session in dev and vibe, and the execution pass in campaign. V is set by whoever implemented the stage.
- The base-plan Status table column `Agent` becomes `Executor`, filled with `session` or `implementer <model>`. This plan keeps the old `Agent` column because the currently installed dev-ai-tools executes it.
- `dev-ai-tools` and `vibe-ai-tools` drop `<return_protocol>`, because no coordinator returns to the session any more. Campaign keeps its protocol for pass signals. Nothing cites `dev-ai-tools <return_protocol>` (verified by grep).

## Execution graph

Run one stage at a time: 1 → 2 → 3 → 4 → 5 → 6 → 7.

- **1 is independent** of the others. It goes first so that later stages never touch `models-ai-tools` or `selection_method`.
- **2 and 3 are file-disjoint**, so they can be implemented concurrently. Commit 2 before 3.
- **3 before 4.** Vibe cites `dev-ai-tools <step id="4">`, `plan-ai-tools <step id="3">`, and the new `plan_file_format` sections, which stage 3 creates.
- **3 and 4 before 5.** Campaign cites `plan-ai-tools <template role="repo-discovery">` (stage 3) and uses `<implementer_job>`, which stage 4 registers in `XML_VOCAB`.
- **5 before 6.** Lint enforcement can only pass after every skill conforms.
- **6 before 7.** Stage 7 documents and greps the final state, and bumps the version once.

## Stages

1. [Delete models-ai-tools](./1-skills-session-model.md): remove the skill directory. Drop it from the lint shipped-skill list, and drop `selection_method` from `XML_VOCAB` and the README.
2. [Cloud and maintenance skills on the session model](./2-skills-session-model.md): az, gc, gh, update, and remove get `executor="default-worker"`, `Agent: session.`, and a `default-worker` rule. Update and remove send both dry run and execution to `script-runner`.
3. [dev and plan inline in the session](./3-skills-session-model.md): delete `dev-coordinator`, the dev `stage-implementer`, and `plan-author`. Add `repo-discovery`, give `stage-verifier` the `default-worker` executor, and write explicit dev steps. Neutral status owners, plan format sections.
4. [vibe inline with an implementer question](./4-skills-session-model.md): rewrite vibe around plan steps 1-3, the model question, and dev steps 2-4. Add `<implementer_job>`, register it in `XML_VOCAB`, the README vocabulary table, and README rule 5.
5. [campaign passes on session subagents](./5-skills-session-model.md): planning and execution passes use `executor="session-subagent"`. The model is asked at initialization, recorded in `campaign.md`, and reused on resume. `stage-implementer` uses `executor="implementer"`. A pass that cannot spawn subagents itself ends BLOCKED, with no fallback, and a BLOCKED campaign closes with a report.
6. [Lint the executor convention and the Agent: field](./6-skills-session-model.md): enforce valid `executor` values, reject `agent=`, check the ordered `Agent:` value, and check that implementer usage is consistent and limited to vibe and campaign. README rules 5, 6, and 9, the Semantic XML grammar, and Development checks change in the same commit.
7. [Documentation, version, final grep](./7-skills-session-model.md): update the README overview and rule 24, and `docs/USAGE.md` (execution model, vibe, dev, campaign). Bump the version and run the repository-wide grep.

## Baseline (measured on `plan/remove-agents` at `ee8596b`)

- `scripts/lint.sh`: exit 0, `340 ok, 1 skipped, 0 warnings`. The skip is the version-bump check, which needs `--base`.
- `scripts/test.sh`: exit 0, `307 ok, 0 skipped, 0 warnings`.
- shellcheck (CI command): only the known `SC1071` on `scripts/shell/install-zsh.sh`.
- Skill descriptions (characters, cap 500): az 308, campaign 374, dev 367, gc 306, gh 352, models 315, plan 281, remove 314, update 340, vibe 418.
- `scripts/test/**` never names `models-ai-tools` and does not run lint. Install and verify loop over `skills/*-ai-tools`.

## Design validation (planner, scratch copy)

The drafted targets were applied to a disposable copy of `ee8596b` outside the repository:

- stage 1
- stage 2 in structural form: executor, `Agent:`, and the shared rule
- the full stage 3-5 target texts, with verbatim placeholders filled
- the stage 6 lint code

Results:

- **After stages 1-5:** `scripts/lint.sh` exits 0 (`315 ok, 0 warnings`). Every cross-skill reference resolves, placeholder parity holds, and descriptions measure vibe 442, campaign 404, az 295, and remove 302 characters.
- **After stage 6:** lint exits 0 (`324 ok`, nine `skill Agent: matches implementer usage` lines). `shellcheck scripts/lint.sh` is clean, and the six stage 6 negative probes fail as described.
- **After the user-answer-2 revision:** the revised stage 5 campaign target and the stage 3 campaign sentence were re-applied on top of stage 6.
  - Lint exits 0 (`332 ok, 0 warnings`), and `<rule id="no-nested-fallback">`, `<signal code="BLOCKED">`, and `<step id="5">` resolve in campaign.
  - The no-fallback probe prints nothing, and `nested-spawn capability` hits exactly 3 lines.
  - The dev and plan rules each carry the campaign sentence once.

## Invariants for every stage

- `scripts/lint.sh` exits 0. A version-bump SKIP without `--base` does not fail.
- `scripts/test.sh` exits 0.
- shellcheck (`shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`) reports nothing beyond the known `SC1071`.
- `git diff --quiet ee8596b -- USER-AGENTS.md .github scripts/shell scripts/test` succeeds.
- Every skill description stays within 500 characters, checked by the lint output line `largest skill description`.
- No new files outside `skills/`, `scripts/lint.sh`, `README.md`, and `docs/USAGE.md`. No installer change.

## Final acceptance: repository-wide grep

Run from the repository root after stage 7. All three commands must print nothing. The allowlist is `USER-AGENTS.md` and `dev/` only. The third command is the no-fallback probe for campaign passes (user answer 2).

```bash
TERMS='(planner|implementer|mechanical)-ai-tools|models-ai-tools|MODELS\.csv|harness-models|aa-metrics|selection_method|agent="'
git ls-files --cached --others --exclude-standard -- . ':!USER-AGENTS.md' ':!dev' \
  | xargs -d '\n' grep -HnIE "$TERMS"

git grep -niE '\bagents?\b|coordinator|sub-dispatch|high-reasoning' -- skills \
  | sed -E 's/(USER-)?AGENTS(\.md)?//g; s/Agent://g' \
  | grep -iE '\bagents?\b|coordinator|sub-dispatch|high-reasoning'

git grep -niE 'carr(y|ies) (that|the) work itself|records? the fallback|fall(s)? back to the session|run the payload in the session|on the session model instead' -- skills/campaign-ai-tools
```

Also required: `git grep -n 'nested-spawn capability' -- skills/campaign-ai-tools` hits exactly 3 lines (the rule and one constraint per pass template).

Also required: `test ! -e skills/models-ai-tools`.

## Planner decisions (in scope, recorded)

- **Delete models-ai-tools (default confirmed).** Everything it maintains (`MODELS.csv`, wrapper pins, both scripts, the README anchor) is gone, and the implementer model is now chosen at runtime. Keeping the skill would ship a broken slash command. The only enumerations are `scripts/lint.sh` (`maintainer` list) and `XML_VOCAB` (`selection_method`, used only by that skill). README rule 5 and the vocabulary table name `<selection_method>`. `docs/USAGE.md` and the tests already omit it.
- **One question per run (default confirmed).** Vibe asks after the plan is on disk, so the user sees the scope before choosing capability versus cost. Unattended execution then never stops for it. Campaign asks at initialization, because passes are subagents with no user channel of their own. Recording the answer in `campaign.md` makes resume deterministic. A resumed `campaign.md` with no recorded model triggers the question once, then the answer is recorded.
- **Harness without per-spawn model selection (default confirmed).** Skip the question, record `harness default` as the model, and say so in the report. If a spawn with the chosen model fails, retry once with the harness default and log it. The user is not asked a second question.
- **Where spawn semantics live.** `USER-AGENTS <dispatch_protocol>` still points to the retired `agent` attribute and stays untouched in this phase. So every skill carries its own spawn rule in `<boundaries>`, naming the native subagent APIs. This is duplicated text, which README rule 5 allows. The native question tool is cited as `USER-AGENTS <user_interaction>`, which is still accurate.
- **Runtime reading of cited skills.** Vibe runs plan and dev steps by qualified reference. Campaign passes run from a payload, so their templates tell them to read `$HOME/.ai-tools/skills/campaign-ai-tools/SKILL.md` (and the cited sibling skills). `$HOME/.ai-tools` is the only supported clone (README rule 16).
- **Updated wording.** The update and remove descriptions still say "remove agents". Stage 2 rewrites them. The update report step no longer mentions agents.
- **Script-runner payload.** `script-runner` gains `{FLAGS}` and `{LOG_PATH}` so one template serves both the dry run and the approved execution, and placeholder parity holds.
- **Lint limits implementers to vibe and campaign.** The allowlist in `scripts/lint.sh` mirrors binding decision 3, next to the existing `gated` and `maintainer` lists.
- **No nested-spawn fallback in campaign passes (user answer 2).** Campaign passes are subagents that must spawn their own implementers and default workers.
  - **What a pass does.** When a pass cannot spawn one, it never does that work itself. It ends with `<signal code="BLOCKED">` and a reason naming the missing nested-spawn capability. This covers a planning pass that needs a test run or bulk discovery, and an execution pass that needs the implementer or a verifier.
  - **Where it is stated.** Stage 5 adds the rule `no-nested-fallback` and one constraint to each pass template. It also points `<implementer_job>` at that rule.
  - **dev and plan rules.** The `default-worker` rules of dev and plan run inside passes, through the reused `stage-verifier` and `repo-discovery`. Stage 3 adds a sentence excluding passes from their in-session fallback.
  - **What is still allowed.** A spawn rejected only for the chosen model may still retry once with the harness default model. That is still a spawn, not in-pass work.
  - **Termination.**
    - Step 1 (the model question) never spawns, so it reads unchanged.
    - Step 4 already stops the loop on BLOCKED and now names step 5 as the next step.
    - Step 5 gains a BLOCKED branch (open question 6).
- **Version.** One bump in stage 7, `0.0.48-ALPHA` → `0.0.49-ALPHA` (user answer 3).

## Risks

- **R1: Stale `USER-AGENTS.md` (kept untouched by scope).**
  - `<dispatch_protocol>` tells the session to "Spawn the agent in the cited `<template>`'s `agent` attribute". No template has that attribute any more.
  - `<agents>` lists the three deleted workers. `<system_overview>` says "Ten skills" (nine after stage 1).
  - `<rule id="memory-only">` names wrappers and `MODELS.csv`. The intro mentions "agent wrappers".
  - "If spawning fails, carry the work yourself" softens "mechanical work never on the session model".
  - Mitigation: each skill states its own spawn rule. A follow-up phase must rewrite `USER-AGENTS.md` before `master` ships this (user answer 5).
- **R2: Harness capability variance.** Per-spawn model selection and model enumeration are not uniform across Claude Code, Copilot, Codex, Grok, Antigravity, and Cursor, and this plan does not verify them per harness. The skip-and-report fallback covers "cannot select". A harness that accepts a model without listing its models forces the session to name options from its own knowledge.
- **R3: Nested spawning.** Campaign passes are subagents that must themselves spawn implementers and default workers, and some harnesses restrict subagents from spawning subagents. By user decision there is no fallback: on such a harness the first pass that needs a spawn ends BLOCKED, so `/campaign-ai-tools` cannot deliver there at all. The failure is explicit (a named capability in the BLOCKED reason and report), never silent session-model work. The model question at initialization is asked before this surfaces. The recorded model stays in `campaign.md` for a resume on a capable harness.
- **R4: The default worker may be the session model.** Some harnesses give a default subagent the parent's model, for example Claude Code without a configured subagent model. Mechanical work then costs session-tier tokens. This is accepted: the user asked for the harness default.
- **R5: Session context growth.** Dev and vibe now implement or review every stage inline, so long plans and dev Queue mode load more into the session. Mitigation: substance stays on disk, verifier output goes to `dev/tmp/*-output.log`, and review reads diffs, not logs.
- **R6: Cross-skill runtime references.** Vibe and campaign depend on the numbered dev steps 2-4 and plan steps 1-3. Renumbering those steps later breaks the meaning silently. Lint catches only a missing id, not a changed meaning.
- **R7: Cursor has no instructions destination.** `USER-AGENTS <user_interaction>` is not loaded there, so Cursor sessions ask the model question with their own default mechanism.
- **R8: Merge coupling with PR #21.** This branch builds on an unmerged PR, and the version bump and CI base depend on where the PR targets (open questions 3, 4).
- **R9: Locally modified installed `models-ai-tools` copies.** `update.sh` removes unmodified copies with the pre-reset clone. A locally edited copy stays as an orphan and makes verify warn (exit 2) until `--overwrite` or `--force`. This is existing, documented behaviour. No code is added.
- **R10: Known shellcheck SC1071** on `scripts/shell/install-zsh.sh`. Not a regression.
- **R11: Temporarily stale README.** Between stages 2 and 6, README rule 9 and the grammar still describe templates by `role` only, and the `Agent:` rule is absent. Stage 6 closes that gap within the same PR.

## User answers

1. **Mechanical work in the session (accepted).**
   - One-off pinpoint commands may run in the session.
   - Builds, tests, script runs, and bulk collection go to a default worker.
   - If a spawn fails, the session does the work itself and notes it in the report.
   - This applies outside campaign passes. It is carried by the stage 2 `default-worker` rule, and stage 3 excludes campaign passes from it.
2. **No nested spawning (changed from the recommendation).**
   - A campaign pass (`session-subagent`) that cannot spawn implementer or default-worker subagents itself must not fall back to doing that work on the session model.
   - It ends with `<signal code="BLOCKED">` and a reason naming the missing nested-spawn capability.
   - The campaign stops through its normal BLOCKED path and closes with a report. Stages 3, 5, and 7 and the final acceptance grep implement and probe this.
3. **Version (accepted).** Bump to `0.0.49-ALPHA` in stage 7.
4. **PR target (accepted).** The PR targets `plan/remove-agents`, so PR #21 takes both phases to `master`.
5. **USER-AGENTS.md (accepted).** It stays untouched in this phase. A dedicated later phase rewrites it before anything reaches `master`.
6. **BLOCKED closing in campaign step 5 (accepted).** A campaign that ends BLOCKED is not archived. The campaign sets its status to blocked in `campaign.md` with the reason, commits `chore(dev): block campaign {CAMPAIGN}`, reports, and stays resumable. Stage 5 already carries this.

## Open questions

None. Question 6 (BLOCKED closing in campaign step 5) is resolved by user answer 6. Archiving would remove `dev/improve/{CAMPAIGN}/` and the recorded implementer model, which would break resume on a capable harness.
