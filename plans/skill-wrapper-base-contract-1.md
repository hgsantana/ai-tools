# Stage 1: Shared contract and the rules that define the layout

## Objective

Ship `skills/SKILL-CONTRACT.md` — the single copy of what every agent-backed skill repeats — and make the README define the new three-part skill layout and its two caps, so stages 2–4 have a rule to conform to. No skill file changes yet; the tree is intentionally left with the contract present and unused until stage 2.

## Files

- Create: `skills/SKILL-CONTRACT.md` — the shared contract, read by path, never installed (mirrors `agents/SUBAGENT-CONTRACT.md`)
- Modify: `ROADMAP.md` — story 3's status cell `idea` → `doing` (a plan now exists under `plans/`)
- Modify: `README.md` — rule 7 (layout + wrapper cap), rule 9 (description cap), the `skills/` row of *What is inside*, and the `agents/SUBAGENT-CONTRACT.md` row's sibling entry (the version line is stage 6's)

## Steps

1. **Create `skills/SKILL-CONTRACT.md`** with exactly this content. Every sentence taken from today's `SKILL.md` files is reproduced verbatim; only the hardcoded category, agent name, and base path become references to the base.

   ````markdown
   > Shared contract. Every agent-backed skill wrapper at `skills/<name>/SKILL.md` points here before pointing to its base; edit this file, never a wrapper.

   You are running an **agent-backed skill** in the user's own session. The skill decides only **who runs the work**: the shipped agent, on the model its wrapper pins, or this session, on the model it already has. This contract holds what every agent-backed skill does identically — the model check, the offer, and the route mechanics. What is specific — scope, stake, the agent and its task, the report — is the skill base you load next, and the base prevails wherever the two differ.

   ## 1. Stake

   Surface the base's stake, in the user's language, before anything is read, run, or changed (rule 16). Nothing below happens until the user has seen it.

   ## 2. Model check

   1. Read `$HOME/.ai-tools/MODELS.md` (Windows: `%USERPROFILE%\.ai-tools\MODELS.md`) and take the row of the harness you are running in. This agent's model is that row's column for the category the base names; compare model tokens only — a `· effort` note in the cell is advisory.
   2. Compare it with the model this session is actually running, as the harness reports it, never a guess.
   3. A difference — or a harness, row, or running model you cannot determine — counts as a mismatch. It blocks nothing; it only changes what you say next.

   ## 3. Offer, then ask

   Send **one** chat message, in the user's language, carrying the stake above and what each route costs and gives:

   - **Dispatch the agent** — runs on the model its wrapper pins, in its own context. This session stays clean and relays every question and approval; the agent cannot talk to the user directly.
   - **Run it here** — this session reads the agent's base file and follows it on the current model, in this context. No relay: questions and approvals go straight to the user, and this session's context is spent on the work.
   - **Stop** — nothing is read, run, or changed.

   On a mismatch, that same message also states which model is running, which one this agent expects, that the current model is not the best fit for this task, and how to switch it — the row's *Change the session model* column. If this session cannot spawn agents, say so there: only the other two routes remain.

   Then ask one short question referring back to it ("per the notes above, how do you want to proceed?") with three short answers: **dispatch the agent** · **run it here** · **stop**. Wait for an explicit answer; never pick a route yourself.

   ## 4. Route A — dispatch

   - Announce the spawn in chat, in the user's language, then spawn the agent the base names, with the task the base names plus the user's request, passing context as file paths, not contents.
   - The agent cannot reach the user: it returns open questions and approval requests instead of asking. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with that approval. Approval never carries over between actions.
   - Reuse the same agent and its context where the harness allows. What that agent returns, and what must accompany each relay, is the base's *Route A* section.

   ## 5. Route B — run it here

   - Announce it in chat, then read the agent base file the skill base names, in full, and follow it as your own rule set for this request. It is the absolute rule set; the skill base adds only what it states.
   - You are **not** a subagent: never load `agents/SUBAGENT-CONTRACT.md`. Where the base puts a question to the user, ask it here and wait for the answer. Where it requires approval, take it from the user for that specific action; approval never carries over.
   - Categories the base spawns still resolve through `MODELS.md`, your harness row. Announce every spawn in chat with its category and concrete model.

   ## 6. Report

   Report in chat, in the user's language, as the skill base's *Report* section prescribes; reference saved output by path, never by pasting contents.
   ````

