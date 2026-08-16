# ai-tools

## Introduction

A **harness-agnostic** home for shared AI coding configuration: one global `GLOBAL-AGENTS.md` plus the skills `/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, and `/gc-ai-tools`. It lives at a user-level directory — `$HOME/.ai-tools/` on Linux/Mac, or the equivalent user-level location on Windows — and is linked into whichever AI CLIs or IDEs you use (Claude Code, Grok, Cursor, Gemini, OpenAI Codex, GitHub Copilot, and similar).

This repo's `GLOBAL-AGENTS.md` is the linked global source of truth; `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is a separate user overlay that agents are instructed to read after it — never a symlink of this file.

Goals:

- One global `GLOBAL-AGENTS.md` that teaches any harness the same orchestration cycle — classify the request, offer the planner, get the plan approved, dispatch the executor — on **agent categories** (`planner`, `implementer`, `mechanical`) rather than hard-coded vendor model names
- Skills that behave the same across tools: multi-file plans, token-efficient stage execution, safe cloud and GitHub CLIs
- Install by **symlinks**, never by forked copies that drift
- **Extreme conciseness**: all instructions, skills, rules, and configuration across this repository aim for extreme conciseness, avoiding ambiguities and redundancies to the maximum extent possible while never omitting instructions, rules, or intentions in exchange for brevity.

**Naming rule:** everything installed from this repo — skill directory, frontmatter `name:`, slash command, and agent name — ends in `-ai-tools`, so nothing collides with harness-bundled names. Never install a bare name like `plan`, `dev`, or `planner`.

