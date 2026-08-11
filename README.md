# ai-tools

## Introduction

A **harness-agnostic** home for shared AI coding configuration: one global `AGENTS.md` plus the skills `/plan-ai-tools`, `/dev-ai-tools`, `/az-ai-tools`, `/gh-ai-tools`, and `/gc-ai-tools`. It lives at `~/.config/ai-tools/` and is linked into whichever AI CLIs or IDEs you use (Claude Code, Grok, Cursor, and similar).

Goals:

- One global `AGENTS.md` built on **agent categories** (`planner`, `implementer`, `mechanical`), so any model can map roles without hard-coded vendor model names
- Skills that behave the same across tools: multi-file plans, token-efficient stage execution, safe cloud and GitHub CLIs
- Install by **symlinks**, never by forked copies that drift

**Naming rule:** everything installed from this repo — skill directory, frontmatter `name:`, slash command, and any future agent — ends in `-ai-tools`, so nothing collides with harness-bundled names. Never install a bare name like `plan` or `dev`.

**No shipped agents:** this repo has no agent definition files, only the empty `agents/` directory. Harnesses map the three categories with their own subagent mechanisms. Do not create stubs unless the user asks.

## Contents

| Path | Description |
|------|-------------|
| [`AGENTS.md`](AGENTS.md) | Global instructions: agent categories, the change flow, interaction and output discipline, CLI skill pointers, security defaults |
| [`skills/plan-ai-tools/`](skills/plan-ai-tools/) | `/plan-ai-tools` — explore, then write a **base plan** plus **one file per stage** under `plans/`; stops without implementing |
| [`skills/dev-ai-tools/`](skills/dev-ai-tools/) | `/dev-ai-tools` — run the plan queue or ad-hoc work unattended; **implementer** codes, **planner** validates; status table (`W`/`V`/`R`/`T`/`TV`/`E`/`F`); stage context isolation |
| [`skills/az-ai-tools/`](skills/az-ai-tools/) | `/az-ai-tools` — Azure CLI: read freely, mutate only with explicit per-action approval, surface cost |
| [`skills/gh-ai-tools/`](skills/gh-ai-tools/) | `/gh-ai-tools` — GitHub CLI: read freely, mutate only with explicit per-action approval |
| [`skills/gc-ai-tools/`](skills/gc-ai-tools/) | `/gc-ai-tools` — Google Cloud CLI: read freely, mutate only with explicit per-action approval, surface cost |
| `agents/` | Reserved and empty — see the naming and no-shipped-agents rules above |

### Agent categories

| Category | Role |
|----------|------|
| **planner** | Plan, orchestrate, validate, escalate |
| **implementer** | Write and edit code for one specified stage or brief |
| **mechanical** | Fully specified low-ambiguity work and evidence gathering |

### Change flow

`/plan-ai-tools` iterates a plan with the user and saves it. Accepting the plan is the **only** approval point: from there `/dev-ai-tools` runs to completion unattended, recording detail in the plan files and reporting a short summary at the end. A direct `/plan-ai-tools` invocation always stops at the saved plan and never implements.

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
- **Never** `rm -rf` a harness skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`.
- Never touch vendor bundles such as `~/.grok/bundled/`, unrelated user skills, or a repository's own `AGENTS.md` describing that application's architecture.
- Ask which harnesses are in scope before changing anything, and report findings first.

Helpers used by every section below:

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"

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

The repository is cloned at `~/.config/ai-tools`, or another path the user names. `$AI_TOOLS` defaults to `~/.config/ai-tools`; expand `~` to the current user's real home.

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"
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
test -d "$HOME/.agents" && echo "found: $HOME/.agents"
```

Check project-local harness directories only when the user asked to wire projects:

```bash
find "$HOME/projetos" -maxdepth 3 \( -name '.claude' -o -name '.grok' -o -name '.cursor' \) 2>/dev/null
```

### 2. Ask which targets to install

Present the discovery list and let the user choose. Do not install into every tool by default when the user only uses one.

### 3. Install global instructions

Link `AGENTS.md` to each selected harness's user-wide instruction file.

| Harness | Typical destination | Notes |
|---------|---------------------|-------|
| Claude Code | `$HOME/.claude/CLAUDE.md` | Claude loads the user `CLAUDE.md` |
| Grok | User-wide agents file when supported, otherwise project `AGENTS.md` | Alternatively add `$AI_TOOLS` to the tool's config paths and ensure sessions read `$AI_TOOLS/AGENTS.md` |
| Cursor | User rules / `AGENTS.md` location for the installed version | Confirm the current path before linking |
| Generic | Point the tool at `$AI_TOOLS/AGENTS.md` | This file is the source of truth |

```bash
safe_link "$AI_TOOLS/AGENTS.md" "$HOME/.claude/CLAUDE.md"
```

When a harness cannot use a symlink for instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

### 4. Install skills

Link each skill directory into the harness user skills root: `plan-ai-tools`, `dev-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`.

| Harness | User skills root |
|---------|------------------|
| Claude Code | `$HOME/.claude/skills/` |
| Grok | `$HOME/.grok/skills/` |
| Cursor | `$HOME/.cursor/skills/` (when skills are enabled) |

```bash
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  safe_link "$path" "$HOME/.claude/skills/$name"   # if Claude selected
  safe_link "$path" "$HOME/.grok/skills/$name"     # if Grok selected
done
```

If Grok is configured with `[skills] paths`, adding `$AI_TOOLS/skills` as a scan path is an option, but only when it cannot clobber existing names. Prefer explicit per-skill links.

