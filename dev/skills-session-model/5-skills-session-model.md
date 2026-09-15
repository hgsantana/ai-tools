# Stage 5: campaign passes on session subagents

## Objective

`campaign-ai-tools` keeps its loop, but the passes change:

- Each planning pass and each execution pass runs in a fresh subagent on the session model (`executor="session-subagent"`).
- The session asks the implementer-model question once, at initialization, records it in `dev/improve/{CAMPAIGN}/campaign.md`, and reuses it for every iteration and on resume.
- Execution passes run dev-ai-tools step 3 as the accepting context. They spawn `stage-implementer` with the recorded model and send tests to the dev `stage-verifier` default worker.
- Planning passes send discovery to plan-ai-tools `repo-discovery`.

## Files

- Create: none
- Modify:
  - `skills/campaign-ai-tools/SKILL.md` (full rewrite to the target below)
- Remove: none

## Steps

1. Replace `skills/campaign-ai-tools/SKILL.md` with the target below.
   - The campaign `stage-verifier` template is deleted.
   - `<return_protocol>` and the rules `strictly-local`, `preserve-history`, and `tmp-untracked` keep their current text.
   - Steps 4 and 5 change only as shown in the target.
2. No nested-spawn fallback (user answer 2 in the base plan). A pass that cannot spawn an implementer or a default worker never does that work itself. It ends with `<signal code="BLOCKED">` and a reason naming the missing nested-spawn capability. The campaign then stops through step 4 and closes in step 5. This is carried by:
   - rule `no-nested-fallback`
   - one constraint in each pass template
   - the `implementer_job` sentence that points to that rule

   No text may tell a pass to carry the implementer's or a default worker's work itself, or to record such a fallback.
3. BLOCKED closing (step 5) follows base plan user answer 6: skip archival so the campaign stays resumable, record the reason in `campaign.md`, and commit it.

### Target: skills/campaign-ai-tools/SKILL.md

