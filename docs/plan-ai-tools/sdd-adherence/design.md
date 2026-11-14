# SDD design brief

Transient working state for implementers and evaluators. `report.md` beside it holds the rationale; this file holds the decisions and the target text.

<design>

<decisions>
- D1 = C: requirements live in spec files that survive delivery; story, plan, and task files are removed at finalization.
- D2: plan, vibe, team, campaign, and audit all change in this delivery.
- D3: in vibe the session amends the spec autonomously and the pull request lists every amendment.
- No new XML vocabulary. Every change fits `<rule>`, `<step>`, `<template>`, `<signal>`.
- Tests carry no requirement IDs; the ID mapping lives in task files, reports, and the acceptance table.
</decisions>

<authoring_constraints>
- Read `README.md` sections "Structure and authoring" and "Semantic XML grammar" first; they bind every edit.
- Extreme concision: add only what this brief asks; keep every existing instruction this brief does not change. Do not reformat or reword untouched text.
- Angle brackets appear only in structural tags or inside backticks. Never write a bare `<` or `>` in prose.
- Lint strips backticked spans before checking. Inside a `<template>`, every `{PLACEHOLDER}` outside backticks must be declared in its `<input>`, and every declared one must appear outside backticks at least once. Do not introduce undeclared placeholders in templates (no `{SPEC_DIR}`, `{CAPABILITY}`, `{N}`, `{M}` there: say "the spec files it names").
- Every backticked reference with an attribute must resolve in the same file or in `AI-TOOLS-AGENTS.md`: `<rule id>`, `<step id>`, `<template role>`, `<signal code>`. After renumbering steps, fix every `<step id>` reference.
- Never write the word "rule" or "rules" followed by a digit in a skill (lint reads it as a README rule citation).
- Skills are self-contained: cite no other skill. Shared text is duplicated verbatim across plan, vibe, and team except where this brief names a variant.
- Frontmatter `description` stays within 500 characters and keeps `Use for /<name>.`
- Positive phrasing; a negative only where it reinforces an essential positive.
- Edit only the files assigned to you. Do not commit. Run `AI_TOOLS="$PWD" bash scripts/lint.sh` from the repository root and leave zero warnings attributable to your files.
</authoring_constraints>

<concepts>
- Spec file: `{SPEC_DIR}/{CAPABILITY}.md`, the authority on behavior. Kept `{SPEC_DIR}` is `docs/specs` or the directory the repository already keeps; a declined one lives at `docs/<skill>/{SLUG}/specs` and is removed with the plan directory. One mechanism, two locations: templates never branch on it.
- Story: the change. It lists requirement IDs added, changed, or removed; it holds no requirement text.
- Coverage table: in the plan, requirement to tasks.
- Compliance table: in the task file, per attempt, scenario to verdict.
- Acceptance table: in the plan, per round, requirement to verdict for the whole branch.
- Acceptor: fresh clean-context subagent that judges the whole branch before the pull request.
</concepts>

<skill name="plan-ai-tools" role="reference implementation">

<frontmatter_description limit="500">
Plan and deliver one story, spec first. The session, as PO, writes the requirements into the spec and the story; a clean-context Planner writes the plan. On approval it orchestrates each task: a Task Planner details it, an Implementer delivers it, and an Evaluator judges the diff against spec and plan and commits. An Acceptor checks the whole branch against the spec before the pull request. Given the slug of an existing plan, it resumes orchestration. Use for /plan-ai-tools.
</frontmatter_description>

<overview_changes>
Rewrite the overview in place to state, with no new sentence beyond these: the PO writes the requirements into the spec and the change into the story; the Planner questions what the spec leaves unverifiable and its plan also holds the constraints and verification commands and the coverage of every requirement by a task; story, spec, and plan are committed together; the Evaluator judges the diff scenario by scenario against the spec, the plan, and the task file; once every task is done an Acceptor judges the whole branch against the spec and sends gaps back through the task loop; the session then removes the plan directory, keeps the spec, pushes, and creates a pull request carrying the acceptance table.
</overview_changes>

<boundaries_changes>

In `ubiquitous-language`, replace the `Story` line and add `Spec` before it and `Acceptor` after `Evaluator`:

