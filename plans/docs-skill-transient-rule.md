# Plan: docs-skill-transient-rule

## Status Table
| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Bootstrap Branch and Plan | done | default-worker |
| 2 | Global Rule in USER-AGENTS.md | done | default-worker |
| 3 | Migrate vibe-ai-tools to docs/vibe-ai-tools | pending | default-worker |
| 4 | Migrate campaign-ai-tools to docs/campaign-ai-tools | pending | default-worker |
| 5 | Migrate team-ai-tools to docs/team-ai-tools | pending | default-worker |
| 6 | Migrate ui-ai-tools to docs/ui-ai-tools | pending | default-worker |
| 7 | Documentation & Scripts Alignment (README & tests) | pending | default-worker |
| 8 | Final Verification and Delivery to Pull Request | pending | default-worker |

---

### Stage 1: Bootstrap Branch and Plan
- **Files in scope**: `plans/docs-skill-transient-rule.md`
- **Out of scope**: any edits to source rules, skills, or scripts
- **Acceptance criteria**:
  - Branch `plan/docs-skill-transient-rule` is checked out from `master`.
  - The full plan is saved to `plans/docs-skill-transient-rule.md`.
  - Status of Stage 1 is marked as `done` in `plans/docs-skill-transient-rule.md`.
- **Required tests**: Git branch check and file existence.
- **Verification commands**: `git branch --show-current && test -f plans/docs-skill-transient-rule.md`
- **Conventional Commit message**: `chore(plans): bootstrap plan docs-skill-transient-rule`

---

### Stage 2: Global Rule in USER-AGENTS.md
- **Files in scope**: `USER-AGENTS.md`
- **Out of scope**: Skills, README.md, scripts
- **Acceptance criteria**:
  - Global rule establishes that all plan files, reports, decisions, and documentation (even transient) must be saved in `docs/<full-skill-name>/*` (or `docs/plan/{SLUG}/*` for general sessions without a skill).
  - All other artifacts (raw tool results, binaries such as screenshots, caches, or files pending AI analysis/reporting) remain in harness temporary folders (`${TMPDIR:-/tmp}/ai-tools/`).
  - Every skill that writes to `docs/<skill>/*` deletes the entire skill directory upon delivery (`git rm -r docs/<skill>`), so that intermediate evolution is tracked in git history while the final repo state remains clean.
  - On `blocked` status, `docs/<skill>/*` is preserved on the branch for post-mortem inspection.
  - Existing rules (`first-stage`, `stage-report`, `last-stage`, `clean-context`, `stage-close`, `chat`, `no-secrets`) are updated consistently.
  - Character count does not exceed the 8,000 character limit (rule 3).
  - No `##` sub-headings.
  - Semantic XML conforms to `XML_VOCAB`.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `feat(rules): add global transient docs rule to USER-AGENTS.md`

---

### Stage 3: Migrate vibe-ai-tools to docs/vibe-ai-tools
- **Files in scope**: `skills/vibe-ai-tools/SKILL.md`
- **Out of scope**: other skills, README.md, scripts
- **Acceptance criteria**:
  - `vibe-ai-tools` writes plans and stage reports to `docs/vibe-ai-tools/{SLUG}.md` (or `docs/vibe-ai-tools/{SLUG}/plan.md`).
  - During the last stage, removes `docs/vibe-ai-tools/{SLUG}/` (or `docs/vibe-ai-tools/`), commits removal, pushes, and opens PR.
  - On block, preserves `docs/vibe-ai-tools/` with blocked evidence.
  - Description <= 500 characters.
  - Semantic XML validates against `scripts/lint.sh`.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `feat(vibe-ai-tools): migrate plans and reports to docs/vibe-ai-tools`

---

### Stage 4: Migrate campaign-ai-tools to docs/campaign-ai-tools
- **Files in scope**: `skills/campaign-ai-tools/SKILL.md`
- **Out of scope**: other skills, README.md, scripts
- **Acceptance criteria**:
  - `campaign-ai-tools` bootstrap writes campaign plan/record to `docs/campaign-ai-tools/{CAMPAIGN}/campaign.md` (or `docs/campaign-ai-tools/{CAMPAIGN}.md`).
  - Stage 1 of each goal writes to `docs/campaign-ai-tools/{CAMPAIGN}/{N}-{SLUG}.md`.
  - Finish stage deletes `docs/campaign-ai-tools/{CAMPAIGN}/` (or `docs/campaign-ai-tools/`), commits, pushes, and opens PR.
  - Block preserves the campaign directory under `docs/campaign-ai-tools/`.
  - Description <= 500 characters.
  - Semantic XML validates against `scripts/lint.sh`.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `feat(campaign-ai-tools): migrate campaign plans and reports to docs/campaign-ai-tools`