```
---
name: campaign-ai-tools
description: >
  Run an autonomous local campaign in which fresh session-model passes
  repeatedly plan and deliver user-directed, multi-stage repository
  improvements. Use for /campaign-ai-tools. Impact: creates or resumes a
  campaign branch, edits or removes files, runs commands and tests, and makes
  multiple local commits. It never pushes or writes outside the repository.
  Agent: session + implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Run an autonomous local campaign that repeatedly plans and delivers user-directed repository improvements.
    Each iteration addresses one cohesive improvement or correction on branch `improve/{CAMPAIGN}`,
    orchestrated by the session through fresh subagents on the session model: one planning pass and one execution pass per iteration.
    Execution passes spawn implementers on the model the user chose at initialization and send builds and tests to default workers.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve {CAMPAIGN} from the user request (kebab-case), plus {PRIORITIES} and {EXCLUSIONS}.
      Verify repository root with `git rev-parse --show-toplevel`.
      Check out work branch `improve/{CAMPAIGN}` from clean default/base branch, or resume it.
      Initialize or update `dev/improve/{CAMPAIGN}/campaign.md` with goals, priorities, exclusions, and active status.
      Resolve {IMPLEMENTER_MODEL}: reuse the implementer model recorded in campaign.md; when none is recorded, ask the user exactly one question through USER-AGENTS `<user_interaction>`, which model implements this campaign's stages, with 1-3 options chosen per `<implementer_job>`, and record the answer in campaign.md.
      Commit campaign start if new: `chore(dev): start campaign {CAMPAIGN}`; on resume, commit a newly recorded model with the campaign.md update.
    </step>

    <step id="2" name="planning_pass">
      Spawn a fresh, zero-context planning pass using `<template role="campaign-planner">` from `<dispatch_templates>`,
      substituting {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS}.
      The pass inspects repository state, selects one cohesive improvement matching user priorities,
      writes `dev/{SLUG}/` (base and stage files), and ends with one `<signal>` from `<return_protocol>`.
      Two consecutive `<signal code="NONE">` outcomes terminate the campaign cleanly.
    </step>

    <step id="3" name="execution_pass">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, spawn a separate, fresh execution pass using `<template role="campaign-executor">` from `<dispatch_templates>`,
      substituting {PLAN_PATH}, {CAMPAIGN}, {N} (the iteration number), and {IMPLEMENTER_MODEL}.
      The pass owns plan delivery and acceptance as its template instructs and ends with one `<signal>` from `<return_protocol>`.
    </step>

    <step id="4" name="iteration_loop">
      Record the iteration result from the execution pass.
      Repeat `<step id="2">` with a new zero-context planning pass.
      Do not reuse conversation context between iterations to prevent context degradation.
      Continue until budget ends, host halts, two planning passes return `<signal code="NONE">`, or a pass returns `<signal code="BLOCKED">`; then run `<step id="5">`.
    </step>

    <step id="5" name="completion_and_archival">
      At completion or controlled stop:
      Copy `dev/improve/{CAMPAIGN}/` to `dev/tmp/finished/improve/{CAMPAIGN}/`.
      Remove tracked folder: `git rm -r dev/improve/{CAMPAIGN}/`.
      Commit closing record: `chore(dev): complete campaign {CAMPAIGN}`.
      After `<signal code="BLOCKED">`: skip archival so the campaign stays resumable, set the campaign.md status to blocked with the pass's reason, and commit `chore(dev): block campaign {CAMPAIGN}`.
      In chat (user's language), provide branch, final HEAD, the campaign report path, and the blocking reason when there is one.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: the strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` as the model in campaign.md, and state that in the campaign report. When a spawn is rejected only for the recorded model, retry once with the harness default model and name the model used in the iteration file. When a pass cannot spawn subagents at all, `<rule id="no-nested-fallback">` applies.
  </implementer_job>

  <dispatch_templates>
    <template role="campaign-planner" executor="session-subagent">
      <job>Campaign planning pass: evaluate repository state and design one cohesive improvement.</job>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <priorities>{PRIORITIES}</priorities>
        <exclusions>{EXCLUSIONS}</exclusions>
      </input>
      <instructions>
        Read `$HOME/.ai-tools/skills/campaign-ai-tools/SKILL.md` and the sibling skills it cites for the protocols and templates named here.
        Inspect working tree and test suites of campaign {CAMPAIGN} against {PRIORITIES}, skipping {EXCLUSIONS}; send broad discovery to plan-ai-tools `<template role="repo-discovery">` and test runs to dev-ai-tools `<template role="stage-verifier">`.
        Derive a kebab-case slug for the chosen improvement.
        Draft the canonical multi-file plan under dev/ for that slug in the plan-ai-tools `<plan_file_format>`.
        Decide open design questions from evidence and user criteria.
        End with one `<signal>` from `<return_protocol>`: PLAN, RESUME, NONE, or BLOCKED.
      </instructions>
      <constraints>
        <constraint>Do not edit code files during planning pass.</constraint>
        <constraint>Do not push or touch remote repository.</constraint>
        <constraint>Read and grep files directly, but run no test suites, builds, or bulk collection yourself: when a needed default-worker spawn is unavailable, end with `<signal code="BLOCKED">` naming the missing nested-spawn capability.</constraint>
      </constraints>
    </template>

    <template role="campaign-executor" executor="session-subagent">
      <job>Campaign execution pass: deliver one plan's stages on the campaign branch.</job>
      <input>
        <plan_path>{PLAN_PATH}</plan_path>
        <campaign>{CAMPAIGN}</campaign>
        <iteration>{N}</iteration>
        <implementer_model>{IMPLEMENTER_MODEL}</implementer_model>
      </input>
      <instructions>
        Read `$HOME/.ai-tools/skills/campaign-ai-tools/SKILL.md` and the sibling skills it cites for the protocols and templates named here.
        Read the plan at {PLAN_PATH} and stay on improve/{CAMPAIGN}.
        Run dev-ai-tools `<step id="3">` for that plan as its accepting context, sending each stage's implementation to `<template role="stage-implementer">` spawned with {IMPLEMENTER_MODEL}, and commit each accepted stage locally with Conventional Commits.
        Archive the completed plan to dev/tmp/finished/ and write dev/improve/{CAMPAIGN}/iterations/{N}.md, including the implementer model used.
        Update dev/improve/{CAMPAIGN}/campaign.md and decisions.md.
        End with one `<signal>` from `<return_protocol>`: DELIVERED or BLOCKED.
      </instructions>
      <constraints>
        <constraint>All work stays local on improve/{CAMPAIGN}: do not push or create PRs.</constraint>
        <constraint>Leave stage code to the implementer and builds and tests to default workers; own review, acceptance, and commits.</constraint>
        <constraint>When the implementer or a default worker cannot be spawned, do not do that work yourself: leave the stage unaccepted and end with `<signal code="BLOCKED">` naming the missing nested-spawn capability.</constraint>
        <constraint>Preserve pre-existing commit history and base branch.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <campaign>{CAMPAIGN}</campaign>
      </input>
      <instructions>
        Read {STAGE_FILE} on improve/{CAMPAIGN} and the repository rules (README.md, AGENTS.md if present). Implement only that stage.
        Match surrounding style, keep edits within the declared files, and write behaviour tests for delivered changes.
        Append factual notes to the Implementation log of {STAGE_FILE}, set status V per dev-ai-tools `<status_protocol>`, and return a one-line outcome with the changed paths.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for execution pass review.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    (current body, verbatim)
  </return_protocol>

  <boundaries>
    <rule id="session-orchestrates">The session orchestrates the loop and owns the implementer question; every planning and execution pass runs in a fresh subagent with clean isolated context.</rule>
    <rule id="one-model-question">Ask the implementer model question at most once per campaign; reuse the model recorded in campaign.md for every iteration and on resume.</rule>
    <rule id="spawn-apis">Spawn through the harness's native subagent API (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent), passing the populated payload and file paths, never conversation context: each `<template executor="session-subagent">` on the session's own model where the API accepts a model, each `<template executor="implementer">` with the recorded implementer model, and default-worker templates with the harness default agent type and model.</rule>
    <rule id="no-nested-fallback">A pass that cannot spawn the implementer or a default worker never does that work itself, on the session model or any other: it ends with `<signal code="BLOCKED">` naming the missing nested-spawn capability, and the campaign stops through `<step id="4">` and closes in `<step id="5">`. The fallback of dev-ai-tools and plan-ai-tools default-worker rules does not apply inside passes.</rule>
    <rule id="strictly-local">(current text)</rule>
    <rule id="preserve-history">(current text)</rule>
    <rule id="tmp-untracked">(current text)</rule>
  </boundaries>
