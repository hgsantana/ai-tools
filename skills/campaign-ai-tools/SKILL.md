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
      Record only the `<signal>` from `<return_protocol>`. Do not open the plan directory.
      Two consecutive `<signal code="NONE">` outcomes terminate the campaign cleanly.
    </step>

    <step id="3" name="execution_pass">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, spawn a separate, fresh execution pass using `<template role="campaign-executor">` from `<dispatch_templates>`,
      substituting {PLAN_PATH}, {CAMPAIGN}, {N} (the iteration number), and {IMPLEMENTER_MODEL}.
      Record only the `<signal>` from `<return_protocol>`. Do not open the plan, the iteration file, or campaign.md.
    </step>

    <step id="4" name="iteration_loop">
      Store only the `<signal>` from each pass.
      Repeat `<step id="2">` with a new zero-context planning pass.
      Do not reuse conversation context between iterations to prevent context degradation.
      Continue until budget ends, host halts, two planning passes return `<signal code="NONE">`, or a pass returns `<signal code="BLOCKED">`; then run `<step id="5">`.
    </step>

    <step id="5" name="completion_and_archival">
      At completion or controlled stop:
      Copy `dev/improve/{CAMPAIGN}/` to `dev/tmp/finished/improve/{CAMPAIGN}/`.
      Remove tracked folder: `git rm -r dev/improve/{CAMPAIGN}/`.
      Commit closing record: `chore(dev): complete campaign {CAMPAIGN}`.
      After `<signal code="BLOCKED">`: skip archival so the campaign stays resumable, write the signal's reason into campaign.md status, and commit `chore(dev): block campaign {CAMPAIGN}`.
      In chat (user's language), provide branch, final HEAD, and the signal line.
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
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are stated here.
        Inspect the working tree of campaign {CAMPAIGN} against {PRIORITIES}, skipping {EXCLUSIONS}. Spawn plan-ai-tools `<template role="repo-discovery">` as executor="default-worker" with questions and a kebab-case topic (it writes facts under dev/tmp/ and returns the path and a one-line summary). Spawn dev-ai-tools `<template role="stage-verifier">` as executor="default-worker" for test or build evidence.
        Derive a kebab-case slug. Write only under that directory: base `0-<slug>.md` (Status table with empty Status and Executor cells, Goal, Base branch, Execution graph, Stages index, Open questions) and one numbered stage file per Conventional Commit (Objective, Files, Steps, Tests, Acceptance criteria, Commit message, Dependencies, Implementation log). Leave product and test code unchanged.
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
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are stated here.
        Read the plan at {PLAN_PATH} and stay on improve/{CAMPAIGN}.
        For each stage in dependency order, own every status except V: set W and record Executor as implementer plus {IMPLEMENTER_MODEL}; spawn `<template role="stage-implementer">` as executor="implementer" with {IMPLEMENTER_MODEL}, substituting the stage file; review the working-tree diff against objective, declared files, and acceptance; set T and spawn dev-ai-tools `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic (it writes logs under dev/tmp/ and returns command, exit code, and path); on pass, commit locally with the stage's Conventional Commit message and set F; else append corrections, set R1..R3, retry up to three times, then set E.
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
        Append factual notes to the Implementation log of {STAGE_FILE}, set status V, and return a one-line outcome with the changed paths.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for execution pass review.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="PLAN">PLAN {PLAN_PATH}</signal>
    <signal code="RESUME">RESUME {PLAN_PATH}</signal>
    <signal code="NONE">NONE</signal>
    <signal code="DELIVERED">DELIVERED {ITERATION_PATH}</signal>
    <signal code="BLOCKED">BLOCKED {REASON}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-orchestrates">The session orchestrates the loop and owns the implementer question; every planning and execution pass runs in a fresh subagent with clean isolated context.</rule>
    <rule id="signals-only">After each spawn, the session stores only the `<signal>` line and paths. It does not read the plan, the iteration file, campaign.md, or decisions.md.</rule>
    <rule id="brief-not-skills">Each pass receives its job in the spawn payload, including nested spawn payloads. Passes do not read sibling skill files.</rule>
    <rule id="one-model-question">Ask the implementer model question at most once per campaign; reuse the model recorded in campaign.md for every iteration and on resume.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>` for the native subagent API list and payload rules: `<template role="campaign-planner">` and `<template role="campaign-executor">` run as `executor="session-subagent"` on the session's own model; `<template role="stage-implementer">` runs as `executor="implementer"` with the recorded {IMPLEMENTER_MODEL}, or `harness default` per `<implementer_job>` when the API cannot select a model.</rule>
    <rule id="no-nested-fallback">A pass that cannot spawn the implementer or a default worker never does that work itself, on the session model or any other: it ends with `<signal code="BLOCKED">` naming the missing nested-spawn capability, and the campaign stops through `<step id="4">` and closes in `<step id="5">`. Passes never take the fallback of USER-AGENTS `<rule id="spawn-fallback">`.</rule>
    <rule id="strictly-local">Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule id="preserve-history">Preserve pre-existing commit history and base branch.</rule>
    <rule id="tmp-untracked">Store runtime caches and temporary logs ignored under dev/tmp/.</rule>
  </boundaries>
</skill>
