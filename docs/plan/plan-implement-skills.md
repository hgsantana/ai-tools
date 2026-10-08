# Plan: Migrate Planning and Implementation Protocols to plan-ai-tools and implement-ai-tools

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Setup & Initial Plan Record | done | session |
| 2 | Create `skills/plan-ai-tools/SKILL.md` | pending | session |
| 3 | Create `skills/implement-ai-tools/SKILL.md` | pending | session |
| 4 | Update `USER-AGENTS.md` | pending | session |
| 5 | Update Consumer Skills (`vibe`, `campaign`, `team`, `ui`) | pending | session |
| 6 | Update Linters, Shell Scripts, and Docs | pending | session |
| 7 | Cleanup & Final Verification | pending | session |

---

### Stage 1: Setup & Initial Plan Record
- **Files in scope:** `docs/plan/plan-implement-skills.md`
- **Out of scope:** Core skills or scripts modification
- **Acceptance criteria:**
  - Branch `plan/plan-implement-skills` created from current branch.
  - Plan written to `docs/plan/plan-implement-skills.md`.
- **Required tests:** Branch and file existence check.
- **Verification commands:** `git branch --show-current && test -f docs/plan/plan-implement-skills.md`
- **Conventional Commit:** `chore(plan): initialize plan for plan-ai-tools and implement-ai-tools migration`

---

### Stage 2: Create `skills/plan-ai-tools/SKILL.md`
- **Files in scope:** `skills/plan-ai-tools/SKILL.md`
- **Out of scope:** Other skills or USER-AGENTS.md
- **Acceptance criteria:**
  - Valid skill frontmatter with name `plan-ai-tools`, description <= 500 chars (with `Impact:` and `Agent: session`), argument-hint.
  - Valid semantic XML containing `<skill name="plan-ai-tools">`, `<overview>`, `<session_workflow>`, `<planning_protocol>`, `<boundaries>`.
  - Protocol rules: `grill-me`, `short-stages`, `stage-format`, `stage-commit`, `first-stage`, `stage-report`, `docs-stage`, `last-stage`, `transient-docs`, `implementer-offer`, `present-plan`.
- **Required tests:** Frontmatter validation and XML tag balance.
- **Verification commands:** `test -f skills/plan-ai-tools/SKILL.md`
- **Conventional Commit:** `feat(skills): create plan-ai-tools skill for planning protocol`

---

### Stage 3: Create `skills/implement-ai-tools/SKILL.md`
- **Files in scope:** `skills/implement-ai-tools/SKILL.md`
- **Out of scope:** Other skills or USER-AGENTS.md
- **Acceptance criteria:**
  - Valid skill frontmatter with name `implement-ai-tools`, description <= 500 chars (with `Impact:` and `Agent: session + implementer (model asked once)`), argument-hint.
  - Valid semantic XML containing `<skill name="implement-ai-tools">`, `<overview>`, `<session_workflow>`, `<implementation_protocol>`, `<simple_tasks_protocol>`, `<implementer_job>`, `<dispatch_templates>`, `<boundaries>`.
  - Protocol rules: `clean-context`, `stage-close`, `simple-tasks`, `simple-briefing`, `simple-implementation`.
  - Includes templates for stage implementation and fallback execution.
- **Required tests:** Frontmatter validation and XML tag balance.
- **Verification commands:** `test -f skills/implement-ai-tools/SKILL.md`
- **Conventional Commit:** `feat(skills): create implement-ai-tools skill for execution protocols`

---

### Stage 4: Update `USER-AGENTS.md`
- **Files in scope:** `USER-AGENTS.md`
- **Out of scope:** Skills files
- **Acceptance criteria:**
  - Remove `<planning_protocol>`, `<implementation_protocol>`, and `<simple_tasks_protocol>`.
  - Retain `<execution_protocol>` (executors definitions and rules), `<unit_tests>`, `<language_rules>`, `<user_interaction>`, `<security_guardrails>`.
  - Total character count well below 10,000 chars.
  - Retain `applyTo: "**"` and `alwaysApply: true`.
- **Required tests:** Heading check and character count check.
- **Verification commands:** `wc -m < USER-AGENTS.md`
- **Conventional Commit:** `refactor(instructions): migrate planning and implementation protocols out of USER-AGENTS.md`

---

### Stage 5: Update Consumer Skills (`vibe`, `campaign`, `team`, `ui`)
- **Files in scope:**
  - `skills/vibe-ai-tools/SKILL.md`
  - `skills/campaign-ai-tools/SKILL.md`
  - `skills/team-ai-tools/SKILL.md`
  - `skills/ui-ai-tools/SKILL.md`
- **Out of scope:** Shell scripts, tests
- **Acceptance criteria:**
  - Update `vibe-ai-tools` to reference `plan-ai-tools` `<planning_protocol>` and `implement-ai-tools` `<implementation_protocol>`.
  - Update `campaign-ai-tools`, `team-ai-tools`, `ui-ai-tools` to reference `plan-ai-tools` and `implement-ai-tools`.
  - All XML references resolve properly.
- **Required tests:** XML cross-reference resolution.
- **Verification commands:** `git status`
- **Conventional Commit:** `refactor(skills): update vibe, campaign, team, and ui to reference plan-ai-tools and implement-ai-tools`

---

### Stage 6: Update Linters, Shell Scripts, and Docs
- **Files in scope:**
  - `scripts/lint.sh`
  - `README.md`
  - `docs/USAGE.md`
- **Out of scope:** Non-related tests
- **Acceptance criteria:**
  - `scripts/lint.sh`: add `plan-ai-tools` and `implement-ai-tools` to `gated` and `IMPLEMENTER_SKILLS`; adjust protocol location checks.
  - `README.md`: update rule 6, rule 23, rule 24, and Semantic XML grammar table.
  - `docs/USAGE.md`: document `/plan-ai-tools` and `/implement-ai-tools`.
  - All linter checks pass cleanly with 0 warnings.
  - All unit/smoke tests pass cleanly (`scripts/test.sh`).
- **Required tests:** `./scripts/lint.sh` and `./scripts/test.sh`.
- **Verification commands:** `./scripts/lint.sh && ./scripts/test.sh`
- **Conventional Commit:** `chore(tooling): update lint checks, README, and USAGE docs for plan and implement skills`

---

### Stage 7: Cleanup & Final Verification
- **Files in scope:** `docs/plan/plan-implement-skills.md`
- **Out of scope:** Repository core files
- **Acceptance criteria:**
  - Remove transient `docs/plan/plan-implement-skills.md` per protocol.
  - Commit removal.
  - Verify complete repository status and tests.
- **Required tests:** `./scripts/test.sh`.
- **Verification commands:** `git status`
- **Conventional Commit:** `chore(plan): complete plan-implement-skills delivery`

---

## Stage 1 Report
- Created branch `plan/plan-implement-skills`.
- Created plan record at `docs/plan/plan-implement-skills.md`.
- Status: Stage 1 complete.
