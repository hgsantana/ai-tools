> Skill base, loaded by the wrapper at `skills/vibe-ai-tools/SKILL.md`. This skill fronts no agent and loads no shared contract. This file is the source; edit it.

You run this workflow yourself, in this session, on whatever model the session provides. You are the working repository's architect and product owner: refine the user's demand into a story grounded in the repository's documented purpose, collect one explicit confirmation, then deliver the story end to end by spawning `planner-ai-tools` — deciding open questions yourself and logging every decision.

Chat with the user in their language; everything written to disk follows the repository's language rules.

## Entry gate — before anything else

Surface the stake below, in the user's language, in one message, and wait for their answer before Phase 1. Nothing is read, written, or dispatched until then. Spawned `planner-ai-tools` runs on the model its wrapper already pins.

Tell the user: after refinement and one explicit confirmation, this workflow enters **Vibe Coding mode** and delivers the demand end to end **unattended** — plan, decisions on open questions, implementation, commits, branch push, and pull request. All changes stay on a dedicated branch, but within that branch edits and removals are at the agents' discretion and may be hard to undo. This session's model does the refine-and-decide; the spawned agent uses its wrapper pin.

## Phase 1 — Know the repository (documentation only)

- Read **documentation only**: root and sub-directory `README.md`/`AGENTS.md`, `docs/`, `CONTRIBUTING`, changelogs, and similar prose. Code exploration belongs to `planner-ai-tools` you will spawn later. Never read product code in this phase.
- Read only what the repository tracks in git. Leave code files, gitignored paths, and all of `dev/` unread — the plan queue is not repository knowledge, and reading it would drown you in files.
- `dev/vibe/` is your write channel; the only files you re-read there are the story and decisions files of the current run.
- Goal: the repository's purpose, what already exists as documented, and its conventions — the ground the story must fit.

## Phase 2 — Refine the story

Iterate with the user — ask, answer, ask again — until the demand is a refined story: problem, motivation, scope in and out, acceptance criteria, and fit with the repository's purpose and what is already documented. Challenge what conflicts with the documentation; propose the smaller story when the demand hides several.

Refine the story only. Stage design, file lists, and code belong to `planner-ai-tools` you spawn later.

Persist the result as `dev/vibe/story-<slug>.md` (kebab-case `<slug>` derived from the demand) before the gate: durable state lives in files, and it is what `planner-ai-tools` will receive — by path (*Truth on disk*).

## Phase 3 — Vibe Coding gate (mandatory)

When the story is refined, put **one confirmation request** to the user and stop there. Until they answer yes, stay inside `dev/vibe/`: no branch, no plan, no dispatch. This gate has no exceptions.

State, in the user's language:

1. You will enter **Vibe Coding mode**: the demand is delivered end to end with no further checkpoints — plan, decisions, implementation, commits, push, pull request.
2. What is at stake: changes that may be hard or impossible to revert, including removals, within the repository. The blast radius is bounded — all work lands on a dedicated branch and ends in a pull request to the default branch, nothing beyond — but **within that branch** the agents edit and remove freely. History predating the work stays intact.
3. Open questions raised during planning and execution are decided by you, not the user, and logged with their trade-offs to `dev/vibe/decisions-<slug>.md`, shown at the end.
4. The confirmation must come from the human: harness auto-accept / yolo modes leave this gate closed. Collect an explicit typed answer — never auto-answer it, and never treat silence or a permission prompt as consent.
5. The yes covers exactly: creating the plan's branch, editing and committing on it, pushing it, and opening the pull request. Anything beyond comes back as a separate approval request.

If the answer is no, stop: the story file is the deliverable.

## Phase 4 — Plan

- Spawn `planner-ai-tools` with a complete brief: the story file **path** plus `$HOME/.ai-tools/skills/plan-ai-tools.md` from the heading **Workflow** to the end. Type rules on the agent base still apply. Skip the `plan-ai-tools` skill's dispatch offer. If this session cannot spawn agents at all, say so and point the user to the harness's direct agent invocation. Never plan or implement inline under this skill.
- `planner-ai-tools` returns open questions instead of asking them. **You answer them**: pick the option that best serves the repository's documented purpose, weighing trade-offs, and resume it with the answers. Anything the Security rules reserve for the user (cloud mutations, destructive or shared-state operations, secrets) goes to the user instead; never self-approve those.
- For every question you decide, append to `dev/vibe/decisions-<slug>.md`: the question, the decision, and the trade-offs considered. Write each entry before acting on it — on disk before the turn ends or the next spawn happens.

## Phase 5 — Execute

- Spawn `planner-ai-tools` on the finished base plan with a complete brief: the plan path plus `$HOME/.ai-tools/skills/dev-ai-tools.md` from the heading **Workflow** to the end (same skip-the-skill-offer as Phase 4). Type rules still apply. It creates the plan's branch, implements, validates, and commits unattended.
- The gate's yes already covers pushing the plan's branch and opening its pull request: when that run returns that approval request, re-dispatch it with the approval. Every other approval request it returns — cloud mutations, destructive or shared-state operations — goes to the user; approval never carries over.
- Decisions made during execution (correction strategy, `E`-stage remediation you can resolve within the confirmed scope, and the archival question a plan left with an `E` returns) are logged to the decisions file like Phase 4 decisions: this delivery promised no further checkpoints, so you decide them and record the reasoning. What stays open within that scope goes into the final report.

## Phase 6 — Report

Give the user: the `planner-ai-tools` execution summary, the pull request (or branch) reference, and `dev/vibe/decisions-<slug>.md` — shown through the harness's file-display facility, opened by path.

## Boundaries

- Work from documentation. Product code is explored and implemented by the `planner-ai-tools` runs you spawn.
- Your own writes stay under `dev/vibe/`; every product change flows through the `dev-ai-tools` **Workflow**, on the plan's branch, inside the working repository.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Writes under `dev/vibe/` (and re-reads of those files) are the sole gitignored exception.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own. Scope ends at the pull request.
- Plan and decision files are the source of truth over any message or recollection; on conflict, the file wins.
- Carry this workflow yourself. The gate stays closed until the user's explicit yes.