```
      - `Spec`: Requirements and scenarios, the authority on behavior, in `{SPEC_DIR}/{CAPABILITY}.md` per `<rule id="spec-format">`, written by the PO session.
      - `Story` (User Story): The change, in `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, written by the PO session: context, the requirement IDs it adds, changes, or removes, scope, and the implementer type.
      - `Acceptor`: Clean-context subagent inheriting session model and effort; judges the whole branch against the spec before the pull request.
```

New rules, placed after `ubiquitous-language`:

```
    <rule id="spec-format">Requirements live in spec files, the authority on behavior:
      - {SPEC_DIR} is the spec directory the repository keeps: `docs/specs`, or its own, in the format and identifiers already used there. When the repository keeps none and its documentation settles no spec policy, the PO asks the user once whether to keep one at `docs/specs`; if declined, {SPEC_DIR} is `docs/plan-ai-tools/{SLUG}/specs`, removed with the plan directory.
      - One file per capability, a kebab-case area of behavior, `{SPEC_DIR}/{CAPABILITY}.md`, states current behavior: a one-paragraph purpose, then one `### R{N}. {NAME}` heading per requirement holding one sentence of observable behavior ("The system must ...") and its scenarios as `- R{N}.S{M} Given ..., when ..., then ...` lines, with a failure scenario wherever failure is possible.
      - IDs are unique within a file and never renumbered or reused; outside its file an ID carries the capability: `{CAPABILITY}/R{N}.S{M}`.
      - A story edits these files in place, so the diff of {SPEC_DIR} against the base branch is the change. Existing behavior the change must not break, when no requirement states it yet, is written as a requirement too. Every requirement of a touched file that the story leaves unchanged is preserved behavior.
      - Spec files state behavior only, free of implementation detail and vague qualifiers; an unsettled point is marked `[NEEDS CLARIFICATION: question]` until settled.
    </rule>

    <rule id="story-format">The story states one change, in these sections:
      - `Context and goal`: who needs what, and why.
      - `Requirements`: per spec file, the IDs this story adds, changes, or removes, marking `existing` an added requirement that documents current behavior.
      - `Out of scope`: explicit non-goals.
      - `Delivery`: the {IMPLEMENTER} type per `<rule id="implementer-selection">` and {BASE_BRANCH}, the branch current when the story is written.
      - When they apply: `Constraints` (imposed limits and measurable thresholds), `Documentation` (durable documents other than the spec that must reflect the change), `Assumptions and clarifications` (defaults assumed and questions settled with the user), and `Amendments` (changes after approval per `<rule id="spec-authority">`: what, why, and who approved).
    </rule>

    <rule id="story-quality">Before each approval request the PO verifies and corrects until all hold: every requirement the story adds or changes states one observable behavior and has at least one scenario; the story is one independently deliverable outcome, else the PO proposes a split to the user; no `[NEEDS CLARIFICATION]` marker remains.</rule>

    <rule id="spec-authority">The spec is the authority on behavior and the story on the scope of this change, after approval too:
      - A decision that adds, changes, or removes observable behavior is an amendment, whatever raised it: a Planner or Task Planner question, a plan modification, a blocked task, or an acceptance gap. Once the user confirms it, the session edits the spec files and logs it under `Amendments` in the story; when branch `plan/{SLUG}` exists, it commits only those files with `docs(spec): amend {SLUG}`.
      - When an amendment leaves a requirement without a task, the session has the Planner re-plan, the live one before the plan is committed and a fresh `<template role="planner">` afterwards, with {ACTION} = re-plan and {FEEDBACK} naming the amendment.
      - A decision that leaves behavior unchanged stays in the "Decisions" section of the plan or of the task file.
    </rule>
```

`session-role`, changed bullets:

```
      - As PO it never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps) and resolves scope boundaries, business logic, user-facing behavior, and ambiguities.
      - From the plan it reads only the task status table, to pick the next task, the coverage table, to gate plan approval, and the last acceptance section and the decisions, to write the pull request. It never reads task files, diffs, or code to validate, rework, or re-judge a delivery; validation belongs to the Evaluator and the Acceptor.
