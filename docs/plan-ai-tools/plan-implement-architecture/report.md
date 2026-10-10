# Architecture & Separation: `plan-ai-tools` & `implement-ai-tools`

## 1. Ubiquitous Language

- **História (User Story)**: Business-level structuring of the user request written to `docs/plan-ai-tools/<slug>/historia-<slug>.md` by the interactive Session acting as PO. Focuses on business goals, user value, domain rules, acceptance criteria, and documentation updates without reading code.
- **Plano (Plan)**: Macro technical execution artifact written to `docs/plan-ai-tools/<slug>/0-<slug>.md` by the Architect specialist. Contains status table, technical objective, Mermaid architecture diagrams, task breakdown, and architectural decisions.
- **Tarefa (Task)**: Atomic, self-sufficient, committable unit of work written to `docs/plan-ai-tools/<slug>/<N>-<slug-tarefa>.md` by a designated Specialist. Contains technical specifications, touched files, component diagrams, and suggested implementation steps.
- **Especialista (Specialist)**: Subagent spawned with clean, zeroed context (inheriting session model and effort) assigned a domain role (architect, sec-eng, devops-eng, back-eng, front-eng, data-eng, qa-eng, techwriter, ux-designer).
- **Validador (Validator)**: The Specialist responsible for inspecting the uncommitted `git diff` against the implementation report, determining approval/rework verdict, updating plan status, and committing the task.
- **Usuário (User)**: The person interacting with the session who invoked the skill.
- **PO (Product Owner)**: The session itself! The PO never reads application code; it inspects repository documentation (README.md, AGENTS.md, docs/) to settle scope, business logic, trade-offs, and documentation requirements.
- **Arquiteto (Architect)**: Dispatched specialist subagent who inspects codebase reality, designs target architecture, creates the general plan `0-<slug>.md`, assigns specialists to tasks, and defines architectural decisions.
- **Implementer**: Agent dispatched with clean zeroed context to write code, execute tests and linters, and record factual findings.

---

## 2. Implementer Types Resolution

The first mandatory question asked by the PO before executing any planning step settles who will implement the story:
1. `mid-level` (Recommended): Mid-level tier of current harness skill (`agy-ai-tools`, `claude-ai-tools`, `copilot-ai-tools`).
2. `harness-default`: Default subagent worker of the current harness (Antigravity = `Flash`, Claude = `Sonnet`, Copilot = `Gemini 3.8 Flash (Copilot)`).
3. `session-subagent`: Subagent spawned with clean zeroed context inheriting current session model and effort.
4. `senior`: Senior tier of current harness skill.
5. `junior`: Junior tier of current harness skill.
6. `session`: Interactive session itself executes code directly without subagents.

The user story records only the generic type identifier so any harness can resolve it dynamically via `<rule id="implementer-types">`.

---

## 3. Specialists Catalog

1. **`architect`** (Software Architect): Macro and micro architecture design, system modeling, modularity, dependency boundaries, architectural rules, interface contracts, and validation.
2. **`sec-eng`** (Senior Security Engineer): Threat modeling, authentication, authorization, secret hygiene, input sanitization, least privilege, OWASP Top 10 mitigation.
3. **`devops-eng`** (Senior DevOps Engineer): CI/CD automation, build configurations, containerization, environment configuration, infrastructure safety, observability.
4. **`back-eng`** (Senior Backend Engineer): Domain modeling, business logic, API contracts, services, error handling, performance optimization, transactional boundaries.
5. **`front-eng`** (Senior Frontend Engineer): UI components, client state, styling, responsive design, bundle optimization, accessibility (WCAG), client routing.
6. **`data-eng`** (Senior Data Engineer / DBA): Data schemas, migrations, storage engines, queries, indexes, data integrity, transactional safety.
7. **`qa-eng`** (Senior QA and Test Engineer): Testing strategy, unit/integration/e2e tests, edge cases, anti-happy-path, boundary values, mock isolation, coverage rigor.
8. **`techwriter`** (Senior Technical Writer): Architectural documentation, user guides, API references, changelogs, migration notes, verification protocols.
9. **`ux-designer`** (Senior UX Designer): User flows, ergonomics, consistency, interaction patterns, design system compliance, microcopy, accessibility.

---

## 4. Separation of Responsibilities

### `plan-ai-tools` (Steps 1–15)
- **Role**: PO Session & Architect Specialist.
- **Scope**:
  - PO queries mandatory Implementer choice (`mid-level` recommended).
  - PO analyzes repository documentation (README.md, AGENTS.md, docs/) without reading source code.
  - PO asks batched questions with recommended options to clarify ambiguities, trade-offs, and scope.
  - PO records finalized user story in `docs/plan-ai-tools/<slug>/historia-<slug>.md` with business requirements, doc adequacy needs, and implementer type.
  - PO sends atomic chat message linking the story.
  - PO asks user for explicit story approval via native interaction tool.
  - Upon story approval, PO dispatches Architect subagent with clean context and story link.
  - Architect inspects code in scope, generates `docs/plan-ai-tools/<slug>/0-<slug>.md` with task status table, technical objective, Mermaid architecture diagrams, task list with assigned Specialists, and architectural decisions.
  - Architect questions loop with PO (up to 3 batched rounds; critical decisions relayed to user).
  - Architect finishes and outputs "Plano concluído com sucesso: <link-arquivo-plano>".
  - PO outputs atomic chat message linking plan and story.
  - Upon plan approval, PO creates branch `plan/<slug>` and commits story and plan (`chore(plan): initialize plan and story for <slug>`).
  - PO sends an atomic completion notice with links to the user story and macro plan.
  - PO prompts user via interactive tool offering to start `implement-ai-tools` directly within the current session to execute the story and plan.

