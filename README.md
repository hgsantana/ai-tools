# ai-tools

> **Version 0.0.2-ALPHA** — under active development. Usable for testing; no guarantees, and no backward compatibility between alpha versions (rule 4).

## What is this repository

ai-tools is a toolkit for AI coding harnesses: **agents**, **skills**, and **instructions**, written once and compatible with the main harnesses on the market — Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, Cursor, and Gemini CLI.

It is cloned to `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows) and linked into each harness's user-level configuration, so every tool loads the same instructions, agents, and skills. Every agent runs on a strong model **by construction**: each harness wrapper pins the model, so there is no "which model am I running on?" question at execution time.

### What is inside

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | Install artifact: becomes the user-wide instructions file of each harness. Teaches the orchestration cycle (classify → refine → confirm → deliver end to end), the agent categories, and the language, security, and plan rules |
| [`agents/vibe-ai-tools.md`](agents/vibe-ai-tools.md) | Agent base: repository architect/PO — refines a demand with the user from documentation only, then, after one explicit confirmation (the Vibe Coding gate), delivers it end to end through the planner and orchestrator, deciding open questions itself and logging them under `plans/vibe/` |
| [`agents/planner-ai-tools.md`](agents/planner-ai-tools.md) | Agent base: designs a change — explores the repository and writes a multi-file implementation plan under `plans/`, then stops; never implements |
| [`agents/orchestrator-ai-tools.md`](agents/orchestrator-ai-tools.md) | Agent base: executes accepted plans or an ad-hoc brief unattended; delegates code to **implementer** and evidence to **mechanical** subagents |
| [`agents/az-ai-tools.md`](agents/az-ai-tools.md) | Agent base: Azure CLI (`az`) — read freely, return mutations to the session for explicit per-action approval, surface cost |
| [`agents/gh-ai-tools.md`](agents/gh-ai-tools.md) | Agent base: GitHub CLI (`gh`) — read freely, return mutations to the session for explicit per-action approval |
| [`agents/gc-ai-tools.md`](agents/gc-ai-tools.md) | Agent base: Google Cloud CLI (`gcloud`) — read freely, return mutations to the session for explicit per-action approval, surface cost |
| [`agents/maintainer-ai-tools.md`](agents/maintainer-ai-tools.md) | Agent base: maintains the installation — runs this README's [Update](#update), [Removal](#removal), or [Reinstallation](#reinstallation) procedure on request, returning destructive steps for per-action approval. Never the first install — that is this README's own bootstrap, before the agent exists |
| [`agents/<harness>/`](agents/) | Per-harness wrappers for the seven agents — harness-specific syntax, the pinned model, the category → model mapping for subagents, and a pointer to the base file; nothing else |
| [`skills/`](skills/) | Nine dispatch skills: one same-named per agent, except `maintainer-ai-tools`, which ships three task skills (`update-ai-tools`, `remove-ai-tools`, `reinstall-ai-tools`). Each surfaces the agent's stake, spawns it, and relays approvals, questions, and results between agent and user. A skill must run on **any** model; anything model-dependent ships as an agent instead (rules 7–9) |

### How to install, remove, update, or reinstall

Open your preferred harness and instruct it:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

Replace *Install* with *Remove*, *Update*, or *Reinstall* as needed. The AI will follow the corresponding section of this file.

Or follow the instructions yourself: [Installation](#installation), [Removal](#removal), [Update](#update), [Reinstallation](#reinstallation).

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the single source of truth for this repository: its explanation, its rules, and its AI instructions for installation, removal, update, and reinstallation.
2. AIs working on this repository follow instructions **about this repository** exclusively from this README. User-wide or harness-global instructions — including an installed `USER-AGENTS.md` — yield to it here.
3. `USER-AGENTS.md` is an artifact: it exists only to be installed on the user's machine as their user-wide harness instructions. It is not an instruction file for this repository. Like every shipped artifact, it must fit **every** supported harness that consumes it — the tightest harness constraint governs (today: Antigravity's 12,000-character cap on rules files). Constraints are registered in the [Supported harnesses](#supported-harnesses) notes; a harness bringing a stricter one updates the notes and the affected artifacts in the same commit.
4. This repository is pre-release (see the version at the top). While in `0.x`/ALPHA, no backward compatibility is maintained: this README always describes the current state only, breaking changes carry no migration notes, and a machine on an older layout is fixed by [Reinstallation](#reinstallation) with its stale-link sweep. Bump the version in the same commit as any change to shipped content or process; backward-compatibility records begin with the first stable release.

### Structure and authoring

5. Every agent has a harness-agnostic **base file** at `agents/<name>.md`, holding its whole behaviour — purpose, workflow, rules — and one **wrapper** per supported harness at `agents/<harness-short-name>/<agent-name>.<ext>`.
6. A wrapper's header carries only harness-specific syntax (frontmatter or TOML keys, model pinning, file naming). Its body carries exactly two things: **(1)** the category → model conversion table for that harness, present only when the base file cites any of **planner**/**implementer**/**mechanical**; **(2)** the pointer to follow the base file, hardcoded as `$HOME/.ai-tools/agents/<name>.md`. Anything more is drift — move it to the base. The canonical body is in the [authoring reference](#category--model-authoring-reference).
7. Skills may be shipped too. A skill is harness-agnostic and exists as a single file, `skills/<name>/SKILL.md`, in one shared directory registered as-is by every harness — no per-harness copies, no wrappers.
8. A skill must run correctly on **any** model the session happens to provide — no model requirements, no category checks, no gates. The moment it depends on a specific model or category, it must be an agent instead, whose wrapper pins the model.
9. Skill frontmatter carries only universally accepted keys: `name` and `description`, plus optional keys every supported harness tolerates (e.g. `argument-hint`). A key any supported harness rejects does not belong in a shared file.
10. Agent wrappers follow each harness's official documentation. Re-check vendor docs before adding a harness or editing a wrapper — formats change upstream.
11. Vendor model names appear only in agent wrappers and in the [category → model authoring reference](#category--model-authoring-reference). Agent base files speak only in categories: **planner**, **implementer**, **mechanical** (defined in `USER-AGENTS.md`); skills cite neither models nor categories (rule 8).
12. Wrappers and the authoring reference must always match: creating an agent or updating a model changes the table and every affected wrapper in the same commit.
13. Everything installed from this repo — agent name, skill directory, slash command, frontmatter `name:`, file basename — ends in `-ai-tools`, so nothing collides with harness-bundled names. Never install a bare name like `planner` or `az`.
14. Extreme conciseness: all instructions, agents, skills, rules, and configuration in this repository avoid ambiguity and redundancy to the maximum extent, while never omitting an instruction, rule, or intention in exchange for brevity.
15. Everything written to disk in this repository is concise English. Chat with the user happens in the user's language.
16. Every agent whose actions can be **destructive** or **generate cost** opens its base file with a stake disclaimer — one short block, before any workflow, naming what can be billed (when applicable) and what can be deleted, removed, or destroyed (when applicable). Whoever invokes the agent — the session model, or whatever spawns it — must surface that warning to the user **before** dispatching it.

### Installation contract

17. Install by **symlink** whenever possible; copy only where the OS or filesystem refuses symlinks, and report every copy as such.
18. Never overwrite user files during installation, update, or reinstallation — only files that are themselves ai-tools links or unmodified ai-tools copies.
19. Never remove anything that was not explicitly created by ai-tools.
20. Every install/remove/update/reinstall step is idempotent; on conflict, skip and report rather than fail or overwrite.
21. `$HOME/.ai-tools` is the only supported clone location — always user-level, never inside a project. The wrapper pointers hardcode it, so any other location breaks them by design.
22. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: created empty only when missing during installation; never edited, overwritten, truncated, symlinked, or removed.

### Category → model authoring reference

The maintenance-time source for every model name in this repository (rules 11–12). An AI creating a new agent, adding a harness, or updating models reads this table and writes the wrappers from it. Assignment principle: **planner** takes the strongest model regardless of cost, **implementer** the best code-quality-to-cost ratio, **mechanical** the cheapest that reliably finishes. Verified against vendor documentation in August 2026 — re-check at each model release.

| Harness | planner | implementer | mechanical |
|---|---|---|---|
| Claude Code | `opus` (Claude Opus 5) | `sonnet` (Claude Sonnet 5) | `haiku` (Claude Haiku 4.5) |
| Grok Build | `grok-4.6` | `grok-build-0.1` | `grok-4.20-0309-non-reasoning` |
| OpenAI Codex | `gpt-5.6-sol` | `gpt-5.6-terra` | `gpt-5.6-luna` |
| GitHub Copilot | `Claude Opus 5` | `Claude Sonnet 5` | `Claude Haiku 4.5` |
| Google Antigravity | `pro` | `flash` | `flash` |
| Cursor | `claude-opus-5[effort=high]` | `composer-2.5` | `composer-2.5[fast=true]` |
| Gemini CLI | `gemini-3.1-pro` | `gemini-3.7-flash` | `gemini-3.5-flash-lite` |

Notes: Gemini's Pro line is frozen at 3.1 while Flash has moved to 3.7, so planner and implementer come from different generations. Antigravity's `model:` accepts only tiers (`inherit`, `flash`, `pro`), not model IDs — `pro` is its strongest tier and there is no cheaper-than-`flash` tier, so mechanical also runs `flash`. Grok Build ignores `model:` in agent frontmatter — models are pinned in `~/.grok/config.toml` (see [Installation §5](#5-install-agents)).

Every shipped agent runs as **planner** — except `maintainer-ai-tools`, which runs as **implementer** (it follows this README's documented procedures) — so each wrapper pins its own category's column for its harness. The wrapper body carries exactly two things (rule 6), in this order — the canonical form, below the harness's own frontmatter/TOML header:

```markdown
When the base file cites these categories, they mean:

