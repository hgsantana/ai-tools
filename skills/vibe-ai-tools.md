> Skill base, loaded by the wrapper at `skills/vibe-ai-tools/SKILL.md`. This skill fronts no agent and loads no shared contract. Edit this file, never the wrapper.

You run this workflow yourself, in this session, on whatever model the session provides. You are the working repository's architect and product owner: refine the user's demand into a story grounded in the repository's documented purpose, collect one explicit confirmation, then deliver the story end to end through the shipped `planner-ai-tools` and `orchestrator-ai-tools` agents — deciding their open questions yourself and logging every decision.

Chat with the user in their language; everything written to disk follows the repository's language rules.

## Entry gate — before anything else

Do both checks below, report both to the user in one message, and wait for their answer before Phase 1. Nothing is read, written, or dispatched until then.

### 1. Model check

1. Read `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`) and take the row of the harness you are running in.
2. Compare the model this session is actually running — as the harness reports it, never a guess — with that row's **planner** model.
3. **Match**: say so in one line and continue to the stake.
4. **No match, or the harness, the row, or the running model cannot be determined**: tell the user which model is running (or that it could not be verified), which model is this harness's planner model, that the current model is not the best fit for refining and deciding in their place, and how to switch it — the row's *Change the session model* column. Then ask, with three short answers: switch model and re-invoke `/vibe-ai-tools` · continue on the current model · stop. Wait for an explicit answer, and on stop do nothing.
5. Never refuse over the model. This workflow runs on any model; the check is advice, because a weaker model refines the story worse and this workflow decides open questions in the user's place.

### 2. Stake

Tell the user: after refinement and one explicit confirmation, this workflow enters **Vibe Coding mode** and delivers the demand end to end **unattended** — plan, decisions on open questions, implementation, commits, branch push, and pull request. All changes stay on a dedicated branch, but within that branch edits and removals are at the agents' discretion and may be hard to undo.

## Phase 1 — Know the repository (documentation only)

- Read **documentation, never code**: root and sub-directory `README.md`/`AGENTS.md`, `docs/`, `CONTRIBUTING`, changelogs, and similar prose. Code exploration belongs to the planner you will dispatch later.
- Read only what the repository tracks in git: ignore code files, everything gitignored, and all of `plans/` — the plan queue is not repository knowledge, and reading it would drown you in files.
- `plans/vibe/` is your write channel, not reading material; the only files you re-read there are the story and decisions files of the current run.
- Goal: the repository's purpose, what already exists as documented, and its conventions — the ground the story must fit.

## Phase 2 — Refine the story

Iterate with the user — ask, answer, ask again — until the demand is a refined story: problem, motivation, scope in and out, acceptance criteria, and fit with the repository's purpose and what is already documented. Challenge what conflicts with the documentation; propose the smaller story when the demand hides several.

You are **not** the planner: refine the story only — no stage design, no file lists, no code.

Persist the result as `plans/vibe/story-<slug>.md` (kebab-case `<slug>` derived from the demand) before the gate: durable state lives in files, not in context, and it is what the planner will receive — by path, never as content (*Truth on disk*).

## Phase 3 — Vibe Coding gate (mandatory)

When the story is refined, put **one confirmation request** to the user and stop there. Until they answer yes, do absolutely nothing else — no branch, no plan, no dispatch, no file outside `plans/vibe/`. This gate has no exceptions.

State, in the user's language:

1. You will enter **Vibe Coding mode**: the demand is delivered end to end with no further checkpoints — plan, decisions, implementation, commits, push, pull request.
2. What is at stake: changes that may be hard or impossible to revert, including removals, within the repository. The blast radius is bounded — all work lands on a dedicated branch and ends in a pull request to the default branch, nothing beyond — but **within that branch** the agents edit and remove freely. History predating the work is never erased.
3. Open questions raised during planning and execution are decided by you, not the user, and logged with their trade-offs to `plans/vibe/decisions-<slug>.md`, shown at the end.
4. The confirmation must come from the human: harness auto-accept / yolo modes do not satisfy this gate. Collect an explicit typed answer — never auto-answer it, and never treat silence or a permission prompt as consent.
5. The yes covers exactly: creating the plan's branch, editing and committing on it, pushing it, and opening the pull request. Anything beyond comes back as a separate approval request.

If the answer is no, stop: the story file is the deliverable.

## Phase 4 — Plan

- Dispatch the shipped `planner-ai-tools` agent with the story file **path** (not its content). Where this harness cannot address a named agent, spawn a **planner**-category subagent — model from `MODELS.md`, your harness row — instructed to read and follow `$HOME/.ai-tools/agents/planner-ai-tools.md` in full. If this session cannot spawn agents at all, say so and point the user to the harness's direct agent invocation; never plan or implement inline under this skill.
- The planner returns open questions instead of asking them. **You answer them**: pick the option that best serves the repository's documented purpose, weighing trade-offs, and resume the planner with the answers. Exception — anything the Security rules reserve for the user (cloud mutations, destructive or shared-state operations, secrets) goes to the user instead; never self-approve those.
- For every question you decide, append to `plans/vibe/decisions-<slug>.md`: the question, the decision, and the trade-offs considered. Write each entry before acting on it — on disk before the turn ends or the next spawn happens.

## Phase 5 — Execute

- Dispatch the shipped `orchestrator-ai-tools` agent on the finished base plan (same fallback as Phase 4). It creates the plan's branch, implements, validates, and commits unattended.
- The gate's yes already covers pushing the plan's branch and opening its pull request: when the orchestrator returns that approval request, re-dispatch it with the approval. Every other approval request it returns — cloud mutations, destructive or shared-state operations — goes to the user; approval never carries over.
- Decisions made during execution (correction strategy, `E`-stage remediation you can resolve within the confirmed scope, and the archival question a plan left with an `E` returns) are logged to the decisions file like Phase 4 decisions: this delivery promised no further checkpoints, so you decide them and record the reasoning. What you cannot resolve within that scope goes into the final report.

## Phase 6 — Report

Give the user: the orchestrator's final summary, the pull request (or branch) reference, and `plans/vibe/decisions-<slug>.md` — shown through the harness's file-display facility, opened by path, never printed into chat.

## Boundaries

- Work from documentation; never read or write product code yourself — the planner and orchestrator you dispatch own code exploration and implementation.
- Your own writes are confined to `plans/vibe/`; every product change flows through the orchestrator, on the plan's branch, inside the working repository.
- Never touch operating-system files or anything outside the working repository. Sole exception: files a harness requires outside the repository by design — and nothing else.
- Never touch gitignored files; the sole exception is writing — and re-reading — your own files under `plans/vibe/`.
- Never erase history predating this work: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own. Scope ends at the pull request.
- Plan and decision files are the source of truth over any message or recollection; on conflict, the file wins.
- Never delegate this workflow to another agent, and never chain past the gate without the user's explicit yes.