### `implement-ai-tools`
- **Role**: Session Orchestrator, Task Specialists, and Implementer.
- **Scope**:
  - Locates approved plan in `docs/plan-ai-tools/<slug>/0-<slug>.md` and reads `historia-<slug>.md`.
  - Sequential task loop (Tasks $1..N$):
    1. **Just-in-time Task Planning**: Dispatches assigned Specialist with clean context to write `docs/plan-ai-tools/<slug>/<N>-<slug-tarefa>.md` (objective, touched files, Mermaid diagram, suggested steps without code).
    2. **Execution**: Session marks status `working` in `0-<slug>.md`, resolves Implementer type, and dispatches Implementer with clean context to write code, run tests, run linters, and append factual report.
    3. **Validation**: Session re-engages Specialist (Validator) to inspect uncommitted git diff against task report.
    4. **Verdict & Commit**: If approved, Validator sets status to `done` in `0-<slug>.md`, stages files, commits locally with Conventional Commit message, and returns approved message. Specialist and Implementer are terminated.
    5. **Rework / Blocked**: If rework needed, Validator sets status to `retry<1..3>`, appends rework notes, and session loops with live Implementer (up to 3 retries). If exceeded, Validator sets status to `blocked`, session sends atomic chat notification, then interactive prompt asking user for instructions (+3 retries) or abort.
  - **Finalization**:
    - When all tasks are `done`, Session removes `docs/plan-ai-tools/<slug>/` and commits cleanup (`chore(plan): complete <slug> delivery`).
    - Session pushes branch `plan/<slug>` to remote.
    - Session inspects `git log` diff against base branch and opens a Pull Request formatted with business overview first, followed by technical highlights.

---

## 5. Dispatch Templates & Agnostic Prompts

### A. Specialist Summary Injection (`{SPECIALIST_SUMMARY}`)
Injected into every specialist dispatch to enforce domain-specific standards:
- **Architect**: Clean architecture, modularity, dependency inversion, interface contracts.
- **Sec-Eng**: Zero trust, input validation, authentication/authorization, secret hygiene.
- **DevOps-Eng**: Reproducible builds, CI/CD safety, environment configurations, observability.
- **Back-Eng**: Domain logic integrity, API contracts, error handling, transactional safety.
- **Front-Eng**: Component isolation, accessibility (WCAG), responsive design, state management.
- **Data-Eng**: Schema normalization, backward-compatible migrations, safe rollbacks, index optimization.
- **QA-Eng**: Test pyramid, anti-happy-path, boundary values, mock isolation, negative tests.
- **TechWriter**: Accurate documentation matching code reality, ADRs, verification commands.
- **UX-Designer**: Ergonomic flows, design system adherence, clear feedback states, accessibility.

### B. Generic Task Planning Prompt (Agnostic for all specialists)
Instructs the specialist to write `<N>-<slug-tarefa>.md`:
1. Technical objective.
2. Touched/created files list with brief expectations.
3. Mermaid relationship diagram.
4. Suggested sequential implementation steps for the implementer (without writing code).
5. Injected `{SPECIALIST_SUMMARY}` to enforce domain excellence.

### C. Generic Task Validation Prompt (Agnostic for all specialists)
Instructs the validator specialist to:
1. Read implementation report in `<N>-<slug-tarefa>.md`.
2. Inspect uncommitted `git diff` against reported changes.
3. Evaluate test and linter coverage and domain best practices ({SPECIALIST_SUMMARY}).
4. Append review observations and verdict to task file.
5. Update task status in `0-<slug>.md` (`done`, `retry<1..3>`, or `blocked`).
6. If approved, stage files and commit locally with Conventional Commit message.

### D. Generic Execution Prompt for the Implementer
Instructs the implementer to:
1. Deliver only within scope of `{TASK_FILE}`, referencing `{STORY_FILE}` and `{PLAN_FILE}`.
2. Stop and notify session immediately if blocked or if plan contradicts codebase reality.
3. Execute test suites and static analysis tools/linters, resolving all defects.
4. Append concise factual report to `{TASK_FILE}` (changed files, test/lint outcomes, obstacles, resolved decisions; no self-evaluations).
5. Update task status to `validating` in `{PLAN_FILE}`.
6. Do NOT commit changes locally.

### E. Additional Prompts
- **Architect Macro-Planning Prompt**: Read story, intake codebase, generate `0-<slug>.md` with status table, Mermaid diagrams, task breakdown with specialist assignments, architectural decisions.
- **Architect Re-Planning Prompt**: Adjust plan based on user feedback.
- **Implementer Rework Prompt**: Read rework notes, apply fixes in place, re-run tests/linters, update report, keep status `validating`.