| Category | Model in this harness |
|---|---|
| planner | `<planner model>` |
| implementer | `<implementer model>` |
| mechanical | `<mechanical model>` |

The base file for this agent is `$HOME/.ai-tools/agents/<name>.md` (Windows: `%USERPROFILE%\.ai-tools\agents\<name>.md`).
Read it and follow it in full — it is the absolute rule set for this agent.
```

The conversion table keeps only the rows for categories the base file actually cites, and is omitted entirely when it cites none — the pointer is then the whole body. Model values come from this section's reference table, translated to the harness's own syntax.

## Cross-platform glossary

Every command in this document is written in POSIX/bash, which covers Linux (including WSL) and Mac unchanged. A harness running natively on Windows (no WSL, no Git Bash) follows the same steps by translating:

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
| `git clone <url> <dir>` | identical (`git` is shell-agnostic) |

The safety semantics — idempotent, never overwrite a non-ai-tools destination, skip and report instead of failing — apply identically no matter which shell executes them.

## Safety rules

These bind the AI (or careful human) executing [Installation](#installation), [Removal](#removal), [Update](#update), and [Reinstallation](#reinstallation), on top of the [Installation contract](#installation-contract) rules 17–22:

- **Never replace** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip it, report it, and continue** (rules 18, 20). Silent overwrite is a bug; a destination that is already the correct link is left alone.
- **Never** `rm -rf` a harness agents or skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source — a locally modified copy is user work and is skipped, not deleted (rule 19).
- Never touch vendor bundles such as `~/.grok/bundled/`, unrelated user agents or skills, a repository's own `AGENTS.md` describing that application's architecture, or `$HOME/AGENTS.md` (rule 22).
- Ask which harnesses are in scope before changing anything, and report findings first.

Helpers used by every process section below:

```bash
export AI_TOOLS="$HOME/.ai-tools"

