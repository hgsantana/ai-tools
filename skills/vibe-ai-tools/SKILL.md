---
name: vibe-ai-tools
description: >
  Dispatch the vibe-ai-tools agent — the repository's architect/PO: it refines a demand
  with the user from the repository's documentation, then, after explicit confirmation,
  delivers it end to end (plan, decisions, implementation, pull request) via the planner
  and orchestrator agents. Use for /vibe-ai-tools or whenever a demand should be refined
  and delivered end to end.
argument-hint: "[the demand to refine and deliver]"
---

# Vibe dispatch

This skill refines and implements nothing itself. It dispatches the `vibe-ai-tools` agent — whose harness wrapper pins its model — and relays between agent and user.

## Stake — surface before dispatch

Tell the user in their language, before spawning: after refinement and one explicit confirmation, this agent enters **Vibe Coding mode** and delivers the task end to end **unattended** — plan, decisions on open questions, implementation, commits, branch push, and pull request. Changes stay on a dedicated branch, but within it edits and removals are at the agent's discretion and may be hard to undo. Dispatch only once they are aware.

## Dispatch

- Announce the spawn in chat, in the user's language, then spawn the `vibe-ai-tools` agent with the user's demand, passing context as file paths, not contents.
- If this session cannot spawn agents, say so and point the user to the harness's direct agent invocation. Do not refine or implement inline under this skill.

## Relay

- The agent cannot reach the user, so it returns its refinement questions instead of asking them. Relay them in the user's language, collect the answers, and resume the same agent with them — reusing its context where the harness allows.
- **Vibe Coding gate**: before doing anything, the agent returns one mandatory confirmation request. Put it to the user in their language and wait for an explicit answer from the human — never auto-answer it; harness auto-accept / yolo modes do not satisfy it. Resume the agent only on an explicit yes. On no, stop: the story file on disk is the deliverable.
- Any approval request beyond the confirmed scope — cloud mutations, destructive or shared-state operations — is relayed the same way; approval never carries over between actions.

## Report

- Relay the agent's final summary in the user's language, with the pull request (or branch) reference.
- Show the decisions file (`plans/vibe/decisions-<slug>.md`) by opening it through the harness's file-display facility, referencing it by path — do not print its content into chat.
