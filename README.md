# ai-tools

## Introduction

This repository is a **harness-agnostic** home for shared AI coding configuration: global agent instructions and slash skills (`/plan`, `/dev`, `/az`, `/gh`, `/gc`). It is meant to live at `~/.config/ai-tools/` and be linked into whatever AI CLIs or IDEs you use (Claude Code, Grok, Cursor, and similar).

Goals:

- One global `AGENTS.md` with **agent categories** (`planner`, `implementer`, `mechanical`) so any model can map roles without hard-coding vendor model names
- Skills that work the same across tools: multi-file plans, token-efficient stage execution, safe cloud/GitHub CLIs
- Install by **symlinks**, not by forking copies that drift

This repo does not ship pre-defined subagent markdown files. The running model chooses how to spawn agents for each category.

## Contents

| Path | Description |
|------|-------------|
| [`AGENTS.md`](AGENTS.md) | Global user-wide instructions: agent categories, mandatory `/plan` → confirm → `/dev` flow, CLI skill pointers, security defaults |
| [`skills/plan/`](skills/plan/) | `/plan` — explore the codebase, write a **base plan** plus **one file per stage** under `plans/`, stop without implementing |
| [`skills/dev/`](skills/dev/) | `/dev` — execute plan queue or ad-hoc work; **implementer** codes; **planner** validates; status table (`W`/`V`/`R`/`E`/`T`/`TV`/`F`); stage context isolation |
| [`skills/az/`](skills/az/) | `/az` — Azure CLI: read freely; mutate only with explicit per-action approval; surface cost |
| [`skills/gh/`](skills/gh/) | `/gh` — GitHub CLI: read freely; mutate only with explicit per-action approval |
| [`skills/gc/`](skills/gc/) | `/gc` — Google Cloud CLI: read freely; mutate only with explicit per-action approval; surface cost |
| `agents/` | Reserved (empty). No agent definitions yet; harness maps categories at runtime |
| `README.md` | This file |

### Agent categories (summary)

| Category | Role |
|----------|------|
| **planner** | Plan, orchestrate, validate, escalate |
| **implementer** | Write/edit code for a specified stage or brief |
| **mechanical** | Fully specified low-ambiguity work and evidence gathering |

### Plan file layout (summary)

```text
plans/
  <slug>.md           # base: status table, goal, graph, stage links
  <slug>-1.md         # stage 1 detail + implementation log
  <slug>-2.md
  finished/           # completed stage and base files
```

## Installation

These steps are written so an **AI assistant** (or a careful human) can install this repo onto a machine. Prefer **symlinks** into each tool’s user-wide config. Do **not** overwrite existing files unless the user explicitly wants a replace.

### 0. Preconditions

- This repository is cloned or present at `~/.config/ai-tools` (or another path the user names; below, `$AI_TOOLS` defaults to `~/.config/ai-tools`).
- Expand `~` to the real home directory of the **current user**.

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"
test -f "$AI_TOOLS/AGENTS.md" && test -d "$AI_TOOLS/skills"
```

### 1. Discover installed AI harnesses

Scan the current user account for known tools. Report what you find before changing anything.

```bash
# Claude Code
test -d "$HOME/.claude" && echo "found: Claude Code ($HOME/.claude)"

# Grok (xAI)
test -d "$HOME/.grok" && echo "found: Grok ($HOME/.grok)"
command -v grok >/dev/null && echo "found: grok CLI"

# Cursor
test -d "$HOME/.cursor" && echo "found: Cursor ($HOME/.cursor)"

# Codex / OpenAI-style
test -d "$HOME/.codex" && echo "found: Codex ($HOME/.codex)"

