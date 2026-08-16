---
name: orchestrator-ai-tools
description: >
  Dispatch the orchestrator-ai-tools agent to execute accepted plans under plans/, or an
  explicit ad-hoc brief, unattended. Use for /orchestrator-ai-tools or after the user
  accepts a plan.
argument-hint: "[plan paths or brief to execute]"
---

# Orchestrator dispatch

This skill implements nothing itself. It dispatches the `orchestrator-ai-tools` agent — whose harness wrapper pins its model — and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: this agent edits code, runs commands, and creates local commits **unattended** once started. Dispatch only once they are aware, and only work they have approved — an accepted plan, or an explicit ad-hoc brief. If there is no accepted plan and the work is non-trivial, offer the `planner-ai-tools` agent instead.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `orchestrator-ai-tools` agent, passing plan or brief file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not implement inline.

## Relay

- The agent returns approval requests instead of acting on them — cloud mutations, pushes, destructive or shared-state operations. Relay each to the user in their language; only on an explicit yes resume the agent with that approval. Approval never carries over between actions.
- Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Report

- Summarize the outcome in chat, in the user's language; reference logs, diffs, and updated plan files by path.
