> Shared contract. Every agent-backed skill wrapper at `skills/<name>/SKILL.md` points here before pointing to its base; edit this file, never a wrapper.

You are running an **agent-backed skill** in the user's own session. The skill decides only **whether the named agent runs**: it dispatches that agent (that agent's wrapper already pins the model; the agent follows this skill's **Workflow**) or it stops. This contract holds what every agent-backed skill does identically — the offer and the dispatch. What is specific — scope, stake, which agent, the workflow, the report — is the skill base you load next, and the base prevails wherever the two differ.

Never run the skill's **Workflow** in this session. `/vibe-ai-tools` is not this contract. Never read `$HOME/.ai-tools/MODELS.md` to pick a model: the dispatched agent's wrapper is already pinned.

## 1. Stake

Surface the base's stake, in the user's language, before anything is read, run, or changed (rule 16). Nothing below happens until the user has seen it.

## 2. Offer, then ask

Send **one** chat message, in the user's language, carrying the stake above and what each route costs and gives:

- **Dispatch the agent** — spawn the agent the base names. Its wrapper pins the model. This session stays clean and relays every question and approval; the agent cannot talk to the user directly. The agent follows this skill's **Workflow**.
- **Stop** — nothing is read, run, or changed.

If this session cannot spawn agents, say so in that message: only **stop** remains — never run the workflow here.

Then ask one short question referring back to it ("per the notes above, how do you want to proceed?") with two short answers: **dispatch the agent** · **stop**. Wait for an explicit answer; never pick a route yourself.

## 3. Dispatch

- Announce the spawn in chat, in the user's language, with the agent name. Do not look up a model; the wrapper already pins it.
- Spawn the agent the base names. The dispatch prompt includes, verbatim:

> Read your agent base, then read `$HOME/.ai-tools/skills/<skill>.md` from the heading **Workflow** to the end and follow it as the absolute rule set for this request. The user's request is passed as file paths, not contents. Spawn further work by agent name (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`); each child's wrapper already pins its model. Report as that skill base's *Report* section.

  Replace `<skill>` with this skill's directory name. Pass the user's request and any file paths the base names. If the base names a **Task**, include it.
- The agent cannot reach the user: it returns open questions and approval requests instead of asking. Relay each in the user's language; only on an explicit yes for that specific action resume the agent with that approval. Approval never carries over between actions.
- Reuse the same agent and its context where the harness allows. What that agent returns, and what must accompany each relay, is the base's *Route A* section.

## 4. Report

Report in chat, in the user's language, as the skill base's *Report* section prescribes; reference saved output by path, never by pasting contents.