2. **README rule 7** — replace the current single-file sentence with the three-part layout and the wrapper cap, keeping the rule number:

   > 7. Skills are optional and harness-agnostic — no per-harness copies, no wrappers per harness. A skill is split like an agent: a **wrapper** at `skills/<name>/SKILL.md`, the only installed file, in one directory every harness registers as-is; a **base** at `skills/<name>.md` holding the behaviour; and, for a skill that fronts an agent, `skills/SKILL-CONTRACT.md` — the model check, the three-route offer, and the route mechanics, shared by every agent-backed skill and read by path, never installed. The wrapper body is exactly, in this order: a one-line scope; the pointer to `$HOME/.ai-tools/skills/SKILL-CONTRACT.md` (agent-backed skills only); the pointer to `$HOME/.ai-tools/skills/<name>.md`, which prevails over the contract. Anything else is drift — move it to the base or the contract. A wrapper is at most **2,000 characters**, frontmatter included: it is what the harness reads to decide whether to route to the skill. That cap is concision (rule 14), not token economy — no supported harness preloads skill bodies; every one that documents the mechanics reads the body on invocation. Canonical body: [skill authoring](#model-map-and-wrapper-authoring).

3. **README rule 9** — append the description cap, keeping the rule number:

   > 9. Skill frontmatter: only universally accepted keys (`name`, `description`) plus optional keys every supported harness tolerates (e.g. `argument-hint`). A key any supported harness rejects does not belong in a shared file. `description` is at most **500 characters**: harnesses budget the skill *list*, not the body — Codex caps it at 2% of the context window or 8,000 characters, Claude Code truncates a description at 1,536.

4. **README canonical skill wrapper body** — in *Model map and wrapper authoring*, after the agent wrapper body block, add the canonical skill wrapper body so the linter can reconstruct it (stage 6 depends on this text existing):

   ````markdown
   A skill wrapper carries frontmatter (rule 9), then exactly:

   ```markdown
   # <Title>

   <One sentence: what this skill covers and who defines the work.>

   You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
   Read it and follow it — it governs the model check, the route offer, and the route mechanics.

   Your base file is `$HOME/.ai-tools/skills/<name>.md`.
   Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
   ```

   On Windows, `%USERPROFILE%` replaces `$HOME`. A skill that fronts no agent omits the contract paragraph.
   ````

5. **README *What is inside*** — update the `skills/` row to describe wrapper + base + contract and the two caps, and add a row for `skills/SKILL-CONTRACT.md` immediately after it, phrased like the `agents/SUBAGENT-CONTRACT.md` row ("Not installed; read by path").
6. **`ROADMAP.md`** — set story 3's status to `doing` in the story table. The entry is deleted only when the work ships (that is the orchestrator's archival step, not this plan's).
7. Run `tools/lint.sh` and fix any finding it reports on the touched files.

## Tests

- No test framework exists in this repository. Validation is `"$HOME/.ai-tools/tools/lint.sh"` — expected clean (`0`), and specifically no new *skill frontmatter*, *naming*, or *size caps* finding.
- Manual: `wc -c skills/SKILL-CONTRACT.md` and confirm the file is **not** matched by `ls -d skills/*-ai-tools` (the installer's glob) — it must never be installed.

## Acceptance criteria

- [ ] `skills/SKILL-CONTRACT.md` exists with the text above, and no skill file references it yet
- [ ] README rules 7 and 9 state the three-part layout, the 2,000-character wrapper cap, and the 500-character description cap, with no rule inserted or renumbered
- [ ] README carries the canonical skill wrapper body and an updated *What is inside* entry for `skills/` plus a row for the contract
- [ ] ROADMAP story 3 shows `doing`; the README version line is **untouched** — the single bump for this branch belongs to stage 6
- [ ] `tools/lint.sh` exits `0`

## Commit

Suggested message: `feat(skills): add the shared skill contract and define the split layout`

## Dependencies

- Requires stages: none
- Parallel-safe with: none (stages 2–4 conform to the text this stage writes)

## Implementation log

(Append-only log added by implementers and planner during execution.)
