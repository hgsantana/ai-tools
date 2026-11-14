---
name: team-ai-tools
description: >
  Run a full engineering team over one story, spec first. The session, as PO,
  writes the requirements into the spec and the story; an Architect designs the
  architecture and a plan covering every requirement. For each task a domain
  Specialist details it, a clean-context Implementer delivers, and the
  Specialist validates against the spec and commits. A qa-eng Acceptor checks
  the whole branch against the spec before cleanup and the pull request. Use for
  /team-ai-tools.
argument-hint: "[story or feature description, or slug of a team plan to resume]"
---

<skill name="team-ai-tools">
  <overview>
    Plan and deliver one story with a team of specialist subagents. The session acts as the Product Owner (PO), reviewing repository documentation without reading application code, asking batched questions with recommended options, resolving the implementer, and writing the requirements into the spec and the change into the story. Once approved, the session dispatches an Architect subagent with clean context to perform technical code intake, question what the spec leaves unverifiable, draft the target architecture with Mermaid diagrams, decompose work into atomic tasks with assigned Specialists, and record architectural decisions, constraints, verification commands, and the coverage of every requirement by a task. Story, spec, and plan are committed together. After plan approval, for each task the session dispatches the designated Specialist with clean context to write the task file detailing changes and required test behaviors, dispatches a fresh resolved Implementer per delivery attempt to write code, author and execute tests, run linters, and record a factual report, and re-engages the Specialist to validate the delivery scenario by scenario against the spec and the uncommitted git diff and commit on approval. Once every task is done, a fresh `qa-eng` Acceptor judges the whole branch against the spec and sends gaps back through the task loop. The session then removes the plan directory, keeps the spec, commits the cleanup, pushes the team branch, and creates a pull request carrying the acceptance table.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `Spec`: Requirements and scenarios, the authority on behavior, in `{SPEC_DIR}/{CAPABILITY}.md` per `<rule id="spec-format">`, written by the PO session.
      - `Story` (User Story): The change, in `docs/team-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, written by the PO session: context, the requirement IDs it adds, changes, or removes, scope, and the implementer type.
      - `Plan`: Technical artifact written to `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` decomposed into atomic tasks, guiding technical execution, with constraints, verification commands, and the coverage of every requirement.
      - `Task`: Atomic, committable deliverable specified in `docs/team-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md` by a Specialist.
      - `Specialist`: Subagent dispatched with clean zeroed context and assigned a specific domain role to plan, advise, and validate a task.
      - `Validator`: The Specialist when adversarially reviewing task implementation against the spec and the uncommitted git diff, hunting for defects, and committing the task.
      - `Acceptor`: Fresh `qa-eng` Specialist with clean context that judges the whole branch against the spec before the pull request.
      - `User`: Person interacting with the session.
      - `PO` (Product Owner): The interactive session itself. Focuses exclusively on repository documentation and business domain requirements without reading application code.
      - `Architect`: Dispatched specialist subagent who designs architecture, creates the general plan `0-{SLUG}.md`, assigns specialists, and specifies architectural decisions.
      - `Implementer`: Clean-context agent of the story implementer type, resolved per `<rule id="implementer-selection">`, that writes code and tests for one delivery attempt per `<rule id="implementer-lifecycle">`.
    </rule>

    <rule id="spec-format">Requirements live in spec files, the authority on behavior:
      - {SPEC_DIR} is the spec directory the repository keeps: `docs/specs`, or its own, in the format and identifiers already used there. When the repository keeps none and its documentation settles no spec policy, the PO asks the user once whether to keep one at `docs/specs`; if declined, {SPEC_DIR} is `docs/team-ai-tools/{SLUG}/specs`, removed with the plan directory.
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
      - A decision that adds, changes, or removes observable behavior is an amendment, whatever raised it: an Architect or Specialist question, a plan modification, a blocked task, or an acceptance gap. Once the user confirms it, the session edits the spec files and logs it under `Amendments` in the story; when branch `team/{SLUG}` exists, it commits only those files with `docs(spec): amend {SLUG}`.
      - When an amendment leaves a requirement without a task, the session has the Architect re-plan, the live one before the plan is committed and a fresh `<template role="architect">` afterwards, with {ACTION} = re-plan and {FEEDBACK} naming the amendment.
      - A decision that leaves behavior unchanged stays in the "Decisions" section of the plan or of the task file.
    </rule>

    <rule id="po-role">The session embodies the Product Owner role exclusively:
      - The PO never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps).
      - The PO resolves scope boundaries, business logic, user-facing behavior, and ambiguities.
      - If documentation is missing, outdated, or requires adjustments, the PO includes documentation adequacy as a mandatory story requirement.
    </rule>

    <rule id="specialists-catalog">Specialist roles available for task assignment in the macro plan, each with the domain guidelines injected into its dispatches ({SPECIALIST_SUMMARY}):
      - `architect`: Software architect — modularity, clean architecture, dependency inversion, interface contracts, loose coupling, verifying assumptions against code.
      - `sec-eng`: Senior security engineer — zero trust, threat modeling, input sanitization, authentication and authorization, secret hygiene, least privilege, OWASP Top 10 mitigations.
      - `devops-eng`: Senior DevOps engineer — CI/CD automation, reproducible builds, containerization, environment configuration, infrastructure safety, observability.
      - `back-eng`: Senior backend engineer — domain modeling, business logic integrity, API contracts, robust error handling, performance optimization, transactional safety.
      - `front-eng`: Senior frontend engineer — component isolation, accessible UI (WCAG), responsive design, predictable state management, client routing, bundle size awareness.
      - `data-eng`: Senior data engineer / DBA — schema evolution, backward-compatible migrations, safe rollbacks, index optimization, query performance, data integrity.
      - `qa-eng`: Senior QA and test engineer — comprehensive test design, anti-happy-path, boundary values, negative test cases, mock isolation, coverage rigor.
      - `techwriter`: Senior technical writer — accurate documentation matching real implementation, API references, user guides, ADRs, changelogs, verification commands.
      - `ux-designer`: Senior UX designer — intuitive flows, ergonomic interaction patterns, design system consistency, clear feedback and error messaging, microcopy, accessibility.
    </rule>

    <rule id="transient-docs">All user-facing artifacts, user stories, general plans, task files, and decisions belong under `docs/team-ai-tools/{SLUG}/`. A kept spec lives in {SPEC_DIR}, outside that directory, and survives its removal. Raw tool outputs, binary caches, and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. In-repo plan files are committed along the workflow.</rule>

    <rule id="architect-question-rounds">If the Architect finds a requirement it cannot turn into a verifiable check, requirements that contradict each other, or major discrepancies between the spec and repository code, it sends batched questions with recommended options to the PO session. The PO answers directly, up to a maximum of 3 rounds. If critical ambiguities remain after 3 rounds, the PO asks the user whether to continue for another 3 rounds. For critical decisions involving financial costs, irreversible data loss, or destructive operations, the PO relays the question directly to the user and awaits explicit confirmation before proceeding. An answer that changes behavior is an amendment per `<rule id="spec-authority">`; other settled answers are recorded in the "Decisions" section of the plan or of the task file.</rule>

    <rule id="clean-context-lifecycle">Specialist instances are spawned with clean, zeroed context for each task, remain active exclusively while their task is underway (for queries and validation), and are terminated once it is committed or finalized. Every Implementer follows `<rule id="implementer-lifecycle">`: it ends on its return, and rework or a retry goes to a fresh one. No context carries over across distinct tasks. Each acceptance round gets a fresh Acceptor, which ends on its return.</rule>

    <rule id="implementer-rules">The Implementer executes under strict agnostic constraints:
      - Delivers strictly the scope defined in the task file, referencing the user story, the spec files it names, and general plan.
      - If blocked or if planned instructions contradict codebase realities or the spec, stops immediately and returns one line stating it, ending with `<signal code="TASK_STOPPED">`; the session consults the live specialist and spawns a fresh implementer.
      - Authors tests covering specified behaviors (unit tests, smoke tests, schema checks, linters per task nature) and runs the verification commands of the task file, fixing defects until all checks pass.
      - Appends a concise, factual implementation report to the task file covering changed files, a table from each scenario ID to its test and result, test/lint outcomes, obstacles, and resolved specialist decisions (no self-evaluation).
      - Updates task status to `validating` in `0-{SLUG}.md` and ends its return with `<signal code="TASK_DELIVERED">`.
      - Leaves the spec files and the story untouched.
      - Does not commit changes locally.
    </rule>

    <rule id="retry-and-blocked">Retry and escalation protocol:
      - The validator records review observations and verdict at the bottom of the task file.
      - On rework, the validator updates task status to `retry<1..3>` in `0-{SLUG}.md` and appends rework notes. The session spawns a fresh implementer with rework instructions.
      - A task allows up to 3 attempts. If the third attempt fails, the validator sets status to `blocked` in `0-{SLUG}.md`.
      - On blocked status, the session sends an atomic chat message linking the task report.
      - After sending the announcement, the session prompts the user via `<user_interaction>` asking whether to provide extra instructions for 3 additional retries, delivered by a fresh implementer, or abort.
    </rule>

    <rule id="story-acceptance">Once every task is `done`, a fresh Acceptor judges the whole branch against the spec and the story. On gaps it appends convergence tasks to the plan and the session runs them through the task loop, for at most 2 convergence rounds. When the third acceptance still finds a gap, the Acceptor returns `<signal code="STORY_BLOCKED">`; the session sends an atomic chat message linking the plan, then prompts the user via `<user_interaction>` to provide extra instructions for 3 more acceptance rounds, amend the spec per `<rule id="spec-authority">`, or abort.</rule>

    <rule id="finalization-and-pr">Once the story is accepted:
      - The session copies the last acceptance table and the "Decisions" of the plan and the `Amendments` of the story to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`.
      - The session removes the plan directory (`git rm -r docs/team-ai-tools/{SLUG}`) and commits with `chore(team): complete {SLUG} delivery`; a kept spec stays.
      - The session pushes branch `team/{SLUG}` to remote.
      - The session inspects `git log` difference against {BASE_BRANCH} and creates a pull request formatted with a business overview, the acceptance table, the amendments, the decisions, and technical change highlights.
    </rule>
  </boundaries>

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

  <session_workflow>
    <step id="1" name="resolve-entry">
      Derive kebab-case {SLUG} from the argument. If `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` exists, or the active branch is `team/{SLUG}` holding that file, resume at `<step id="15">`. Otherwise start a new story at `<step id="2">`.
    </step>

    <step id="2" name="resolve-implementer">
      Set the {IMPLEMENTER} type per `<rule id="implementer-selection">`: `harness-default` unless the user's request names another.
    </step>

    <step id="3" name="po-doc-analysis">
      Session acts as PO per `<rule id="po-role">`: read repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps). Do not inspect application code. Evaluate user request feasibility from a business perspective and against the requirements already specified. If documentation is lacking or outdated, mark documentation updates as a mandatory requirement.
    </step>

    <step id="4" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first), including the spec directory question of `<rule id="spec-format">` when it applies. Resolve ambiguities, business rules, requirements and their scenarios, edge cases, and scope trade-offs. Repeat until all points are settled, recording a gap too small to ask about as an assumption.
    </step>

    <step id="5" name="write-story">
      Write the requirements into the spec files under {SPEC_DIR} per `<rule id="spec-format">`, editing existing files in place, and the finalized user story to `docs/team-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, recording the {IMPLEMENTER} type per `<rule id="implementer-selection">` and the current branch as {BASE_BRANCH}. Verify both per `<rule id="story-quality">`.
    </step>

    <step id="6" name="story-approval">
      Send an atomic chat message to the user containing the links to the story file and the spec files it touches, as an independent step sent before requesting approval. Then prompt the user via `<user_interaction>` asking whether they approve them or request modifications. If modifications are requested, iterate through `<step id="4">` and `<step id="5">` until approved.
    </step>

    <step id="7" name="dispatch-architect">
      Spawn `<template role="architect">` with clean zeroed context (inheriting session model and effort) with {ACTION} = macro-plan, passing {SLUG}, {STORY_FILE} = `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`, {PLAN_FILE} = `docs/team-ai-tools/{SLUG}/0-{SLUG}.md`, and empty {FEEDBACK}.
    </step>

    <step id="8" name="architect-planning">
      Architect reads {STORY_FILE} and the spec files it names, inspects repository code in scope, identifies points of change, and drafts `0-{SLUG}.md`. The plan must contain:
      1. A task status table: `#`, `Status` (empty for unexecuted, `working`, `validating`, `retry<1..3>`, `blocked`, `done`), `Task` (name), and `Specialist` (assigned specialist from `<rule id="specialists-catalog">`).
      2. Technical objective.
      3. Mermaid target architecture diagram(s).
      4. "Constraints and verification": the repository rules and invariants that bind the design (AGENTS.md, README.md, ADRs, CI) and the exact build, lint, typecheck, and test commands.
      5. Atomic, self-contained, and committable task list with summarized technical descriptions and assigned specialists, each task also giving the requirement and scenario IDs it delivers, its boundary (modules and areas inside it, and what is left to other tasks), its dependencies on earlier tasks, and the architectural direction to follow.
      6. "Coverage": a table from each requirement the story adds, changes, or removes and each `Documentation` item to the tasks that deliver it, marking `enabling` a task that serves none.
      7. Architectural decisions and general rules.
    </step>

    <step id="9" name="architect-clarifications">
      If doubts arise, Architect sends batched questions with recommendations to the PO session per `<rule id="architect-question-rounds">`. Session answers or relays critical decisions to the user, applying amendments per `<rule id="spec-authority">`. All settled decisions are appended to the "Decisions" section of `0-{SLUG}.md`.
    </step>

    <step id="10" name="architect-handover">
      Architect concludes plan drafting, appends decisions, and replies to the session with: "Plan completed successfully: docs/team-ai-tools/{SLUG}/0-{SLUG}.md".
    </step>

    <step id="11" name="plan-announcement">
      Session outputs an atomic chat message to the user with: "Plan completed successfully: docs/team-ai-tools/{SLUG}/0-{SLUG}.md" along with the link to `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`.
    </step>

    <step id="12" name="plan-approval">
      Read the coverage table of the plan: every requirement the story adds, changes, or removes and every `Documentation` item names a task. On gaps, dispatch the live Architect with {ACTION} = re-plan and {FEEDBACK} listing them, and check again. Then prompt the user via `<user_interaction>` asking whether they approve the plan or request modifications.
    </step>

    <step id="13" name="plan-iteration">
      If modifications are requested, amend per `<rule id="spec-authority">` when behavior changes and update {STORY_FILE} if necessary, then dispatch the live Architect with {ACTION} = re-plan and {FEEDBACK} containing user requests. Repeat `<step id="11">` and `<step id="12">` until the user approves.
    </step>

    <step id="14" name="branch-and-commit">
      Upon plan approval, create git branch `team/{SLUG}` based on {BASE_BRANCH}. Stage and commit `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`, `docs/team-ai-tools/{SLUG}/0-{SLUG}.md`, and the spec files with Conventional Commit message `chore(team): initialize plan and story for {SLUG}`. Proceed directly to `<step id="15">`.
    </step>

    <step id="15" name="resolve-task">
      Read `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` and `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`, taking {BASE_BRANCH} from the story. Locate the first unexecuted or active task from the plan status table. When every task is `done`, proceed to `<step id="22">`.
    </step>

    <step id="16" name="dispatch-task-planner">
      For task {TASK_NUM}, identify the assigned specialist role ({SPECIALIST_ROLE}) from `0-{SLUG}.md`. Spawn `<template role="specialist">` with clean zeroed context, {ACTION} = detail-task, passing {SLUG}, {TASK_NUM}, {TASK_SLUG}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE} = `docs/team-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY} from `<rule id="specialists-catalog">`.
    </step>

    <step id="17" name="task-planning-wait">
      Specialist drafts {TASK_FILE} with technical objective, the scenario IDs in scope, touched files list, test behaviors to verify per file/change, at least one per scenario ID and each naming the ID it verifies (unit tests for code; smoke tests, linters, or schema validations for non-code files), the verification commands of the plan that apply, Mermaid relationship diagram, and suggested implementation steps. If questions arise, specialist queries PO or Architect via session relay (up to 3 rounds). Specialist finishes and returns concise outcome with {TASK_FILE} link. Specialist remains active on standby.
    </step>

    <step id="18" name="dispatch-implementer">
      On the first attempt, update task status to `working` in `0-{SLUG}.md` and set {ACTION} = execute-task with empty {REWORK_NOTES}. Resolve the implementer type recorded in `story-{SLUG}.md` per `<rule id="implementer-selection">`. Spawn `<template role="implementer">` as one fresh agent with clean zeroed context, passing {ACTION}, {SLUG}, {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and {REWORK_NOTES}. It ends on its return per `<rule id="implementer-lifecycle">`.
    </step>

    <step id="19" name="implementer-execution-wait">
      Implementer executes per `<rule id="implementer-rules">`: changes, tests and verification commands, factual report appended to {TASK_FILE}, task status `validating` in `0-{SLUG}.md`, and outcome with {TASK_FILE} link. Branch on the signal that ends its return, without reading or validating anything:
      1. `<signal code="TASK_DELIVERED">`: proceed to `<step id="20">`.
      2. `<signal code="TASK_STOPPED">`: the session relays its line to the live specialist, which records guidance in {TASK_FILE}, then repeats `<step id="18">` with a fresh implementer and the same {ACTION} and {REWORK_NOTES}.
    </step>

    <step id="20" name="dispatch-validator">
      Session sends validation request to the active Specialist with {ACTION} = validate-task, {SLUG}, {TASK_NUM}, {PLAN_FILE}, {TASK_FILE}, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY}.
    </step>

    <step id="21" name="validation-and-verdict">
      Specialist judges the uncommitted `git diff` scenario by scenario against the spec files the story names, not only against the task file it wrote, compares it with the implementation report, explicitly verifying that tests were written and genuinely validate defined behaviors (unit tests, smoke tests, validation scripts, or pipeline checks per task type), runs the verification commands of {TASK_FILE}, appends a compliance table, and adversarially hunts for bugs, edge cases, misuse, security flaws, and scope deviations beyond the expected behavior. The session branches on the signal that ends its return:
      1. `<signal code="TASK_APPROVED">`: Specialist confirmed test presence and rigor, set task status to `done` in `0-{SLUG}.md`, staged files, and committed locally with Conventional Commit message. Session terminates the specialist per `<rule id="clean-context-lifecycle">`, and advances to the next task (`<step id="15">`).
      2. `<signal code="TASK_REWORK">` (missing tests, superficial verification, an `unmet` scenario, defects, unhandled edge cases, misuse paths, security flaws, or domain deviation): Specialist set status to `retry<1..3>` in `0-{SLUG}.md` and appended rework items to {TASK_FILE}. Session repeats `<step id="18">` with a fresh implementer, {ACTION} = rework-task, and {REWORK_NOTES} pointing at the rework items (up to 3 attempts).
      3. `<signal code="TASK_BLOCKED">` (3 attempts exhausted): Specialist set status to `blocked` in `0-{SLUG}.md`. Session sends an atomic chat message linking {TASK_FILE}, followed by an interactive prompt via `<user_interaction>` asking the user for extra instructions (+3 retries) or abort per `<rule id="retry-and-blocked">`. On extra instructions, apply any amendment they carry per `<rule id="spec-authority">`, then repeat `<step id="18">` with a fresh implementer, {ACTION} = rework-task, and {REWORK_NOTES} set to them.
    </step>

    <step id="22" name="story-acceptance">
      When {ROUND} is unset, set {ROUND} = 1 and empty {ACCEPTANCE_NOTES}. Announce the spawn in one chat line. Spawn `<template role="acceptor">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {ROUND}, {BASE_BRANCH}, {STORY_FILE}, {PLAN_FILE}, {ACCEPTANCE_NOTES}, and {SPECIALIST_SUMMARY} of `qa-eng` from `<rule id="specialists-catalog">`. It ends on its return; branch per `<rule id="story-acceptance">` without reading or validating anything:
      1. `<signal code="STORY_ACCEPTED">`: proceed to `<step id="23">`.
      2. `<signal code="STORY_GAPS">`: increment {ROUND} and return to `<step id="15">`.
      3. `<signal code="STORY_BLOCKED">`: escalate. On extra instructions, set {ACCEPTANCE_NOTES} to them and {ROUND} = 1, and repeat this step. On an amendment, apply it per `<rule id="spec-authority">`, set {ROUND} = 1, and return to `<step id="15">`. On abort, leave branch `team/{SLUG}` and the plan directory in place for inspection, and report the unmet requirements in one line.
    </step>

    <step id="23" name="plan-cleanup">
      Copy the acceptance table, decisions, and amendments to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`, then remove the plan directory via `git rm -r docs/team-ai-tools/{SLUG}` and commit with `chore(team): complete {SLUG} delivery`, per `<rule id="finalization-and-pr">`.
    </step>

    <step id="24" name="push-and-pr">
      Push branch `team/{SLUG}` to remote. Inspect git log diff against {BASE_BRANCH} and open a pull request formatted per `<rule id="finalization-and-pr">`. Send a one-line outcome with the pull request link.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="architect" executor="inherited">
      <job>Software architect: macro architecture design, system modeling, task decomposition, architectural rules, and technical validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is macro-plan:
        1. Read user story for {SLUG} from {STORY_FILE} and every spec file it names: the requirements it adds, changes, or removes, and the unchanged ones of the same files, which are preserved behavior.
        2. Perform repository intake across files, modules, and dependencies in scope. Do not assume; verify actual code patterns.
        3. Identify existing points of extension and new components needed.
        4. Send batched questions with recommended options to the PO session (up to 3 rounds) on any requirement you cannot turn into a verifiable check, requirements that contradict each other, and major discrepancies between the spec and the code.
        5. Write {PLAN_FILE}:
           - Task status table with columns: `#`, `Status` (initially blank), `Task`, `Specialist`.
           - Technical objective.
           - Mermaid architecture diagram(s) showing target modules, classes, and service boundaries.
           - "Constraints and verification": the repository rules and invariants that bind the design (AGENTS.md, README.md, ADRs, CI) and the exact build, lint, typecheck, and test commands.
           - Atomic task breakdown: each task must be self-sufficient and independently committable, with technical summary, the requirement and scenario IDs it delivers, its boundary (modules and areas inside it, and what is left to other tasks), its dependencies on earlier tasks, the architectural direction to follow, and assigned specialist (from architect, sec-eng, devops-eng, back-eng, front-eng, data-eng, qa-eng, techwriter, ux-designer). Leave file-level changes, test behaviors, and implementation steps to the Specialist.
           - "Coverage": a table from each requirement the story adds, changes, or removes and each `Documentation` item to the tasks that deliver it, marking `enabling` a task that serves none.
           - Architectural decisions and general rules guiding specialists and implementers.
           - "Decisions" section recording resolved questions and choices.
        6. Return concise outcome: "Plan completed successfully: {PLAN_FILE}".

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, the spec files it names, existing {PLAN_FILE}, and user {FEEDBACK}.
        2. Adjust architecture diagrams, task breakdown, specialist assignments, coverage, and decisions in {PLAN_FILE}, leaving `done` tasks as they are.
        3. Return concise outcome: "Plan completed successfully: {PLAN_FILE}".
      </instructions>
      <constraints>
        <constraint>Adhere strictly to clean architecture, dependency inversion, and modularity principles.</constraint>
        <constraint>Do not make unverified code assumptions; verify against repository reality.</constraint>
      </constraints>
    </template>

    <template role="specialist" executor="inherited">
      <job>Domain specialist: task planning, architectural guidance, and adversarial delivery validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <task_slug>{TASK_SLUG}</task_slug>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <specialist_role>{SPECIALIST_ROLE}</specialist_role>
        <specialist_summary>{SPECIALIST_SUMMARY}</specialist_summary>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Act as {SPECIALIST_ROLE} applying domain principles: {SPECIALIST_SUMMARY}.
        When {ACTION} is detail-task:
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE} for plan {SLUG}: architecture, constraints and verification, decisions, and task {TASK_NUM} ({TASK_SLUG}) with its summary, requirement and scenario IDs, boundary, dependencies, and direction.
        2. Inspect relevant repository code in scope. If ambiguities arise, query the PO or Architect via session relay (up to 3 rounds).
        3. Write {TASK_FILE}:
           - General task objective in technical terms.
           - The scenario IDs in scope.
           - List of files to create or modify, with brief description of expected changes.
           - Test behaviors per file or change, at least one per scenario ID and each naming the ID it verifies, plus those the code needs beyond the spec: concrete summary of expected behaviors to verify via unit tests (for application code) or suitable alternatives based on task nature (smoke tests, linter rules, schema validations, or integrity checks for non-code assets such as XML, JSON, markdown, CI pipelines, or configuration files).
           - The verification commands of the plan that apply.
           - Mermaid diagram illustrating relationships between affected components.
           - Suggested sequential implementation steps for the implementer (without writing code), explicitly including authoring tests and verifications for the defined behaviors.
        4. Return concise outcome with link to {TASK_FILE}. Remain active on standby.

        When {ACTION} is validate-task:
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} with its implementation report. Read the uncommitted git diff and judge it scenario by scenario: for each scenario ID in the scope of {TASK_FILE}, the behavior is delivered and a test that would fail without it verifies it.
        2. Verify that corresponding tests were actually written (e.g., unit tests for code; smoke tests, validation scripts, schema checks, or linters for non-code files, pipelines, or configs) and assert that they genuinely test the behaviors defined in {TASK_FILE}, failure paths and edge cases included, rather than superficial or happy-path-only assertions. Run the verification commands of {TASK_FILE} yourself.
        3. Evaluate that the delivery adds no behavior the spec does not ask for, breaks no preserved behavior, follows the plan's architecture, constraints, and decisions, stays inside the task's scope, and matches the report; then evaluate test coverage and execution results, code quality, and domain principles ({SPECIALIST_SUMMARY}).
        4. Review adversarially: assume the delivery hides defects until you have hunted them down, probing beyond the expected behavior for bugs and regressions, unhandled edge cases and boundary values, empty, null, and malformed input, misuse and malicious input, security flaws (injection, missing authorization, secret exposure, unsafe defaults), race conditions and partial failures, error handling, and scope creep or gaps, with the eye of {SPECIALIST_ROLE}. An unlikely but plausible failure in what the delivery touches is a defect.
        5. Append to {TASK_FILE} the compliance table for this attempt, each scenario ID with `met` or `unmet` and its evidence, then review observations, every defect found, and verdict.
        6. If approved: update task {TASK_NUM} status to `done` in {PLAN_FILE}, stage files, commit locally with Conventional Commit message, and return one line with {TASK_FILE}, ending with `<signal code="TASK_APPROVED">`.
        7. If rework needed (including an `unmet` scenario, missing tests, tests failing to verify defined behaviors, defects found by the adversarial review, or domain regressions): update task {TASK_NUM} status to `retry<attempt>` (1..3) or `blocked` (if attempt exceeds 3) in {PLAN_FILE}, append specific rework instructions to {TASK_FILE}, and return one line with {TASK_FILE}, ending with `<signal code="TASK_REWORK">`, or with `<signal code="TASK_BLOCKED">` when the status is `blocked`.
      </instructions>
      <constraints>
        <constraint>Maintain strict domain standards and never approve implementations that lack required tests, fail to genuinely verify defined behaviors, or leave a scenario `unmet`.</constraint>
        <constraint>Delivering what was expected is not enough: never approve while a defect, unhandled edge case, misuse path, or security flaw you found remains.</constraint>
      </constraints>
    </template>

    <template role="implementer" executor="implementer">
      <job>Task implementer: deliver code, run tests, and report factual findings without self-validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <rework_notes>{REWORK_NOTES}</rework_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is execute-task:
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM} of plan {SLUG}. Take any uncommitted changes already in the worktree as your starting point.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities or the spec, stop immediately and return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Author tests covering defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files per task specification) and run the verification commands of {TASK_FILE}. Fix defects until all tests and checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE} detailing changed files, a table from each scenario ID to its test and result, other tests written and executed, test/lint outcomes, blockers encountered, and specialist decisions applied. Do not include self-evaluations.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit changes locally. Return one line with link to {TASK_FILE}, ending with `<signal code="TASK_DELIVERED">`.

        When {ACTION} is rework-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, {TASK_FILE} with its reports and feedback appended to it, and {REWORK_NOTES}. The uncommitted changes in the worktree are the previous attempt; rework them in place.
        2. Apply requested fixes to affected files, tests, or validation scripts. If blocked, stop immediately and return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Re-run the verification commands of {TASK_FILE}, fixing any new failures.
        4. Append rework summary to {TASK_FILE} and ensure task {TASK_NUM} status remains `validating` in {PLAN_FILE}.
        5. Do not commit changes locally. Return one line with link to {TASK_FILE}, ending with `<signal code="TASK_DELIVERED">`.
      </instructions>
      <constraints>
        <constraint>Stay strictly within task scope, leave the spec files and the story untouched, and report factual results only without local commits.</constraint>
      </constraints>
    </template>

    <template role="acceptor" executor="inherited">
      <job>Independent acceptance judge: check the whole branch of one story against every requirement of its spec before the pull request.</job>
      <input>
        <slug>{SLUG}</slug>
        <round>{ROUND}</round>
        <base_branch>{BASE_BRANCH}</base_branch>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <acceptance_notes>{ACCEPTANCE_NOTES}</acceptance_notes>
        <specialist_summary>{SPECIALIST_SUMMARY}</specialist_summary>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Act as `qa-eng` applying: {SPECIALIST_SUMMARY}. You own the acceptance of story {SLUG}; nobody reviews it afterwards. You took no part in planning, implementing, or validating it: judge what is on the branch, not what the reports claim.
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE}: constraints and verification, coverage, and decisions. Treat a non-empty {ACCEPTANCE_NOTES} as the user's extra instructions, granted after the story blocked.
        2. Read the diff of the branch against {BASE_BRANCH}, the plan directory aside, and run every verification command of the plan.
        3. Judge every requirement, scenario by scenario: one the story adds or changes is delivered and verified by a test that would fail without it; one it removes is gone with its tests; every other requirement of the touched spec files still holds; every `Documentation` item is reflected in its document; the spec files changed only in the requirements the story lists, and their text matches the delivered behavior.
        4. Append an "Acceptance round {ROUND}" section to {PLAN_FILE}: a table with columns `ID`, `Requirement`, `Verdict` (`met` or `unmet`), and `Evidence` (the test or the diff location).
        5. If every row is `met`: commit only {PLAN_FILE} with `chore(team): accept {SLUG}` and return one line ending with `<signal code="STORY_ACCEPTED">`.
        6. If a row is `unmet` and {ROUND} is below 3: append one convergence task per gap to {PLAN_FILE}, as a blank-status row in the task status table and an entry with technical summary, requirement and scenario IDs, boundary, dependencies, direction, and assigned specialist (from architect, sec-eng, devops-eng, back-eng, front-eng, data-eng, qa-eng, techwriter, ux-designer), update the coverage table, commit only {PLAN_FILE} with `chore(team): record acceptance gaps for {SLUG}`, and return one line ending with `<signal code="STORY_GAPS">`.
        7. If a row is `unmet` and {ROUND} is 3: commit only {PLAN_FILE} with that same message and return one line naming the unmet IDs and ending with `<signal code="STORY_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Never fix code, tests, the spec, or the story yourself; write nothing but {PLAN_FILE}.</constraint>
        <constraint>Never accept while a scenario lacks a test that genuinely verifies it or a verification command fails.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
