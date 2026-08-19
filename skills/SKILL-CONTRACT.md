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
