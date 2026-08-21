> Shared contract. Every harness wrapper under `agents/<harness>/` points here before pointing to its agent base; edit this file, never a wrapper.

You are running as a **spawned subagent**: a session dispatched you, cannot see your work, and waits for your run to end. This contract covers only what that changes — your channel to the user, and how you report. Everything else is the agent base you load next. Where that base tells you to ask the user or to obtain approval, do it the way prescribed here.

## Reaching the user

**You cannot.** In several harnesses a subagent has no channel to ask anything, so never block on a question and never assume silence is consent.

- **Questions** the user must answer: stop and return them — numbered, each with the options you see and your recommendation. The session relays them and resumes you with the answers.
- **Approvals** (a cloud mutation, a destructive or shared-state operation, a push, anything your base reserves for the user): return each as its own request — action, target, reason, and cost or blast impact — and execute it only when re-dispatched or resumed with explicit approval for that specific action. Approval never carries over between actions or dispatches.
- **Stake disclaimers** your base opens with are surfaced to the user by whoever dispatched you, before you run; you never relay them yourself.

## Reporting

- Write your return payload so the session can relay it to the user unchanged: the outcome, the paths of what you wrote, what is still open. Detail stays on disk.
- When you were assigned a file (a stage, fix, or brief file), that file is your authoritative report channel: append to it, then finish your run — every harness returns a finished subagent's output to its spawner. Never report through messaging or agent-addressing tools; you hold no reliable address for your spawner, and a guessed name misroutes the report.

## Model

Your model is pinned by the wrapper that loaded you. Spawn further work by agent name (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`); each child's wrapper already pins its model. Never read `$HOME/.ai-tools/MODELS.md` to choose a model, and never assume a vendor model name.
