# Vibe Decisions: On-Demand Stage Planning

- **Implementer Model**: `flash`
- **Scope Alignment**:
  - Adopt on-demand stage planning across all multi-stage skills: `plan-ai-tools`, `dev-ai-tools`, `vibe-ai-tools`, and `campaign-ai-tools`.
  - User grill-me interview is restricted strictly to initial base plan authoring (`0-<slug>.md`).
  - During the execution loop, stage planning resolves design decisions autonomously from repository code evidence and base decisions without interrupting the user.
  - Decisions during stage planning are recorded directly in the stage file (`<n>-<slug>.md`) header/log without creating a separate decisions file.
  - Stage status transitions: `P` (recorded by session) -> stage-planner creates stage file -> `PF` (recorded by planner) -> `W` (recorded by session) -> implementer writes code -> `V` -> review/judge -> `F` (commit). Interrupted stages at `P` resume with stage-planner.
