> Shared workflow for `/update-ai-tools`, `/remove-ai-tools`, and `/reinstall-ai-tools`. Not installed. The dispatching skill names the **Task**. Edit this file, never a wrapper.

Drive the scripts shipped under `$HOME/.ai-tools/scripts/` for the task you were given, then stop.

You are not the installer. A fresh installation is the README's own bootstrap — it happens before these skills exist in any harness. Install steps run only where `update`/`reinstall` embed them.

## Scope and approvals

Settle the scope with the user before touching anything, and put every destructive step to them as its own request — the flag, what it discards, and why the task needs it. Run only with the explicit answers; a declined flag is simply omitted. Approval never carries over between actions.

## Source of truth

`$HOME/.ai-tools/README.md` defines the processes and their Safety rules; the scripts are their executable form — run them, never re-implement their steps by hand. Shell scripts on Linux, macOS, WSL, and Git Bash.

| Task | Script | Flags needing explicit user approval |
|---|---|---|
| `update` | `scripts/shell/update.sh` | `--discard-local` |
| `remove` | `scripts/shell/remove.sh` | `--instructions`, `--purge` (with `--yes` only inside that same approval) |
| `reinstall` | `scripts/shell/reinstall.sh` | `--discard-local` |

Never invent agents, remotes, URLs, paths, or flags that are not in the tree, the README, or the scripts' `--help`. When the tree and the README disagree with your recollection, they win.

## Workflow

1. **Scope** — ask which harnesses are in scope, plus the task's own questions (instructions too? purge the clone?). Pass the answer as `--harnesses`; only an explicit "all" means every detected harness.
2. **Dry run** — run the task's script with `--dry-run` and the scoped flags. Its report is your findings: surface it together with each destructive flag the task needs as its own approval request.
3. **Execute** — only with the explicit answers, run the script for real, adding exactly the approved flags; a declined flag is simply omitted.
4. **Interpret** — exit 0: clean. Exit 2: report every `WARN` line with its reason. Exit 1: the script stopped on a precondition — report its output, fix only what the README's Troubleshooting names, and never work around a safety refusal (for example by resetting or deleting manually).

Read-only steps — discovery, `--dry-run`, `verify.sh` — run freely.

## Boundaries

- Touch only `$AI_TOOLS` and the harness destinations the scripts name. Nothing else on the machine.
- **Never touch `$HOME/AGENTS.md`** — user-owned, never part of any procedure.
- Never bypass the scripts' `safe_*` semantics with manual file operations: a conflict the script skipped is the user's to resolve, not yours to force.
- Every script is idempotent; re-running a partial task is safe and is the recovery path.
- No product code, no plans, no cloud resources. Never delegate this role to another agent.

## Report

Report: the exact script invocations, each run's `done: … ok, … skipped, … warnings` line, every `SKIP`/`WARN` with its reason, the resulting tree state (`HEAD`, clean or not), and every request still awaiting approval. Remind the user to restart harnesses that cache agents or skills.
