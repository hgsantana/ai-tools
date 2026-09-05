---
name: campaign-ai-tools
description: >
  Run an autonomous local campaign in which fresh planner agents repeatedly
  plan and deliver user-directed, multi-stage repository improvements. Use for
  /campaign-ai-tools. Impact: creates or resumes a campaign branch, edits or
  removes files, runs commands and tests, and makes multiple local commits. It
  never pushes or writes outside the repository. Agent: planner-ai-tools.
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Run an autonomous local campaign that repeatedly plans and delivers user-directed repository improvements.
    Each iteration addresses one cohesive improvement or correction on branch `improve/{CAMPAIGN}`,
    orchestrated by the session using fresh zero-context workers.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve {CAMPAIGN} from the user request (kebab-case), plus {PRIORITIES} and {EXCLUSIONS}.
      Verify repository root with `git rev-parse --show-toplevel`.
      Check out work branch `improve/{CAMPAIGN}` from clean default/base branch.
      Initialize or update `dev/improve/{CAMPAIGN}/campaign.md` with goals, priorities, exclusions, and active status.
      Commit campaign start if new: `chore(dev): start campaign {CAMPAIGN}`.
    </step>

    <step id="2" name="planning_pass">
      Dispatch a fresh, zero-context planner using `<template role="campaign-planner">` from `<dispatch_templates>`,
      substituting {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS}.
      The planner inspects repository state, selects one cohesive improvement matching user priorities,
      writes `dev/{SLUG}/` (base and stage files), and ends with one `<signal>` from `<return_protocol>`.
      Two consecutive `<signal code="NONE">` outcomes terminate the campaign cleanly.
    </step>

    <step id="3" name="execution_pass">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, dispatch a separate, fresh coordinator using `<template role="campaign-executor">` from `<dispatch_templates>`,
      substituting {PLAN_PATH}, {CAMPAIGN}, and {N} (the iteration number).
      The executor owns plan delivery and acceptance as its template instructs and ends with one `<signal>` from `<return_protocol>`.
    </step>

    <step id="4" name="iteration_loop">
      Record the iteration result from the executor.
      Repeat `<step id="2">` with a new zero-context planner.
      Do not reuse conversation context between iterations to prevent context degradation.
      Continue until budget ends, host halts, two planners return `<signal code="NONE">`, or a pass returns `<signal code="BLOCKED">`.
    </step>

    <step id="5" name="completion_and_archival">
      At controlled stop or completion:
      Copy `dev/improve/{CAMPAIGN}/` to `dev/tmp/finished/improve/{CAMPAIGN}/`.
      Remove tracked folder: `git rm -r dev/improve/{CAMPAIGN}/`.
      Commit closing record: `chore(dev): complete campaign {CAMPAIGN}`.
      In chat (user's language), provide branch, final HEAD, and archived campaign report path.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="campaign-planner" agent="planner-ai-tools">
      <job>Campaign planner: evaluate repository state and design one cohesive improvement.</job>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <priorities>{PRIORITIES}</priorities>
        <exclusions>{EXCLUSIONS}</exclusions>
      </input>
      <instructions>
        Inspect working tree and test suites of campaign {CAMPAIGN} against {PRIORITIES}, skipping {EXCLUSIONS}.
        Derive a kebab-case slug for the chosen improvement.
        Draft the canonical multi-file plan under dev/ for that slug in the plan-ai-tools `<plan_file_format>`.
        Decide open design questions from evidence and user criteria.
        End with one `<signal>` from `<return_protocol>`: PLAN, RESUME, NONE, or BLOCKED.
      </instructions>
      <constraints>
        <constraint>Do not edit code files during planning pass.</constraint>
        <constraint>Do not push or touch remote repository.</constraint>
      </constraints>
    </template>

    <template role="campaign-executor" agent="planner-ai-tools">
      <job>Campaign execution coordinator: execute plan stages on the campaign branch.</job>
      <input>
        <plan_path>{PLAN_PATH}</plan_path>
        <campaign>{CAMPAIGN}</campaign>
        <iteration>{N}</iteration>
      </input>
      <instructions>
        Read the plan at {PLAN_PATH} and stay on improve/{CAMPAIGN}.
        Execute stages sequentially, owning acceptance of each stage, following dev-ai-tools `<status_protocol>`:
          1. Sub-dispatch `<template role="stage-implementer">` for code changes.
          2. Sub-dispatch `<template role="stage-verifier">` for builds, tests, and commit checks.
          3. Audit test results and commit each accepted stage locally with Conventional Commits.
        Archive the completed plan to dev/tmp/finished/ and write dev/improve/{CAMPAIGN}/iterations/{N}.md.
        Update dev/improve/{CAMPAIGN}/campaign.md and decisions.md.
        End with one `<signal>` from `<return_protocol>`: DELIVERED or BLOCKED.
      </instructions>
      <constraints>
        <constraint>All work stays local on improve/{CAMPAIGN}: do not push or create PRs.</constraint>
        <constraint>Sub-dispatch `<template role="stage-implementer">` and `<template role="stage-verifier">`; do not carry editing directly.</constraint>
        <constraint>Preserve pre-existing commit history and base branch.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" agent="implementer-ai-tools">
      <job>Implementer worker: write and edit code and unit tests for the assigned stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <campaign>{CAMPAIGN}</campaign>
      </input>
      <instructions>
        Implement the stage in {STAGE_FILE} on improve/{CAMPAIGN}: match surrounding style, write tests, append report.
        Set status V per dev-ai-tools `<status_protocol>`.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in working tree for executor audit.</constraint>
      </constraints>
    </template>

    <template role="stage-verifier" agent="mechanical-ai-tools">
      <job>Mechanical worker: run builds, tests, and collect factual evidence.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute {COMMANDS} without design decisions.
        Capture stdout and stderr to dev/tmp/{TOPIC}-output.log.
        Return facts: command, exit code, and output path.
      </instructions>
      <constraints>
        <constraint>Do not modify production or test code unless explicitly passed as a patch.</constraint>
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
    <rule id="session-orchestrates">Session orchestrates the loop; workers run with clean isolated context per pass.</rule>
    <rule id="strictly-local">Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule id="preserve-history">Preserve pre-existing commit history and base branch.</rule>
    <rule id="tmp-untracked">Store runtime caches and temporary logs ignored under dev/tmp/.</rule>
  </boundaries>
</skill>
