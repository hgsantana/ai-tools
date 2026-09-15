# Stage 3: dev and plan inline in the session

## Objective

`dev-ai-tools` and `plan-ai-tools` stop dispatching a planner coordinator. The session plans, implements, accepts, commits, archives, and delivers itself, and sends builds, tests, and bulk discovery to default workers.

Dev gets explicitly numbered steps that vibe (stage 4) and the campaign execution pass (stage 5) reuse by qualified reference. The plan format gains the section lists that lived in the deleted `plan-author` template. The status protocol names owners neutrally.

## Files

- Create: none
- Modify:
  - `skills/dev-ai-tools/SKILL.md` (full rewrite to the target below)
  - `skills/plan-ai-tools/SKILL.md` (full rewrite to the target below)
- Remove: none

## Steps

1. Replace `skills/dev-ai-tools/SKILL.md` with the target text below.
   - The `intake_and_mode` step body is kept verbatim from the current file.
   - The `dev-coordinator` template, the dev `stage-implementer` template, and `<return_protocol>` are deleted.
2. Replace `skills/plan-ai-tools/SKILL.md` with the target text below.
   - Steps 1, 2, and 4 are kept verbatim from the current file.
   - The `plan-author` template is deleted.
3. The `default-worker` rule text matches stage 2 exactly, plus one final sentence. Campaign passes reuse `stage-verifier` and `repo-discovery` (user answer 2 in the base plan), so the sentence is: "Campaign-ai-tools passes never take this fallback: a pass that cannot spawn ends with BLOCKED." Write BLOCKED as plain text; dev and plan have no `<signal>`, so a backticked reference would not resolve.
4. Do not touch `vibe-ai-tools` or `campaign-ai-tools`. Their current references (`dev-ai-tools <status_protocol>`, `plan-ai-tools <plan_file_format>`, and their own templates) must still resolve.

### Target: skills/dev-ai-tools/SKILL.md

