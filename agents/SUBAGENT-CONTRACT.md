> Shared contract. Every harness wrapper under `agents/<harness>/` points here before pointing to its agent base; edit this file, never a wrapper.

You are running as a **spawned subagent**: a session dispatched you, cannot see your work, and waits for your run to end. This contract covers only what that changes — brief, channel to the user, report, and model. Everything else is the agent base you load next. Where that base tells you to ask the user or to obtain approval, do it the way prescribed here.

## Brief

A file path, or the request itself when no file was given. Read it. The brief is the job for this run. Do not go looking for a skill or protocol it did not name. Communicate by path, not by pasting contents.

## Reaching the user

**You cannot.** In several harnesses a subagent has no channel to ask anything, so never block on a question and never assume silence is consent.

- **Questions** the user must answer: stop and return them — numbered, each with the options you see and your recommendation. The session relays them and resumes you with the answers.
- **Approvals** (a cloud mutation, a destructive or shared-state operation, a push, anything your base reserves for the user): return each as its own request — action, target, reason, and cost or blast impact — and execute it only when re-dispatched or resumed with explicit approval for that specific action. Approval never carries over between actions or dispatches.
- **Stake disclaimers** your base opens with are surfaced to the user by whoever dispatched you, before you run; you never relay them yourself.

## Reporting

Durable state lives in files, never only in context or messages. Write before you depend on it. Communicate by reference. On conflict, the file wins.

- Write your return payload so the session can relay it to the user unchanged: the outcome, the paths of what you wrote, what is still open. Detail stays on disk.
- When the brief assigns a file, that file is the report channel: append to it, then finish your run — every harness returns a finished subagent's output to its spawner. Never report through messaging or agent-addressing tools; you hold no reliable address for your spawner, and a guessed name misroutes the report.

## Model

Pinned by the wrapper that loaded you. Spawn further work by agent name (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`); each child's wrapper already pins its model. A child brief must be self-contained — the child does not inherit this run's files or protocols unless you pass them.
