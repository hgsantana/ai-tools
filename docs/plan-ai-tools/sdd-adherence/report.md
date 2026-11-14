# SDD adherence of the ai-tools skills

Analysis only: no skill was changed. Base: version 0.0.91-ALPHA, commit `fabd0ba`.

## 1. Reading of "SDD for AI"

SDD is read here as Spec-Driven Development with AI coding agents: a structured, behavior-oriented specification is the authority on intent, and plan, tasks, code, and verification derive from it and are checked against it. Practices that recur across Spec Kit, Kiro, OpenSpec, and the literature ([Sources](#sources)):

| Practice | Typical form |
|---|---|
| Structured, testable requirements with stable IDs | Spec Kit `FR-001: System MUST …` with Given/When/Then scenarios; Kiro EARS `WHEN … THE SYSTEM SHALL …`; OpenSpec `### Requirement:` with at least one `#### Scenario:` |
| WHAT and WHY apart from HOW | Functional spec first, technical plan second |
| Ambiguity marked, never guessed | `[NEEDS CLARIFICATION: …]`, a bounded clarify phase, answers kept in the spec |
| Standing project context apart from the spec | Constitution, steering, `AGENTS.md`; the plan passes a compliance gate against it |
| Traceability both ways | Every requirement has a task and every task a requirement (Spec Kit `analyze`) |
| Verification against the spec | Tests encode scenarios; Spec Kit `converge` re-assesses code against the spec until it reports `Converged` |
| An explicit spec lifecycle | Spec-first (discarded after delivery), spec-anchored (kept and evolved), spec-as-source; OpenSpec merges change deltas into living specs at archive |
| Rigor sized to the change | "Use the minimum level of specification rigor that removes ambiguity for your context"; critics report review fatigue and a false sense of control from long markdown specs |

These weigh more for agents than for people. Agents share no memory between dispatches, so files are the only contract. Each prose restatement between artifacts loses precision, so IDs outperform paraphrase. An underspecified agent guesses and over-delivers, so unknowns, non-goals, and preserved behavior must be written. An agent grading its own work passes it, so verification needs an independent reader and per-requirement evidence.

## 2. Verdict per skill

| Skill | Fit | State today | Change | Size |
|---|---|---|---|---|
| `plan-ai-tools` | High | Spec-first pipeline with user gates; free-form story; traceability by paraphrase; verification per task only | G1–G9 | M |
| `vibe-ai-tools` | High, highest payoff | Same pipeline, unattended after story approval: the story is the user's only control surface | G1–G9 with autonomous variants | M |
| `team-ai-tools` | High, largest delta | Same pipeline; validation never returns to the story; the plan lacks per-task criteria | G1–G9, T1–T4 | L |
| `campaign-ai-tools` | Partial | The campaign file is a charter in free prose; each Planner re-invents the scan | C1–C3 | S |
| `audit-ai-tools` | Edges only | Read-only investigation; its charter, evidence, and verdict contracts already exceed SDD rigor | A1–A2, optional | S |
| `agy-`, `claude-`, `codex-`, `copilot-ai-tools` | None | Transport of one task prompt | None | — |
| `az-`, `gc-`, `gh-`, `stripe-ai-tools` | None | Operational queries behind approval guardrails | None | — |
| `update-`, `remove-ai-tools` | None | Script runners | None | — |
| `AI-TOOLS-AGENTS.md` | None | Already the constitution layer | None (section 6) | — |

Size is the relative edit size: small, medium, large. G, T, C, and A items are defined in sections 4 and 5.

## 3. What already matches SDD (keep)

- Story, plan, and task file are three artifacts with approval gates between them: WHAT, HOW, and unit of work.
- The PO never reads application code, which keeps the story at behavior level by construction.
- Clean-context subagents whose only continuity is the plan directory and git history: the files already are the contract.
- Task files are detailed just in time against what earlier tasks committed, so they do not go stale like an upfront task list.
- An independent Evaluator judges the worktree, not the report, and hunts adversarially.
- Batched questions with a recommended option, bounded Planner question rounds, capped rework with escalation.
- "Documentation adequacy as a mandatory story requirement" already ties each story to the durable docs.

## 4. Gaps in the delivery skills (plan, vibe, team)

Line references use `plan-ai-tools`; `vibe-ai-tools` carries the same text unless noted.

### G1. The story is free-form

- Today: `write-story` asks for "business context, scope boundaries, acceptance criteria, documentation requirements" with no structure (`skills/plan-ai-tools/SKILL.md:81`, `skills/vibe-ai-tools/SKILL.md:82`, `skills/team-ai-tools/SKILL.md:97`).
- Change: a `story-format` rule fixes the schema. Sections that do not apply are omitted; `Requirements` and `Out of scope` are mandatory. The file keeps the name "story": renaming it to "spec" would churn every placeholder for no behavior change.

```markdown
# Story: {title}
## Context and goal            who needs what, and why
## Requirements
### R1. {name}
The system must {observable behavior}.
- R1.S1 Given {state}, when {action}, then {outcome}.
- R1.S2 Given {invalid state}, when {action}, then {failure outcome}.
## Preserved behavior          P1..Pn: what must not change; for a defect, current versus expected behavior
## Out of scope                explicit non-goals
## Constraints                 imposed technical or business limits, measurable thresholds
## Documentation               per requirement, the durable document that must state it after delivery
## Assumptions and clarifications   defaults assumed, questions settled with the user
## Implementer                 the implementer type
## Amendments                  post-approval changes: what, why, who approved
```

One requirement sentence plus Given/When/Then scenarios is the shape Spec Kit and OpenSpec converge on, and each scenario maps to one test. EARS is the alternative for the requirement sentence.

### G2. No quality gate on the story, and unknowns are not marked

- Today: `po-clarification` repeats "until all points are settled" (`skills/plan-ai-tools/SKILL.md:77`); approval rests on the user's reading (`:84`). Nothing records assumptions or marks an unresolved point.
- Change: before `story-approval` the PO checks the story against a fixed list: each requirement observable and testable, at least one scenario each with the failure path where one exists, no implementation detail, no vague qualifier, one independently deliverable outcome (propose a split otherwise), zero open `[NEEDS CLARIFICATION: …]` markers. Low-impact gaps become recorded assumptions instead of questions.

### G3. Planner questions are limited to code discrepancies

- Today: the Planner asks only on "major discrepancies between the story and repository code" (`skills/plan-ai-tools/SKILL.md:41`, `:165`).
- Change: the Planner opens with an ambiguity pass. Any requirement it cannot turn into a verifiable check, or that contradicts another, returns as a batched question before planning. A clean-context reader is the cheapest test of a spec written for agents.

### G4. Traceability is by paraphrase

- Today: each task receives "the acceptance criteria of the story it serves" in prose (`:167`); test behaviors derive from the task file (`:198`); the Evaluator judges "the story's acceptance criteria for this task" (`:258`). Three restatements separate a requirement from its test.
- Change: IDs run through the chain. The plan names requirement IDs per task. The task file lists the scenario IDs in scope and keys test behaviors by them. The implementer report maps scenario to test to result. The Evaluator verdict opens with a per-scenario compliance table, then hunts adversarially; delivered behavior that no requirement asks for is scope creep.

### G5. Plan coverage is unchecked in plan and team

- Today: `vibe-ai-tools` checks coverage by reading prose (`skills/vibe-ai-tools/SKILL.md:97`); in `plan-ai-tools` the session "reads only the task status table" (`skills/plan-ai-tools/SKILL.md:36`); `team-ai-tools` has no check.
- Change: the Planner writes a coverage table, requirement or preserved behavior to tasks, and marks tasks that serve no requirement as enabling. The session reads that table and returns gaps to the Planner before plan approval (plan, team) or self-approval (vibe).

### G6. Verification stops at the task

- Today: once every task is `done` the session goes straight to cleanup and pull request (`skills/plan-ai-tools/SKILL.md:141`, `:145`). No one checks the integrated branch against the whole story.
- Change: a story acceptance step before cleanup. One clean-context subagent judges the full branch diff against every requirement and preserved behavior, runs the recorded verification commands, and writes an acceptance table: ID, requirement, evidence, documented in. For each unmet requirement it appends one convergence task to the plan and the session re-enters the task loop, capped at 2 rounds before escalation. The table goes into the pull request body, which is where the requirement record survives.

### G7. Standing constraints and verification commands are not captured

- Today: the Planner inspects "files, modules, and dependencies in scope" (`:164`); every clean-context Implementer and Evaluator rediscovers how to run tests and linters (`:228`, `:260`). `audit-ai-tools` already records invariants and toolchain commands once (`skills/audit-ai-tools/SKILL.md:150`).
- Change: the plan gains a "Constraints and verification" section: binding rules and invariants from `AGENTS.md`, `README.md`, ADRs, and CI, plus the exact build, lint, typecheck, and test commands. Implementer and Evaluator run those. This is the SDD constitution check without a new file per repository.

### G8. The story stops being the authority after approval

- Today: settled answers go to "Decisions" of the plan or task file (`:41`, `skills/vibe-ai-tools/SKILL.md:43`); instructions for a blocked task travel as `{FEEDBACK}` (`skills/plan-ai-tools/SKILL.md:137`); the story changes only during plan approval (`:96`).
- Change: a `spec-authority` rule. A decision that adds, changes, or removes observable behavior is written to the story's "Amendments" by the session and the coverage table follows; technical decisions stay in "Decisions". In plan and team the user confirms the amendment. In vibe the session amends under its autonomous policy and the pull request lists every amendment as a deviation from the approved story.

### G9. The spec is discarded

- Today: `finalization-and-pr` removes the plan directory (`skills/plan-ai-tools/SKILL.md:47`), as README rule 22 intends. The skills are spec-first by design; the durable trace is the pull request overview and the documentation the story required.
- Change: decision D1 in section 7.

## 5. Changes per skill

### plan-ai-tools and vibe-ai-tools

| Block | Change |
|---|---|
| `<boundaries>` | New rules `story-format` (G1), `spec-authority` (G8); `session-role` lets the session read the coverage table (G5) |
| `po-doc-analysis` | Also read any spec directory the repository keeps (`specs/`, `openspec/`, `.kiro/specs/`) as documentation |
| `po-clarification`, `write-story`, `story-approval` | Schema, assumptions, open markers, quality check (G1, G2) |
| `<template role="planner">` | Ambiguity pass (G3); requirement IDs per task (G4); coverage table (G5); "Constraints and verification" section (G7) |
| `plan-approval` (plan), `plan-validation` (vibe) | Gate on the coverage table (G5) |
| `<template role="task-planner">`, `<template role="implementer">`, `<template role="evaluator">` | Scenario IDs in the task file, report, and verdict (G4); run the recorded commands (G7) |
| New step, template, and signals before `plan-cleanup` | Story acceptance and convergence (G6) |
| `push-and-pr` | Acceptance table and amendments in the pull request body (G6, G8) |

The two skills share their templates almost verbatim, so one design applies twice. Vibe differs in two places: amendments follow `autonomous-decision-policy`, and a failed convergence takes one autonomous recovery before the user is asked.

### team-ai-tools

G1–G9 as above, plus:

- T1. Validation never returns to the story. `validate-task` reads the report, the diff, and the task file the same Specialist wrote (`skills/team-ai-tools/SKILL.md:244`); the story is a template input that validation does not use. Judge against the story requirements assigned to the task.
- T2. The Architect's plan gives each task only a "technical summary and assigned specialist" (`:202`). Bring it to parity with the Planner: requirement IDs, boundary, dependencies, direction.
- T3. Story acceptance (G6) by a fresh `qa-eng` Specialist.
- T4. Adjacent, not SDD: the skill has no `<return_protocol>`, yet the session branches on prose outcomes (`:165`) while the README grammar requires a `<signal>` for any outcome the caller branches on (`README.md:79`). The validation return changes under G4, so fix both in one edit.

### campaign-ai-tools

- C1. The campaign file holds goal, scope, "definition of a finished work point", and constraints as free prose (`skills/campaign-ai-tools/SKILL.md:59`, `:67`). Structure it: work-point predicate (what qualifies and how to enumerate candidates, as a search recipe or command), done criteria `D1..Dn` each verifiable with its check command when one exists, preserved behavior `P1..Pn`, verification commands.
- C2. Each clean-context Planner re-invents the scan (`:114`), so `CYCLE_EMPTY` depends on one Planner's search. The scan follows the recorded predicate and recipe.
- C3. Validation is per task against the task file (`:124`). Before closing the cycle (`:128`) the Planner checks the work point against every `D` and `P` and records the result per criterion in the cycle plan.

No new gate or subagent: the campaign stays unattended.

### audit-ai-tools (optional)

- A1. Specification conformance as a defect class. A kept spec drifts unless something enforces it; with D1 option B the audit becomes that enforcement. The Mapper lists the durable behavior sources (docs, spec directories, API schemas) in the perimeter, and an eighth lens flags implementation that contradicts them. Runbooks "audited as operational contracts" (`skills/audit-ai-tools/SKILL.md:46`) and the cross-layer fidelity lens (`:185`) cover part of it today.
- A2. Remediation work packages (`:292`) gain expected behavior, preserved invariants, and the check that proves the fix, so a package is a ready story input.

Cost: the skill is 50 KB and was just hardened; each lens adds load to every Scope Auditor.

## 6. Repository-level impact

- No new XML vocabulary: every change fits `<rule>`, `<step>`, `<template>`, and `<signal>`.
- New steps before `plan-cleanup` renumber later steps and every `<step id>` reference in plan, vibe, and team; `scripts/lint.sh` resolves them.
- The story schema is duplicated in plan, vibe, and team, as README rules 5 and 9 require of self-contained skills. Hosting it once in `AI-TOOLS-AGENTS.md` is rejected: that file loads into every session of every harness, and only the story writer needs the schema because the story is self-describing to its readers.
- `docs/USAGE.md` and the README version change in the same commit (rule 4). Rule 22 stays as written under D1 options A and B.
- Runtime cost per story: one acceptance subagent, up to 2 convergence rounds, and longer story and plan files. No extra user gate.

## 7. Decisions for the user

- D1. Spec lifecycle.
  - A. Transient spec, pull request record: the plan directory is still removed; the acceptance table in the pull request body is the trace.
  - B. A plus durable docs as the living spec (recommended): the story names, per requirement, the durable document that must state it, and acceptance verifies it. No new directory in target repositories; a repository that already keeps Spec Kit, OpenSpec, or Kiro specs gets them updated as documentation.
  - C. A durable spec directory in every target repository, merged at finalization in the OpenSpec manner. Closest to spec-anchored, but it imposes a layout on every repository, changes README rule 22, and accumulates files nothing enforces.
- D2. Rollout. Recommended: plan and vibe first, then team, then campaign; audit only if D1 is B or C.
- D3. Amendments in vibe. Recommended: autonomous and listed in the pull request. The alternative, always asking the user, breaks the unattended run.

## 8. Not recommended

- The Spec Kit artifact set (`research.md`, `data-model.md`, `quickstart.md`, `contracts/`, `checklists/`): story, plan, and task file hold the same content in fewer files to review.
- An upfront task list with parallel markers or waves: the uncommitted worktree is the handoff of exactly one task.
- Mandatory failing-test-first: the Evaluator judges the worktree, so a "failed first" claim is unverifiable by design.
- Spec-as-source: Böckeler's concern is that it inherits the downsides of both model-driven development and LLMs, inflexibility and non-determinism.
- A constitution file per repository: `AGENTS.md` and `README.md` hold that role and G7 reads them.

## Sources

- [GitHub Spec Kit](https://github.com/github/spec-kit): templates and commands `specify`, `clarify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`, `converge` (v1.4.0 at reading time).
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) and its [CLI reference](https://openspec.dev/docs/cli): requirement and scenario format, change deltas, archive merge.
- [Kiro specs](https://kiro.dev/docs/specs/), [best practices](https://kiro.dev/docs/specs/best-practices/), [correctness](https://kiro.dev/docs/specs/correctness/), [steering](https://kiro.dev/docs/steering/): EARS requirements, bugfix specs, Quick Spec, steering files.
- [Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), Birgitta Böckeler: the three levels and the criticisms.
- [Spec-Driven Development: From Code to Contract in the Age of AI Coding Assistants](https://arxiv.org/html/2602.00180), arXiv 2602.00180: workflow, validation, when SDD is not worth it.
- [Thoughtworks Technology Radar: Spec-driven development](https://www.thoughtworks.com/radar/techniques/spec-driven-development): Assess ring, November 2025 edition, with its cautions.
