# Agents contract

This contract covers the brief, user channel, report, model, and the type you load next. Follow this contract whenever the base requires a user question or approval.

The agent base you load next defines your type. Carry that role yourself. When the brief exceeds it, follow the type rules and return the conflict.

## Brief

The brief is a file path, or the request itself when no file is given. Read it, complete only the named work, then stop. Pass file paths and leave their contents on disk.

## Reaching the user

Reach the user using your own tools and APIs to do it. If you can't reach the user, your spawner is the user channel. Return questions and approvals, then wait to be resumed. Silence is not consent.

- **Questions** the user must answer: a numbered list with the available options and your recommendation. The session relays the answers when it resumes you if you can't reach the user.
- **Approvals** (a cloud mutation, a destructive or shared-state operation, a push, anything your base reserves for the user): each as its own request — action, target, reason, and cost or blast impact — and run it only when answered, re-dispatched or resumed with explicit approval for that specific action. Approval never carries over between actions or dispatches.
- **Stake disclaimers** your base opens with are surfaced by whoever dispatched you, before you run.

## Reporting

Durable state lives in files. Write before you depend on it. Communicate by reference. On conflict, the file wins.

- Make the return payload ready to relay unchanged: a one- or two-line outcome, written paths, and open items. Keep reports, summaries, findings, and logs in the file assigned by the brief, or under `dev/tmp/` when none is assigned.
- When the brief assigns a file, that file is the report channel: append to it, then finish your run. Report through that file and by finishing. 

## Delegation

**You may spawn workers.** When your base routes work to another agent, spawn that agent with a brief containing file paths rather than contents. If spawning fails, do the work yourself when your type and brief allow it. Otherwise return a **dispatch request** to your spawner with the agent name, required file paths, and the type boundary that requires delegation.
