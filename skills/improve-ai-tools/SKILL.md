---
name: improve-ai-tools
description: >
  Run an autonomous local campaign in which fresh planner agents repeatedly
  plan and deliver user-directed, multi-stage repository improvements. Use for
  /improve-ai-tools. Impact: creates or resumes a campaign branch, edits or
  removes files, runs commands and tests, and makes multiple local commits. It
  never pushes or writes outside the repository. Agent: planner-ai-tools.
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="improve-ai-tools">
  <overview>
    Run an autonomous local campaign that repeatedly plans and delivers user-directed repository improvements.
    Each iteration addresses one cohesive improvement or correction on branch `improve/<campaign>`,
    orchestrated by the session using fresh zero-context workers.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve campaign name from user request (kebab-case campaign).
      Verify repository root with `git rev-parse --show-toplevel`.
      Check out work branch `improve/<campaign>` from clean default/base branch.
      Initialize or update `dev/improve/<campaign>/campaign.md` with goals, priorities, exclusions, and active status.
      Commit campaign start if new: `chore(dev): start campaign <campaign>`.
    </step>

    <step id="2" name="planning_pass">
      Dispatch a fresh, zero-context `planner-ai-tools` instance using `<template role="campaign-planner">`.
      The planner inspects repository state, selects one cohesive improvement matching user priorities,
      and writes `dev/<slug>/` (base and stage files).
      Returns: `PLAN <path>`, `RESUME <path>`, `NONE`, or `BLOCKED`.
      Two consecutive `NONE` outcomes terminate the campaign cleanly.
    </step>

    <step id="3" name="execution_pass">
      On `PLAN` or `RESUME`, dispatch a separate, fresh `planner-ai-tools` instance using `<template role="campaign-executor">`.
      The campaign executor operates with high thinking/reasoning, owns plan delivery and acceptance, and sub-dispatches:
      - `implementer-ai-tools` for code changes on separate files.
      - `mechanical-ai-tools` for running tests, applying mechanical renames, and verifying commits.
      Apply campaign overrides inside the executor:
      - Work stays on `improve/<campaign>` without creating `plan/<slug>`.
      - Commits accumulate locally (one commit per stage with Conventional Commits).
      - Delivery is local: updates `dev/improve/<campaign>/campaign.md` and logs iteration under `dev/improve/<campaign>/iterations/<N>.md`.
      - No remote push or pull request.
      Returns to session: `DELIVERED <iteration_path>` or `BLOCKED <reason>`.
    </step>

    <step id="4" name="iteration_loop">
      Record iteration result from campaign executor.
      Repeat step 2 (Planning pass) with a new zero-context planner.
      Do not reuse conversation context between iterations to prevent context degradation.
      Continue until budget ends, host halts, two planners return NONE, or a pass is BLOCKED.
    </step>

    <step id="5" name="completion_and_archival">
      At controlled stop or completion:
      Copy `dev/improve/<campaign>/` to `dev/tmp/finished/improve/<campaign>/`.
      Remove tracked folder: `git rm -r dev/improve/<campaign>/`.
      Commit closing record: `chore(dev): complete campaign <campaign>`.
      In chat (user's language), provide branch, final HEAD, and archived campaign report path.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="campaign-planner">
      <role>Campaign planner: evaluate repository state and design one cohesive improvement.</role>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <priorities>{PRIORITIES}</priorities>
        <exclusions>{EXCLUSIONS}</exclusions>
      </input>
      <instructions>
        Inspect working tree and test suites against user priorities.
        Draft canonical multi-file plan under dev/{SLUG}/.
        Decide open design questions from evidence and user criteria.
        Return PLAN dev/{SLUG}/0-{SLUG}.md (or NONE/BLOCKED).
      </instructions>
      <constraints>
        <constraint>Do not edit code files during planning pass.</constraint>
        <constraint>Do not push or touch remote repository.</constraint>
      </constraints>
    </template>

    <template role="campaign-executor">
      <role>Campaign execution coordinator (planner-ai-tools): execute plan stages on campaign branch.</role>
      <input>
        <plan_path>{PLAN_PATH}</plan_path>
        <campaign_branch>improve/{CAMPAIGN}</campaign_branch>
      </input>
      <instructions>
        Execute stages sequentially, owning acceptance of each stage.
        Sub-dispatch implementer-ai-tools for code changes and mechanical-ai-tools for builds, tests, and commit checks.
        Audit test results, commit each accepted stage locally with Conventional Commits.
        Archive completed plan to dev/tmp/finished/ and update campaign iteration logs.
        Return DELIVERED dev/improve/{CAMPAIGN}/iterations/{N}.md (or BLOCKED with rationale).
      </instructions>
      <constraints>
        <constraint>All work stays local on improve/{CAMPAIGN}: do not push or create PRs.</constraint>
        <constraint>Sub-dispatch implementer-ai-tools and mechanical-ai-tools; do not carry editing directly.</constraint>
        <constraint>Preserve pre-existing commit history and base branch.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule>Session orchestrates loop; workers run with clean isolated context per pass.</rule>
    <rule>Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule>Preserve pre-existing commit history and base branch.</rule>
    <rule>Store runtime caches and temporary logs ignored under dev/tmp/.</rule>
  </boundaries>
</skill>
