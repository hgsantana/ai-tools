# ai-tools

## Introduction

This repository is a **harness-agnostic** home for shared AI coding configuration: global agent instructions and slash skills (`/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, `/gc-ai-tools`). Skill and agent install names always end with `-ai-tools` so they do not collide with harness-bundled skills. It is meant to live at `~/.config/ai-tools/` and be linked into whatever AI CLIs or IDEs you use (Claude Code, Grok, Cursor, and similar).

Goals:

- One global `AGENTS.md` with **agent categories** (`planner`, `implementer`, `mechanical`) so any model can map roles without hard-coding vendor model names
- Skills that work the same across tools: multi-file plans, token-efficient stage execution, safe cloud/GitHub CLIs
- Install by **symlinks**, not by forking copies that drift

This repo does not ship pre-defined subagent markdown files. The running model chooses how to spawn agents for each category.

## Contents

| Path | Description |
|------|-------------|
| [`AGENTS.md`](AGENTS.md) | Global user-wide instructions: agent categories, mandatory `/plan-ai-tools` → confirm → `/dev-ai-tools` flow, CLI skill pointers, security defaults |
| [`skills/plan-ai-tools/`](skills/plan-ai-tools/) | `/plan-ai-tools` — explore the codebase, write a **base plan** plus **one file per stage** under `plans/`, stop without implementing |
| [`skills/dev-ai-tools/`](skills/dev-ai-tools/) | `/dev-ai-tools` — execute plan queue or ad-hoc work; **implementer** codes; **planner** validates; status table (`W`/`V`/`R`/`E`/`T`/`TV`/`F`); stage context isolation |
| [`skills/az-ai-tools/`](skills/az-ai-tools/) | `/az-ai-tools` — Azure CLI: read freely; mutate only with explicit per-action approval; surface cost |
| [`skills/gh-ai-tools/`](skills/gh-ai-tools/) | `/gh-ai-tools` — GitHub CLI: read freely; mutate only with explicit per-action approval |
| [`skills/gc-ai-tools/`](skills/gc-ai-tools/) | `/gc-ai-tools` — Google Cloud CLI: read freely; mutate only with explicit per-action approval; surface cost |
| `agents/` | Reserved (empty). Future agent definitions must use `*-ai-tools` names; harness maps categories at runtime |
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

Skills to install (always with `-ai-tools` suffix): `plan-ai-tools`, `dev-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`.

| Harness | User skills root |
|---------|------------------|
| Claude Code | `$HOME/.claude/skills/` |
| Grok | `$HOME/.grok/skills/` |
| Cursor | `$HOME/.cursor/skills/` (if skills are enabled) |

```bash
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools; do
  safe_link "$AI_TOOLS/skills/$name" "$HOME/.claude/skills/$name"   # if Claude selected
  safe_link "$AI_TOOLS/skills/$name" "$HOME/.grok/skills/$name"     # if Grok selected
done
```

Optional: if Grok is configured with `[skills] paths`, you may add `$AI_TOOLS/skills` as a scan path instead of per-skill links — only when that avoids clobbering existing names. Prefer explicit per-skill links for clarity.

**Naming rule:** every skill and agent installed from this repo must use a name ending in `-ai-tools` (directory name, frontmatter `name:`, and slash command). Do not install bare names like `plan` or `dev`.

### 6. Agents directory

This repository intentionally has **no** agent definition files yet. Do **not** create stub agents unless the user asks. Harnesses should map **planner** / **implementer** / **mechanical** using their own subagent mechanisms.

If the user later adds files under `$AI_TOOLS/agents/`, each agent **must** be named `*-ai-tools` (e.g. `reviewer-ai-tools`). Link those paths the same safe way into `$HOME/.claude/agents` or `$HOME/.grok/agents` only when empty or already linked here.

### 7. Verify

```bash
# Symlinks resolve
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
ls -la "$HOME/.claude/skills" "$HOME/.grok/skills" 2>/dev/null

# Skill entrypoints exist
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools; do
  test -f "$AI_TOOLS/skills/$name/SKILL.md" && echo "skill ok: $name"
done
```

Restart or reload the harness if it caches skills at startup. Confirm `/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, and `/gc-ai-tools` appear in the slash menu when supported.

## Removal

Remove **only** symlinks (and optional config pointers) that point into `$AI_TOOLS`. Never delete harness-bundled skills, unrelated user skills, or the `$AI_TOOLS` repository itself unless the user explicitly asks to delete the clone.

These steps are written so an **AI assistant** (or a careful human) can uninstall safely. Ask which harnesses to clean before changing anything.

### 0. Preconditions

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"
```

### 1. Discover what is linked from ai-tools

Report findings; do not remove until the user confirms targets.

```bash
# Skills (Claude / Grok / Cursor)
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills"; do
  [ -d "$root" ] || continue
  echo "=== $root ==="
  find "$root" -maxdepth 1 \( -type l -o -type d \) -print 2>/dev/null | while read -r p; do
    [ -L "$p" ] || continue
    t=$(readlink "$p")
    case "$t" in
      *ai-tools*|"$AI_TOOLS"/*) echo "linked: $p -> $t" ;;
    esac
  done
done

# Global instructions (example: Claude)
if [ -L "$HOME/.claude/CLAUDE.md" ]; then
  echo "instructions: $HOME/.claude/CLAUDE.md -> $(readlink "$HOME/.claude/CLAUDE.md")"
fi

# Agents (only if present)
for root in "$HOME/.claude/agents" "$HOME/.grok/agents"; do
  [ -d "$root" ] || continue
  echo "=== $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in
      *ai-tools*|"$AI_TOOLS"/*) echo "linked: $p -> $t" ;;
    esac
  done
done
```

Also note legacy bare names (`plan`, `dev`, `az`, `gh`, `gc`) if any broken or old links still point at `$AI_TOOLS`.

### 2. Safety rules (mandatory)

- Remove a destination **only** if it is a symlink whose target resolves under `$AI_TOOLS` (or clearly contains `ai-tools` as this repo).
- **Never** `rm -rf` a harness skills root. Remove individual links only.
- **Never** delete a regular file or a symlink that points elsewhere without explicit user approval for that path.
- Do not touch `$HOME/.grok/bundled/` or other vendor bundles.
- Leaving `$AI_TOOLS` on disk is normal; removal means “unlink from harnesses”, not “delete the config repo”.

Helper:

```bash
safe_unlink() {
  # usage: safe_unlink <destination-path>
  local dest="$1"
  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "absent: $dest"
    return 0
  fi
  if [ ! -L "$dest" ]; then
    echo "SKIP (not a symlink): $dest"
    return 1
  fi
  local t
  t=$(readlink "$dest")
  case "$t" in
    *ai-tools*|"$AI_TOOLS"/*) ;;
    *)
      # Also accept resolved path under AI_TOOLS
      local resolved
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

### 3. Remove skills

For each harness the user selected:

```bash
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools \
            plan dev az gh gc; do   # include legacy bare names if any remain
  safe_unlink "$HOME/.claude/skills/$name"   # if Claude selected
  safe_unlink "$HOME/.grok/skills/$name"     # if Grok selected
  safe_unlink "$HOME/.cursor/skills/$name"   # if Cursor selected
done
```

If the user added `$AI_TOOLS/skills` to a harness scan path (e.g. Grok `[skills] paths`), remove **only that path entry** from the harness config when asked — do not wipe the whole config file.

### 4. Remove agents (if any were linked)

```bash
# Only when agent links from this repo exist
if [ -d "$AI_TOOLS/agents" ]; then
  find "$AI_TOOLS/agents" -maxdepth 1 -mindepth 1 ! -name '.gitkeep' -print 2>/dev/null | while read -r src; do
    base=$(basename "$src")
    safe_unlink "$HOME/.claude/agents/$base"
    safe_unlink "$HOME/.grok/agents/$base"
  done
  # Whole-directory link (rare)
  safe_unlink "$HOME/.claude/agents"
  safe_unlink "$HOME/.grok/agents"
fi
```

### 5. Remove global instructions link (optional)

Only if the user wants the harness to stop loading this repo’s `AGENTS.md`:

```bash
safe_unlink "$HOME/.claude/CLAUDE.md"
# Other harnesses: unlink only destinations that were created as links into $AI_TOOLS/AGENTS.md
```

If `CLAUDE.md` (or equivalent) was an include pointer rather than a symlink, edit that one line out — do not delete the whole instructions file unless it is only the pointer.

### 6. Verify removal

```bash
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills"; do
  [ -d "$root" ] || continue
  echo "=== remaining ai-tools links in $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) echo "STILL LINKED: $p -> $t" ;; esac
  done
done
```

Expected: no skill/agent links into `$AI_TOOLS` for the harnesses that were cleaned. Restart or reload the harness; `/plan-ai-tools` and siblings should disappear from the slash menu.

### 7. Optional: remove the repository clone

**Only** if the user explicitly asks to delete the config tree itself:

```bash
# Confirm path first — destructive
# rm -rf "$AI_TOOLS"
```

Default: leave `$AI_TOOLS` in place so [Reinstallation / Update](#reinstallation--update) is a pull + re-link only.

## Reinstallation / Update

Use this when the user asks to **update**, **reinstall**, or **refresh** ai-tools on a machine that already has (or should have) this repo.

One process covers both cases:

1. **Update the source** — fetch `origin` and **reset the working tree to `origin/master`**
2. **Re-wire harnesses** — remove stale ai-tools links, then install links again from that tree

Typical triggers: new skills or renames landed upstream, partial/broken install, wrong legacy names (`plan` vs `plan-ai-tools`), or switching which harnesses are wired.

**Canonical source of truth for reinstall/update:** `origin/master`. Do not reinstall from a dirty tree, a feature branch, or a local-only commit unless the user explicitly overrides that.

### 0. Preconditions

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"
test -d "$AI_TOOLS" && test -d "$AI_TOOLS/.git"
test -f "$AI_TOOLS/AGENTS.md" && test -d "$AI_TOOLS/skills"
```

If `$AI_TOOLS` is missing, stop and offer a fresh [Installation](#installation) (clone first). Do not invent skills that are not in the tree.

### 1. Ask scope

Confirm with the user:

1. Which harnesses to reinstall (Claude Code, Grok, Cursor, …)
2. Whether to refresh **instructions** (`AGENTS.md` / `CLAUDE.md`) as well as skills
3. Whether to clean **legacy** bare names (`plan`, `dev`, …) left from older installs
4. That the update will **reset `$AI_TOOLS` to `origin/master`** (discards local commits and uncommitted changes in this repo unless they opt out)

### 2. Reset repository to `origin/master`

Always bring `$AI_TOOLS` exactly to **`origin/master` before** removing or re-linking, so destinations match the published skill set (names and paths can change between versions).

```bash
cd "$AI_TOOLS" || exit 1

# Show state before changing anything
git status -sb
git remote -v
git rev-parse --abbrev-ref HEAD
git log --oneline -3

# Surface local work that a hard reset will discard
if [ -n "$(git status --porcelain)" ]; then
  echo "WARN: local changes in $AI_TOOLS will be discarded by reset to origin/master"
  git status --short
fi
# Also warn if HEAD is not already master or has local commits ahead of origin
git fetch origin

if ! git show-ref --verify --quiet refs/remotes/origin/master; then
  echo "ERROR: origin/master not found after fetch — fix remote and retry"
  git branch -r
  exit 1
fi

# Record previous tip for the summary below
PREV=$(git rev-parse HEAD)

# Required for reinstall/update: match remote master exactly
git checkout master
git reset --hard origin/master
# Optional: drop untracked files left from experiments (only if user wants a fully clean tree)
# git clean -fd
```

Notes:

- **`git fetch origin` + `git checkout master` + `git reset --hard origin/master`** is the default update path for this repo.
- This is **destructive** inside `$AI_TOOLS` only: it discards local commits on `master`, uncommitted edits, and leaves you on `master` at the same commit as `origin/master`. It does **not** touch other harness config outside this directory.
- If the user has **uncommitted or local-only work they care about**, stop, show `git status` / `git log`, and get explicit approval before `reset --hard` (or help them branch/stash first).
- If the default branch is ever renamed (e.g. `main`), use that name instead of `master` only when the user or remote confirms it; until then prefer `origin/master`.
- **Skip this reset only** if the user explicitly asks for re-link only with no git update (still verify `AGENTS.md` and `skills/` exist). Do not skip by default.

After a successful reset, list what will be reinstalled from:

```bash
echo "HEAD: $(git rev-parse --short HEAD) (was $(git rev-parse --short "$PREV" 2>/dev/null || echo unknown))"
git status -sb
ls -1 "$AI_TOOLS/skills"
git log --oneline -5
```

### 3. Remove first (same safety as Removal)

Reuse the `safe_unlink` helper from [Removal](#removal). Clean only the harnesses in scope:

```bash
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools \
            plan dev az gh gc; do
  safe_unlink "$HOME/.claude/skills/$name"   # if Claude in scope
  safe_unlink "$HOME/.grok/skills/$name"     # if Grok in scope
  safe_unlink "$HOME/.cursor/skills/$name"   # if Cursor in scope
done

# If reinstalling instructions too:
# safe_unlink "$HOME/.claude/CLAUDE.md"
```

Removing after the reset avoids stale names (e.g. old `plan` next to new `plan-ai-tools`) and broken symlinks after directory renames introduced by the update.

### 4. Install again

Run the [Installation](#installation) link steps for the same harnesses (discovery optional if scope was already confirmed):

1. `safe_link` helper (Installation section 3)
2. Global instructions if requested (section 4)
3. Skills with **only** names present under `$AI_TOOLS/skills/` that end in `-ai-tools` (section 5) — prefer listing the directory after pull over a hard-coded list if they may have changed
4. Agents only if definitions exist under `$AI_TOOLS/agents/` (section 6)

```bash
# Skills reinstall from the updated tree (example: Claude + Grok)
# Prefer dynamic list after reset to origin/master:
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  safe_link "$path" "$HOME/.claude/skills/$name"
  safe_link "$path" "$HOME/.grok/skills/$name"
done

# Or fixed list when the set is known:
# for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools; do
#   safe_link "$AI_TOOLS/skills/$name" "$HOME/.claude/skills/$name"
#   safe_link "$AI_TOOLS/skills/$name" "$HOME/.grok/skills/$name"
# done

# Instructions (if requested)
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.claude/CLAUDE.md"
```

`safe_link` remains non-destructive: if a destination exists and is **not** already the correct ai-tools link, **skip and report** — do not overwrite unless the user approved replace for that path.

### 5. Verify update + reinstall

```bash
# Source tree must be master == origin/master
echo "HEAD: $(git -C "$AI_TOOLS" rev-parse --short HEAD) ($(git -C "$AI_TOOLS" rev-parse --abbrev-ref HEAD))"
git -C "$AI_TOOLS" status -sb
git -C "$AI_TOOLS" rev-parse HEAD
git -C "$AI_TOOLS" rev-parse origin/master
# Expect: same SHA, branch master, clean working tree

# Skills present and linked
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  test -f "$path/SKILL.md" && echo "source ok: $name"
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
    [ -L "$root/$name" ] || continue
    echo "link ok: $root/$name -> $(readlink "$root/$name")"
  done
done

# No legacy bare skill names should remain as ai-tools links
for name in plan dev az gh gc; do
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
    [ -L "$root/$name" ] && echo "WARN legacy link still present: $root/$name"
  done
done
```

Restart or reload the harness. Confirm slash commands for every skill under `$AI_TOOLS/skills/*-ai-tools` (e.g. `/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, `/gc-ai-tools`).

### 6. When update / reinstall is not enough

- **Local changes the user wants to keep:** do not `reset --hard` until they stash, branch, or approve discard.
- **`origin/master` missing / fetch failed:** fix remote auth or URL; do not invent a remote.
- **No git remote / not a clone:** user must set `remote` or re-clone; do not invent a URL.
- **Wrong `$AI_TOOLS` path:** fix the env / clone location, remove links that pointed at the old path, then run this section again.
- **Harness caches skills:** fully restart the CLI/IDE after re-linking.
- **User wants replace of a non-ai-tools file:** require explicit per-path approval; default remains skip and report.

## Warning

**Do not replace** existing configuration, skills, agents, or instruction files at the destination unless the owner of this repository (the human user) explicitly asks for a replace. Default behavior is **skip and report**. Silent overwrite is a bug.

## License / ownership

Personal configuration repository for multi-tool AI workflows. Adjust paths if you host a clone elsewhere; keep `$AI_TOOLS` consistent in install, removal, and reinstall/update steps.
