---
name: implement-ai-tools
description: >
  Deliver changes by executing stages of an approved plan or directly through
  a simplified single-stage flow when no plan is present. Use for
  /implement-ai-tools.
argument-hint: "[slug of plan to implement | task description for simple execution]"
---

<skill name="implement-ai-tools">
  <overview>
    Deliver changes either stage-by-stage from a plan created by plan-ai-tools per `<implementation_protocol>`, or in a single stage per `<simple_tasks_protocol>` when no plan is involved, using agents configured per `<harness_agents>`.
  </overview>

  <session_workflow>
    <step id="1" name="detect">
      Determine execution mode: if {SLUG} or a plan file under `docs/<skill>/` or `docs/plan/` is given, run staged delivery per `<step id="2">`; otherwise, run simplified single-stage delivery per `<step id="3">`.
    </step>

    <step id="2" name="staged-delivery">
      For each stage of the plan, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {SLUG}, {STAGE}, and {PLAN} (for stage 1, the plan content or external file path; else empty); the session validates delivery by inspecting the git diff and concise test summary against the plan and stage acceptance criteria per `<rule id="stage-close">`.
      Decide in-scope questions from code evidence and log each in that stage's report. On a failed check, run `git reset --soft HEAD~1` before respawning once with corrections in the brief; on a second failure, stop as blocked without push or pull request, write evidence to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md`, and preserve the docs directory.
    </step>

    <step id="3" name="simple-delivery">
      Follow `<simple_tasks_protocol>`: brief the user with a concise summary of {BRIEF}, its scope, and any assumptions per `<rule id="simple-briefing">`. Confirm via `<user_interaction>`. Spawn `<template role="simple-implementer">` as {IMPLEMENTER}, substituting {BRIEF}; run tests and commit locally per `<rule id="simple-implementation">`.
    </step>

    <step id="4" name="report">
      In chat (user's language): one-line outcome, the implementer actually used, commit hash, and changed paths.
    </step>
  </session_workflow>

  <harness_agents>
    <rule id="default-worker">`executor="default-worker"`: harness default subagent for tasks, tests, and facts. Antigravity = Flash. Claude = Sonnet 5.5. Copilot = Gemini Flash 3.8.</rule>
    <rule id="inherited">`executor="inherited"`: subagent spawned per `<rule id="native-spawn">` with the session's model and effort, else the closest available, for review and planning.</rule>
    <rule id="inherit">Alias for `<rule id="inherited">`.</rule>
    <rule id="implementer">`executor="implementer"`: {IMPLEMENTER} per `<rule id="implementer-offer">`, for code and tests. Default: Antigravity = Flash, Claude = Sonnet 5.5, Copilot = Gemini Flash 3.8.</rule>
    <rule id="session">Executes within the session itself without spawning a subagent.</rule>
    <rule id="senior">Senior tier agent dispatched per the current harness skill (`claude-ai-tools`, `copilot-ai-tools`, `agy-ai-tools`).</rule>
    <rule id="mid-level">Mid-level tier agent dispatched per the current harness skill (`claude-ai-tools`, `copilot-ai-tools`, `agy-ai-tools`).</rule>
    <rule id="junior">Junior tier agent dispatched per the current harness skill (`claude-ai-tools`, `copilot-ai-tools`, `agy-ai-tools`).</rule>
    <rule id="implementer-offer">Offer once as the final question of the initial grill-me batch who implements every stage ({IMPLEMENTER}): 1. the `mid-level` (recommended), `senior`, or `junior` tier of the current harness skill (`claude-ai-tools`, `copilot-ai-tools`, `agy-ai-tools`) showing model and effort; 2. a session subagent (`inherit`); 3. the session itself; 4. the harness default executor (`default-worker`).</rule>
    <rule id="native-spawn">Spawn subagents via native harness APIs: Claude Code `Agent`, Copilot `runSubagent`, Antigravity `invoke_subagent`.</rule>
    <rule id="payload-assembly">A delegated brief states it is an authorized delegated payload and passes only the brief and paths, never conversation context.</rule>
    <rule id="spawn-fallback">A failed default-worker task runs in the spawning context; a failed implementer spawn reports blocked, never falls back to the session.</rule>
    <rule id="parallel-spawns">Parallel code-writing only on separate files; exploration, builds, and tests run concurrently.</rule>
    <rule id="session-commit">Commit all changes before returning session: run tests when code changed and commit LOCALLY if files were modified, created, or removed. Pushing is allowed to plan/task branches.</rule>
    <rule id="file-modification">Modify files via harness APIs or terminal commands, not IDE APIs.</rule>
  </harness_agents>

  <implementation_protocol>
    Adds to, never replaces, the harness's own implementation flow when implementing a plan. If not a plan, ignore it.
    <rule id="clean-context">Each stage of a multi-stage plan runs in a fresh {IMPLEMENTER} with a clean context, briefed with the plan file under `docs/<skill>/` (or `docs/plan/`) and the stage number; stage 1 also carries the full plan (content or external file path) to write there.</rule>
    <rule id="stage-close">The implementer executes its stage within scope, runs tests reporting only a concise summary of coverage and execution, appends its stage report to the plan under `docs/<skill>/` (or `docs/plan/`), sets status to done, and commits locally without validating delivery against the macro plan. The planner that created the plan ({PLANNER}) validates that delivery by reviewing the git diff and test summary against the plan and acceptance criteria before starting the next stage. On a failed check, the session runs `git reset --soft HEAD~1` before respawning the implementer once with corrections (second failure blocks).</rule>
  </implementation_protocol>

  <simple_tasks_protocol>
    <rule id="simple-tasks">For simple tasks, questions, code review, or documentation only tasks, follow the harness default flow. If a plan is requested, follow plan-ai-tools `<planning_protocol>` instead.</rule>
    <rule id="simple-briefing">Brief the user with a concise summary of the task, its scope, and any assumptions or constraints. Ask for confirmation before proceeding.</rule>
    <rule id="simple-implementation">Implement the task in a single stage, following the harness default flow. Fix tests when code changes, run them and report results concisely. Commit changes locally if files were modified, created, or removed with conventional commit messages.</rule>
  </simple_tasks_protocol>

  <implementer_job>
    The implementer takes one stage (or a simple single-stage task) and delivers it without supervision: it reads the plan or brief and the code it touches, edits code and tests across files within scope, matches repository style, runs tests reporting only a concise summary of coverage and execution, appends its report when a plan file exists, sets status to done, and commits locally. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan stage from a clean context.</job>
      <input>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to docs/plan/{SLUG}.md as that stage specifies. Read docs/plan/{SLUG}.md and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of docs/plan/{SLUG}.md, and commit with the stage's Conventional Commit message.
        For the last stage, remove the transient docs directory (with `git rm -r docs/plan/{SLUG}` or equivalent), commit the removal with the stage's commit message, and run push and pull request against the base branch if applicable.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
      </constraints>
    </template>

    <template role="simple-implementer" executor="implementer">
      <job>Implementer: deliver a simple task in a single stage.</job>
      <input>
        <brief>{BRIEF}</brief>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Read the repository rules (README.md, AGENTS.md if present).
        Implement the task described in {BRIEF}: match surrounding code style, fix and add tests covering edge cases and boundary conditions, run tests reporting only a concise summary of coverage and execution, and commit changes locally with a Conventional Commit message.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the task's scope.</constraint>
        <constraint>Commit locally only; do not push or open remote pull requests.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="protocols">Execution follows `<implementation_protocol>` for staged plans and `<simple_tasks_protocol>` for simple tasks; subagent dispatch follows `<harness_agents>`.</rule>
    <rule id="spawn-apis">Spawn implementers per `<harness_agents>`; if an implementer cannot be spawned, stop as blocked per `<rule id="spawn-fallback">`.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
