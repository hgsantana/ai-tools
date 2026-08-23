> Shared contract. Every agent-backed skill wrapper at `skills/<name>/SKILL.md` points here before pointing to its base. This file is the source; edit it.

You are running an **agent-backed skill** in the user's own session. The base you load next names the agent whose role this skill runs on; scope, stake, the workflow, and the report are all its, and it prevails wherever the two differ. This contract owns the gate, the route offer, and the dispatch.

**Spawn depth is one.** Only this session spawns agents; a spawned agent spawns nothing (`$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`). So the **planner** role — which orchestrates and spawns workers — is carried here, by this session, behind the gate below. Every other role spawns nothing: dispatch it, and relay for it.

## 1. Stake

Surface the base's stake, in the user's language, before anything is read, run, or changed (rule 18). Nothing below happens until the user has seen it.

## 2. Planner gate

Only when the base's **Agent** section names `planner-ai-tools`. Read the `planner` cell of this harness's row in `$HOME/.ai-tools/MODELS.md` and compare it with the model this session is running:

- **They match** — this session is the planner. Say so in one line, and offer *run it here* below.
- **They differ, or the session model is undetermined** — that is a second stake and it goes in the message below: this workflow's design decisions would run on a model that is not the pinned planner. Name the session model, or say it is undetermined. *Run it here* stays on offer under that stake — proceeding anyway is the user's call — and `MODELS.md` also names how they change the session model in this harness, which is a route of its own.

## 3. Offer, then ask

Send **one** chat message, in the user's language, carrying the stake above — both, when the gate raised one — and what each route costs and gives:

- **Run it here** (planner role) — this session follows the base's **Workflow** itself and spawns `implementer-ai-tools` and `mechanical-ai-tools` for the work that workflow assigns. Questions and approvals reach the user directly.
- **Dispatch the agent** (every other role) — spawn the agent the base names (wrapper already pins the model). This session stays clean and relays questions and approvals; the agent cannot talk to the user, and it spawns nothing.
- **Change the session model, then re-invoke** — only when the gate did not match: the harness's own way, per `MODELS.md`. Nothing runs until then.
- **Stop** — nothing is read, run, or changed.

Offer only the routes that apply. If this session cannot spawn agents, say so in that message and name what the base cannot deliver without workers.

Then ask one short question referring back to it ("per the notes above, how do you want to proceed?") with those routes as its short answers. Wait for an explicit answer; never pick a route yourself.

## 4. Run it here

- Load the agent base the **Agent** section names and carry that role for the whole run: its type rules bind you as they bind a spawned agent, except that you reach the user directly.
- Follow the base's **Workflow** to the end. Announce every spawn in chat, in the user's language, with the agent name; the wrapper already pins the model.
- Each worker gets a self-contained brief — the user's request and file paths, not contents — plus every obligation the base names for it: a worker does not load this skill.
- A worker cannot reach the user. It returns questions, approval requests, and dispatch requests, and it reports through its assigned file and by finishing. Put each request to the user yourself, in their language; only an explicit yes for that specific action runs it. Approval never carries over between actions. A returned dispatch request is yours to spawn — this session is the only spawner. What the run returns is the base's *Route A* section.

## 5. Dispatch

- Announce the spawn in chat, in the user's language, with the agent name. The wrapper already pins the model.
- Spawn the agent the base names. The dispatch prompt includes, verbatim:

> The brief for this run is the user's request (file paths, not contents) plus `$HOME/.ai-tools/skills/<skill>.md` from the heading **Workflow** to the end. You spawn nothing: work outside your type returns as a dispatch request. Report as that skill base's *Report* section.

  Replace `<skill>` with this skill's directory name. Pass the user's request and any file paths the base names. If the base names a **Task**, include it.
- The agent cannot reach the user: it returns open questions, approval requests, and dispatch requests instead of acting on them. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with that approval. Approval never carries over between actions. A returned dispatch request is yours to spawn — this session is the only spawner.
- Reuse the same agent and its context where the harness allows. What that agent returns, and what must accompany each relay, is the base's *Route A* section.

## 6. Report

Report in chat, in the user's language, as the skill base's *Report* section prescribes; reference saved output by path.
