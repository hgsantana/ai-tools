# ai-tools

> **Version 0.0.3-ALPHA** — under active development. Usable for testing; no guarantees, and no backward compatibility between alpha versions (rule 4).

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
| [`agents/maintainer-ai-tools.md`](agents/maintainer-ai-tools.md) | Agent base: maintains the installation — drives the [scripts](#scripts) for this README's [Update](#update), [Removal](#removal), or [Reinstallation](#reinstallation) process on request, returning destructive flags for per-action approval. Never the first install — that is this README's own bootstrap, before the agent exists |
| [`agents/<harness>/`](agents/) | Per-harness wrappers for the seven agents — harness-specific syntax, the pinned model, the category → model mapping for subagents, and a pointer to the base file; nothing else |
| [`skills/`](skills/) | Nine dispatch skills: one same-named per agent, except `maintainer-ai-tools`, which ships three task skills (`update-ai-tools`, `remove-ai-tools`, `reinstall-ai-tools`). Each surfaces the agent's stake, spawns it, and relays approvals, questions, and results between agent and user. A skill must run on **any** model; anything model-dependent ships as an agent instead (rules 7–9) |
| [`scripts/`](scripts/) | Executable maintenance procedures: `install`, `remove`, `update`, `reinstall`, `verify`, as shell and PowerShell scripts plus CMD shims — see [Scripts](#scripts) (rules 23–26) |

### How to install, remove, update, or reinstall

Run the matching script — the same command whether a human or an AI executes it ([Scripts](#scripts)):

```bash
# Linux, macOS, WSL, Git Bash — Windows: scripts/powershell/*.ps1 or scripts/cmd/*.cmd
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first install only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

Replace `install` with `remove`, `update`, `reinstall`, or `verify`; every script takes `--dry-run` and `--help`. Or open your preferred harness and instruct it:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

The AI follows the matching process section of this file — which has it run the same script.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the single source of truth for this repository: its explanation, its rules, and its processes — installation, removal, update, and reinstallation — whose executable form is the scripts under `scripts/` (rules 23–26).
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
11. Vendor model names appear only in agent wrappers, in the [category → model authoring reference](#category--model-authoring-reference), and in the scripts' Grok model pinning, which encodes that reference where Grok reads models from config instead of wrappers (see [Installation](#installation)). Agent base files speak only in categories: **planner**, **implementer**, **mechanical** (defined in `USER-AGENTS.md`); skills cite neither models nor categories (rule 8).
12. Wrappers and the authoring reference must always match: creating an agent or updating a model changes the table, every affected wrapper, and the scripts' Grok pinning in the same commit.
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

### Script contract

23. Every process — install, remove, update, reinstall, verify — ships as an executable script: `scripts/shell/<process>.sh` (Linux, macOS, WSL, Git Bash; bash 3.2+, BSD/GNU tools) and `scripts/powershell/<process>.ps1` (Windows PowerShell 5.1+ and pwsh); `scripts/cmd/<process>.cmd` are shims that only delegate to the PowerShell scripts. Shared logic lives in `lib.sh`/`lib.ps1`, never duplicated across scripts.
24. `scripts/shell` is canonical. A behaviour change lands there, in the PowerShell mirror, and in the process sections below in the same commit — none may drift.
25. Scripts run to completion: per-item conflicts skip and report instead of aborting; destructive steps sit behind explicit flags (`--discard-local`, `--instructions`, `--purge`) and default to refusing; every mutating script supports `--dry-run`. Exit codes: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
26. Shell and PowerShell scripts are committed with the executable bit set; `.gitattributes` pins them to LF and the CMD shims to CRLF.

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

Notes: Gemini's Pro line is frozen at 3.1 while Flash has moved to 3.7, so planner and implementer come from different generations. Antigravity's `model:` accepts only tiers (`inherit`, `flash`, `pro`), not model IDs — `pro` is its strongest tier and there is no cheaper-than-`flash` tier, so mechanical also runs `flash`. Grok Build ignores `model:` in agent frontmatter — the install script pins its models in `~/.grok/config.toml` (see [Installation](#installation)).

Every shipped agent runs as **planner** — except `maintainer-ai-tools`, which runs as **implementer** (it drives this README's scripts) — so each wrapper pins its own category's column for its harness. The wrapper body carries exactly two things (rule 6), in this order — the canonical form, below the harness's own frontmatter/TOML header:

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

## Scripts

Every process below is an executable script — the same command whether a human or an AI runs it. All scripts are idempotent, keep going on per-item conflicts (skip and report), and honour the [Safety rules](#safety-rules) by construction.

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |
| Windows — PowerShell 5.1+ or pwsh | [`scripts/powershell/`](scripts/powershell/) | `& "$env:USERPROFILE\.ai-tools\scripts\powershell\<process>.ps1" [flags]` |
| Windows — CMD | [`scripts/cmd/`](scripts/cmd/) | `%USERPROFILE%\.ai-tools\scripts\cmd\<process>.cmd [flags]` — delegates to the PowerShell script |

Processes: `install`, `remove`, `update`, `reinstall`, and the read-only `verify`. `--help` (shell) or the header comment (PowerShell) documents each script's flags; PowerShell spells a flag `-LikeThis` (`--dry-run` → `-DryRun`).

Behaviour contract, all scripts:

- **Scope** — `--harnesses <list>` restricts the target harnesses (comma-separated folder names under `agents/`); the default is every detected harness. An AI running a mutating script asks the user for scope first and passes the flag.
- **Dry run** — `--dry-run` reports every action without changing anything: the findings/approval report for unattended runs.
- **Destructive steps only behind explicit flags** — `--discard-local` (reset discarding local work in the clone), `--instructions` (unlink global instructions on removal), `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Exit codes** — `0` clean; `2` finished with `WARN` lines to review; `1` aborted on a precondition, nothing else touched.
- **Symlink fallback** — where the OS refuses symlinks (Windows without Developer Mode or elevation, mounts without symlink support), agents and skills install as copies, reported as `copied (will not track updates)`; global instructions are never copied — the script asks for an include pointer instead, so this repo stays the single source of truth.

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), [Update](#update), and [Reinstallation](#reinstallation), on top of the [Installation contract](#installation-contract) rules 17–22:

- **Never replace** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip it, report it, and continue** (rules 18, 20). Silent overwrite is a bug; a destination that is already the correct link is left alone.
- **Never** `rm -rf` a harness agents or skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source — a locally modified copy is user work and is skipped, not deleted (rule 19).
- Never touch vendor bundles such as `~/.grok/bundled/`, unrelated user agents or skills, a repository's own `AGENTS.md` describing that application's architecture, or `$HOME/AGENTS.md` (rule 22).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before running a mutating script; the scripts themselves default to every detected harness.

These semantics are implemented once — `safe_link`, `link_or_copy`, `safe_unlink`, `safe_uninstall_copy` in [`scripts/shell/lib.sh`](scripts/shell/lib.sh), mirrored in [`scripts/powershell/lib.ps1`](scripts/powershell/lib.ps1). The scripts refuse the unsafe path automatically; manual intervention must honour the same rules.

## Supported harnesses

Reference for every process section. One row per harness: where its global instructions, skills, and agents live, which wrapper folder serves it, and the agent file form its wrapper uses.

| Harness | Global instructions destination | Skills root | Agents root | Wrapper folder · agent file form |
|---|---|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` | `$HOME/.claude/agents/` | `agents/claude-code/` · `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/full ID/`inherit`) |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` | `$HOME/.grok/agents/` | `agents/grok/` · `*.md`; **no `model:` in frontmatter** — models pinned in `~/.grok/config.toml` (see [Installation](#installation)) |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` | `$HOME/.codex/agents/` | `agents/codex/` · `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` | `$HOME/.copilot/agents/` | `agents/copilot/` · `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` (shared with Gemini CLI) | `$HOME/.gemini/config/skills/` | `$HOME/.gemini/config/agents/` | `agents/antigravity/` · `*.md`, frontmatter `name`, `description`, `model` (`inherit`/`flash`/`pro`), `subagent`, `mainAgent`, `commandExecutionPolicy` |
| Cursor | Not linked — no documented file path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` | `$HOME/.cursor/agents/` | `agents/cursor/` · `*.md`, `model:` accepts bracketed parameters (`claude-opus-5[effort=high]`) |
| Gemini CLI | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/skills/` (**not** `$HOME/.gemini/config/skills/`) | `$HOME/.gemini/agents/` | `agents/gemini/` · `*.md`, frontmatter `kind`, `model`, `temperature`, `max_turns`, `timeout_mins` |

Notes:

- **Antigravity and Gemini CLI share `$HOME/.gemini`** but not the same roots: one `GEMINI.md` link serves both, while skills and agents install into `config/skills/`/`config/agents/` for Antigravity and `skills/`/`agents/` for Gemini CLI — the scripts install into each selected harness's own roots.
- **Antigravity limits rules files to 12,000 characters each** — currently the tightest instructions-file constraint among supported harnesses, so it caps `USER-AGENTS.md` (rule 3); over it, the file is truncated or rejected there.
- **Codex**: reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope.
- **Never link into `$HOME/.agents/`.** It is a live shared discovery root read by several harnesses — linking there as well as into each harness's own root would double-register every agent.
- When a harness cannot use a symlink for instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

## Installation

Run the `install` script ([Scripts](#scripts)):

```bash
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first machine only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

What it does, in order — every step idempotent, conflicts skipped and reported:

1. **Preconditions** — clones to `$HOME/.ai-tools` when missing and validates the tree (rule 21; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery** — reports each detected harness (config directory, CLI, or known IDE extension) plus possible AI extensions it will never touch; `$HOME/.agents` is only reported, never linked into.
3. **Instructions** — links `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; one `GEMINI.md` link serves Gemini CLI and Antigravity; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **User overlay** — creates `$HOME/AGENTS.md` empty only when missing (rule 22); its contents are written only if the user later asks for that directly.
5. **Agents** — links each wrapper file from `agents/<harness>/` into that harness's agents root, per file, never per directory — the roots hold agents from other sources, and a directory link would shadow them.
6. **Skills** — links each `skills/*-ai-tools` directory into each scoped skills root; the same shared directory serves every harness (rules 7–9). Prefer these explicit links over harness scan paths (Grok `[skills] paths`), which can clobber existing names.
7. **Grok model pinning** — Grok resolves subagent models from `~/.grok/config.toml`, not from agent frontmatter, so the script maintains a marker-delimited `[subagents.models]` block there: names from the tree, models from the [authoring reference](#category--model-authoring-reference). A pre-existing unmanaged block is skipped and reported, never edited. Without pinning the agents still load but inherit the session's model — the strong-model guarantee is lost; the same fallback applies to any harness whose `model:` field is ignored.
8. **Verify** — instructions resolve into the clone, `USER-AGENTS.md` fits the 12,000-character cap (rule 3), every agent base exists at the pinned location, and every installed agent and skill is a link or an unmodified copy. Skipped under `--dry-run`; re-run standalone any time with `verify`.

Then restart or reload any harness that caches agents or skills at startup, and confirm the seven agents (`vibe-ai-tools`, `planner-ai-tools`, `orchestrator-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`, `maintainer-ai-tools`) appear in the harness's agent list, plus a slash command for every shipped skill.

## Removal

Removal means "unlink from harnesses", not "delete the config repo" — leaving `$HOME/.ai-tools` on disk is normal and makes [Update](#update) a reset plus re-link. Run the `remove` script ([Scripts](#scripts)):

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # unlink agents and skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

What it does, in order:

1. **Report** — lists every ai-tools link, possible copy, and instructions link in the scoped roots before touching anything.
2. **Agents and skills** — mirror of Installation: links are unlinked; copies are removed only while their contents still match their source — a locally modified copy is user work, skipped and kept (rule 19).
3. **Grok** — deletes only the marker-delimited ai-tools block in `~/.grok/config.toml`; an unmanaged `[subagents.models]` is left untouched, and the file is never removed.
4. **Stale-link sweep** — removes anything in the scoped roots still resolving into the clone, whatever its name or era: alpha keeps no backward compatibility (rule 4), and the sweep is what cleans older layouts. `--no-sweep` skips it.
5. **Instructions** — only with `--instructions`, and only destinations that are ai-tools links; `GEMINI.md` is kept while the other of Gemini CLI/Antigravity remains out of scope; an include pointer is edited out manually, never the file deleted. **Never `$HOME/AGENTS.md`** (rule 22).
6. **Verify** — reports any ai-tools link still present in the scoped roots; expected none.
7. **Purge** — only with `--purge` (confirmation prompted; `--yes` skips the prompt): deletes `$HOME/.ai-tools` itself. Never includes `$HOME/AGENTS.md`.

If `$AI_TOOLS/skills` was ever added to a harness scan path (Grok `[skills] paths`), remove only that entry, manually — never wipe the config file. After removal, restart the harness: the agents disappear from its list, and the skill slash commands from its menu.

## Update

Brings the clone to `origin/master` — the canonical source — and re-synchronizes what is installed. Symlinks track the new content automatically; copies do not, and are refreshed here. Run the `update` script ([Scripts](#scripts)):

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

What it does, in order:

1. **Preconditions** — requires the clone at `$HOME/.ai-tools`; a missing clone means [Installation](#installation) instead.
2. **Reset** — fetches and resets to `origin/master`. When local commits or uncommitted edits would be discarded, it prints them and stops until re-run with `--discard-local` — never silently; `--no-reset` re-synchronizes from the current tree instead. Destructive **inside the clone only**: harness config and `$HOME/AGENTS.md` are never touched by the reset.
3. **Refresh copies** — a copy matching the pre-reset revision is stale, not user work: replaced. One matching neither revision was modified locally: skipped and kept (rule 19).
4. **Link anything newly shipped** — re-runs the idempotent install steps for the scoped harnesses: existing installs untouched, new agents or skills added, `$HOME/AGENTS.md` created only if missing.
5. **Verify** — the Installation checks.

Use [Reinstallation](#reinstallation) instead when the install is broken, comes from an older alpha layout, or the set of harnesses changed. If the default branch is ever renamed (for example `main`), the scripts follow only once the user or remote confirms it — never a guessed branch.

## Reinstallation

A full removal + installation pass against a fresh `origin/master`, for when [Update](#update) is not enough: a broken or partial install, stale names or layouts from an older alpha version, dangling links after upstream renames, or a change in which harnesses are wired. A link is never upgraded in place — re-creating it is the fix. Run the `reinstall` script ([Scripts](#scripts)):

```bash
"$HOME/.ai-tools/scripts/shell/reinstall.sh"
```

What it does, in order:

1. **Source first** — clones if missing, otherwise resets to `origin/master` (same `--discard-local` guard as Update), **before** removing or re-linking, so destinations match the published agent set — names and paths can change between versions.
2. **Remove** — agents, skills, the Grok block, the stale-link sweep (`--no-sweep` skips), and the instructions links (`--no-instructions` keeps them). Unmodified copies are dropped; modified copies are skipped and reported.
3. **Install** — the Installation steps against the fresh tree, listing agents and skills from the tree itself, never from hardcoded names.
4. **Verify** — the Installation checks, plus no stale links left behind.

Then restart or reload the harness and confirm the seven agents appear in its agent list, plus a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user must set a remote or re-clone from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there. It is the only supported location (rule 21); the wrappers hardcode that path, so no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then re-check with `verify`.
- **Dangling links after an upstream rename or layout change:** run [Reinstallation](#reinstallation); links are never upgraded in place.
- **Copied agents out of date:** copies do not track `git pull` — run [Update](#update); if a copy predates the locally known previous revision, run [Reinstallation](#reinstallation).
- **A destination is occupied by a non-ai-tools file the user wants replaced:** the scripts always skip and report it; replacing it requires the user removing that file themselves, per path.
- **An agent runs on the wrong (weak) model:** the wrapper's model pinning is not applied — for Grok, check the managed `[subagents.models]` block in `~/.grok/config.toml` (re-run [Installation](#installation) to restore it); for other harnesses, compare the installed wrapper against `$AI_TOOLS/agents/<harness>/` and the [authoring reference](#category--model-authoring-reference).
- **Scripts report `copied (will not track updates)`:** the OS or filesystem refused symlinks (on Windows, enable Developer Mode or use an elevated shell, then [Reinstallation](#reinstallation) converts copies back to links); until then, run [Update](#update) after every upstream change on that machine.