**Shipped agents:** two base files, `agents/planner-ai-tools.md` (runs `/plan-ai-tools`) and `agents/orchestrator-ai-tools.md` (runs `/dev-ai-tools`), each wrapped once per supported harness under `agents/<harness>/`. They are the two halves of the [orchestration cycle](#orchestration): the session offers the planner, the user approves its plan, the session dispatches the orchestrator. Each is deliberately minimal — pin the **planner** category to a concrete model, invoke one skill, return paths plus a short summary — and neither ever talks to the user directly ([Subagents cannot reach the user](#subagents-cannot-reach-the-user)). Calling `/plan-ai-tools` directly stays equally valid; skills never delegate themselves to these agents. One wrapper folder per harness, because agent file format and model IDs are harness-specific; `agents/<harness>/` is the **only** layer in this repo allowed to name vendor models. What each agent *does* lives once in its base file — see [One file per skill; wrappers only for agents](#one-file-per-skill-wrappers-only-for-agents).

### Cross-platform paths

Every command in this document is written in POSIX/bash, which already covers Linux and Mac unchanged. A harness running natively on Windows (no WSL, no Git Bash) follows the same steps by translating:

| POSIX (this doc) | Windows (PowerShell) |
|---|---|
| `$HOME` | `$env:USERPROFILE` |
| `ln -s <target> <dest>` | `New-Item -ItemType SymbolicLink -Path <dest> -Target <target>` (needs Developer Mode or an elevated shell) |
| `readlink <dest>` / `readlink -f <dest>` | `(Get-Item <dest>).Target` |
| `test -e`/`-f`/`-d`/`-L <path>` | `Test-Path <path>` (add `-PathType Leaf`/`Container`; symlink check: `(Get-Item <path>).LinkType -eq 'SymbolicLink'`) |
| `find <dir> -maxdepth 1 -type l` | `Get-ChildItem <dir> -Depth 0 \| Where-Object { $_.LinkType -eq 'SymbolicLink' }` |
| `mkdir -p <dir>` | `New-Item -ItemType Directory -Force -Path <dir>` |
| `cp <src> <dest>` (symlink fallback) | `Copy-Item <src> <dest>` |
| `cmp -s <a> <b>` | `(Get-FileHash <a>).Hash -eq (Get-FileHash <b>).Hash` |

The safety semantics — idempotent, never overwrite a non-ai-tools destination, skip and report instead of failing — apply identically no matter which shell executes them.

## Contents

| Path | Description |
|------|-------------|
| [`GLOBAL-AGENTS.md`](GLOBAL-AGENTS.md) | Global instructions, installed into each harness: what is shipped and when to offer it, the agent-category glossary, the orchestration cycle (plan → approve → execute), language, security, plans, and where the installed files live. Carries no skill entry gate — skills own that |
| [`skills/plan-ai-tools/`](skills/plan-ai-tools/) | `/plan-ai-tools` — explore, then write a **base plan** plus **one file per stage** under `plans/`; stops without implementing |
| [`skills/dev-ai-tools/`](skills/dev-ai-tools/) | `/dev-ai-tools` — run the plan queue or ad-hoc work unattended; **implementer** codes, **planner** validates; status table (`W`/`V`/`R`/`T`/`TV`/`E`/`F`); stage context isolation |
| [`skills/az-ai-tools/`](skills/az-ai-tools/) | `/az-ai-tools` — Azure CLI: read freely, mutate only with explicit per-action approval, surface cost |
| [`skills/gh-ai-tools/`](skills/gh-ai-tools/) | `/gh-ai-tools` — GitHub CLI: read freely, mutate only with explicit per-action approval |
| [`skills/gc-ai-tools/`](skills/gc-ai-tools/) | `/gc-ai-tools` — Google Cloud CLI: read freely, mutate only with explicit per-action approval, surface cost |
| [`agents/<name>.md`](agents/) | Base instructions for the two shipped agents — `planner-ai-tools`, `orchestrator-ai-tools` |
| [`agents/<harness>/`](agents/) | `planner-ai-tools` and `orchestrator-ai-tools` wrappers per supported harness — optional, user-invoked entry points that run `/plan-ai-tools` and `/dev-ai-tools` in a clean context, with the **planner** category pinned to a concrete model. One folder per harness; see [Agent categories](#agent-categories) and [§6 Install agents](#6-install-agents) |

### One file per skill; wrappers only for agents

**Skills need no wrapper.** Every harness supported here registers a skill the same way: a directory named
after the skill, holding `SKILL.md`, with `name` and `description` in YAML frontmatter. So a skill is
written **once**, as `skills/<skill-name>/SKILL.md`, and that same directory is linked into every harness's
skills root. Nothing about it is harness-specific.

**Agents still need one.** Their file format itself varies — `*.md`, `*.agent.md`, `*.toml` — and each
harness pins the model with its own key. So an agent is written once as a base file and wrapped once per
harness, the wrapper carrying only that harness's syntax plus a pointer to the base.

| Layer | Path | Holds |
|---|---|---|
| Skill | `skills/<skill-name>/SKILL.md` | Frontmatter plus the whole instruction. Installed as-is, into every harness |
| Agent base | `agents/<agent-name>.md` | The whole instruction — purpose, workflow, rules: everything common to all harnesses |
| Agent wrapper | `agents/<harness>/<agent-name>.<ext>` | Only harness-specific syntax — frontmatter or TOML keys, `model:`, file naming — plus a pointer handing execution to the base file |

Rules:

1. A wrapper carries **no** behaviour of its own. Anything it states that the base does not is drift: move it to the base.
2. The pointer is the literal absolute path `$HOME/.ai-tools/...` — e.g. *"Read `$HOME/.ai-tools/agents/planner-ai-tools.md` and follow it in full."* There is no configurable root: `$HOME/.ai-tools` is the only supported clone location, so the pointer is hardcoded, not templated from an environment variable. The clone stays on disk after installation, so the pointer resolves for symlinked and copied installs alike.
3. Vendor model names appear in agent wrappers only ([Category → model per harness](#category--model-per-harness) and `agents/<harness>/`), never in a skill and never in an agent base.
4. A skill's frontmatter keeps `name` and `description` — read by every harness — plus optional keys that are ignored where unsupported, such as `argument-hint`. A key that any supported harness would **reject** does not belong in a shared file; that is what would force a skill wrapper layer back into existence.
5. A new harness means one new agent wrapper folder and nothing at all for skills. A new skill is one new directory; a new agent is one base file plus one wrapper per supported harness.
6. [Installation](#installation) links `skills/<skill-name>/` directly, and links or copies **agent wrappers**. Agent base files are never installed — they are read through the pointer.

Harness syntax changes upstream: re-check each vendor's current skill and agent file format before adding a harness or editing a wrapper. If one ever diverges on the skill format, add the wrapper layer back for that harness alone — do not fork the skill.

### Agent categories

| Category | Role |
|----------|------|
| **planner** | Plan, orchestrate, validate, escalate |
| **implementer** | Write and edit code for one specified stage or brief |
| **mechanical** | Fully specified low-ambiguity work and evidence gathering |

A category is what an agent **is**, not what it was asked to do. Receiving a request grants no category; each skill's entry gate checks the session against the category it requires, and asks the user before running under-qualified. `GLOBAL-AGENTS.md` carries the same table so that a harness reading only that file understands what a skill means by planner, implementer, or mechanical.

#### Why the shipped agents exist

They are the two halves of the cycle the session orchestrates: `planner-ai-tools` designs, `orchestrator-ai-tools` executes, and the user approves between them ([Orchestration](#orchestration)).

Running `/plan-ai-tools` and then `/dev-ai-tools` in one session is equally valid but expensive: planning's exploration rounds stay resident while `/dev-ai-tools` runs, and every later turn re-sends them. Going through the agents instead puts that exploration in a **context that is discarded when the agent returns**. The plan files are already the deliverable, so the return payload is a path plus a few lines.

They also settle the category up front: the agent's model is pinned to **planner**, so the skill's entry gate passes without a question. A skill never delegates itself to one of these agents; a session that runs a skill directly still follows the gate and asks when it is under-qualified.

#### Subagents cannot reach the user

Verified against vendor documentation in August 2026, and the reason the cycle is shaped the way it is:

| Harness | A subagent can ask the user |
|---|---|
| Claude Code | **No** — `AskUserQuestion` is stripped from every subagent, whatever its config. Only permission prompts surface in the parent session |
| Cursor | Yes — the ask-question tool is available to custom subagents |
| GitHub Copilot | Yes — the ask-question tool covers agent mode, custom agents, and subagents |
| Grok Build | Yes — `ask_user_question` works in subagents |
| Codex | Yes, indirectly — approval requests surface from inactive threads, and `/agent` opens the thread to answer |
| Gemini CLI | Undocumented — `ask_user` exists as a tool, but the subagent documentation neither grants nor forbids it |

One behaviour has to hold everywhere, so it is the strictest one: **the agents never ask, they return.** The planner returns numbered open questions; the session relays them and resumes the planner with the answers. The orchestrator returns anything needing approval instead of acting on it. Nothing in this repo depends on a subagent's ability to talk to the user.

#### Category → model per harness

The lowest capable category wins ([`GLOBAL-AGENTS.md`](GLOBAL-AGENTS.md) rule 4): **planner** takes the strongest model regardless of cost, **implementer** the best code-quality-to-cost ratio, **mechanical** the cheapest that reliably finishes. Verified against vendor documentation in August 2026 — re-check at each model release, since only this table and `agents/<harness>/` carry vendor names.

| Harness | planner | implementer | mechanical |
|---|---|---|---|
| Claude Code | `opus` (Claude Opus 5) | `sonnet` (Claude Sonnet 5) | `haiku` (Claude Haiku 4.5) |
| Codex | `gpt-5.6-sol` | `gpt-5.6-terra` | `gpt-5.6-luna` |
| Gemini CLI | `gemini-3.1-pro` | `gemini-3.7-flash` | `gemini-3.5-flash-lite` |
| Grok Build | `grok-4.6` | `grok-build-0.1` | `grok-4.20-0309-non-reasoning` |
| GitHub Copilot | `Claude Opus 5` | `Claude Sonnet 5` | `Claude Haiku 4.5` |
| Cursor | `claude-opus-5[effort=high]` | `composer-2.5` | `composer-2.5[fast=true]` |

Notes: Gemini's Pro line is frozen at 3.1 while Flash has moved to 3.7, so planner and implementer come from different generations. Grok Build accepts no `model:` in agent frontmatter — pin it in `~/.grok/config.toml` (see [§6](#6-install-agents)). Copilot CLI takes `model:` as a **string**, not the array VS Code Copilot Chat accepts. Cursor appends model parameters in square brackets.

### Skill authoring standard

Every skill file in this repository — the five that exist and any added later — **must** open its body with the entry-gate block below, verbatim, changing only the category it declares. The gate is absolute: nothing precedes it but the frontmatter and the H1 title — no purpose blurb, no usage note. Whatever the skill used to say up front moves below the block.

```markdown
## Entry gate — required category: planner

This skill must run on a **planner** model. Before anything else:

1. Decide whether you are one (*Agent categories*, in the global agent instructions).
2. **You are** — run the skill here, spawning the subagents it names.
3. **You are not, or cannot tell** — do not start it and do not delegate it. Send one short chat message in
   the user's language: name the model running this session (or say the harness does not expose it); say how
   to get a planner here — switch this session to the harness's strongest model, or start the work over from
   the `planner-ai-tools` agent, which is pinned to one; then ask whether to run anyway. Wait for the answer.
4. **Yes** — run the skill here, as its planner, for the rest of the session; ask again only if the model
   changes. **No, or no answer** — stop here: no exploration, no writes, no spawns.
```

It is duplicated into every skill file rather than referenced, because skills can be installed without this repo's `GLOBAL-AGENTS.md` being linked into the harness — each one has to carry its own gate. Identical wording is the point: any drift shows up in a diff.

The gate lives in the skill and nowhere else. `GLOBAL-AGENTS.md` does not restate it and does not enforce it: a skill invoked directly by the user answers for its own qualification, whether or not the global instructions are loaded. So an under-qualified session **asks** — and if the user says yes, that same session runs the skill as its planner. Only the implementer and mechanical subagents the skill names are spawned.

The `agents/<harness>/` entry points are the other path in: invoking `planner-ai-tools` starts the skill in a clean context on a model already pinned to the category, which is why its gate passes without a question. Nothing in a skill reaches for them.

**Choosing the declared category:** the lowest category that can carry the skill's *own* decisions. A skill that can run destructive or externally visible commands requires **planner**, because approving those is planner judgment — which is why all five skills here declare it. Exploration subagents a planner spawns stay read-only and return facts, never verdicts.

### Orchestration

The session — whatever model it runs — is the only thing that talks to the user. It sorts each request into one of two buckets and never implements anything non-trivial on its own:

1. **Simple, well specified, or documentation only** → do it now.
2. **Anything else** → ask whether to dispatch `planner-ai-tools`. On yes, spawn it.

From there:

- Planner returns **open questions** → the session relays them, collects answers, resumes the planner.
- Planner returns a **finished plan** → the session reports what it will do, in a few lines, and asks whether to implement. On yes, it spawns `orchestrator-ai-tools` against those plans; on no, the saved plan is the deliverable.
- Orchestrator returns **anything needing approval** → the session asks, then resumes it.

Two approval points, both in the session: dispatching the planner, and accepting the plan. The full protocol lives in [`GLOBAL-AGENTS.md`](GLOBAL-AGENTS.md) — that file is what makes a harness behave this way.

Invoking `/plan-ai-tools` or `/dev-ai-tools` directly stays valid and bypasses the orchestration entirely: the skill runs in the session that received it, subject only to its own entry gate. A direct `/plan-ai-tools` always stops at the saved plan and never implements.

### Language

Two destinations, two rules (full detail in [`GLOBAL-AGENTS.md`](GLOBAL-AGENTS.md)):

- **Chat** — the user's language.
- **Disk** — concise English by default for everything written into a repository (code, comments, commits, docs, plans, briefs, logs, subagent prompts).

Any one of these exceptions drops the English requirement: (1) the user explicitly names another language; (2) the task is translation — write in the target language; (3) the **working repository** is already in another language (check that repo's `AGENTS.md` / `README.md` prose first, then the dominant language of comments and docs in the files being edited; if mixed or unclear, stay English). The working repository is the project being changed — this clone being English does not force English elsewhere.

When an exception applies, disk matches that language, not English. Skills, agents, and these instructions yield to that rule; they must not restate a hard "always English on disk". The shipped agent files are written in English because this repository is English — that never forces English on a target repository.

### Plan file layout

```text
plans/
  <slug>.md           # base: status table, goal, execution graph, stage links
  <slug>-1.md         # stage 1 detail + implementation log
  <slug>-2.md
  dev/                # /dev-ai-tools ad-hoc briefs and feedback
  finished/           # completed stage and base files
```

## Safety rules

These apply to [Installation](#installation), [Removal](#removal), and [Reinstallation / Update](#reinstallation--update) alike. They are written so an **AI assistant**, or a careful human, can run the steps without damaging an existing setup.

- **Never replace** an existing regular file or a symlink pointing outside `$AI_TOOLS`. If a destination exists and is not already an ai-tools link, **skip it, report it, and continue**. Silent overwrite is a bug.
- A destination that is already the correct link is left alone — every step is idempotent.
- **Copies are a fallback, never a preference.** Fall back to copying only where the OS or filesystem refuses symlinks. Report every copy as such, and remove a copy only when its contents still match the `$AI_TOOLS` source — a locally modified copy is user work and is skipped, not deleted.
- **Never** `rm -rf` a harness skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`.
- Never touch vendor bundles such as `~/.grok/bundled/`, unrelated user skills, or a repository's own `AGENTS.md` describing that application's architecture.
- **Never overwrite, unlink, edit, or delete `$HOME/AGENTS.md`** (`%USERPROFILE%\AGENTS.md` / `$env:USERPROFILE\AGENTS.md` on Windows). It is user-authored (or an empty placeholder created only when missing) and lives outside `$AI_TOOLS`. Do not symlink it to `$AI_TOOLS/GLOBAL-AGENTS.md`.
- Ask which harnesses are in scope before changing anything, and report findings first.

Helpers used by every section below:

```bash
export AI_TOOLS="$HOME/.ai-tools"

# Skill roots, one per harness — the same skill directory is linked into each.
# Keep only the harnesses the user selected; every section below iterates this list.
SKILL_ROOTS="$HOME/.claude/skills $HOME/.grok/skills $HOME/.codex/skills
             $HOME/.copilot/skills $HOME/.cursor/skills $HOME/.gemini/skills"

safe_link() {
  # usage: safe_link <target-in-ai-tools> <destination-path>
  local target="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    local cur want
    cur=$(readlink -f "$dest" 2>/dev/null || readlink "$dest")
    want=$(readlink -f "$target" 2>/dev/null || echo "$target")
    if [ "$cur" = "$want" ] || [ "$(readlink "$dest")" = "$target" ]; then
      echo "ok (already linked): $dest"
      return 0
    fi
    echo "SKIP (symlink points elsewhere): $dest -> $(readlink "$dest")"
    return 1
  fi
  if [ -e "$dest" ]; then
    echo "SKIP (exists, not overwriting): $dest"
    return 1
  fi
  ln -s "$target" "$dest"
  echo "linked: $dest -> $target"
}

link_or_copy() {
  # usage: link_or_copy <target-in-ai-tools> <destination-path>
  # Symlink when the OS/filesystem allows it; copy otherwise. Never overwrites.
  local target="$1" dest="$2"
  safe_link "$target" "$dest" && return 0
  [ -e "$dest" ] || [ -L "$dest" ] && return 1   # destination occupied: safe_link already reported it
  mkdir -p "$(dirname "$dest")"
  cp -- "$target" "$dest" || { echo "FAILED (neither link nor copy): $dest"; return 1; }
  echo "copied (will not track updates): $dest <- $target"
}

safe_uninstall_copy() {
  # usage: safe_uninstall_copy <destination-path> <source-in-ai-tools>
  # Removes a regular file ONLY when its contents still match the ai-tools source.
  local dest="$1" src="$2"
  [ -f "$dest" ] && [ ! -L "$dest" ] || return 1
  if cmp -s -- "$dest" "$src"; then
    rm -- "$dest"
    echo "removed copy: $dest"
  else
    echo "SKIP (copy was modified locally): $dest"
    return 1
  fi
}

safe_unlink() {
  # usage: safe_unlink <destination-path>
  local dest="$1" t resolved
  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "absent: $dest"
    return 0
  fi
  if [ ! -L "$dest" ]; then
    echo "SKIP (not a symlink): $dest"
    return 1
  fi
  t=$(readlink "$dest")
  case "$t" in
    *ai-tools*|"$AI_TOOLS"/*) ;;
    *)
      resolved=$(readlink -f "$dest" 2>/dev/null || true)
      case "$resolved" in
        "$AI_TOOLS"/*) ;;
        *)
          echo "SKIP (symlink not to ai-tools): $dest -> $t"
          return 1
          ;;
      esac
      ;;
  esac
  rm "$dest"
  echo "removed: $dest (was -> $t)"
}
```

## Installation

### 0. Preconditions

`$HOME/.ai-tools` is the **only** supported clone path — always user-level, never inside a project, never another location. The wrapper files hardcode `$HOME/.ai-tools/...` (see [One file per skill; wrappers only for agents](#one-file-per-skill-wrappers-only-for-agents)), so a clone anywhere else breaks every pointer by design. Resolve `$HOME` to the current user's real home. See [Cross-platform paths](#cross-platform-paths) above for the Windows-shell equivalent and every other command translation in this document.

```bash
export AI_TOOLS="$HOME/.ai-tools"
test -f "$AI_TOOLS/GLOBAL-AGENTS.md" && test -d "$AI_TOOLS/skills"
```

### 1. Discover installed AI harnesses

Report what you find before changing anything.

```bash
test -d "$HOME/.claude" && echo "found: Claude Code ($HOME/.claude)"
test -d "$HOME/.grok"   && echo "found: Grok ($HOME/.grok)"
command -v grok >/dev/null && echo "found: grok CLI"
test -d "$HOME/.cursor" && echo "found: Cursor ($HOME/.cursor)"
test -d "$HOME/.codex"  && echo "found: Codex ($HOME/.codex)"
command -v codex >/dev/null && echo "found: codex CLI"
test -d "$HOME/.copilot" && echo "found: GitHub Copilot ($HOME/.copilot)"
command -v copilot >/dev/null && echo "found: copilot CLI"
test -d "$HOME/.agents" && echo "found: $HOME/.agents"
```

Check project-local harness directories only when the user asked to wire projects:

```bash
find "$HOME/projetos" -maxdepth 3 \( -name '.claude' -o -name '.grok' -o -name '.cursor' \) 2>/dev/null
```

Some harnesses manifest only as an installed **IDE extension** — no standalone CLI, no dedicated
home directory to `test -d`. Scan the usual IDE extension roots (VS Code family and JetBrains) and
match against a small known-extension table that drives real install actions:

| Extension ID (prefix match) | Harness | Config home |
|---|---|---|
| `google.geminicodeassist-*` | Gemini | `$HOME/.gemini` |
| `anthropic.claude-code-*` | Claude Code | `$HOME/.claude` |
| `openai.chatgpt-*` | OpenAI Codex | `$HOME/.codex` |
| `github.copilot-chat-*` | GitHub Copilot | `$HOME/.copilot` |

(The Claude Code row exists for machines where only the VS Code extension is present, with no CLI
install; when both exist, `safe_link` idempotency already handles the overlap.)

```bash
EXT_ROOTS="$HOME/.vscode/extensions $HOME/.vscode-server/extensions $HOME/.vscode-insiders/extensions $HOME/.vscode-server-insiders/extensions $HOME/.vscodium/extensions"

# JetBrains plugin roots (Linux layout; Windows/Mac paths differ, confirm on those machines)
JETBRAINS_ROOTS=""
for jb in "$HOME"/.local/share/JetBrains/*/plugins; do
  [ -d "$jb" ] && JETBRAINS_ROOTS="$JETBRAINS_ROOTS $jb"
done

# Known-extension table: prefix match -> harness with a confirmed config convention
for root in $EXT_ROOTS; do
  [ -d "$root" ] || continue
  for ext in "$root"/*/; do
    [ -d "$ext" ] || continue
    name=$(basename "$ext")
    case "$name" in
      google.geminicodeassist-*) echo "found: Gemini (extension $name in $root)" ;;
      anthropic.claude-code-*)   echo "found: Claude Code (extension $name in $root)" ;;
      openai.chatgpt-*)          echo "found: OpenAI Codex (extension $name in $root)" ;;
      github.copilot-chat-*)     echo "found: GitHub Copilot (extension $name in $root)" ;;
    esac
  done
done

# Informational-only: grep the same roots plus JetBrains plugin roots for AI-related
# keywords. No confirmed instructions/skills convention for these in this repo yet,
# so nothing here is offered as an install target unless the user names one explicitly.
for root in $EXT_ROOTS $JETBRAINS_ROOTS; do
  [ -d "$root" ] || continue
  ls "$root" 2>/dev/null | grep -iE 'gemini|claude|codeium|windsurf|continue|cody|cursor|tabnine' | while read -r name; do
    echo "info: possible AI extension '$name' in $root"
  done
done
```

### 2. Ask which targets to install

Present the discovery list and let the user choose — both CLI/home-dir harnesses and
extension-discovered harnesses from the known table. Keyword-only matches are informational, not
offered as install targets unless the user names one explicitly. Do not install into every tool by
default when the user only uses one.

### 3. Install global instructions

Link `GLOBAL-AGENTS.md` to each selected harness's user-wide instruction file.

| Harness | Typical destination | Notes |
|---------|---------------------|-------|
| Claude Code | `$HOME/.claude/CLAUDE.md` | Claude loads the user `CLAUDE.md` |
| Grok | `$HOME/.grok/AGENTS.md` | Grok Build CLI auto-reads the `AGENTS.md` family at the user level |
| Codex | `$HOME/.codex/AGENTS.md` | Codex reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`; never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope for `safe_link`/`safe_unlink` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | Copilot's Agent Host reads every file under `~/.copilot/instructions/` recursively; plain Markdown works with no frontmatter for an always-applied global file |
| Gemini | `$HOME/.gemini/GEMINI.md` | Detected via the google.geminicodeassist VS Code extension even without a gemini CLI on PATH; Gemini CLI's documented convention loads this as user-level context — confirm against the installed extension/CLI version before linking |
| Cursor | Not linked | No confirmed, documented file path for Cursor's global "User Rules" as of this writing — Cursor's own docs describe it only as a Settings UI concept, not a file. Cursor already reads project-root `AGENTS.md` natively, so project-level coverage exists without this step; revisit once Cursor documents a stable path |
| Generic | Point the tool at `$AI_TOOLS/GLOBAL-AGENTS.md` | This file is the source of truth |

```bash
safe_link "$AI_TOOLS/GLOBAL-AGENTS.md" "$HOME/.claude/CLAUDE.md"
safe_link "$AI_TOOLS/GLOBAL-AGENTS.md" "$HOME/.grok/AGENTS.md"      # if Grok selected

# Codex: link anyway as the fallback layer even though override.md wins while present (see table above)
test -f "$HOME/.codex/AGENTS.override.md" && echo "NOTE: ~/.codex/AGENTS.override.md exists and takes precedence over AGENTS.md while present"
safe_link "$AI_TOOLS/GLOBAL-AGENTS.md" "$HOME/.codex/AGENTS.md"     # if Codex selected

safe_link "$AI_TOOLS/GLOBAL-AGENTS.md" "$HOME/.copilot/instructions/ai-tools.instructions.md"   # if GitHub Copilot selected
safe_link "$AI_TOOLS/GLOBAL-AGENTS.md" "$HOME/.gemini/GEMINI.md"    # if Gemini selected
```

When a harness cannot use a symlink for instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

### 4. Ensure user-level `$HOME/AGENTS.md`

Create an empty user overlay file if it is missing. This is **not** a harness link and must **not** use `safe_link`. Agents are instructed (in this repo's `GLOBAL-AGENTS.md`) to read this file after the global defaults; it overrides them when the two conflict, and a project's own `AGENTS.md` / `README.md` still wins over both.

| POSIX | Windows |
|---|---|
| `$HOME/AGENTS.md` | `%USERPROFILE%\AGENTS.md` / `$env:USERPROFILE\AGENTS.md` |

```bash
if [ -e "$HOME/AGENTS.md" ]; then
  echo "ok (already present): $HOME/AGENTS.md"
else
  : > "$HOME/AGENTS.md"
  echo "created (empty): $HOME/AGENTS.md"
fi
```

Rules for this step:

- If the path exists (file or otherwise), leave it untouched — never overwrite, replace, truncate, or symlink it to `$AI_TOOLS/GLOBAL-AGENTS.md`.
- Do **not** ask whether the user wants to add instructions.
- Write or edit contents only if the user later asks for that **directly** (not during install).

### 5. Install skills

Link each skill directory — `skills/<name>/`, holding `SKILL.md` — into every selected harness's user skills root. The same directory serves all of them; there is no per-harness skill file ([One file per skill; wrappers only for agents](#one-file-per-skill-wrappers-only-for-agents)).

| Harness | User skills root |
|---------|------------------|
| Claude Code | `$HOME/.claude/skills/` |
| Grok | `$HOME/.grok/skills/` |
| Codex | `$HOME/.codex/skills/` (`$HOME/.agents/skills/` is the vendor's current documented location — see the warning below) |
| GitHub Copilot | `$HOME/.copilot/skills/` |
| Cursor | `$HOME/.cursor/skills/` |
| Gemini | `$HOME/.gemini/skills/` (**not** `$HOME/.gemini/config/skills/`, contrary to an earlier version of this document) |

**Never link into `$HOME/.agents/skills/`.** It is a live discovery root read by Codex, Copilot, Cursor and Gemini — linking this repo's skills there as well as into each harness's own root would double-register every skill.

```bash
# $SKILL_ROOTS is defined with the helpers under Safety rules — trim it to the selected harnesses
for root in $SKILL_ROOTS; do
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    safe_link "$path" "$root/$(basename "$path")"
  done
done
```

If Grok is configured with `[skills] paths`, adding `$AI_TOOLS/skills` as a scan path is an option, but only when it cannot clobber existing names. Prefer explicit per-skill links.

### 6. Install agents

Link the two agent **wrapper** files for each selected harness from `$AI_TOOLS/agents/<harness>/` into that harness's user agents root — each wrapper is a thin pointer to a base file (`agents/planner-ai-tools.md`, `agents/orchestrator-ai-tools.md`) that carries the actual instruction. Agents are linked **per file**, not per directory — the harness roots hold agents from other sources, so a directory link would shadow them.

| Harness | Source folder | User agents root | File form |
|---------|---------------|------------------|-----------|
| Claude Code | `agents/claude-code/` | `$HOME/.claude/agents/` | `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/`fable`/full ID/`inherit`) |
| Codex | `agents/codex/` | `$HOME/.codex/agents/` | `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `agents/copilot/` | `$HOME/.copilot/agents/` | `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Cursor | `agents/cursor/` | `$HOME/.cursor/agents/` | `*.md`, `model:` accepts bracketed parameters (`claude-opus-5[effort=high]`) |
| Gemini | `agents/gemini/` | `$HOME/.gemini/agents/` | `*.md`, frontmatter `kind`, `model`, `temperature`, `max_turns`, `timeout_mins` |
| Grok Build | `agents/grok/` | `$HOME/.grok/agents/` | `*.md`; **no `model:` in frontmatter** — pin models in `config.toml`, below |

```bash
# usage: install_agents <harness-folder> <destination-root>
install_agents() {
  local src="$AI_TOOLS/agents/$1" dest="$2"
  [ -d "$src" ] || { echo "SKIP (no such harness folder): $src"; return 1; }
  find "$src" -maxdepth 1 -type f -name '*-ai-tools*' -print | while read -r file; do
    link_or_copy "$file" "$dest/$(basename "$file")"
  done
}

install_agents claude-code "$HOME/.claude/agents"    # if Claude Code selected
install_agents codex       "$HOME/.codex/agents"     # if Codex selected
install_agents copilot     "$HOME/.copilot/agents"   # if GitHub Copilot selected
install_agents cursor      "$HOME/.cursor/agents"    # if Cursor selected
install_agents gemini      "$HOME/.gemini/agents"    # if Gemini selected
install_agents grok        "$HOME/.grok/agents"      # if Grok selected
```

`link_or_copy` (defined with the other helpers under [Safety rules](#safety-rules)) prefers a symlink and falls back to a copy only where the OS or filesystem refuses one — Windows without Developer Mode, or a mount that does not support symlinks. **A copied agent drifts**: it does not track `git pull`, so re-run [Reinstallation / Update](#reinstallation--update) after every upstream change on those machines. Copies are reported as `copied (will not track updates)` so the drift is visible in the install log.

**Grok Build — pin the models separately.** Grok resolves subagent models from `~/.grok/config.toml`, not from agent frontmatter. Add (never replace the file):

```toml
[subagents.models]
planner-ai-tools = "grok-4.6"
orchestrator-ai-tools = "grok-4.6"
```

Without this block the agents still load and still run their skill — they simply inherit the session's model, which means the **planner** category is not guaranteed. Same fallback applies to any harness whose `model:` field is ignored or unsupported: the agent works, the category guarantee does not.

### 7. Verify

```bash
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
readlink -f "$HOME/.grok/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.codex/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.copilot/instructions/ai-tools.instructions.md" 2>/dev/null
readlink -f "$HOME/.gemini/GEMINI.md" 2>/dev/null
# User overlay (not a harness link): expect a regular file at $HOME/AGENTS.md
test -e "$HOME/AGENTS.md" && echo "user overlay present: $HOME/AGENTS.md" || echo "WARN: missing $HOME/AGENTS.md"

# The five skills and two agent bases exist at the pinned location
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools; do
  test -f "$AI_TOOLS/skills/$name/SKILL.md" && echo "skill ok: skills/$name/SKILL.md" || echo "WARN missing skill: skills/$name/SKILL.md"
done
for base in planner-ai-tools orchestrator-ai-tools; do
  test -f "$AI_TOOLS/agents/$base.md" && echo "base ok: agents/$base.md" || echo "WARN missing base: agents/$base.md"
done

ls -la "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.cursor/skills" "$HOME/.gemini/skills" 2>/dev/null

# Every installed skill link resolves to a real SKILL.md
for root in $SKILL_ROOTS; do
  [ -d "$root" ] || continue
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    name=$(basename "$path")
    test -f "$root/$name/SKILL.md" && echo "skill ok: $root/$name" || echo "WARN not installed or broken: $root/$name"
  done
done

# Agents: source present, and installed as a link or an unmodified copy
for dir in "$AI_TOOLS/agents"/*/; do
  [ -d "$dir" ] || continue
  harness=$(basename "$dir")
  case "$harness" in
    claude-code) root="$HOME/.claude/agents" ;;
    codex)       root="$HOME/.codex/agents" ;;
    copilot)     root="$HOME/.copilot/agents" ;;
    cursor)      root="$HOME/.cursor/agents" ;;
    gemini)      root="$HOME/.gemini/agents" ;;
    grok)        root="$HOME/.grok/agents" ;;
    *)           echo "WARN unmapped harness folder: $harness"; continue ;;
  esac
  for file in "$dir"*-ai-tools*; do
    [ -f "$file" ] || continue
    base=$(basename "$file")
    if [ -L "$root/$base" ]; then echo "agent link ok: $root/$base"
    elif cmp -s -- "$root/$base" "$file" 2>/dev/null; then echo "agent copy ok: $root/$base"
    elif [ -e "$root/$base" ]; then echo "WARN agent differs from source: $root/$base"
    else echo "absent: $root/$base"
    fi
  done
done
```

Restart or reload any harness that caches skills or agents at startup, then confirm the five slash commands appear in the menu and that `planner-ai-tools` and `orchestrator-ai-tools` appear in the harness's agent list.

## Removal

Removal means "unlink from harnesses", not "delete the config repo". Leaving `$AI_TOOLS` on disk is normal and makes [Reinstallation / Update](#reinstallation--update) a pull plus re-link.

### 1. Discover what is linked from ai-tools

Report findings; remove nothing until the user confirms the targets.

```bash
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills" \
            "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.gemini/skills" \
            "$HOME/.claude/agents" "$HOME/.grok/agents" "$HOME/.codex/agents" \
            "$HOME/.copilot/agents" "$HOME/.cursor/agents" "$HOME/.gemini/agents"; do
  [ -d "$root" ] || continue
  echo "=== $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) echo "linked: $p -> $t" ;; esac
  done
  # Copies from a symlink-less install: name match only — contents are checked at removal
  find "$root" -maxdepth 1 -type f -name '*-ai-tools*' -print 2>/dev/null | while read -r p; do
    echo "possible copy: $p"
  done
done

# Skill names as currently shipped, for reference
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] && echo "shipped: $(basename "$path")"
done

if [ -L "$HOME/.claude/CLAUDE.md" ]; then
  echo "instructions: $HOME/.claude/CLAUDE.md -> $(readlink "$HOME/.claude/CLAUDE.md")"
fi
if [ -L "$HOME/.grok/AGENTS.md" ]; then
  echo "instructions: $HOME/.grok/AGENTS.md -> $(readlink "$HOME/.grok/AGENTS.md")"
fi
if [ -L "$HOME/.codex/AGENTS.md" ]; then
  echo "instructions: $HOME/.codex/AGENTS.md -> $(readlink "$HOME/.codex/AGENTS.md")"
fi
if [ -L "$HOME/.copilot/instructions/ai-tools.instructions.md" ]; then
  echo "instructions: $HOME/.copilot/instructions/ai-tools.instructions.md -> $(readlink "$HOME/.copilot/instructions/ai-tools.instructions.md")"
fi
if [ -L "$HOME/.gemini/GEMINI.md" ]; then
  echo "instructions: $HOME/.gemini/GEMINI.md -> $(readlink "$HOME/.gemini/GEMINI.md")"
fi
```

Note any legacy bare names (`plan`, `dev`, `az`, `gh`, `gc`) still pointing at `$AI_TOOLS`, and any
link resolving to a path that no longer exists — a dangling link still needs cleaning up.
Re-run Installation §1's extension scan to know which
extension-only harnesses (like Gemini) are even in scope for removal — installed extensions can
change between runs.

### 2. Remove skills

Names come from the skill directories under `$AI_TOOLS/skills/*-ai-tools`, never a hardcoded list:

```bash
for root in $SKILL_ROOTS; do
  [ -d "$root" ] || continue
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    safe_unlink "$root/$(basename "$path")"
  done
  # Legacy bare names from older installs
  for name in plan dev az gh gc; do
    safe_unlink "$root/$name"
  done
done
```

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove **only that entry** when asked — never wipe the config file.

### 3. Remove agents

Mirror of [§6 Install agents](#6-install-agents): per-file, per-harness. Links are unlinked; copies are removed only when unmodified.

```bash
# usage: uninstall_agents <harness-folder> <destination-root>
uninstall_agents() {
  local src="$AI_TOOLS/agents/$1" dest="$2"
  [ -d "$src" ] || return 0
  find "$src" -maxdepth 1 -type f -name '*-ai-tools*' -print | while read -r file; do
    base=$(basename "$file")
    safe_unlink "$dest/$base" >/dev/null 2>&1 || safe_uninstall_copy "$dest/$base" "$file"
  done
}

uninstall_agents claude-code "$HOME/.claude/agents"    # if Claude Code selected
uninstall_agents codex       "$HOME/.codex/agents"     # if Codex selected
uninstall_agents copilot     "$HOME/.copilot/agents"   # if GitHub Copilot selected
uninstall_agents cursor      "$HOME/.cursor/agents"    # if Cursor selected
uninstall_agents gemini      "$HOME/.gemini/agents"    # if Gemini selected
uninstall_agents grok        "$HOME/.grok/agents"      # if Grok selected

# Whole-directory link from an older install (rare)
safe_unlink "$HOME/.claude/agents"
safe_unlink "$HOME/.grok/agents"
```

If Grok's `~/.grok/config.toml` carries the `[subagents.models]` entries from §6, remove **only those two keys** when asked — never the file, and never other entries in the table.

### 4. Remove the global instructions link, optional

Only when the user wants the harness to stop loading this repo's `GLOBAL-AGENTS.md`. Unlink only harness destinations that are links into `$AI_TOOLS/GLOBAL-AGENTS.md`. **Do not** `safe_unlink` or otherwise touch `$HOME/AGENTS.md` — it is not a harness link and is never part of removal.

```bash
safe_unlink "$HOME/.claude/CLAUDE.md"
safe_unlink "$HOME/.grok/AGENTS.md"
safe_unlink "$HOME/.codex/AGENTS.md"
safe_unlink "$HOME/.copilot/instructions/ai-tools.instructions.md"
safe_unlink "$HOME/.gemini/GEMINI.md"
# Other harnesses: unlink only destinations created as links into $AI_TOOLS/GLOBAL-AGENTS.md
# Never: safe_unlink "$HOME/AGENTS.md"
```

If the instructions file is an include pointer rather than a symlink, edit out that one line instead of deleting the file.

### 5. Verify removal

```bash
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills" \
            "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.gemini/skills" \
            "$HOME/.claude/agents" "$HOME/.grok/agents" "$HOME/.codex/agents" \
            "$HOME/.copilot/agents" "$HOME/.cursor/agents" "$HOME/.gemini/agents"; do
  [ -d "$root" ] || continue
  echo "=== remaining ai-tools links in $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) echo "STILL LINKED: $p -> $t" ;; esac
  done
done
```

Expected: no links into `$AI_TOOLS` for the cleaned harnesses. Restart the harness; the slash commands should disappear.

### 6. Remove the repository clone, optional

Only when the user explicitly asks to delete the config tree itself. This never includes `$HOME/AGENTS.md`.

```bash
# Confirm the path first — destructive; does not touch $HOME/AGENTS.md
# rm -rf "$AI_TOOLS"
```

## Reinstallation / Update

Use this when the user asks to **update**, **reinstall**, or **refresh** ai-tools. Typical triggers: new skills or renames landed upstream, a partial or broken install, legacy names (`plan` instead of `plan-ai-tools`), or a change in which harnesses are wired.

One process covers every case: **update the source** to `origin/master`, then **re-wire harnesses** by removing stale ai-tools links and installing again from that tree. `origin/master` is the canonical source — never reinstall from a dirty tree, a feature branch, or a local-only commit unless the user explicitly overrides that.

### 0. Preconditions

```bash
export AI_TOOLS="$HOME/.ai-tools"
test -d "$AI_TOOLS/.git" && test -f "$AI_TOOLS/GLOBAL-AGENTS.md" && test -d "$AI_TOOLS/skills"
```

If `$AI_TOOLS` is missing, stop and offer a fresh [Installation](#installation), cloning first. Never invent skills that are not in the tree.

### 1. Ask scope

1. Which harnesses to reinstall
2. Whether to refresh **instructions** and **agents** as well as skills
3. Whether to clean **legacy** bare names from older installs
4. That the update **resets `$AI_TOOLS` to `origin/master`**, discarding local commits and uncommitted changes in this repo unless they opt out
5. Installed IDE extensions can change between reinstalls — an extension-only harness like Gemini
   may have been added or removed since the last run. Re-run Installation §1's extension scan
   rather than reuse a stale harness list.

### 2. Reset the repository to `origin/master`

Do this **before** removing or re-linking, so destinations match the published skill set — names and paths can change between versions.

```bash
cd "$AI_TOOLS" || exit 1

# Show state before changing anything
git status -sb
git remote -v
git log --oneline -3

# Surface local work that the reset will discard
if [ -n "$(git status --porcelain)" ]; then
  echo "WARN: local changes in $AI_TOOLS will be discarded by reset to origin/master"
  git status --short
fi

git fetch origin

if ! git show-ref --verify --quiet refs/remotes/origin/master; then
  echo "ERROR: origin/master not found after fetch — fix the remote and retry"
  git branch -r
  exit 1
fi

# Surface local commits ahead of origin, also discarded by the reset
git log --oneline origin/master..HEAD

PREV=$(git rev-parse HEAD)   # for the summary below
git checkout master
git reset --hard origin/master
# Optional, only for a fully clean tree: git clean -fd
```

Notes:

- This is destructive **inside `$AI_TOOLS` only**: it discards local commits on `master` and uncommitted edits. It never touches harness config outside this directory, and never touches `$HOME/AGENTS.md`.
- If the user has local work they care about, stop, show `git status` and `git log`, and get explicit approval before `reset --hard`, or help them branch or stash first.
- If the default branch is ever renamed (for example `main`), use that name only once the user or remote confirms it.
- Skip the reset **only** when the user explicitly asks for re-link with no git update; still verify `GLOBAL-AGENTS.md` and `skills/` exist.

```bash
echo "HEAD: $(git rev-parse --short HEAD) (was $(git rev-parse --short "$PREV" 2>/dev/null || echo unknown))"
ls -1 "$AI_TOOLS/skills"
```

### 3. Remove first

Run [Removal](#removal) steps 2–4 for the harnesses in scope, including legacy bare names. Removing after the reset avoids stale names left beside new ones and broken links after directory renames.

### 4. Install again

A layout change upstream can leave every previously created link dangling — a link is never upgraded in
place. The fix is always a full Removal + Install pass, which is exactly what this section does. Machines
installed while skills were wrapped per harness (`$AI_TOOLS/skills/<harness>/<name>/`) are the current
case: those links resolve nowhere, and re-installing repoints them at `$AI_TOOLS/skills/<name>/`.

Run the [Installation](#installation) link steps for the same harnesses — discovery is optional when scope was already confirmed. Prefer listing `$AI_TOOLS/skills/*-ai-tools` and `$AI_TOOLS/agents/*/` after the reset over hard-coded lists, since both sets may have changed. `safe_link` stays non-destructive: an existing destination that is not already the correct link is skipped and reported.

Re-run [§6 Install agents](#6-install-agents) too. This step matters most on machines where agents were **copied** rather than linked: a copy does not follow `git pull`, so the reset in §2 is only half the update until the copies are refreshed. §3's removal drops unmodified copies, and §6 writes the new ones.

Also re-run Installation §4 (ensure user-level `$HOME/AGENTS.md`): create it empty only if missing; if present, leave it untouched. Do not ask the user to fill it or add instructions.

### 5. Verify update and reinstall

```bash
# Source tree must be master == origin/master, clean
git -C "$AI_TOOLS" status -sb
git -C "$AI_TOOLS" rev-parse HEAD origin/master   # expect the same SHA twice

# Instructions link, including extension-only harnesses like Gemini
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
readlink -f "$HOME/.grok/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.codex/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.copilot/instructions/ai-tools.instructions.md" 2>/dev/null
readlink -f "$HOME/.gemini/GEMINI.md" 2>/dev/null

# User overlay (not a harness link)
test -e "$HOME/AGENTS.md" && echo "user overlay present: $HOME/AGENTS.md" || echo "WARN: missing $HOME/AGENTS.md"

# Skills present at the source and linked into every selected root (mirrors Installation §5/§7)
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  test -f "$path/SKILL.md" && echo "source ok: skills/$name/SKILL.md" || echo "WARN missing SKILL.md: skills/$name"
  for root in $SKILL_ROOTS; do
    [ -d "$root" ] || continue
    [ -L "$root/$name" ] && echo "link ok: $root/$name -> $(readlink "$root/$name")"
  done
done

# Agents: re-run the agent verification block from Installation §7
# (link / unmodified-copy / drifted-copy per harness)

# No legacy bare names should remain
for root in $SKILL_ROOTS; do
  for name in plan dev az gh gc; do
    [ -L "$root/$name" ] && echo "WARN legacy link still present: $root/$name"
  done
done
```

Restart or reload the harness, then confirm a slash command for every skill under `$AI_TOOLS/skills/*-ai-tools`.

### 6. When update or reinstall is not enough

- **Local changes the user wants to keep:** do not `reset --hard` until they stash, branch, or approve the discard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user must set a remote or re-clone; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there. `$HOME/.ai-tools` is the only supported location; the wrappers hardcode that path, so no other clone location is recoverable by adjusting an env var.
- **Harness caches skills:** fully restart the CLI or IDE after re-linking.
- **User wants to replace a non-ai-tools file:** require explicit per-path approval; the default stays skip and report.

## Ownership

Personal configuration repository for multi-tool AI workflows, kept at user level on every OS — never inside a project repository. The wrapper files hardcode `$HOME/.ai-tools/...`, so a clone anywhere else is unsupported and breaks them by design; see [Cross-platform paths](#cross-platform-paths) for translating the bash helpers to a native Windows shell.
