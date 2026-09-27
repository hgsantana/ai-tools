---
name: campaign-ai-tools
description: >
  Run an autonomous local campaign in which the session iterates scope,
  a planner writes each plan, and implementers deliver its stages. Use for
  /campaign-ai-tools. Impact: creates or resumes a campaign branch, edits or
  removes files, runs commands and tests, and makes multiple local commits.
  It never pushes or writes outside the repository. Agent: session +
  implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Run an autonomous local campaign that repeatedly plans and delivers user-directed repository improvements.
    The session iterates campaign scope with the user, then mediates on disk: it spawns a planner to write each plan, spawns an implementer per stage, and respawns the same planner role to validate that stage from the working-tree diff. Chat names paths only.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve {CAMPAIGN} from the user request (kebab-case), plus {PRIORITIES} and {EXCLUSIONS}, exploring the codebase before asking and interviewing the user through USER-AGENTS `<user_interaction>` one question at a time with recommended answers, resolving campaign scope boundaries until those are recorded.
      Verify repository root with `git rev-parse --show-toplevel`.
      Before any mutation, run the recovery check: if `plans/improve/{CAMPAIGN}/campaign.md` exists on `improve/{CAMPAIGN}` or can be restored from that branch, resume it. Record the branch, last accepted stage, last iteration number, and recorded implementer model. Preserve accepted commits and a dirty worktree from an unfinished stage. Choose the next iteration as last + 1. A planner PLAN spawn may return `<signal code="RESUME">` only for a unit this check found. If the name is new, check out `improve/{CAMPAIGN}` from a clean default/base branch and initialize `plans/improve/{CAMPAIGN}/campaign.md` with goals, priorities, exclusions, and active status.
      Resolve {IMPLEMENTER_MODEL}: reuse the implementer model recorded in campaign.md; when none is recorded, check `$HOME/.ai-tools/config.local.json`: if `ask_implementer_model` under `"behavior"` is set to false, skip prompting the user and resolve {IMPLEMENTER_MODEL} from the configured tier model in `$HOME/.ai-tools/config.local.json` under `"models"` or `config/agents.json` default for `mid` tier; otherwise ask the user exactly one question through USER-AGENTS `<user_interaction>`, which model implements this campaign's stages, with 1-3 options chosen per `<implementer_job>`, and record the answer in campaign.md.
      Commit campaign start if new: `chore(plans): start campaign {CAMPAIGN}`; on resume, commit a newly recorded model with the campaign.md update.
    </step>

    <step id="2" name="plan">
      Spawn `<template role="campaign-planner">` from `<dispatch_templates>` as executor="session-subagent" with {MODE} set to PLAN, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and empty {STAGE_FILE}.
      Record only the `<signal>` from `<return_protocol>`. In chat, name the plan path from that signal. Do not open the plan directory.
      Two consecutive `<signal code="NONE">` outcomes terminate the campaign cleanly.
      If the planner cannot be spawned, treat the campaign as `<signal code="BLOCKED">` without planning in the session.
    </step>

    <step id="3" name="stage_loop">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, stay on `improve/{CAMPAIGN}`. If the unit is not yet committed on this branch, commit it first as `chore(plans): plan` plus the plan directory name. Resume unfinished stages without rewriting accepted F commits.
      For each unfinished stage in dependency order, following USER-AGENTS `<status_protocol>`:
        1. If the stage is not yet planned (status empty or resumed at P): set P in the base plan Status table, spawn `<template role="campaign-planner">` from `<dispatch_templates>` as executor="session-subagent" with {MODE} set to STAGE-PLAN, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and {STAGE_FILE}; if that spawn fails, treat the campaign as `<signal code="BLOCKED">`.
        2. Set W and record Executor as implementer plus {IMPLEMENTER_MODEL} in the base plan Status table.
        3. Spawn `<template role="stage-implementer">` from `<dispatch_templates>` as executor="implementer" with {IMPLEMENTER_MODEL}, substituting {STAGE_FILE} and {CAMPAIGN}; if that spawn is rejected only for the recorded model, retry once with the harness default and name the model used in the iteration file; if the spawn fails, leave the stage unaccepted and treat the campaign as `<signal code="BLOCKED">` without implementing in the session.
        4. Spawn `<template role="campaign-planner">` again as executor="session-subagent" with {MODE} set to VALIDATE, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and {STAGE_FILE}. The session passes only those paths; it does not assemble a diff or open the stage. Record only the VALIDATE `<signal>`.
        5. On `<signal code="ACCEPT">`: commit with the stage's Conventional Commit message and set F. On `<signal code="REWORK">`: set R1..R3 and retry the implementer spawn up to three times, then set E. On `<signal code="BLOCKED">` from VALIDATE: set E. The session does not open the verdict file; a retrying implementer reads `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md` when that path exists.
      On E: stop remaining stages, retain the plan, and go to `<step id="5">` as blocked. Do not start a dependent stage.
      Successful completion of the iteration is every required stage F. Only then: copy the plan to `${TMPDIR:-/tmp}/ai-tools/finished/` under its slug, `git rm -r` the tracked plan, commit `chore(plans): archive` plus that slug, write the iteration file for {N} under `plans/improve/{CAMPAIGN}/iterations/`, including the implementer model actually used, update campaign.md and decisions.md with last accepted stage and iteration {N}, and commit `chore(plans): record campaign {CAMPAIGN} iteration {N}`.
      If any required stage is E, a planner or implementer spawn is missing, or a reserved approval is pending: retain the plan, do not archive it, write evidence under `${TMPDIR:-/tmp}/ai-tools/` named from the plan slug, update campaign.md status, and treat the outcome as `<signal code="BLOCKED">`. Partial delivery is not authorized.
    </step>

    <step id="4" name="iteration_loop">
      Store only the `<signal>` from each spawn.
      Repeat `<step id="2">` with a new PLAN spawn.
      Continue until budget ends, host halts, two PLAN spawns return `<signal code="NONE">`, or a spawn returns `<signal code="BLOCKED">`; then run `<step id="5">`.
    </step>

    <step id="5" name="completion_and_archival">
      Distinguish outcomes. Archive only a completed campaign (two consecutive `<signal code="NONE">`): copy `plans/improve/{CAMPAIGN}/` to `${TMPDIR:-/tmp}/ai-tools/finished/improve/{CAMPAIGN}/`, `git rm -r plans/improve/{CAMPAIGN}/`, and commit `chore(plans): complete campaign {CAMPAIGN}`.
      On budget exhaustion or host halt: do not archive. Preserve `plans/improve/{CAMPAIGN}/`, write paused status, last accepted stage, last iteration, and {IMPLEMENTER_MODEL} into campaign.md, commit `chore(plans): pause campaign {CAMPAIGN}`, and name the pause path in chat. The campaign stays resumable.
      After `<signal code="BLOCKED">`: skip archival so the campaign stays resumable, write the signal's reason and evidence path into campaign.md status, and commit `chore(plans): block campaign {CAMPAIGN}`.
      In chat (user's language), name branch, final HEAD, and disk paths. Do not paste reports.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: the strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` as the model in campaign.md, and name that path in chat. When a spawn is rejected only for the recorded model, retry once with the harness default model and name the model used in the iteration file. When the planner or implementer cannot be spawned, `<rule id="no-planner-or-implementer-fallback">` applies.
  </implementer_job>

  <dispatch_templates>
    <template role="campaign-planner" executor="session-subagent">
      <job>Campaign planner: in PLAN mode, write base plan with succinct stages; in STAGE-PLAN mode, detail one stage file; in VALIDATE mode, judge one stage from the working-tree diff.</job>
      <input>
        <mode>{MODE}</mode>
        <campaign>{CAMPAIGN}</campaign>
        <priorities>{PRIORITIES}</priorities>
        <exclusions>{EXCLUSIONS}</exclusions>
        <assigned_file>{STAGE_FILE}</assigned_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`. Include `<template role="repo-discovery">` in the brief.
        When {MODE} is PLAN: inspect the working tree of campaign {CAMPAIGN} against {PRIORITIES}, skipping {EXCLUSIONS}. If an unfinished plan directory already exists for this campaign, validate its recorded branch and stage statuses and end with `<signal code="RESUME">` for that path; do not derive a new slug. Spawn `<template role="repo-discovery">` as executor="default-worker" with questions and a kebab-case topic. If that spawn fails, read and grep the tree yourself. For new work, derive a kebab-case slug. Write only under that directory: base `0-<slug>.md` (Status table with empty Status and Executor cells, Goal, Base branch, Execution graph, Stages outline, Open questions) containing succinct outlines for all stages. Leave product and test code unchanged. Do not commit. Decide open design questions from evidence and user criteria. End with one PLAN, RESUME, NONE, or BLOCKED `<signal>`. Return `<signal code="RESUME">` only when the recovery check found an unfinished unit. {STAGE_FILE} is unused in PLAN.
        When {MODE} is STAGE-PLAN: read {STAGE_FILE}'s succinct outline in `plans/improve/{CAMPAIGN}/`'s base plan and inspect current working tree and commits. Write detailed stage file `{STAGE_FILE}` under the campaign plan directory (Objective, Decisions, Files, Steps, Tests, Acceptance criteria, Commit message, Dependencies, Implementation log), set that stage's Status cell to PF in base plan, and end with one PLANNED or BLOCKED `<signal>`.
        When {MODE} is VALIDATE: read {STAGE_FILE} and run `git diff` against HEAD on `improve/{CAMPAIGN}` yourself. Judge whether that uncommitted diff meets the stage Objective, Files, and Acceptance criteria. Reject the stage when a criterion is not demonstrated. Write the verdict to `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md`. End with one ACCEPT, REWORK, or BLOCKED `<signal>`. Do not commit and do not edit product code. The session does not assemble or pass a diff.
      </instructions>
      <constraints>
        <constraint>Do not push or touch remote repository.</constraint>
        <constraint>PLAN does not edit product or test code; VALIDATE does not edit product, test, or plan files other than the verdict file.</constraint>
        <constraint>If a default-worker spawn fails, run that discovery yourself per USER-AGENTS `<rule id="spawn-fallback">`.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <campaign>{CAMPAIGN}</campaign>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`. Include `<template role="stage-verifier">` in the brief.
        Read {STAGE_FILE} on improve/{CAMPAIGN} and the repository rules (README.md, AGENTS.md if present). If `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md` exists, apply its corrections. Implement only that stage.
        Match surrounding style, keep product and test edits within the declared files, and write behaviour tests for delivered changes.
        Spawn `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic. If that spawn fails, run the commands yourself and write the same log.
        Append factual notes to the Implementation log of {STAGE_FILE}, set that stage's Status cell to V in the base plan Status table, and return a one-line outcome with the changed paths, test exit code, and log path.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Edit only the declared stage files, the Implementation log of {STAGE_FILE}, and that stage's Status cell in the plan's `0-*.md`.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for planner VALIDATE.</constraint>
      </constraints>
    </template>

    <template role="stage-verifier" executor="default-worker">
      <job>Default worker: run builds and tests and collect factual evidence.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute {COMMANDS} without design decisions.
        Capture stdout and stderr to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}-output.log.
        Return facts: command, exit code, and output path.
      </instructions>
      <constraints>
        <constraint>Do not modify production or test code unless explicitly passed as a patch.</constraint>
      </constraints>
    </template>

    <template role="repo-discovery" executor="default-worker">
      <job>Default worker: collect read-only repository facts for planning.</job>
      <input>
        <questions>{QUESTIONS}</questions>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Answer {QUESTIONS} from the working tree with read-only searches, file reads, and commands.
        Write file paths, line references, and command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return the output path and a one-line summary.
      </instructions>
      <constraints>
        <constraint>Leave product, test, and plan files unchanged; do not commit or change branches.</constraint>
        <constraint>The sole write is the report file ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.</constraint>
        <constraint>Report facts; leave design decisions to the caller.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="PLAN">PLAN {PLAN_PATH}</signal>
    <signal code="RESUME">RESUME {PLAN_PATH}</signal>
    <signal code="NONE">NONE</signal>
    <signal code="PLANNED">PLANNED {STAGE_FILE}</signal>
    <signal code="ACCEPT">ACCEPT {STAGE_FILE} {VERDICT_PATH}</signal>
    <signal code="REWORK">REWORK {STAGE_FILE} {VERDICT_PATH}</signal>
    <signal code="DELIVERED">DELIVERED {ITERATION_PATH} {IMPLEMENTER_MODEL}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-mediates">The session iterates scope, owns the implementer question, commits, archives, and names disk paths in chat. It does not judge a stage diff; VALIDATE does.</rule>
    <rule id="scope-interview">In campaign initialization, align on scope, priorities, and exclusions through USER-AGENTS `<user_interaction>` one question at a time with recommendations after exploring the codebase.</rule>
    <rule id="signals-only">After each spawn, the session stores only the `<signal>` line and its fields. It does not read the plan, the iteration file, campaign.md, decisions.md, or the VALIDATE verdict body.</rule>
    <rule id="brief-not-skills">Each spawn receives its job in the payload, including nested spawn payloads assembled per USER-AGENTS `<rule id="payload-assembly">`. Spawned contexts do not read sibling skill files.</rule>
    <rule id="one-model-question">Ask the implementer model question at most once per campaign; reuse the model recorded in campaign.md for every iteration and on resume.</rule>
    <rule id="plan-git-lifecycle">The session commits a new plan before implementation, archives a completed iteration by copy-then-`git rm`, and commits iteration and campaign metadata. PLAN writes the plan directory and does not commit.</rule>
    <rule id="validate-is-diff">VALIDATE reads the stage file and the working-tree `git diff` against HEAD; the session passes only {STAGE_FILE} and campaign paths, never an assembled diff.</rule>
    <rule id="completion-is-f">An iteration archives and records DELIVERED only when every required stage is F. An E stage is BLOCKED and retains the plan.</rule>
    <rule id="pause-not-archive">Archive the campaign directory only after two consecutive NONE results. Budget exhaustion and host halt pause and commit resumable campaign.md; they do not remove it.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>`: `<template role="campaign-planner">` runs as `executor="session-subagent"` on the session's own model; `<template role="stage-implementer">` runs as `executor="implementer"` with the recorded {IMPLEMENTER_MODEL}, or `harness default` per `<implementer_job>` when the API cannot select a model.</rule>
    <rule id="no-planner-or-implementer-fallback">If the planner or implementer cannot be spawned, the session does not take that role: it ends as `<signal code="BLOCKED">` naming the missing spawn, and the campaign stops through `<step id="4">` and records the block in `<step id="5">` without archival.</rule>
    <rule id="worker-fallback">If a default-worker spawn fails, the spawning planner or implementer runs that payload itself per USER-AGENTS `<rule id="spawn-fallback">`.</rule>
    <rule id="strictly-local">Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule id="preserve-history">Preserve pre-existing commit history and base branch.</rule>
    <rule id="tmp-untracked">Store runtime caches, temporary logs, and reports in OS temp (${TMPDIR:-/tmp}/ai-tools).</rule>
  </boundaries>
</skill>
