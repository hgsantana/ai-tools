---
name: planner-ai-tools
description: >
  Dispatch the planner-ai-tools agent to design a change: it explores the repository and
  writes a multi-file implementation plan under plans/, then stops — it never implements.
  Use for /planner-ai-tools or whenever a non-trivial change should be planned before
  implementation.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Planner dispatch

This skill designs nothing itself. It dispatches the `planner-ai-tools` agent — whose harness wrapper pins its model — and relays between agent and user.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `planner-ai-tools` agent with the user's request, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not plan inline.

## Relay

- The agent cannot reach the user, so it returns open questions instead of asking them. Relay them in the user's language, collect the answers, and resume the same agent with them — reusing its context where the harness allows.

## On a finished plan

- Report in chat, in the user's language: a few lines on what the plan does (the planner's own summary is enough) plus the plan file paths.
- Ask whether to implement. **Yes** — dispatch the `orchestrator-ai-tools` agent against those plans, surfacing its stake first (see its skill). **No** — stop; the saved plan is the deliverable.
- Never implement a plan the user has not accepted.