### 5. Verify

```bash
readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null
ls -la "$HOME/.claude/skills" "$HOME/.grok/skills" 2>/dev/null

for path in "$AI_TOOLS/skills"/*-ai-tools; do
  test -f "$path/SKILL.md" && echo "skill ok: $(basename "$path")"
done
```

Restart or reload any harness that caches skills at startup, then confirm the five slash commands appear in the menu.

## Removal

Removal means "unlink from harnesses", not "delete the config repo". Leaving `$AI_TOOLS` on disk is normal and makes [Reinstallation / Update](#reinstallation--update) a pull plus re-link.

### 1. Discover what is linked from ai-tools

Report findings; remove nothing until the user confirms the targets.

```bash
for root in "$HOME/.claude/skills" "$HOME/.grok/skills" "$HOME/.cursor/skills" \
            "$HOME/.claude/agents" "$HOME/.grok/agents"; do
  [ -d "$root" ] || continue
  echo "=== $root ==="
  find "$root" -maxdepth 1 -type l -print 2>/dev/null | while read -r p; do
    t=$(readlink "$p")
    case "$t" in *ai-tools*|"$AI_TOOLS"/*) echo "linked: $p -> $t" ;; esac
  done
done

if [ -L "$HOME/.claude/CLAUDE.md" ]; then
  echo "instructions: $HOME/.claude/CLAUDE.md -> $(readlink "$HOME/.claude/CLAUDE.md")"
fi
```

Note any legacy bare names (`plan`, `dev`, `az`, `gh`, `gc`) still pointing at `$AI_TOOLS`.

### 2. Remove skills

```bash
for name in plan-ai-tools dev-ai-tools az-ai-tools gh-ai-tools gc-ai-tools \
            plan dev az gh gc; do   # legacy bare names included
  safe_unlink "$HOME/.claude/skills/$name"   # if Claude selected
  safe_unlink "$HOME/.grok/skills/$name"     # if Grok selected
  safe_unlink "$HOME/.cursor/skills/$name"   # if Cursor selected
done
```

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove **only that entry** when asked — never wipe the config file.

### 3. Remove agents, if any were linked

```bash
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

### 4. Remove the global instructions link, optional

Only when the user wants the harness to stop loading this repo's `AGENTS.md`:

```bash
safe_unlink "$HOME/.claude/CLAUDE.md"
# Other harnesses: unlink only destinations created as links into $AI_TOOLS/AGENTS.md
```

If the instructions file is an include pointer rather than a symlink, edit out that one line instead of deleting the file.

### 5. Verify removal

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

Expected: no links into `$AI_TOOLS` for the cleaned harnesses. Restart the harness; the slash commands should disappear.

### 6. Remove the repository clone, optional

Only when the user explicitly asks to delete the config tree itself:

```bash
# Confirm the path first — destructive
# rm -rf "$AI_TOOLS"
```

## Reinstallation / Update

Use this when the user asks to **update**, **reinstall**, or **refresh** ai-tools. Typical triggers: new skills or renames landed upstream, a partial or broken install, legacy names (`plan` instead of `plan-ai-tools`), or a change in which harnesses are wired.

One process covers every case: **update the source** to `origin/master`, then **re-wire harnesses** by removing stale ai-tools links and installing again from that tree. `origin/master` is the canonical source — never reinstall from a dirty tree, a feature branch, or a local-only commit unless the user explicitly overrides that.

### 0. Preconditions

```bash
export AI_TOOLS="${AI_TOOLS:-$HOME/.config/ai-tools}"
test -d "$AI_TOOLS/.git" && test -f "$AI_TOOLS/AGENTS.md" && test -d "$AI_TOOLS/skills"
```

If `$AI_TOOLS` is missing, stop and offer a fresh [Installation](#installation), cloning first. Never invent skills that are not in the tree.

### 1. Ask scope

1. Which harnesses to reinstall
2. Whether to refresh **instructions** as well as skills
3. Whether to clean **legacy** bare names from older installs
4. That the update **resets `$AI_TOOLS` to `origin/master`**, discarding local commits and uncommitted changes in this repo unless they opt out

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

- This is destructive **inside `$AI_TOOLS` only**: it discards local commits on `master` and uncommitted edits. It never touches harness config outside this directory.
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

Run the [Installation](#installation) link steps for the same harnesses — discovery is optional when scope was already confirmed. Prefer listing `$AI_TOOLS/skills/*-ai-tools` after the reset over a hard-coded list, since the set may have changed. `safe_link` stays non-destructive: an existing destination that is not already the correct link is skipped and reported.

### 5. Verify update and reinstall

```bash
# Source tree must be master == origin/master, clean
git -C "$AI_TOOLS" status -sb
git -C "$AI_TOOLS" rev-parse HEAD origin/master   # expect the same SHA twice

# Skills present and linked
for path in "$AI_TOOLS/skills"/*-ai-tools; do
  [ -d "$path" ] || continue
  name=$(basename "$path")
  test -f "$path/SKILL.md" && echo "source ok: $name"
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
    [ -L "$root/$name" ] && echo "link ok: $root/$name -> $(readlink "$root/$name")"
  done
done

# No legacy bare names should remain
for name in plan dev az gh gc; do
  for root in "$HOME/.claude/skills" "$HOME/.grok/skills"; do
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

Personal configuration repository for multi-tool AI workflows. If you host a clone elsewhere, adjust the paths and keep `$AI_TOOLS` consistent across installation, removal, and update.
