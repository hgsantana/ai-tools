# ai-tools

## Introduction

A **harness-agnostic** home for shared AI coding configuration: one global `AGENTS.md` plus the skills `/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, and `/gc-ai-tools`. It lives at a user-level directory — `$HOME/.ai-tools/` on Linux/Mac, or the equivalent user-level location on Windows — and is linked into whichever AI CLIs or IDEs you use (Claude Code, Grok, Cursor, Gemini, OpenAI Codex, GitHub Copilot, and similar).

This repo's `AGENTS.md` is the linked global source of truth; `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is a separate user overlay that agents are instructed to read after it — never a symlink of this file.

Goals:

- One global `AGENTS.md` built on **agent categories** (`planner`, `implementer`, `mechanical`), so any model can map roles without hard-coded vendor model names — each session resolves the three against its own harness once, to a model or a bundled skill
- Skills that behave the same across tools: multi-file plans, token-efficient stage execution, safe cloud and GitHub CLIs
- Install by **symlinks**, never by forked copies that drift
- **Extreme conciseness**: all instructions, skills, rules, and configuration across this repository aim for extreme conciseness, avoiding ambiguities and redundancies to the maximum extent possible while never omitting instructions, rules, or intentions in exchange for brevity.

**Naming rule:** everything installed from this repo — skill directory, frontmatter `name:`, slash command, and agent name — ends in `-ai-tools`, so nothing collides with harness-bundled names. Never install a bare name like `plan`, `dev`, or `planner`.

