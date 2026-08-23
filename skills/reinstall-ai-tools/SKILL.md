---
name: reinstall-ai-tools
description: >
  Reinstall this installation: full removal plus install against a fresh
  origin/master, per the README Reinstallation procedure. Use for
  /reinstall-ai-tools when the install is broken, stale, or the set of
  harnesses changed. Impact: resets $HOME/.ai-tools to origin/master,
  discarding local commits and edits, then removes and re-creates harness
  links. Destructive steps need an explicit yes.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Reinstallation

Reinstalling ai-tools, task `reinstall`.

## Scope and approvals

The routing gate already surfaced Impact:. Settle the scope with the user before touching anything, and put every destructive step to them as its own request — the flag, what it discards, and why the task needs it. Run only with the explicit answers; a declined flag is simply omitted. Approval never carries over between actions.

## Source of truth

`$HOME/.ai-tools/README.md` defines the processes and their Safety rules; the scripts are their executable form — run them. Shell scripts on Linux, macOS, WSL, and Git Bash.

| Task | Script | Flags needing explicit user approval |
|---|---|---|
| `update` | `scripts/shell/update.sh` | `--discard-local` |
| `remove` | `scripts/shell/remove.sh` | `--instructions`, `--purge` (with `--yes` only inside that same approval) |
| `reinstall` | `scripts/shell/reinstall.sh` | `--discard-local` |

Use only agents, remotes, URLs, paths, and flags that are in the tree, the README, or the scripts' `--help`. When the tree and the README disagree with your recollection, they win.

## Workflow

1. **Scope** — ask which harnesses are in scope, plus the task's own questions (instructions too, stale-link sweep). Pass the answer as `--harnesses`; only an explicit "all" means every detected harness.
2. **Dry run** — run `scripts/shell/reinstall.sh` with `--dry-run` and the scoped flags. Its report is your findings: surface it together with each destructive flag the task needs as its own approval request.
3. **Execute** — only with the explicit answers, run the script for real, adding exactly the approved flags; a declined flag is simply omitted.
4. **Interpret** — exit 0: clean. Exit 2: report every `WARN` line with its reason. Exit 1: the script stopped on a precondition — report its output, fix only what the README's Troubleshooting names. Never work around a safety refusal (for example by resetting or deleting manually).

Read-only steps — discovery, `--dry-run`, `verify.sh` — run freely. Carry this task in this session.

## Boundaries

- Touch only `$AI_TOOLS` and the harness destinations the scripts name.
- Leave `$HOME/AGENTS.md` untouched — user-owned, outside every procedure. **Never touch `$HOME/AGENTS.md`.**
- A conflict the script skipped is the user's to resolve. Leave the scripts' `safe_*` semantics in place.
- Every script is idempotent; re-running a partial task is safe and is the recovery path.
- This task is install maintenance. Carry it yourself.

## Report

Report: the exact script invocations, each run's `done: … ok, … skipped, … warnings` line, every `SKIP`/`WARN` with its reason, the resulting tree state (`HEAD`, clean or not), and every request still awaiting approval. Remind the user to restart harnesses that cache agents or skills.