```

`transient-docs`: after the first sentence add `A kept spec lives in {SPEC_DIR}, outside that directory, and survives its removal.`

`planner-question-rounds`, replace:

```
    <rule id="planner-question-rounds">If the Planner finds a requirement it cannot turn into a verifiable check, requirements that contradict each other, or major discrepancies between the spec and repository code, or a Task Planner finds that its task cannot be delivered inside the boundary the plan gave it, it sends batched questions with recommended options to the PO session, up to 3 rounds. The PO answers directly; decisions involving financial costs, irreversible data loss, or destructive operations are relayed to the user and await explicit confirmation. An answer that changes behavior is an amendment per `<rule id="spec-authority">`; other settled answers are recorded in the "Decisions" section of the plan or of the task file.</rule>
```

`clean-context-lifecycle`: append `Each acceptance round gets a fresh Acceptor, which ends on its return.`

New rule after `retry-and-blocked`:

```
    <rule id="story-acceptance">Once every task is `done`, a fresh Acceptor judges the whole branch against the spec and the story. On gaps it appends convergence tasks to the plan and the session runs them through the task loop, for at most 2 convergence rounds. When the third acceptance still finds a gap, the Acceptor returns `<signal code="STORY_BLOCKED">`; the session sends an atomic chat message linking the plan, then prompts the user via `<user_interaction>` to provide extra instructions for 3 more acceptance rounds, amend the spec per `<rule id="spec-authority">`, or abort.</rule>
```

`finalization-and-pr`, replace:

```
    <rule id="finalization-and-pr">Once the story is accepted:
      - The session copies the last acceptance table and the "Decisions" of the plan and the `Amendments` of the story to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`.
      - The session removes the plan directory (`git rm -r docs/plan-ai-tools/{SLUG}`) and commits with `chore(plan): complete {SLUG} delivery`; a kept spec stays.
      - The session pushes branch `plan/{SLUG}` to remote.
      - The session inspects `git log` difference against {BASE_BRANCH} and creates a pull request formatted with a business overview, the acceptance table, the amendments, the decisions, and technical change highlights.
    </rule>
```
</boundaries_changes>

<return_protocol_changes>
Change `TASK_STOPPED` to read `Implementer: the task file contradicts the codebase or the spec, or a blocker prevents delivery; the line states it.` and append:

```
    <signal code="STORY_ACCEPTED">Acceptor: every requirement met on the whole branch; acceptance table committed in the plan.</signal>
    <signal code="STORY_GAPS">Acceptor: unmet requirements appended to the plan as convergence tasks and committed.</signal>
    <signal code="STORY_BLOCKED">Acceptor: third acceptance still unmet per `<rule id="story-acceptance">`.</signal>
```
</return_protocol_changes>

<workflow_changes>
Steps 1, 2, 7, 11, 13, 15, 16 keep their text (11 also links the spec files). New numbering: 18 `story-acceptance`, 19 `plan-cleanup`, 20 `push-and-pr`. Target text of changed steps:

```
    <step id="3" name="po-doc-analysis">
      Session acts as PO per `<rule id="session-role">`: read repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps). Do not inspect application code. Evaluate user request feasibility from a business perspective and against the requirements already specified. If documentation is lacking or outdated, mark documentation updates as a mandatory requirement.
    </step>

    <step id="4" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first), including the spec directory question of `<rule id="spec-format">` when it applies. Resolve ambiguities, business rules, requirements and their scenarios, edge cases, and scope trade-offs. Repeat until all points are settled, recording a gap too small to ask about as an assumption.
    </step>

    <step id="5" name="write-story">
      Write the requirements into the spec files under {SPEC_DIR} per `<rule id="spec-format">`, editing existing files in place, and the story to `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, recording the {IMPLEMENTER} type and the current branch as {BASE_BRANCH}. Verify both per `<rule id="story-quality">`.
    </step>

    <step id="6" name="story-approval">
      Send an atomic chat message linking the story file and the spec files it touches, then prompt the user via `<user_interaction>` to approve them or request modifications. Iterate `<step id="4">` and `<step id="5">` until approved.
    </step>

    <step id="8" name="planner-clarifications">
      Answer the Planner's batched questions per `<rule id="planner-question-rounds">`, relaying critical decisions to the user and applying amendments per `<rule id="spec-authority">`, until the Planner returns the plan path.
    </step>

    <step id="9" name="plan-approval">
      Read the coverage table of the plan per `<rule id="session-role">`: every requirement the story adds, changes, or removes and every `Documentation` item names a task. On gaps, dispatch the live Planner with {ACTION} = re-plan and {FEEDBACK} listing them, and check again. Then send an atomic chat message linking the plan and story files, and prompt the user via `<user_interaction>` to approve the plan or request modifications. On modifications, amend per `<rule id="spec-authority">` when behavior changes, dispatch the live Planner with {ACTION} = re-plan and {FEEDBACK} containing the user requests, and repeat this step until approved.
    </step>

    <step id="10" name="branch-and-commit">
      Create git branch `plan/{SLUG}` based on {BASE_BRANCH}. Stage and commit only the story, spec, and plan files with Conventional Commit message `chore(plan): initialize plan and story for {SLUG}`. Terminate the Planner.
    </step>