</skill>
```

Replace `(current body, verbatim)` (only in `<return_protocol>`) and every `(current text)` with the real text from the current file.

## Tests

- `scripts/lint.sh; echo $?` prints `0`. The output includes, for campaign:
  - `ok: template placeholders match their input` (covers `{IMPLEMENTER_MODEL}` in `campaign-executor`)
  - resolved references to `plan-ai-tools <template role="repo-discovery">`, `dev-ai-tools <template role="stage-verifier">`, `dev-ai-tools <step id="3">`, `<template executor="session-subagent">`, and `<template executor="implementer">`
- Lint reports the campaign description within 500 characters (expected about 404).
- `git grep -niE '(planner|implementer|mechanical)-ai-tools|agent="|coordinator|sub-dispatch|high-reasoning|\bagents\b' -- skills/campaign-ai-tools` prints nothing.
- `git grep -n 'template role=' -- skills/campaign-ai-tools` lists exactly `campaign-planner`, `campaign-executor`, and `stage-implementer`.
- `git diff` shows `<return_protocol>` unchanged. Step 5 differs only by the BLOCKED line, the report line, and "At completion or controlled stop:".
- No-fallback probe (user answer 2). `git grep -niE 'carr(y|ies) (that|the) work itself|records? the fallback|fall(s)? back to the session|run the payload in the session|on the session model instead' -- skills/campaign-ai-tools` prints nothing.
- Positive probe: `git grep -n 'nested-spawn capability' -- skills/campaign-ai-tools` hits the `no-nested-fallback` rule and one constraint in each of `campaign-planner` and `campaign-executor`, 3 lines in total.
- Lint output includes `ok: reference resolves: <rule id="no-nested-fallback">`, `ok: reference resolves: <signal code="BLOCKED">`, and `ok: reference resolves: <step id="5">` in campaign.
- Termination read-through: step 1 (the model question) never depends on spawning. Step 4 lists BLOCKED as a stop that leads to step 5. Step 5 closes a BLOCKED campaign with a committed campaign.md reason and a chat report, without archival.
- `scripts/test.sh` exits 0. The CI shellcheck command reports only the known `SC1071`.

## Acceptance criteria

- [ ] Planning and execution passes use `executor="session-subagent"`; `stage-implementer` uses `executor="implementer"`; no campaign-local verifier remains
- [ ] The implementer question is asked at most once per campaign, recorded in campaign.md, and reused on resume
- [ ] Execution passes run dev-ai-tools step 3 and pass `{IMPLEMENTER_MODEL}` to implementer spawns; both passes read the installed skill file for cited templates
- [ ] `<implementer_job>` is present and self-contained; the description ends with `Agent: session + implementer (model asked once).`
- [ ] No session-model or in-pass fallback: a pass that cannot spawn the implementer or a default worker ends with `<signal code="BLOCKED">` naming the missing nested-spawn capability; the no-fallback probe prints nothing
- [ ] Step 4 routes BLOCKED to step 5; step 5 closes a BLOCKED campaign with a report and keeps it resumable
- [ ] lint and test exit 0

## Commit message

`feat(skills)!: run campaign passes on session subagents with a chosen implementer model`

## Dependencies

- Requires stages: 3 (`repo-discovery`, dev step 3), 4 (`implementer_job` in `XML_VOCAB`)

## Implementation log