# Optional: other agent skill roots
test -d "$HOME/.agents" && echo "found: $HOME/.agents"
```

Also check project-local harness dirs only if the user asked to wire projects:

```bash
# Example discovery under a projects tree (adjust path)
find "$HOME/projetos" -maxdepth 3 \( -name '.claude' -o -name '.grok' -o -name '.cursor' \) 2>/dev/null
```

### 2. Ask which targets to install

Present the discovery list and **ask the user** which harnesses should receive links. Do not install into every tool by default if the user only uses one.

### 3. Safety rules (mandatory)

- **Never replace** an existing regular file or non-ai-tools symlink with a new link unless the user explicitly approves that path.
- If the destination exists and is **not** already a symlink into `$AI_TOOLS`, **skip** it, report it, and continue.
- If the destination is already a correct symlink into `$AI_TOOLS`, leave it (idempotent).
- Do not delete harness **bundled** skills (e.g. Grok `~/.grok/bundled/`). Only manage user-level skill/agent/instruction paths the user chose.
- Do not remove project product docs such as a repo’s own `AGENTS.md` that describes the **application** architecture unless the user asks.

Helper to link safely:

```bash
safe_link() {
  # usage: safe_link <target-in-ai-tools> <destination-path>
  local target="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    local cur
    cur=$(readlink -f "$dest" 2>/dev/null || readlink "$dest")
    local want
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
```

### 4. Install global instructions

Link this repo’s `AGENTS.md` to each selected harness’s user-wide instruction file.

| Harness | Typical destination | Notes |
|---------|---------------------|--------|
| Claude Code | `$HOME/.claude/CLAUDE.md` | Claude loads user `CLAUDE.md` |
| Grok | Often project `AGENTS.md` or user docs; if the harness supports a user-wide agents file, link there. Alternatively add `$AI_TOOLS` to the tool’s skill/config paths and ensure sessions read `$AI_TOOLS/AGENTS.md` |
| Cursor | User rules / `AGENTS.md` location per Cursor version | Confirm current path before linking |
| Generic | `$HOME/.config/ai-tools/AGENTS.md` is the source of truth | Other tools can be pointed at it |

Example (Claude Code):

```bash
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.claude/CLAUDE.md"
```

If the harness **cannot** use a symlink for instructions, tell the user and offer a one-line include pointer instead of copying the whole file (so the SSOT remains this repo).

### 5. Install skills

For each selected harness, link **each** skill directory from `$AI_TOOLS/skills/<name>` into that harness’s user skills root.

Skills to install: `plan`, `dev`, `az`, `gh`, `gc`.

| Harness | User skills root |
|---------|------------------|
| Claude Code | `$HOME/.claude/skills/` |
| Grok | `$HOME/.grok/skills/` |
| Cursor | `$HOME/.cursor/skills/` (if skills are enabled) |

```bash
for name in plan dev az gh gc; do
  safe_link "$AI_TOOLS/skills/$name" "$HOME/.claude/skills/$name"   # if Claude selected
  safe_link "$AI_TOOLS/skills/$name" "$HOME/.grok/skills/$name"     # if Grok selected
done
```

Optional: if Grok is configured with `[skills] paths`, you may add `$AI_TOOLS/skills` as a scan path instead of per-skill links — only when that avoids clobbering existing names. Prefer explicit per-skill links for clarity.

### 6. Agents directory

This repository intentionally has **no** agent definition files yet. Do **not** create stub agents unless the user asks. Harnesses should map **planner** / **implementer** / **mechanical** using their own subagent mechanisms.

If the user later adds files under `$AI_TOOLS/agents/`, link that directory the same safe way into `$HOME/.claude/agents` or `$HOME/.grok/agents` only when empty or already linked here.

### 7. Verify

```bash
# Symlinks resolve
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
ls -la "$HOME/.claude/skills" "$HOME/.grok/skills" 2>/dev/null

# Skill entrypoints exist
for name in plan dev az gh gc; do
  test -f "$AI_TOOLS/skills/$name/SKILL.md" && echo "skill ok: $name"
done
```

Restart or reload the harness if it caches skills at startup. Confirm `/plan`, `/dev`, `/az`, `/gh`, and `/gc` appear in the slash menu when supported.

### 8. Uninstall (optional)

Remove **only** symlinks that point into `$AI_TOOLS`. Do not delete unrelated skills or harness bundled content.

```bash
# Example: remove a link only if it points at ai-tools
dest="$HOME/.claude/skills/plan"
if [ -L "$dest" ] && readlink "$dest" | grep -q 'ai-tools'; then
  rm "$dest"
fi
```

## Warning

**Do not replace** existing configuration, skills, agents, or instruction files at the destination unless the owner of this repository (the human user) explicitly asks for a replace. Default behavior is **skip and report**. Silent overwrite is a bug.

## License / ownership

Personal configuration repository for multi-tool AI workflows. Adjust paths if you host a clone elsewhere; keep `$AI_TOOLS` consistent in install steps.