# Skill roots, one per harness — used wherever skills are installed, removed, or verified,
# and by the stale-link sweep in Removal §3. Trim to the harnesses in scope.
SKILL_ROOTS="$HOME/.claude/skills $HOME/.grok/skills $HOME/.codex/skills
             $HOME/.copilot/skills $HOME/.cursor/skills $HOME/.gemini/skills
             $HOME/.gemini/config/skills"

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

## Supported harnesses

Reference for every process section. One row per harness: where its global instructions, skills, and agents live, which wrapper folder serves it, and the agent file form its wrapper uses.

| Harness | Global instructions destination | Skills root | Agents root | Wrapper folder · agent file form |
|---|---|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` | `$HOME/.claude/agents/` | `agents/claude-code/` · `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/full ID/`inherit`) |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` | `$HOME/.grok/agents/` | `agents/grok/` · `*.md`; **no `model:` in frontmatter** — pin models in `~/.grok/config.toml` (see [§5](#5-install-agents)) |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` | `$HOME/.codex/agents/` | `agents/codex/` · `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` | `$HOME/.copilot/agents/` | `agents/copilot/` · `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` (shared with Gemini CLI) | `$HOME/.gemini/config/skills/` | `$HOME/.gemini/config/agents/` | `agents/antigravity/` · `*.md`, frontmatter `name`, `description`, `model` (`inherit`/`flash`/`pro`), `subagent`, `mainAgent`, `commandExecutionPolicy` |
| Cursor | Not linked — no documented file path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` | `$HOME/.cursor/agents/` | `agents/cursor/` · `*.md`, `model:` accepts bracketed parameters (`claude-opus-5[effort=high]`) |
| Gemini CLI | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/skills/` (**not** `$HOME/.gemini/config/skills/`) | `$HOME/.gemini/agents/` | `agents/gemini/` · `*.md`, frontmatter `kind`, `model`, `temperature`, `max_turns`, `timeout_mins` |

Notes:

- **Antigravity and Gemini CLI share `$HOME/.gemini`** but not the same roots: one `GEMINI.md` link serves both, while skills and agents install into `config/skills/`/`config/agents/` for Antigravity and `skills/`/`agents/` for Gemini CLI — install into each selected harness's own roots.
- **Antigravity limits rules files to 12,000 characters each** — currently the tightest instructions-file constraint among supported harnesses, so it caps `USER-AGENTS.md` (rule 3); over it, the file is truncated or rejected there.
- **Codex**: reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope.
- **Never link into `$HOME/.agents/`.** It is a live shared discovery root read by several harnesses — linking there as well as into each harness's own root would double-register every agent.
- When a harness cannot use a symlink for instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

## Installation

Written for an AI following it step by step. Read [Safety rules](#safety-rules) and the [Installation contract](#installation-contract) first; use the [Supported harnesses](#supported-harnesses) table for every path.

### 0. Preconditions

`$HOME/.ai-tools` is the **only** supported clone path (rule 21). Resolve `$HOME` to the current user's real home; see the [Cross-platform glossary](#cross-platform-glossary) for Windows equivalents.

```bash
export AI_TOOLS="$HOME/.ai-tools"
test -d "$AI_TOOLS" || git clone https://github.com/hgsantana/ai-tools.git "$AI_TOOLS"
test -f "$AI_TOOLS/USER-AGENTS.md" && test -d "$AI_TOOLS/agents"
```

If the clone exists somewhere else, move it to `$HOME/.ai-tools` — no other location is recoverable by configuration.

### 1. Discover installed harnesses

Report what you find before changing anything.

```bash
test -d "$HOME/.claude"      && echo "found: Claude Code ($HOME/.claude)"
test -d "$HOME/.grok"        && echo "found: Grok Build ($HOME/.grok)"
command -v grok >/dev/null   && echo "found: grok CLI"
test -d "$HOME/.cursor"      && echo "found: Cursor ($HOME/.cursor)"
test -d "$HOME/.codex"       && echo "found: Codex ($HOME/.codex)"
command -v codex >/dev/null  && echo "found: codex CLI"
test -d "$HOME/.copilot"     && echo "found: GitHub Copilot ($HOME/.copilot)"
command -v copilot >/dev/null && echo "found: copilot CLI"
test -d "$HOME/.gemini/config" && echo "found: Google Antigravity ($HOME/.gemini/config)"
command -v antigravity >/dev/null && echo "found: antigravity CLI"
test -d "$HOME/.agents"      && echo "found: $HOME/.agents (shared discovery root — never link here)"
```

Some harnesses manifest only as an installed **IDE extension** — no standalone CLI, no home directory to `test -d`. Scan the usual IDE extension roots and match against the known-extension table:

| Extension ID (prefix match) | Harness | Config home |
|---|---|---|
| `google.geminicodeassist-*` | Gemini | `$HOME/.gemini` |
| `anthropic.claude-code-*` | Claude Code | `$HOME/.claude` |
| `openai.chatgpt-*` | OpenAI Codex | `$HOME/.codex` |
| `github.copilot-chat-*` | GitHub Copilot | `$HOME/.copilot` |

```bash
EXT_ROOTS="$HOME/.vscode/extensions $HOME/.vscode-server/extensions $HOME/.vscode-insiders/extensions $HOME/.vscode-server-insiders/extensions $HOME/.vscodium/extensions"

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

# Informational-only: possible AI extensions with no confirmed config convention here.
# Offer nothing from this list unless the user names one explicitly.
JETBRAINS_ROOTS=""
for jb in "$HOME"/.local/share/JetBrains/*/plugins; do
  [ -d "$jb" ] && JETBRAINS_ROOTS="$JETBRAINS_ROOTS $jb"
done
for root in $EXT_ROOTS $JETBRAINS_ROOTS; do
  [ -d "$root" ] || continue
  ls "$root" 2>/dev/null | grep -iE 'gemini|claude|codeium|windsurf|antigravity|continue|cody|cursor|tabnine' | while read -r name; do
    echo "info: possible AI extension '$name' in $root"
  done
done
```

### 2. Ask which targets to install

Present the discovery list and let the user choose — CLI/home-dir harnesses and extension-discovered harnesses from the known table. Keyword-only matches are informational, not offered unless the user names one explicitly. Do not install into every tool by default when the user only uses one.

### 3. Install global instructions

Link `USER-AGENTS.md` to each selected harness's global instructions destination ([Supported harnesses](#supported-harnesses)):

```bash
safe_link "$AI_TOOLS/USER-AGENTS.md" "$HOME/.claude/CLAUDE.md"     # if Claude Code selected
safe_link "$AI_TOOLS/USER-AGENTS.md" "$HOME/.grok/AGENTS.md"       # if Grok selected

# Codex: link as the fallback layer even though AGENTS.override.md wins while present
test -f "$HOME/.codex/AGENTS.override.md" && echo "NOTE: ~/.codex/AGENTS.override.md exists and takes precedence while present"
safe_link "$AI_TOOLS/USER-AGENTS.md" "$HOME/.codex/AGENTS.md"      # if Codex selected

safe_link "$AI_TOOLS/USER-AGENTS.md" "$HOME/.copilot/instructions/ai-tools.instructions.md"  # if Copilot selected
safe_link "$AI_TOOLS/USER-AGENTS.md" "$HOME/.gemini/GEMINI.md"     # if Gemini CLI or Antigravity selected — one link serves both
# Cursor: no global instructions destination — skip (see harness table)
```

### 4. Ensure user-level `$HOME/AGENTS.md`

Create an empty user overlay file if missing. This is **not** a harness link and must **not** use `safe_link`. Agents are instructed (in `USER-AGENTS.md`) to read this file after the global defaults; it overrides them, and a project's own `AGENTS.md`/`README.md` still wins over both.

```bash
if [ -e "$HOME/AGENTS.md" ]; then
  echo "ok (already present): $HOME/AGENTS.md"
else
  : > "$HOME/AGENTS.md"
  echo "created (empty): $HOME/AGENTS.md"
fi
```

If the path exists in any form, leave it untouched (rule 22). Do not ask whether the user wants to add instructions; write contents only if the user later asks for that directly.

### 5. Install agents

Link each agent **wrapper** file for each selected harness from `$AI_TOOLS/agents/<harness>/` into that harness's agents root ([Supported harnesses](#supported-harnesses)). Agents are linked **per file**, never per directory — the roots hold agents from other sources, so a directory link would shadow them.

```bash
# usage: install_agents <harness-folder> <destination-root>
install_agents() {
  local src="$AI_TOOLS/agents/$1" dest="$2"
  [ -d "$src" ] || { echo "SKIP (no such harness folder): $src"; return 1; }
  find "$src" -maxdepth 1 -type f -name '*-ai-tools*' -print | while read -r file; do
    link_or_copy "$file" "$dest/$(basename "$file")"
  done
}

install_agents claude-code "$HOME/.claude/agents"        # if Claude Code selected
install_agents codex       "$HOME/.codex/agents"         # if Codex selected
install_agents copilot     "$HOME/.copilot/agents"       # if Copilot selected
install_agents cursor      "$HOME/.cursor/agents"        # if Cursor selected
install_agents gemini      "$HOME/.gemini/agents"        # if Gemini selected
install_agents grok        "$HOME/.grok/agents"          # if Grok selected
install_agents antigravity "$HOME/.gemini/config/agents" # if Antigravity selected
```

`link_or_copy` prefers a symlink and falls back to a copy only where the OS or filesystem refuses one — Windows without Developer Mode, or a mount without symlink support. **A copied agent drifts**: it does not track `git pull`, so run [Update](#update) after every upstream change on those machines. Copies are reported as `copied (will not track updates)` so the drift is visible in the install log.

**Grok Build — pin the models separately.** Grok resolves subagent models from `~/.grok/config.toml`, not from agent frontmatter. Add one entry per shipped agent, taken from the [authoring reference](#category--model-authoring-reference) (never replace the file):

```toml
[subagents.models]
vibe-ai-tools = "grok-4.6"
planner-ai-tools = "grok-4.6"
orchestrator-ai-tools = "grok-4.6"
az-ai-tools = "grok-4.6"
gh-ai-tools = "grok-4.6"
gc-ai-tools = "grok-4.6"
maintainer-ai-tools = "grok-build-0.1"
```

Without this block the agents still load — they inherit the session's model, so the strong-model guarantee is lost. The same fallback applies to any harness whose `model:` field is ignored or unsupported.

### 6. Install skills

Link each directory under `$AI_TOOLS/skills/` into every selected harness's skills root ([Supported harnesses](#supported-harnesses)); the same directory serves all of them (rules 7–9):

```bash
for root in $SKILL_ROOTS; do
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    safe_link "$path" "$root/$(basename "$path")"
  done
done
```

If Grok is configured with `[skills] paths`, adding `$AI_TOOLS/skills` as a scan path is an option, but only when it cannot clobber existing names. Prefer explicit per-skill links.

### 7. Verify

```bash
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
readlink -f "$HOME/.grok/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.codex/AGENTS.md" 2>/dev/null
readlink -f "$HOME/.copilot/instructions/ai-tools.instructions.md" 2>/dev/null
readlink -f "$HOME/.gemini/GEMINI.md" 2>/dev/null
# User overlay (not a harness link): expect a regular file at $HOME/AGENTS.md
test -e "$HOME/AGENTS.md" && echo "user overlay present: $HOME/AGENTS.md" || echo "WARN: missing $HOME/AGENTS.md"

# Artifact fits the tightest harness constraint (rule 3; see Supported harnesses notes)
size=$(wc -c < "$AI_TOOLS/USER-AGENTS.md")
[ "$size" -le 12000 ] && echo "instructions size ok: $size chars" || echo "WARN: USER-AGENTS.md exceeds 12000 chars (Antigravity limit)"

# Every agent base exists at the pinned location
for base in "$AI_TOOLS/agents"/*-ai-tools.md; do
  test -f "$base" && echo "base ok: $base" || echo "WARN missing base: $base"
done

# Skills (when shipped): every installed link resolves to a real SKILL.md
for root in $SKILL_ROOTS; do
  [ -d "$root" ] || continue
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    name=$(basename "$path")
    test -f "$root/$name/SKILL.md" && echo "skill ok: $root/$name" || echo "WARN not installed or broken: $root/$name"
  done
done

# Agents: installed as a link or an unmodified copy, per harness
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
    antigravity) root="$HOME/.gemini/config/agents" ;;
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

Restart or reload any harness that caches agents or skills at startup, then confirm the seven agents (`vibe-ai-tools`, `planner-ai-tools`, `orchestrator-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`, `maintainer-ai-tools`) appear in the harness's agent list — plus a slash command for every skill shipped under `$AI_TOOLS/skills/*-ai-tools`, when any exist.

## Removal

Removal means "unlink from harnesses", not "delete the config repo". Leaving `$AI_TOOLS` on disk is normal and makes [Update](#update) a pull plus re-link. Read [Safety rules](#safety-rules) first.

### 1. Discover what is linked from ai-tools

Report findings; remove nothing until the user confirms the targets.

```bash
for root in "$HOME/.claude/agents" "$HOME/.grok/agents" "$HOME/.codex/agents" \
            "$HOME/.copilot/agents" "$HOME/.cursor/agents" "$HOME/.gemini/agents" \
            "$HOME/.gemini/config/agents" $SKILL_ROOTS; do
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

for f in "$HOME/.claude/CLAUDE.md" "$HOME/.grok/AGENTS.md" "$HOME/.codex/AGENTS.md" \
         "$HOME/.copilot/instructions/ai-tools.instructions.md" "$HOME/.gemini/GEMINI.md"; do
  [ -L "$f" ] && echo "instructions: $f -> $(readlink "$f")"
done
```

Note any link resolving to a path that no longer exists — a stale link from an older alpha version still needs cleaning up ([§3](#3-remove-stale-links)). Re-run Installation §1's discovery to know which extension-only harnesses are in scope — installed extensions change between runs.

### 2. Remove agents and skills

Mirror of [Installation §5–§6](#5-install-agents): agents per-file, per-harness; skills per-directory. Links are unlinked; copies are removed only when unmodified.

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

uninstall_agents claude-code "$HOME/.claude/agents"        # if Claude Code selected
uninstall_agents codex       "$HOME/.codex/agents"         # if Codex selected
uninstall_agents copilot     "$HOME/.copilot/agents"       # if Copilot selected
uninstall_agents cursor      "$HOME/.cursor/agents"        # if Cursor selected
uninstall_agents gemini      "$HOME/.gemini/agents"        # if Gemini selected
uninstall_agents grok        "$HOME/.grok/agents"          # if Grok selected
uninstall_agents antigravity "$HOME/.gemini/config/agents" # if Antigravity selected
```

If Grok's `~/.grok/config.toml` carries the `[subagents.models]` entries from Installation §5, remove **only those keys** when asked — never the file, and never other entries in the table.

Skills (when shipped — names come from the tree, never a hardcoded list):

```bash
for root in $SKILL_ROOTS; do
  [ -d "$root" ] || continue
  for path in "$AI_TOOLS/skills"/*-ai-tools; do
    [ -d "$path" ] || continue
    safe_unlink "$root/$(basename "$path")"
  done
done
```

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove **only that entry** when asked — never wipe the config file.

### 3. Remove stale links

No backward compatibility is maintained in alpha (rule 4), so older installs are cleaned generically: remove anything in the known roots that still resolves into `$AI_TOOLS`, whatever its name or era. `safe_unlink` refuses non-ai-tools targets, so the sweep is safe:

```bash
for root in "$HOME/.claude/agents" "$HOME/.grok/agents" "$HOME/.codex/agents" \
            "$HOME/.copilot/agents" "$HOME/.cursor/agents" "$HOME/.gemini/agents" \
            "$HOME/.gemini/config/agents" $SKILL_ROOTS; do
  [ -d "$root" ] || continue
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) safe_unlink "$p" ;; esac
  done
done

# Whole-directory links from an older alpha install (no-op when the root is a real directory)
safe_unlink "$HOME/.claude/agents"
safe_unlink "$HOME/.grok/agents"
```

### 4. Remove the global instructions link, optional

Only when the user wants the harness to stop loading this repo's `USER-AGENTS.md`. Unlink only harness destinations that are links into `$AI_TOOLS/USER-AGENTS.md`. **Never touch `$HOME/AGENTS.md`** (rule 19) — it is not a harness link and is never part of removal.

```bash
safe_unlink "$HOME/.claude/CLAUDE.md"
safe_unlink "$HOME/.grok/AGENTS.md"
safe_unlink "$HOME/.codex/AGENTS.md"
safe_unlink "$HOME/.copilot/instructions/ai-tools.instructions.md"
safe_unlink "$HOME/.gemini/GEMINI.md"   # serves Gemini CLI AND Antigravity — unlink only when both are out of scope
# Never: safe_unlink "$HOME/AGENTS.md"
```

If the instructions file is an include pointer rather than a symlink, edit out that one line instead of deleting the file.

### 5. Verify removal

```bash
for root in "$HOME/.claude/agents" "$HOME/.grok/agents" "$HOME/.codex/agents" \
            "$HOME/.copilot/agents" "$HOME/.cursor/agents" "$HOME/.gemini/agents" \
            "$HOME/.gemini/config/agents" \
            "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.codex/skills" \
            "$HOME/.copilot/skills" "$HOME/.cursor/skills" "$HOME/.gemini/skills" \
            "$HOME/.gemini/config/skills"; do
  [ -d "$root" ] || continue
  echo "=== remaining ai-tools links in $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) echo "STILL LINKED: $p -> $t" ;; esac
  done
done
```

Expected: no links into `$AI_TOOLS` for the cleaned harnesses. Restart the harness; the agents should disappear from its agent list, and any skill slash commands from its menu.

### 6. Remove the repository clone, optional

Only when the user explicitly asks to delete the config tree itself. This never includes `$HOME/AGENTS.md`.

```bash
# Confirm the path first — destructive; does not touch $HOME/AGENTS.md
# rm -rf "$AI_TOOLS"
```

## Update

Update brings the clone to `origin/master` and re-synchronizes what is already installed. Symlinks track the new content automatically; **copies do not** and are refreshed here. Use [Reinstallation](#reinstallation) instead when the install is broken, comes from an older alpha layout, or the set of harnesses changed.

`origin/master` is the canonical source — never update from a dirty tree, a feature branch, or a local-only commit unless the user explicitly overrides that.

### 0. Preconditions

```bash
export AI_TOOLS="$HOME/.ai-tools"
test -d "$AI_TOOLS/.git" && test -f "$AI_TOOLS/USER-AGENTS.md" && test -d "$AI_TOOLS/agents"
```

If `$AI_TOOLS` is missing, stop and offer a fresh [Installation](#installation) instead. Never invent agents that are not in the tree.

### 1. Ask scope

Confirm with the user:

1. Which harnesses are installed and in scope.
2. That the update **resets `$AI_TOOLS` to `origin/master`**, discarding local commits and uncommitted changes in this repo, unless they opt out.

### 2. Reset the repository to `origin/master`

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

PREV=$(git rev-parse HEAD)   # previous version — used to refresh copies below
git checkout master
git reset --hard origin/master

echo "HEAD: $(git rev-parse --short HEAD) (was $(git rev-parse --short "$PREV" 2>/dev/null || echo unknown))"
```

Notes:

- Destructive **inside `$AI_TOOLS` only**: it discards local commits on `master` and uncommitted edits. It never touches harness config outside this directory, and never `$HOME/AGENTS.md`.
- If the user has local work they care about, stop, show `git status` and `git log`, and get explicit approval before `reset --hard`, or help them branch or stash first.
- If the default branch is ever renamed (for example `main`), use that name only once the user or remote confirms it.

### 3. Refresh copies

Symlinked installs are already up to date. On machines where agents were **copied** ([Installation §5](#5-install-agents)), refresh each copy: one matching the file at the previous version (`$PREV`) is stale, not user work — replace it; one matching neither revision was modified locally — skip and report (rule 19).

```bash
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
    antigravity) root="$HOME/.gemini/config/agents" ;;
    *)           echo "WARN unmapped harness folder: $harness"; continue ;;
  esac
  for file in "$dir"*-ai-tools*; do
    [ -f "$file" ] || continue
    base=$(basename "$file")
    dest="$root/$base"
    [ -f "$dest" ] && [ ! -L "$dest" ] || continue   # links track automatically
    if cmp -s -- "$dest" "$file"; then
      echo "copy up to date: $dest"
    elif git -C "$AI_TOOLS" show "$PREV:agents/$harness/$base" 2>/dev/null | cmp -s -- "$dest" -; then
      cp -- "$file" "$dest" && echo "copy refreshed: $dest"
    else
      echo "SKIP (copy modified locally): $dest"
    fi
  done
done
```

### 4. Link anything newly shipped

New agents or skills may have landed upstream. Re-run [Installation §5–§6](#5-install-agents) for the harnesses in scope — `safe_link` and `link_or_copy` are idempotent, so existing installs are untouched and only the new items are added. Re-run [Installation §4](#4-ensure-user-level-homeagentsmd) as well: create `$HOME/AGENTS.md` empty only if missing; if present, leave it untouched.

If the update introduced renames or layout changes, run a [Reinstallation](#reinstallation) instead — its stale-link sweep cleans whatever the older alpha version installed.

### 5. Verify

```bash
# Source tree must be master == origin/master, clean
git -C "$AI_TOOLS" status -sb
git -C "$AI_TOOLS" rev-parse HEAD origin/master   # expect the same SHA twice
```

Then run [Installation §7](#7-verify). Restart or reload any harness that caches agents or skills.

## Reinstallation

A full Removal + Installation pass against a fresh `origin/master`. Use it when [Update](#update) is not enough: a broken or partial install, stale names or layouts from an older alpha version, dangling links after upstream renames, or a change in which harnesses are wired. A link is never upgraded in place — re-creating it is the fix.

### 1. Ask scope

1. Which harnesses to reinstall — re-run [Installation §1](#1-discover-installed-harnesses)'s discovery rather than reuse a stale list; installed extensions change between runs.
2. Whether to refresh **instructions** as well as agents and skills.
3. Whether to run the **stale-link sweep** ([Removal §3](#3-remove-stale-links)).
4. That the source is reset to `origin/master`, discarding local changes in this repo, unless they opt out.

### 2. Update the source

Run [Update §0–§2](#update): preconditions and reset to `origin/master`. If `$AI_TOOLS` is missing entirely, clone it first ([Installation §0](#0-preconditions)). Do this **before** removing or re-linking, so destinations match the published agent set — names and paths can change between versions.

### 3. Remove

Run [Removal §2–§4](#removal) for the harnesses in scope, including the stale-link sweep. Removing after the reset avoids stale names left beside new ones and broken links after renames. Unmodified copies are dropped here; modified copies are skipped and reported.

### 4. Install

Run [Installation §3–§6](#installation) for the same harnesses — discovery is optional when scope was already confirmed. List `$AI_TOOLS/agents/*-ai-tools.md`, `$AI_TOOLS/agents/*/`, and `$AI_TOOLS/skills/*-ai-tools` after the reset instead of using hardcoded lists, since all sets may have changed. `safe_link` stays non-destructive: an existing destination that is not already the correct link is skipped and reported.

### 5. Verify

Run [Installation §7](#7-verify), and expect the [Removal §5](#5-verify-removal) loop to report no stale links. Restart or reload the harness, then confirm the seven agents appear in its agent list, plus a slash command for every shipped skill, when any exist.

## Troubleshooting

- **Local changes the user wants to keep:** do not `reset --hard` until they stash, branch, or approve the discard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user must set a remote or re-clone from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there. It is the only supported location (rule 21); the wrappers hardcode that path, so no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then re-check.
- **Dangling links after an upstream rename or layout change:** run [Reinstallation](#reinstallation); links are never upgraded in place.
- **Copied agents out of date:** copies do not track `git pull` — run [Update §3](#3-refresh-copies), or [Reinstallation](#reinstallation) if the copy predates the `$PREV` revision available locally.
- **A destination is occupied by a non-ai-tools file the user wants replaced:** require explicit per-path approval; the default stays skip and report.
- **An agent runs on the wrong (weak) model:** the wrapper's model pinning is not applied — for Grok, check the `[subagents.models]` block in `~/.grok/config.toml` ([Installation §5](#5-install-agents)); for other harnesses, compare the installed wrapper against `$AI_TOOLS/agents/<harness>/` and the [authoring reference](#category--model-authoring-reference).