```

Step 12: read `the {IMPLEMENTER} type and {BASE_BRANCH} from the story`; case 1 becomes `Every task `done`: proceed to `<step id="18">`.` (same number, now acceptance).

Step 14, case 2: unchanged, the Task Planner revise path. Step 17: after `On extra instructions,` insert `apply any amendment they carry per `<rule id="spec-authority">`,`.

```
    <step id="18" name="story-acceptance">
      When {ROUND} is unset, set {ROUND} = 1 and empty {ACCEPTANCE_NOTES}. Announce the spawn in one chat line. Spawn `<template role="acceptor">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {ROUND}, {BASE_BRANCH}, {STORY_FILE}, {PLAN_FILE}, and {ACCEPTANCE_NOTES}. It ends on its return; branch per `<rule id="story-acceptance">` without reading or validating anything:
      1. `<signal code="STORY_ACCEPTED">`: proceed to `<step id="19">`.
      2. `<signal code="STORY_GAPS">`: increment {ROUND} and return to `<step id="12">`.
      3. `<signal code="STORY_BLOCKED">`: escalate. On extra instructions, set {ACCEPTANCE_NOTES} to them and {ROUND} = 1, and repeat this step. On an amendment, apply it per `<rule id="spec-authority">`, set {ROUND} = 1, and return to `<step id="12">`. On abort, leave branch `plan/{SLUG}` and the plan directory in place for inspection, and report the unmet requirements in one line.
    </step>

    <step id="19" name="plan-cleanup">
      Copy the acceptance table, decisions, and amendments to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`, then remove the plan directory via `git rm -r docs/plan-ai-tools/{SLUG}` and commit with `chore(plan): complete {SLUG} delivery`, per `<rule id="finalization-and-pr">`.
    </step>

    <step id="20" name="push-and-pr">
      Push branch `plan/{SLUG}` to remote. Inspect git log diff against {BASE_BRANCH} and open a pull request formatted per `<rule id="finalization-and-pr">`. Send a one-line outcome with the pull request link.
    </step>
```
</workflow_changes>

<template_changes>

Planner, target `<instructions>`:

```
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is plan:
        1. Read the story for {SLUG} from {STORY_FILE} and every spec file it names: the requirements it adds, changes, or removes, and the unchanged ones of the same files, which are preserved behavior.
        2. Inspect the files, modules, and dependencies in scope. Verify against actual code; do not assume. Identify existing points of extension and new components needed.
        3. Send batched questions with recommended options to the PO session (up to 3 rounds) on any requirement you cannot turn into a verifiable check, requirements that contradict each other, and major discrepancies between the spec and the code.
        4. Write {PLAN_FILE} as a general plan: task status table with columns `#`, `Status` (blank, `working`, `validating`, `retry` plus attempt number, `blocked`, `done`), and `Task`; technical objective; overall architecture with a Mermaid diagram of the affected components; "Constraints and verification", the repository rules and invariants that bind the design (AGENTS.md, README.md, ADRs, CI) and the exact build, lint, typecheck, and test commands; the tasks, each atomic, self-contained, and independently committable; "Coverage", a table from each requirement the story adds, changes, or removes and each `Documentation` item to the tasks that deliver it, marking `enabling` a task that serves none; a "Decisions" section recording resolved questions and choices, where a decision that changes the documented architecture also gets a documentation task.
        5. Give each task what a Task Planner with no other context needs to detail it: a technical summary, the requirement and scenario IDs it delivers, its boundary (modules and areas inside it, and what is left to other tasks), its dependencies on earlier tasks, and the architectural direction to follow. Leave file-level changes, test behaviors, and implementation steps to the Task Planner.
        6. Return a one-line outcome with {PLAN_FILE}.

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, the spec files it names, the existing {PLAN_FILE}, and {FEEDBACK}.
        2. Adjust the architecture, diagram, task separation, coverage, and decisions in {PLAN_FILE}, leaving `done` tasks as they are.
        3. Return a one-line outcome with {PLAN_FILE}.