---

### Stage 5: Migrate team-ai-tools to docs/team-ai-tools
- **Files in scope**: `skills/team-ai-tools/SKILL.md`
- **Out of scope**: other skills, README.md, scripts
- **Acceptance criteria**:
  - Pre-approval exploration stays in harness temp (`${TMPDIR:-/tmp}/ai-tools/team/{SLUG}/`).
  - Starting with stage 1 / bootstrap, reports, findings, decisions, and plans are stored in `docs/team-ai-tools/{SLUG}/*`.
  - Tool outputs and binary artifacts remain in harness temp (`${TMPDIR:-/tmp}/ai-tools/`).
  - On delivery finish / last stage, deletes `docs/team-ai-tools/{SLUG}/` (or `docs/team-ai-tools/`), commits, pushes, and opens PR.
  - On block, preserves `docs/team-ai-tools/` with evidence.
  - Description <= 500 characters.
  - Semantic XML validates against `scripts/lint.sh`.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `feat(team-ai-tools): migrate team reports and plans to docs/team-ai-tools`

---

### Stage 6: Migrate ui-ai-tools to docs/ui-ai-tools
- **Files in scope**: `skills/ui-ai-tools/SKILL.md`
- **Out of scope**: other skills, README.md, scripts
- **Acceptance criteria**:
  - Textual route reports, routes.md, and plans are stored in `docs/ui-ai-tools/{SLUG}/*` during delivery.
  - Screenshots and binaries (`*.png`) and raw server logs remain in harness temp (`${TMPDIR:-/tmp}/ai-tools/ui/{SLUG}/`).
  - On delivery last stage, deletes `docs/ui-ai-tools/{SLUG}/` (or `docs/ui-ai-tools/`), commits, pushes, and opens PR.
  - On block, preserves `docs/ui-ai-tools/` with evidence.
  - Description <= 500 characters.
  - Semantic XML validates against `scripts/lint.sh`.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `feat(ui-ai-tools): migrate route reports and plans to docs/ui-ai-tools`

---

### Stage 7: Documentation & Scripts Alignment (README & tests)
- **Files in scope**: `README.md`, `scripts/test/lib.sh`
- **Out of scope**: `USER-AGENTS.md`, `skills/`
- **Acceptance criteria**:
  - Rules 22, 23, 24, 25 in `README.md` updated to document `docs/<skill>/` and `docs/plan/` transient docs instead of `plans/`.
  - `scripts/test/lib.sh` excludes transient docs or `plans/` as appropriate in `t_build_origin`.
  - All lint checks pass without warnings.
- **Required tests**: `./scripts/lint.sh`
- **Verification commands**: `./scripts/lint.sh`
- **Conventional Commit message**: `docs: update rules and architecture docs for docs-skill convention`

---

### Stage 8: Final Verification and Delivery to Pull Request
- **Files in scope**: `plans/docs-skill-transient-rule.md`
- **Out of scope**: none
- **Acceptance criteria**:
  - Full test suite `./scripts/test.sh` passes completely (0 warnings/failures).
  - `./scripts/lint.sh` passes completely.
  - `plans/docs-skill-transient-rule.md` removed with `git rm`.
  - Final commit committed: `chore(plans): complete docs-skill-transient-rule`.
  - Branch pushed to remote and pull request opened against `master`.
- **Required tests**: `./scripts/lint.sh && ./scripts/test.sh`
- **Verification commands**: `./scripts/lint.sh && ./scripts/test.sh`
- **Conventional Commit message**: `chore(plans): complete docs-skill-transient-rule`

---

## Stage Reports

### Stage 1: Bootstrap Branch and Plan
- Created and checked out branch `plan/docs-skill-transient-rule`.
- Initialized plan document at `plans/docs-skill-transient-rule.md` from `/tmp/ai-tools/plan-docs-skill-transient-rule.md`.
- Updated Stage 1 status to `done` in the status table.
- Verified current branch and plan file existence.

### Stage 2: Global Rule in USER-AGENTS.md
- Updated `USER-AGENTS.md` planning protocol with `<rule id="transient-docs">`, requiring transient plans and docs under `docs/<full-skill-name>/*` (or `docs/plan/{SLUG}/*`).
- Updated existing rules (`first-stage`, `stage-report`, `last-stage`, `clean-context`, `stage-close`, `chat`, `no-secrets`) to align with the `docs/<skill>/` directory convention and harness temp separation.
- Verified XML grammar, heading constraints, and 8,000 char limit (7,450 chars) via `./scripts/lint.sh`.