**Shipped agents:** `agents/<harness>/` holds two **optional, user-invoked** entry points per supported harness — `planner-ai-tools` (runs `/plan-ai-tools`) and `orchestrator-ai-tools` (runs `/dev-ai-tools`). Each is deliberately minimal: pin the **planner** category to a concrete model, invoke one skill, return a path plus a short summary. Starting work from one gives that skill a **clean context** and settles its entry gate without a question — see [Agent categories](#agent-categories). Calling `/plan-ai-tools` directly stays equally valid; skills never delegate themselves to these agents. One folder per harness, because agent file format and model IDs are harness-specific; `agents/<harness>/` is the **only** layer in this repo allowed to name vendor models.

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
| [`AGENTS.md`](AGENTS.md) | Global instructions: agent categories, language (chat vs disk; English default; three exceptions), the change flow, interaction and output discipline, CLI skill pointers, security defaults |
| [`skills/plan-ai-tools/`](skills/plan-ai-tools/) | `/plan-ai-tools` — explore, then write a **base plan** plus **one file per stage** under `plans/`; stops without implementing |
| [`skills/dev-ai-tools/`](skills/dev-ai-tools/) | `/dev-ai-tools` — run the plan queue or ad-hoc work unattended; **implementer** codes, **planner** validates; status table (`W`/`V`/`R`/`T`/`TV`/`E`/`F`); stage context isolation |
| [`skills/az-ai-tools/`](skills/az-ai-tools/) | `/az-ai-tools` — Azure CLI: read freely, mutate only with explicit per-action approval, surface cost |
| [`skills/gh-ai-tools/`](skills/gh-ai-tools/) | `/gh-ai-tools` — GitHub CLI: read freely, mutate only with explicit per-action approval |
| [`skills/gc-ai-tools/`](skills/gc-ai-tools/) | `/gc-ai-tools` — Google Cloud CLI: read freely, mutate only with explicit per-action approval, surface cost |
| [`agents/<harness>/`](agents/) | `planner-ai-tools` and `orchestrator-ai-tools` per supported harness — optional, user-invoked entry points that run `/plan-ai-tools` and `/dev-ai-tools` in a clean context, with the **planner** category pinned to a concrete model. One folder per harness; see [Agent categories](#agent-categories) and [§6 Install agents](#6-install-agents) |

### Agent categories

| Category | Role |
|----------|------|
| **planner** | Plan, orchestrate, validate, escalate |
| **implementer** | Write and edit code for one specified stage or brief |
| **mechanical** | Fully specified low-ambiguity work and evidence gathering |

A category is what an agent **is**, not what it was asked to do. Receiving a request grants no category; the entry gate below checks the session against the category a skill requires, and asks the user before running under-qualified.

#### Why the shipped agents exist

Running `/plan-ai-tools` and then `/dev-ai-tools` in one session is correct but expensive: planning's exploration rounds stay resident while `/dev-ai-tools` runs, and every later turn re-sends them. Invoking the work through `planner-ai-tools` / `orchestrator-ai-tools` instead puts that exploration in a **context that is discarded when the agent returns**. The plan files are already the deliverable ([Output discipline](AGENTS.md)), so the return payload is a path plus a few lines.

They also settle the category up front: the agent's model is pinned to **planner**, so the skill's entry gate passes without a question. This is a choice the **user** makes when starting the work — a skill never delegates itself to one of these agents, and a session that runs a skill directly still follows the gate and asks when it is under-qualified.

#### Category → model per harness

The lowest capable category wins ([`AGENTS.md`](AGENTS.md) rule 4): **planner** takes the strongest model regardless of cost, **implementer** the best code-quality-to-cost ratio, **mechanical** the cheapest that reliably finishes. Verified against vendor documentation in August 2026 — re-check at each model release, since only this table and `agents/<harness>/` carry vendor names.

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

Every `SKILL.md` in this repository — the five that exist and any added later — **must** open its body with the entry-gate block below, verbatim, changing only the category it declares. The gate is absolute: nothing precedes it but the frontmatter and the H1 title — no purpose blurb, no usage note. Whatever the skill used to say up front moves below the block.

```markdown
## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not, or cannot tell** — never delegate this skill, and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. **Authorized** — run this skill here, in this session, acting as its **planner** yourself. That
   authorization holds for the rest of the session and is asked again only if the model changes. Declined or
   unanswered — stop: no exploration, no writes, no spawns.
```

It is duplicated into every skill rather than referenced, because skills can be installed without this repo's `AGENTS.md` being linked into the harness — each one has to carry its own gate. Identical wording is the point: any drift shows up in a diff.

A skill runs in the session that received it, or it does not run. Delegating a whole skill to a spawned agent was tried and dropped: relaying an interactive workflow sends every question and answer across the boundary twice, and the gap the gate detects is one only the user can close. So an under-qualified session **asks** — and if the user says yes, that same session runs the skill as its planner. Only the implementer and mechanical subagents the skill names are spawned.

The `agents/<harness>/` entry points are a **separate, user-initiated** path: invoking `planner-ai-tools` starts the skill in a clean context on a model already pinned to the category. Nothing in a skill reaches for them.

**Choosing the declared category:** the lowest category that can carry the skill's *own* decisions. A skill that can run destructive or externally visible commands requires **planner**, because approving those is planner judgment — which is why all five skills here declare it. Exploration subagents a planner spawns stay read-only and return facts, never verdicts.

### Change flow

`/plan-ai-tools` iterates a plan with the user and saves it. Accepting the plan is the **only** approval point: from there `/dev-ai-tools` runs to completion unattended, recording detail in the plan files and reporting a short summary at the end. A direct `/plan-ai-tools` invocation always stops at the saved plan and never implements.

Each skill's entry gate checks the session against the category it declares. Satisfied, the session runs the skill. Not satisfied — or undecidable — it names its own model, asks whether to run anyway, and says how to switch model and to what. Authorized, it runs the skill in full **in that same session**, as its planner, and the answer holds for the rest of the session; declined, nothing happens.

To skip that question and keep the exploration out of the session, start the work from `planner-ai-tools` / `orchestrator-ai-tools` instead — the user's choice, not the skill's.

### Language

Two destinations, two rules (full detail in [`AGENTS.md`](AGENTS.md)):

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
- **Never overwrite, unlink, edit, or delete `$HOME/AGENTS.md`** (`%USERPROFILE%\AGENTS.md` / `$env:USERPROFILE\AGENTS.md` on Windows). It is user-authored (or an empty placeholder created only when missing) and lives outside `$AI_TOOLS`. Do not symlink it to `$AI_TOOLS/AGENTS.md`.
- Ask which harnesses are in scope before changing anything, and report findings first.

Helpers used by every section below:

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"

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

The repository is cloned at `$HOME/.ai-tools`, or another path the user names — always user-level, never inside a project. `$AI_TOOLS` defaults to `$HOME/.ai-tools`; resolve `$HOME` to the current user's real home. See [Cross-platform paths](#cross-platform-paths) above for the Windows-shell equivalent and every other command translation in this document.

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"
test -f "$AI_TOOLS/AGENTS.md" && test -d "$AI_TOOLS/skills"
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

Link `AGENTS.md` to each selected harness's user-wide instruction file.

| Harness | Typical destination | Notes |
|---------|---------------------|-------|
| Claude Code | `$HOME/.claude/CLAUDE.md` | Claude loads the user `CLAUDE.md` |
| Grok | `$HOME/.grok/AGENTS.md` | Grok Build CLI auto-reads the `AGENTS.md` family at the user level |
| Codex | `$HOME/.codex/AGENTS.md` | Codex reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`; never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope for `safe_link`/`safe_unlink` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | Copilot's Agent Host reads every file under `~/.copilot/instructions/` recursively; plain Markdown works with no frontmatter for an always-applied global file |
| Gemini | `$HOME/.gemini/GEMINI.md` | Detected via the google.geminicodeassist VS Code extension even without a gemini CLI on PATH; Gemini CLI's documented convention loads this as user-level context — confirm against the installed extension/CLI version before linking |
| Cursor | Not linked | No confirmed, documented file path for Cursor's global "User Rules" as of this writing — Cursor's own docs describe it only as a Settings UI concept, not a file. Cursor already reads project-root `AGENTS.md` natively, so project-level coverage exists without this step; revisit once Cursor documents a stable path |
| Generic | Point the tool at `$AI_TOOLS/AGENTS.md` | This file is the source of truth |

```bash
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.claude/CLAUDE.md"
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.grok/AGENTS.md"      # if Grok selected

# Codex: link anyway as the fallback layer even though override.md wins while present (see table above)
test -f "$HOME/.codex/AGENTS.override.md" && echo "NOTE: ~/.codex/AGENTS.override.md exists and takes precedence over AGENTS.md while present"
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.codex/AGENTS.md"     # if Codex selected

safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.copilot/instructions/ai-tools.instructions.md"   # if GitHub Copilot selected
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.gemini/GEMINI.md"    # if Gemini selected
```

When a harness cannot use a symlink for instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

### 4. Ensure user-level `$HOME/AGENTS.md`

Create an empty user overlay file if it is missing. This is **not** a harness link and must **not** use `safe_link`. Agents are instructed (in this repo's `AGENTS.md`) to read this file after the global defaults; it overrides them when the two conflict, and a project's own `AGENTS.md` / `README.md` still wins over both.

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

- If the path exists (file or otherwise), leave it untouched — never overwrite, replace, truncate, or symlink it to `$AI_TOOLS/AGENTS.md`.
- Do **not** ask whether the user wants to add instructions.
- Write or edit contents only if the user later asks for that **directly** (not during install).

### 5. Install skills

Link each skill directory into the harness user skills root: `plan-ai-tools`, `dev-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`.

| Harness | User skills root |
|---------|------------------|
| Claude Code | `$HOME/.claude/skills/` |
| Grok | `$HOME/.grok/skills/` |
| Codex | `$HOME/.codex/skills/` |
| GitHub Copilot | `$HOME/.copilot/skills/` |
| Cursor | `$HOME/.cursor/skills/` (confirmed user-level location per Cursor's docs; `~/.agents/skills/` is also documented as an equivalent shared location, left out of scope here to avoid linking the same skill twice into one harness) |
| Gemini | `$HOME/.gemini/config/skills/` |

```bash
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  safe_link "$path" "$HOME/.claude/skills/$name"   # if Claude selected
  safe_link "$path" "$HOME/.grok/skills/$name"     # if Grok selected
  safe_link "$path" "$HOME/.codex/skills/$name"    # if Codex selected
  safe_link "$path" "$HOME/.copilot/skills/$name"  # if GitHub Copilot selected
  safe_link "$path" "$HOME/.cursor/skills/$name"   # if Cursor selected
  safe_link "$path" "$HOME/.gemini/config/skills/$name" # if Gemini selected
done
```

If Grok is configured with `[skills] paths`, adding `$AI_TOOLS/skills` as a scan path is an option, but only when it cannot clobber existing names. Prefer explicit per-skill links.

### 6. Install agents

Link the two agent files for each selected harness from `$AI_TOOLS/agents/<harness>/` into that harness's user agents root. Agents are linked **per file**, not per directory — the harness roots hold agents from other sources, so a directory link would shadow them.

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
ls -la "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.cursor/skills" "$HOME/.gemini/config/skills" 2>/dev/null

for path in "$AI_TOOLS/skills"/*-ai-tools; do
  test -f "$path/SKILL.md" && echo "skill ok: $(basename "$path")"
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
            "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.gemini/config/skills" \
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

Note any legacy bare names (`plan`, `dev`, `az`, `gh`, `gc`) still pointing at `$AI_TOOLS`. Re-run
Installation §1's extension scan to know which extension-only harnesses (like Gemini) are even in
scope for removal — installed extensions can change between runs.

### 2. Remove skills

```bash
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools \
            plan dev az gh gc; do   # legacy bare names included
  safe_unlink "$HOME/.claude/skills/$name"   # if Claude selected
  safe_unlink "$HOME/.grok/skills/$name"     # if Grok selected
  safe_unlink "$HOME/.codex/skills/$name"    # if Codex selected
  safe_unlink "$HOME/.copilot/skills/$name"  # if GitHub Copilot selected
  safe_unlink "$HOME/.cursor/skills/$name"   # if Cursor selected
  safe_unlink "$HOME/.gemini/config/skills/$name" # if Gemini selected
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

Only when the user wants the harness to stop loading this repo's `AGENTS.md`. Unlink only harness destinations that are links into `$AI_TOOLS/AGENTS.md`. **Do not** `safe_unlink` or otherwise touch `$HOME/AGENTS.md` — it is not a harness link and is never part of removal.

```bash
safe_unlink "$HOME/.claude/CLAUDE.md"
safe_unlink "$HOME/.grok/AGENTS.md"
safe_unlink "$HOME/.codex/AGENTS.md"
safe_unlink "$HOME/.copilot/instructions/ai-tools.instructions.md"
safe_unlink "$HOME/.gemini/GEMINI.md"
# Other harnesses: unlink only destinations created as links into $AI_TOOLS/AGENTS.md
# Never: safe_unlink "$HOME/AGENTS.md"
```

If the instructions file is an include pointer rather than a symlink, edit out that one line instead of deleting the file.

### 5. Verify removal

```bash
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills" \
            "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.gemini/config/skills" \
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
export AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"
test -d "$AI_TOOLS/.git" && test -f "$AI_TOOLS/AGENTS.md" && test -d "$AI_TOOLS/skills"
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
- Skip the reset **only** when the user explicitly asks for re-link with no git update; still verify `AGENTS.md` and `skills/` exist.

```bash
echo "HEAD: $(git rev-parse --short HEAD) (was $(git rev-parse --short "$PREV" 2>/dev/null || echo unknown))"
ls -1 "$AI_TOOLS/skills"
```

### 3. Remove first

Run [Removal](#removal) steps 2–4 for the harnesses in scope, including legacy bare names. Removing after the reset avoids stale names left beside new ones and broken links after directory renames.

### 4. Install again

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

# Skills present and linked
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  test -f "$path/SKILL.md" && echo "source ok: $name"
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.cursor/skills" "$HOME/.gemini/config/skills"; do
    [ -L "$root/$name" ] && echo "link ok: $root/$name -> $(readlink "$root/$name")"
  done
done

# Agents: re-run the agent verification block from Installation §7
# (link / unmodified-copy / drifted-copy per harness)

# No legacy bare names should remain
for name in plan dev az gh gc; do
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.codex/skills" "$HOME/.copilot/skills" "$HOME/.cursor/skills" "$HOME/.gemini/config/skills"; do
    [ -L "$root/$name" ] && echo "WARN legacy link still present: $root/$name"
  done
done
```

Restart or reload the harness, then confirm a slash command for every skill under `$AI_TOOLS/skills/*-ai-tools`.

### 6. When update or reinstall is not enough

- **Local changes the user wants to keep:** do not `reset --hard` until they stash, branch, or approve the discard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user must set a remote or re-clone; never invent a URL.
- **Wrong `$AI_TOOLS` path:** fix the env or clone location, remove links pointing at the old path, then rerun this section.
- **Harness caches skills:** fully restart the CLI or IDE after re-linking.
- **User wants to replace a non-ai-tools file:** require explicit per-path approval; the default stays skip and report.

## Ownership

Personal configuration repository for multi-tool AI workflows, kept at user level on every OS — never inside a project repository. If you host a clone elsewhere, adjust `$AI_TOOLS` and keep it consistent across installation, removal, and update; see [Cross-platform paths](#cross-platform-paths) for translating the bash helpers to a native Windows shell.