```

Task Planner, changed lines:

```
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE} for plan {SLUG}: architecture, constraints and verification, decisions, and task {TASK_NUM} with its summary, requirement and scenario IDs, boundary, dependencies, and direction.
        4. Write {TASK_FILE}: technical objective, the scenario IDs in scope, files to create or modify with expected changes, test behaviors to verify, at least one per scenario ID and each naming the ID it verifies, plus those the code needs beyond the spec (unit tests for code; smoke tests, linters, or schema validations for non-code assets), the verification commands of the plan that apply, suggested implementation steps without writing code, and a "Decisions" section.
```

and in revise-task step 2 append: `When only a change to the spec resolves it, send that as a batched question to the PO session first.`

Implementer, changed lines (execute-task):

```
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM}. Take any uncommitted changes already in the worktree as your starting point.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities or the spec, stop immediately and return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Author tests covering the defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files) and run the verification commands of {TASK_FILE}. Fix defects until all checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE}: changed files, a table from each scenario ID to its test and result, other tests written and executed, command outcomes, and blockers. No self-evaluation.
```

rework-task step 2 runs `the verification commands of {TASK_FILE}` instead of `tests and linters`. Constraint becomes `Stay strictly within task scope, leave the spec files and the story untouched, and report factual results only, without local commits.`

Evaluator, changed lines:

```
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} with its implementation report. Treat a non-empty {FEEDBACK} as the user's extra instructions for this task.
        2. Read the uncommitted git diff and judge it scenario by scenario: for each scenario ID in the scope of {TASK_FILE}, the behavior is delivered and a test that would fail without it verifies it. Then judge that the delivery adds no behavior the spec does not ask for, breaks no preserved behavior, follows the plan's architecture, constraints, and decisions, stays inside the task's scope, matches the report, and holds in quality.
        4. Verify that tests exist and genuinely verify the behaviors defined in {TASK_FILE}, failure paths and edge cases included, not only the happy path, and run the verification commands of {TASK_FILE} yourself.
        5. Append to {TASK_FILE} the compliance table for attempt {ATTEMPT}, each scenario ID with `met` or `unmet` and its evidence, then observations, every defect found, and the verdict.
```

First constraint becomes `Never fix or write task code yourself and never approve a delivery with an `unmet` scenario or without tests genuinely verifying the defined behaviors.`

New template after `evaluator`:

```
    <template role="acceptor" executor="inherited">
      <job>Independent acceptance judge: check the whole branch of one story against every requirement of its spec before the pull request.</job>
      <input>
        <slug>{SLUG}</slug>
        <round>{ROUND}</round>
        <base_branch>{BASE_BRANCH}</base_branch>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <acceptance_notes>{ACCEPTANCE_NOTES}</acceptance_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. You own the acceptance of story {SLUG}; nobody reviews it afterwards. You took no part in planning, implementing, or evaluating it: judge what is on the branch, not what the reports claim.
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE}: constraints and verification, coverage, and decisions. Treat a non-empty {ACCEPTANCE_NOTES} as the user's extra instructions, granted after the story blocked.
        2. Read the diff of the branch against {BASE_BRANCH}, the plan directory aside, and run every verification command of the plan.
        3. Judge every requirement, scenario by scenario: one the story adds or changes is delivered and verified by a test that would fail without it; one it removes is gone with its tests; every other requirement of the touched spec files still holds; every `Documentation` item is reflected in its document; the spec files changed only in the requirements the story lists, and their text matches the delivered behavior.
        4. Append an "Acceptance round {ROUND}" section to {PLAN_FILE}: a table with columns `ID`, `Requirement`, `Verdict` (`met` or `unmet`), and `Evidence` (the test or the diff location).
        5. If every row is `met`: commit only {PLAN_FILE} with `chore(plan): accept {SLUG}` and return one line ending with `<signal code="STORY_ACCEPTED">`.
        6. If a row is `unmet` and {ROUND} is below 3: append one convergence task per gap to {PLAN_FILE}, as a blank-status row in the task status table and an entry with technical summary, requirement and scenario IDs, boundary, dependencies, and direction, update the coverage table, commit only {PLAN_FILE} with `chore(plan): record acceptance gaps for {SLUG}`, and return one line ending with `<signal code="STORY_GAPS">`.
        7. If a row is `unmet` and {ROUND} is 3: commit only {PLAN_FILE} with that same message and return one line naming the unmet IDs and ending with `<signal code="STORY_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Never fix code, tests, the spec, or the story yourself; write nothing but {PLAN_FILE}.</constraint>
        <constraint>Never accept while a scenario lacks a test that genuinely verifies it or a verification command fails.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources.</constraint>
      </constraints>
    </template>
```
</template_changes>
</skill>

