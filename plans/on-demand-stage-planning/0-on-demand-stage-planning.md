# Plan: On-Demand Stage Planning

## Status Table

| Stage | Status | Executor |
|---|---|---|
| 1 | F | implementer flash |
| 2 | F | implementer flash |
| 3 | F | implementer flash |

## Goal

Restructure multi-stage planning and execution workflows across `plan-ai-tools`, `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`. Initial planning creates only a succinct base plan (`0-<slug>.md`) containing outlines for all stages. During execution, each stage is planned in detail on-demand (`P` -> `stage-planner` -> `PF`) immediately before its implementation (`W` -> `stage-implementer` -> review/judge -> `F`), preventing subsequent stages from becoming stale due to changes introduced in earlier stages.

## Base Branch

`master`

## Execution Graph

```
Stage 1 (plan-ai-tools + dev-ai-tools)
    │
    ▼
Stage 2 (vibe-ai-tools + campaign-ai-tools)
    │
    ▼
Stage 3 (README.md + lint.sh verification)
```

## Stages Outline

### Stage 1: Update plan-ai-tools and dev-ai-tools
- **Objective**: Adapt `plan-ai-tools` to write only `0-{SLUG}.md` with succinct stage outlines, and extend `dev-ai-tools` with `P` and `PF` states and a `stage-planner` template that creates `<N>-{SLUG}.md` on demand.
- **Files**:
  - Modify `skills/plan-ai-tools/SKILL.md`
  - Modify `skills/dev-ai-tools/SKILL.md`
- **Expected Commit**: `feat(skills): add on-demand stage planning to plan and dev skills`

### Stage 2: Update vibe-ai-tools and campaign-ai-tools
- **Objective**: Align `vibe-ai-tools` and `campaign-ai-tools` to use the on-demand stage planning flow before implementing each stage.
- **Files**:
  - Modify `skills/vibe-ai-tools/SKILL.md`
  - Modify `skills/campaign-ai-tools/SKILL.md`
- **Expected Commit**: `feat(skills): adopt on-demand stage planning in vibe and campaign skills`

### Stage 3: Update documentation and verify compliance
- **Objective**: Update repository rules in `README.md` (rules 23 and 24) to document the on-demand planning model and verify all rules and references pass `scripts/lint.sh`.
- **Files**:
  - Modify `README.md`
- **Expected Commit**: `docs(readme): document on-demand stage planning lifecycle`

## Open Questions and Risks

- None. Design tree branches resolved during grill-me interview: initial planning conducts the user interview; per-stage planning resolves decisions autonomously from repository code evidence and logs them in each stage file header/log.