```
---
name: dev-ai-tools
description: >
  Execute a specified plan under dev/, or list pending plans, propose an
  order, and run them; or agree one task with the user. Use for /dev-ai-tools
  or after plan acceptance. Impact: edits code, runs commands, commits each
  step on a dedicated branch, archives the plan or task, pushes, and opens a
  pull request unattended once all steps finish. Agent: session.
argument-hint: "[plan paths, or the task to implement]"
---

<skill name="dev-ai-tools">
  <overview>
    Execute a specified plan under dev/{SLUG}/, a queue of pending plans, or one task agreed with the user.
    The session implements, accepts, commits, archives, and delivers the pull request itself; builds and tests go to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_mode">
      Select mode based on input:
      - Specified (path like `dev/{SLUG}/`, `dev/{SLUG}.md`, or archived slug): run that unit.
      - Queue (empty or `dev`): find unfinished base plans (`dev/*/0-*.md`), propose execution order, run accepted list one by one.
      - Task (anything else): agree one task interactively with user in their language, write `dev/{SLUG}.md`.
      Verify repository root with `git rev-parse --show-toplevel`.
      Resolve base branch from plan base or request-time branch.
    </step>

    <step id="2" name="branch_and_record">
      Read the unit of work and the repository rules (README.md, AGENTS.md if present).
      Check out `plan/{SLUG}` from {BASE_BRANCH} and commit the unit first: `chore(dev): plan {SLUG}` (or `chore(dev): task {SLUG}`).
    </step>

    <step id="3" name="stage_loop">
      For each stage in dependency order (a task is one stage), following `<status_protocol>`:
        1. Set W and record the stage's Executor in the base plan Status table, then implement the stage: code and behaviour tests within its declared files, matching surrounding style, with factual notes in its Implementation log. Set V.
        2. Review the working-tree diff against the stage objective, declared files, and acceptance criteria.
        3. Set T and send the stage's test and verification commands to `<template role="stage-verifier">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
        4. On passing evidence and met criteria: stage path by path, commit with the stage's Conventional Commit message, and set F.
        5. Otherwise: append concrete correction tasks to the stage log, set R1..R3, and retry up to three times, then set E.
      Interrupt the user only for a blocker, a decision uncovered by implementation, or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>

    <step id="4" name="archive_and_deliver">
      When every stage is terminal: copy the unit to dev/tmp/finished/{SLUG}, remove it with `git rm -r dev/{SLUG}` (or `git rm dev/{SLUG}.md`), and commit `chore(dev): archive {SLUG}`.
      Push `plan/{SLUG}` and open a pull request targeting {BASE_BRANCH} with `gh pr create`, or write dev/tmp/{SLUG}-review.patch when no host is available.
      Write the summary report to dev/tmp/{SLUG}-report.md.
    </step>

    <step id="5" name="report_and_handover">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or review patch path.
      In Queue mode, repeat `<step id="2">`, `<step id="3">`, and `<step id="4">` for the next accepted plan.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="stage-verifier" executor="default-worker">
      <job>Default worker: run builds and tests and collect factual evidence.</job>
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

  <status_protocol>
    The accepting context owns every state except V: the session in dev-ai-tools and vibe-ai-tools, the execution pass in campaign-ai-tools.
    <states>
      <state code="W">Working - set by the accepting context before implementation starts</state>
      <state code="V">Validating - set by whoever implemented the stage once it is ready for review</state>
      <state code="R1..R3">Rework - corrections after review</state>
      <state code="T">Testing - verification running</state>
      <state code="E">Exhausted - blocked or correction budget exceeded</state>
      <state code="F">Finished - accepted and committed</state>
    </states>
  </status_protocol>

  <boundaries>
    <rule id="session-owns-delivery">The session owns intake, implementation, acceptance, commits, archival, and pull-request delivery.</rule>
    <rule id="substance-on-disk">Write substance to the unit's files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
    <rule id="default-worker">(stage 2 shared rule, verbatim)</rule>
  </boundaries>
</skill>
```

Replace `(stage 2 shared rule, verbatim)` with the full `default-worker` rule body from stage 2, followed by the campaign sentence from step 3.

### Target: skills/plan-ai-tools/SKILL.md

```
---
name: plan-ai-tools
description: >
  Explore the repository and write a multi-file implementation plan under
  dev/. Use for /plan-ai-tools or when a non-trivial change needs planning
  first. Impact: writes only planning files under dev/; product code, commits,
  and remote state remain unchanged. Agent: session.
argument-hint: "[description of the change, feature, or fix to plan]"
---

<skill name="plan-ai-tools">
  <overview>
    Explore a change and write its canonical multi-file implementation plan under dev/{SLUG}/.
    The session aligns with the user, designs, and writes the plan itself; broad discovery goes to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_branch">
      (current body, verbatim)
    </step>
    <step id="2" name="user_alignment">
      (current body, verbatim)
    </step>
    <step id="3" name="plan_writing">
      Read the repository README.md, AGENTS.md if present, docs, and relevant code paths.
      Send broad read-only discovery to `<template role="repo-discovery">` from `<dispatch_templates>`, substituting {QUESTIONS} and {TOPIC}; read or grep directly for pinpoint lookups.
      Split delivery into isolated stages, one Conventional Commit per stage, and write `dev/{SLUG}/0-{SLUG}.md` plus one numbered stage file per stage per `<plan_file_format>`.
      Write only under dev/{SLUG}/, leave product and test code unchanged, and leave the Status table's Status and Executor cells empty.
    </step>
    <step id="4" name="report_and_handover">
      (current body, verbatim)
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="repo-discovery" executor="default-worker">
      <job>Default worker: collect read-only repository facts for planning.</job>
      <input>
        <questions>{QUESTIONS}</questions>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Answer {QUESTIONS} from the working tree with read-only searches, file reads, and commands.
        Write file paths, line references, and command outputs to dev/tmp/{TOPIC}.md.
        Return the output path and a one-line summary.
      </instructions>
      <constraints>
        <constraint>Read-only: do not edit files, commit, or change branches.</constraint>
        <constraint>Report facts; leave design decisions to the caller.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <plan_file_format>
    <structure>
dev/
  {SLUG}/
    0-{SLUG}.md       # Base plan
    1-{SLUG}.md       # Stage 1 (Single Conventional Commit boundary)
    2-{SLUG}.md       # Stage 2
    F1-{SLUG}.md      # Fix file (added during corrections if needed)
  tmp/
    finished/{SLUG}/  # Local archive copy (made once terminal)
    </structure>
    Base plan sections: Status table (Stage, Status, Executor), Goal, Base branch, Execution graph, Stages index, and Open questions and risks when any.
    Stage file sections: Objective, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, Commit message, Dependencies, Implementation log.
  </plan_file_format>

  <boundaries>
    <rule id="write-under-slug">Write only under dev/{SLUG}/; dev-ai-tools owns dev/tmp/finished/.</rule>
    <rule id="planning-only">Limit this workflow to planning: leave product code and builds unchanged.</rule>
    <rule id="plan-is-deliverable">Treat the saved plan as the deliverable until the user accepts the /dev-ai-tools offer.</rule>
    <rule id="default-worker">(stage 2 shared rule, verbatim)</rule>
  </boundaries>
</skill>
```

Replace every `(current body, verbatim)` with the real text. Replace `(stage 2 shared rule, verbatim)` with the stage 2 rule body plus the campaign sentence from step 3. No line may contain a bare `<` outside a tag or a backticked span.

## Tests

- `scripts/lint.sh; echo $?` prints `0`. In particular:
  - No `placeholder parity` warning for `stage-verifier` or `repo-discovery`.
  - `ok: qualified reference resolves: dev-ai-tools <status_protocol>` in the vibe and campaign files.
  - `ok: qualified reference resolves: plan-ai-tools <plan_file_format>` in the vibe and campaign files.
- `git grep -niE '(planner|implementer|mechanical)-ai-tools|agent="|coordinator|sub-dispatch|high-reasoning|return_protocol' -- skills/dev-ai-tools skills/plan-ai-tools` prints nothing.
- `git grep -n 'Campaign-ai-tools passes never take this fallback' -- skills/dev-ai-tools skills/plan-ai-tools` hits exactly one line in each file.
- `git grep -n '<step id=' -- skills/dev-ai-tools/SKILL.md` lists ids 1-5. `skills/plan-ai-tools/SKILL.md` lists 1-4.
- `git grep -n 'template role=' -- skills/dev-ai-tools skills/plan-ai-tools` lists exactly `stage-verifier` (dev) and `repo-discovery` (plan).
- Diff review: `intake_and_mode` and plan steps 1, 2, and 4 are unchanged, byte for byte (`git diff -U0` shows no hunk inside them).
- `scripts/test.sh` exits 0. The CI shellcheck command reports only the known `SC1071`.

## Acceptance criteria

- [ ] dev has no coordinator or implementer template and no `<return_protocol>`; the session owns steps 2-4, and `stage-verifier` uses `executor="default-worker"`
- [ ] plan has no `plan-author`; the session writes the plan in step 3, and `repo-discovery` uses `executor="default-worker"`
- [ ] `<plan_file_format>` lists base-plan and stage-file sections, with the Status table column `Executor`
- [ ] `<status_protocol>` names owners neutrally (accepting context, implementer of the stage)
- [ ] Both descriptions end with `Agent: session.`
- [ ] Both `default-worker` rules exclude campaign passes from the in-session fallback
- [ ] vibe and campaign references still resolve; lint and test exit 0

## Commit message

`refactor(skills)!: run dev and plan workflows inline in the session`

## Dependencies

- Requires stages: 1 (ordering only). File-disjoint from stage 2.

## Implementation log

- Replaced `skills/dev-ai-tools/SKILL.md` and `skills/plan-ai-tools/SKILL.md` with the target texts from this stage file, substituting `(current body, verbatim)` with the real current text of plan steps 1 (`intake_and_branch`), 2 (`user_alignment`), and 4 (`report_and_handover`), and substituting `(stage 2 shared rule, verbatim)` with the stage 2 `default-worker` rule body plus the campaign sentence from step 3 ("Campaign-ai-tools passes never take this fallback: a pass that cannot spawn ends with BLOCKED.").
- dev-ai-tools: deleted `dev-coordinator`, the dev `stage-implementer` template, and `<return_protocol>`; renumbered steps to 1 `intake_and_mode` (kept verbatim), 2 `branch_and_record`, 3 `stage_loop`, 4 `archive_and_deliver`, 5 `report_and_handover`; `stage-verifier` now uses `executor="default-worker"`; `<status_protocol>` names owners neutrally ("the accepting context").
- plan-ai-tools: deleted `plan-author`; added `<template role="repo-discovery" executor="default-worker">`; step 3 renamed `plan_writing` and now writes the plan directly in the session; `<plan_file_format>` gained the base-plan and stage-file section lists; steps 1, 2, and 4 kept verbatim (confirmed byte-for-byte via `git diff -U0`, no hunk touches them).
- `bash scripts/lint.sh; echo $?` -> exit 0, `316 ok, 1 skipped, 0 warnings` (the skip is the version-bump check needing `--base`). Output includes `ok: qualified reference resolves: dev-ai-tools <status_protocol>` and `ok: qualified reference resolves: plan-ai-tools <plan_file_format>` in the vibe and campaign files, and no `placeholder parity` warning for `stage-verifier` or `repo-discovery`.
- `git grep -niE '(planner|implementer|mechanical)-ai-tools|agent="|coordinator|sub-dispatch|high-reasoning|return_protocol' -- skills/dev-ai-tools skills/plan-ai-tools` -> exit 1 (no match), confirmed also with a plain working-tree `grep` (same result).
- `git grep -n 'Campaign-ai-tools passes never take this fallback' -- skills/dev-ai-tools skills/plan-ai-tools` -> exactly one line in each file (dev-ai-tools/SKILL.md:90, plan-ai-tools/SKILL.md:81).
- `git grep -n '<step id=' -- skills/dev-ai-tools/SKILL.md` -> ids 1-5; `-- skills/plan-ai-tools/SKILL.md` -> ids 1-4.
- `git grep -n 'template role=' -- skills/dev-ai-tools skills/plan-ai-tools` -> exactly `stage-verifier` (dev) and `repo-discovery` (plan).
- `git diff -U0 -- skills/dev-ai-tools/SKILL.md` and `-- skills/plan-ai-tools/SKILL.md` reviewed: no hunk touches `intake_and_mode` (dev step 1) or plan steps 1, 2, 4 — confirmed unchanged byte for byte.
- `bash scripts/test.sh; echo $?` -> exit 0, `305 ok, 0 skipped, 0 warnings` (baseline was 307; the difference comes from stage 1's concurrent removal of `models-ai-tools`, not from this stage's files).
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` -> only the known `SC1071` on `scripts/shell/install-zsh.sh`, as expected.
- Note for the parallel stage 1/2 work: at the time of this check, `scripts/lint.sh` already reported 0 warnings across all files, so no lint issue was observed in stage 1's or stage 2's files either; `git status --short` at the time showed `M README.md`, `M dev/skills-session-model/0-skills-session-model.md`, `M scripts/lint.sh`, `D skills/models-ai-tools/SKILL.md` in addition to this stage's two files.
- No files outside `skills/dev-ai-tools/SKILL.md` and `skills/plan-ai-tools/SKILL.md` were touched; `vibe-ai-tools` and `campaign-ai-tools` were left untouched and their qualified references still resolve per lint output above.
- Re-verification pass (fresh implementer invocation, files already at target from the prior pass above; no edits made): `bash scripts/lint.sh; echo $?` -> exit 0, `318 ok, 1 skipped, 0 warnings` (count shifted from 316 to 318 due to concurrent stage 1/2 progress in the same tree, not this stage). `bash scripts/test.sh; echo $?` -> exit 0, `305 ok, 0 skipped, 0 warnings`. `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` -> only the known `SC1071`. All grep checks (undesired terms absent; campaign sentence exactly once per file; step ids 1-5 dev / 1-4 plan; template role stage-verifier/repo-discovery) re-ran with identical results to the entries above. `diff` against the stage-3 target text (placeholders substituted) matched `skills/dev-ai-tools/SKILL.md` exactly; `skills/plan-ai-tools/SKILL.md` matched after accounting for an indentation artifact in the verification script itself (confirmed by direct inspection, not a real file difference). Base plan Status table row 3 was already `V` at read time; left unchanged.