<skill name="vibe-ai-tools" role="twin of plan-ai-tools">
Apply every plan-ai-tools change with paths `docs/vibe-ai-tools/{SLUG}`, branch `vibe/{SLUG}`, and commit prefix `chore(vibe)`. Keep vibe's own wording where the two skills already differ (questions go "to the session", options are flagged for cost or irreversibility, the Evaluator never asks anything). Variants:

- Description: same content adapted to vibe, within 500 characters.
- `spec-format`: the spec directory question is asked during story refinement; the declined location is `docs/vibe-ai-tools/{SLUG}/specs`.
- `spec-authority`, first bullet: `A decision that adds, changes, or removes observable behavior is an amendment, whatever raised it: a Planner or Task Planner question, a blocked task, or an acceptance gap. The session decides it per `<rule id="autonomous-decision-policy">`, edits the spec files, and logs it under `Amendments` in the story as a deviation from what the user approved; when branch `vibe/{SLUG}` exists, it commits only those files with `docs(spec): amend {SLUG}`. The pull request lists every amendment.`
- `autonomous-decision-policy`: the decisions bullet records technical decisions in "Decisions" and behavior changes per `<rule id="spec-authority">`.
- `session-role`, last bullet: `It reads the plan to approve it against the story and the spec and to pick the next task, a blocked task file to recover it, and the acceptance sections to recover a blocked story and to write the pull request. It never reads diffs or code to validate, rework, or re-judge a delivery; validation belongs to the Evaluator and the Acceptor.`
- `story-acceptance`: `Once every task is `done`, a fresh Acceptor judges the whole branch against the spec and the story. On gaps it appends convergence tasks to the plan and the session runs them through the task loop, for at most 2 convergence rounds. When the third acceptance still finds a gap, the Acceptor returns `<signal code="STORY_BLOCKED">`. The session first attempts one autonomous recovery per story: it reads the last acceptance section of the plan, writes extra instructions per `<rule id="autonomous-decision-policy">`, amending the spec per `<rule id="spec-authority">` when a requirement cannot hold, and grants 3 more acceptance rounds. If the story blocks again, the session sends an atomic chat message linking the plan, then prompts the user via `<user_interaction>` to provide extra instructions for 3 more acceptance rounds or abort.`
- Step `plan-validation`: `Read the plan and check it against the story and the spec: the coverage table names a task for every requirement the story adds, changes, or removes and for every `Documentation` item, and nothing exceeds `Out of scope`. On gaps, dispatch the live Planner with {ACTION} = re-plan and {FEEDBACK} listing them, and repeat this step. Approve the plan without prompting the user.`
- New numbering: 16 `story-acceptance`, 17 `plan-cleanup`, 18 `push-and-pr`. Step 10 still proceeds to `<step id="16">` when every task is `done`.
- Step 16 case 3: `<signal code="STORY_BLOCKED">`: recover or escalate per `<rule id="story-acceptance">`. With extra instructions, the session's own or the user's, set {ACCEPTANCE_NOTES} to them and {ROUND} = 1, and repeat this step; after an amendment return to `<step id="10">` instead. On abort, leave branch `vibe/{SLUG}` and the plan directory in place for inspection, and report the unmet requirements in one line.
- Acceptor template: `granted after the story blocked` stays; add `and you never ask the user or the session anything` to its opening, as vibe's Evaluator has; commit prefixes `chore(vibe)`.
- The pull request also lists amendments as deviations from the approved story.
</skill>

