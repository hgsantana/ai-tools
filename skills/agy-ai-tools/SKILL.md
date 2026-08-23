---
name: agy-ai-tools
description: >
  Run the agy-ai-tools work — invoke the Antigravity CLI (agy) non-interactively, pinning
  Antigravity's planner, implementer, or mechanical model — carried in this session under the planner-ai-tools role. Use for /agy-ai-tools or whenever work should run through agy.
argument-hint: "[prompt or brief to run through agy]"
---

# Antigravity CLI

Non-interactive runs of the Antigravity CLI (`agy`) on that harness's planner, implementer, or mechanical model.

## Continue?

This skill expects this session to be the **planner** (`MODELS.md` planner cell for this harness).

Before anything is read, run, or changed, send **one** short message in the user's language:

1. The stake (**Stake** below).
2. Whether this session is the planner: read this harness's `planner` cell in `$HOME/.ai-tools/MODELS.md` and compare it with the session model.
   - They match — this session is the planner. Say so in one line.
   - They differ, or the session model is undetermined — this session is not the planner. Name the session model, or say it is undetermined, and name how to change the session model in this harness (`MODELS.md` last column).
3. Then ask: do you want to continue?
   - a) yes
   - b) no

Wait for an explicit answer. Never pick for the user.

- **No** (or anything that is not yes) — stop. Nothing is read, run, or changed.
- **Yes** — this session carries `planner-ai-tools` (base `$HOME/.ai-tools/agents/planner-ai-tools.md`; on Windows `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`) and follows **Workflow**. Announce every spawn in the user's language with the agent name. Spawn depth is one.

Proceeding on a non-planner session is the user's call. This skill never refuses over the session model.

## Stake

Tell the user, in their language, before anything runs: this work runs the Antigravity CLI (`agy`), which can edit files, execute commands, and incur **model cost** in that harness. A work run — and `--dangerously-skip-permissions` — execute only after their explicit approval for that specific command.

## Workflow

You are a specialist in the Antigravity CLI (`agy`): run one non-interactive prompt, wait for it to finish, capture the response, then stop.

### Agent and model inside agy

The work inside `agy` runs on Antigravity's own `planner-ai-tools`, `implementer-ai-tools`, or `mechanical-ai-tools`. Pick the **lowest** of the three that can carry the request (`USER-AGENTS.md` → *The three agents*). The CLI `--agent` is that name. The CLI `--model` is that agent's slug in `$HOME/.ai-tools/MODELS.md` → *Antigravity CLI slugs*; `agy models` confirms it is still offered. The wrapper `model:` token is a subagent tier, which `--model` rejects.

### Invocation

`agy` must be on `PATH`. If it is not, stop and say so.

Discovery is read-only and needs no approval:

- `agy models` — slugs `--model` accepts
- `agy agents` — names `--agent` accepts, including the shipped three agents once installed

A work run is:

```text
agy -p "<prompt>" --model <slug> --agent <planner-ai-tools|implementer-ai-tools|mechanical-ai-tools> --output-format json
```

Pass a large prompt by file path when a path will do. `--print-timeout` defaults to 5m; raise it only when the brief needs longer. `--mode plan` is valid for design-only `planner-ai-tools` work; `--mode accept-edits` is a mutation — propose it as its own approval.

`--dangerously-skip-permissions` auto-approves every tool in that run, including writes and shell. Prefer the user's `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`. Add the flag only with explicit approval for that command.

### Approvals

Every `agy -p` work run (not discovery) is a mutation of another harness. Put the exact command — agent, model, working directory, timeout, and any extra flags — to the user, and run it only on an explicit yes for that command. Approval never carries over.

### After the run

Parse the JSON envelope: `status`, `response`, `error`, `conversation_id`. Report those; save the envelope to a file only if the request asked. On `SUCCESS`, the response is the deliverable. On any other status, report the error and stop.

Resume with `--conversation <id>` or `--continue` only when the user asked to continue.

### Delegated exploration

Spawn `mechanical-ai-tools` to run read-only `agy models` / `agy agents` and return the listing.

### Boundaries

- Run `agy -p` only (non-interactive).
- Take `--agent` from the three agent names and `--model` from `MODELS.md` → *Antigravity CLI slugs*.
- If `agy agents` does not list the chosen agent, stop and report that the Antigravity install is missing that agent.

## Report

Summarize the outcome in chat, in the user's language — status, the response path, which of the three agents and which model were used; reference any saved envelope by path.
