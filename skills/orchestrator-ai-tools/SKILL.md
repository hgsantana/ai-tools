---
name: orchestrator-ai-tools
description: >
  Run the orchestrator-ai-tools work — execute accepted plans under plans/, or an explicit ad-hoc
  brief, unattended — either by dispatching the orchestrator-ai-tools agent or by running its base file
  in this session. Use for /orchestrator-ai-tools or after the user accepts a plan.
argument-hint: "[plan paths or brief to execute]"
---

# Execution

Executing accepted plans under `plans/`, or an explicit ad-hoc brief, unattended. That work is defined by `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\orchestrator-ai-tools.md`). This skill only decides **who runs it**: the shipped `orchestrator-ai-tools` agent, on the model its wrapper pins, or this session, on the model it already has. Never implement outside one of those two routes.

## 1. Stake

Tell the user, in their language, before anything runs: this work edits code, runs commands, and creates local commits **unattended** once started, on a dedicated branch. Offer it only for work they approved — an accepted plan, or an explicit ad-hoc brief; if there is no accepted plan and the work is non-trivial, offer the `planner-ai-tools` skill instead.

## 2. Model check

1. Read `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`) and take the row of the harness you are running in. This agent's model is that row's **planner** column; compare model tokens only — a `· effort` note in the cell is advisory.
2. Compare it with the model this session is actually running, as the harness reports it, never a guess.
3. A difference — or a harness, row, or running model you cannot determine — counts as a mismatch. It blocks nothing; it only changes what you say next.

## 3. Offer, then ask

Send **one** chat message, in the user's language, carrying the stake above and what each route costs and gives:

- **Dispatch the agent** — runs on the model its wrapper pins, in its own context. This session stays clean and relays every question and approval; the agent cannot talk to the user directly.
- **Run it here** — this session reads the agent's base file and follows it on the current model, in this context. No relay: questions and approvals go straight to the user, and this session's context is spent on the work.
- **Stop** — nothing is read, run, or changed.

On a mismatch, that same message also states which model is running, which one this agent expects, that the current model is not the best fit for this task, and how to switch it — the row's *Change the session model* column. If this session cannot spawn agents, say so there: only the other two routes remain.

Then ask one short question referring back to it ("per the notes above, how do you want to proceed?") with three short answers: **dispatch the agent** · **run it here** · **stop**. Wait for an explicit answer; never pick a route yourself.

## Route A — dispatch

- Announce the spawn in chat, in the user's language, then spawn the `orchestrator-ai-tools` agent with the plan or brief file paths, never their contents, passing context as file paths, not contents.
- The agent returns approval requests instead of acting on them — cloud mutations, pushes, destructive or shared-state operations, and the archival question of a plan left with a failed stage. Relay each to the user in their language; only on an explicit yes resume the agent with that approval. Approval never carries over between actions.
- Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Route B — run it here

- Announce it in chat, then read `$HOME/.ai-tools/agents/orchestrator-ai-tools.md` in full and follow it as your own rule set for this request. It is the absolute rule set; this skill adds only what follows.
- You are **not** a subagent: never load `agents/SUBAGENT-CONTRACT.md`. Where the base puts a question to the user, ask it here and wait for the answer. Where it requires approval, take it from the user for that specific action; approval never carries over.
- Categories the base spawns still resolve through `MODELS.md`, your harness row. Announce every spawn in chat with its category and concrete model.

## Report

Summarize the outcome in chat, in the user's language; reference logs, diffs, and updated plan files by path.