<skill name="team-ai-tools" role="port with structural variants">
Port G1 to G9 from plan-ai-tools, paths `docs/team-ai-tools/{SLUG}`, branch `team/{SLUG}`, commit prefix `chore(team)`. Keep the skill's narrated step style and its attempt mechanics (`retry` plus attempt in the plan). Variants and additions:

- Description and overview: mention spec files, the coverage gate, validation against the spec, and the qa-eng acceptance, within 500 characters for the description.
- `ubiquitous-language`: `Spec` and `Story` as in plan; `Acceptor`: `Fresh `qa-eng` Specialist with clean context that judges the whole branch against the spec before the pull request.`; `Plan` gains constraints, verification, and coverage; `Validator` judges against the spec.
- `po-role`: documentation includes the spec directory the repository keeps.
- Add `spec-format` (declined location `docs/team-ai-tools/{SLUG}/specs`), `story-format`, `story-quality`, `spec-authority` (user confirms; re-plan goes to the live Architect before the plan is committed and to a fresh `<template role="architect">` afterwards; branch `team/{SLUG}`), and `story-acceptance` (as plan, the Acceptor being a fresh `qa-eng` Specialist).
- `architect-question-rounds`: the Architect also asks about a requirement it cannot turn into a verifiable check and about requirements that contradict each other; an answer that changes behavior is an amendment per `<rule id="spec-authority">`.
- `implementer-rules` and the implementer template: stop also when instructions contradict the spec; run the verification commands of the task file; the report holds a table from each scenario ID to its test and result; spec files and story stay untouched.
- `finalization-and-pr`: as plan.
- New `<return_protocol>` between `<boundaries>` and `<session_workflow>` (README grammar: an outcome the caller branches on is a signal):

```
  <return_protocol>
    <signal code="TASK_DELIVERED">Implementer: changes and tests in the worktree, report appended to the task file; task status `validating`.</signal>
    <signal code="TASK_STOPPED">Implementer: the task file contradicts the codebase or the spec, or a blocker prevents delivery; the line states it.</signal>
    <signal code="TASK_APPROVED">Specialist: delivery approved and committed; task status `done`.</signal>
    <signal code="TASK_REWORK">Specialist: delivery rejected with rework items appended to the task file; task status `retry` plus the attempt number.</signal>
    <signal code="TASK_BLOCKED">Specialist: third attempt rejected per `<rule id="retry-and-blocked">`; task status `blocked`.</signal>
    <signal code="STORY_ACCEPTED">Acceptor: every requirement met on the whole branch; acceptance table committed in the plan.</signal>
    <signal code="STORY_GAPS">Acceptor: unmet requirements appended to the plan as convergence tasks and committed.</signal>
    <signal code="STORY_BLOCKED">Acceptor: third acceptance still unmet per `<rule id="story-acceptance">`.</signal>
  </return_protocol>
```

  Steps 19 and 21 branch on these signals; the implementer and specialist templates end their returns with them. The Architect and the Specialist's detail-task keep a one-line outcome.
- Steps: 3 to 6 as plan (spec files, story format, quality check, approval linking both). Step 8 and the architect template: the plan also holds "Constraints and verification" and "Coverage", and each task gets the requirement and scenario IDs it delivers, its boundary, its dependencies, and its direction, beside summary and Specialist. Step 12: the session checks the coverage table before asking for approval. Step 14 commits story, spec, and plan files. Step 15 reads {BASE_BRANCH} from the story and proceeds to `<step id="22">` when every task is `done`. Step 17 and detail-task: scenario IDs in scope, test behaviors each naming the ID it verifies, verification commands. Steps 20 and 21 and validate-task: judge scenario by scenario against the spec files the story names, not only against the task file the Specialist wrote; compliance table; run the verification commands; signals.
- New step 22 `story-acceptance`, then 23 `plan-cleanup` and 24 `push-and-pr`, as plan steps 18 to 20.
- New `<template role="acceptor" executor="inherited">`: the plan acceptor with input `<specialist_summary>{SPECIALIST_SUMMARY}</specialist_summary>` added and used (`Act as `qa-eng` applying: {SPECIALIST_SUMMARY}.`), filled by the session from `specialists-catalog`; each convergence task it appends names its Specialist from the catalog roles; commit prefix `chore(team)`.
</skill>

<skill name="campaign-ai-tools">
The campaign file becomes a structured charter; each Planner follows a recorded scan and checks the work point against the charter. No new gate or subagent.

- `ubiquitous-language`: `Campaign` is recorded per `<rule id="campaign-format">`; `Work point` matches the campaign's work-point definition; `Cycle log` gains a `Criteria` column (`met`, or the unmet IDs).
- New rule:

```
    <rule id="campaign-format">The campaign file is the spec of the campaign, in these sections:
      - `Goal`: the repository-wide outcome, and why.
      - `Scope`: in-scope and out-of-scope areas.
      - `Work point`: what qualifies as one, and the search recipe (commands or patterns) that enumerates candidates.
      - `Done criteria`: `D1..Dn`, each verifiable on one work point, with its check command when one exists.
      - `Preserved behavior`: `P1..Pn`, what no cycle may change. Every requirement of a spec directory the repository keeps is preserved unless the goal names it for change.
      - `Verification`: the build, lint, typecheck, and test commands.
      - `Constraints`, the implementer type per `<rule id="implementer-selection">`, and the cycle log.
      The session writes what documentation and the user settle. A search recipe or verification command left open is derived from the repository and recorded by the first Planner that plans a work point.
    </rule>
```

- Step 1 settles those sections with the user; step 3 writes the file per the rule.
- Planner template. Scan: read every section; enumerate candidates with the recorded search recipe, deriving it from the repository when absent; `CYCLE_EMPTY` still writes and commits nothing. Plan: tasks name the done criteria they satisfy; the cycle-log commit also records any search recipe or verification command the Planner derived. Task file: verification commands. Validation: run the verification commands of the campaign file and reject a delivery that changes preserved behavior; a delivery that changes behavior a kept spec states updates that spec in the same commit, and only when the campaign goal asks for the change. New step before Close: once the tasks are done, check the work point against every done criterion and preserved behavior, running each recorded check command, and append a criteria table (`ID`, `Verdict`, `Evidence`) to the cycle plan; an unmet criterion becomes one more task executed the same way, for at most 2 such rounds. Close: `done` only when every criterion is met; otherwise `blocked` with the reason, and the cycle-log row records `Criteria`.
- Implementer template: runs the verification commands the task file names.
</skill>

<skill name="audit-ai-tools">
Minimal edits; the skill was just hardened.

- "seven-lens" becomes "eight-lens" in the overview and in `audit-modes`; "seven defect lenses" becomes "eight defect lenses"; `Lens-7` stays.
- Mapper step 1: the perimeter also lists specification sources (spec directories such as `docs/specs/`, `specs/`, `openspec/specs/`, or `.kiro/specs/`, API schemas, and documented behavior contracts) with the code areas each governs.
- Scope Auditor step 3, eighth lens after "Verification and guardrail gaps":
  `- Specification conformance (when {PERIMETER_FILE} lists specification sources governing {SCOPE_PATHS}): after reading those sources, implementation that contradicts a requirement or scenario, specified behavior with no implementation, a scenario no test verifies, and, inside a spec file, requirements that contradict each other or describe behavior the code no longer has.`
- Verifier step 2: for a specification divergence, establish from tests, history, and documentation which side is stale and direct the remediation at it.
- Consolidator: each remediation work package states the expected behavior, the invariants to preserve, and the check that proves the fix.
</skill>

<session_owned_files>
Edited by the orchestrating session, not by implementers: `AI-TOOLS-AGENTS.md` (rule `living-spec` in `<engineering_rigor>`), `README.md` (version 0.0.92-ALPHA, rule 22), `docs/USAGE.md`.
</session_owned_files>

</design>
