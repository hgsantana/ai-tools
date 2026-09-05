# ai-tools

> **Version 0.0.47-ALPHA** — under active development. Suitable for testing; alpha versions provide neither guarantees nor backward compatibility (rule 4).

## Overview

A toolkit of **skills**, **three harness-agnostic agents**, and **user-wide instructions** for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, and Cursor.

This repository is the source of those tools. It is installed on the user's machine at `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows). Installation copies artifacts into each harness's user configuration.

How it operates:

1. **A harness toolkit.** Skills, agent bases, wrappers, and `USER-AGENTS.md` are what the supported harnesses load after install.
2. **Machine-local install.** `$HOME/.ai-tools` is the only supported clone. Wrappers hardcode that path.
3. **User-wide instructions.** [`USER-AGENTS.md`](USER-AGENTS.md) is copied as the global instructions file for every supported harness that has a destination. After install it is the user-wide routing file; it is not this repository's rule file (rule 2). Cursor has no documented destination.
4. **Session-first with model-tiered workers.** The three agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`) are model-tiered workers. Skills provide session-directed workflows in semantic XML. The host session orchestrates execution, interacts with the user, and coordinates git delivery, delegating compute-heavy or specialized tasks to model-tiered workers via explicit dispatch templates.
5. **Frontmatter only in the host session.** Harnesses keep skill `name` and `description` in the skill list without loading the body. The host session offers skills from that in-memory description and does not read the skill file. The spawned agent reads the Workflow.

[`MODELS.csv`](MODELS.csv) is a CSV of model and effort pins. Authoring, installation, and lint read it; harnesses never load it. This README defines the CSV and how to fill it at [Model selection and wrapper authoring](#model-selection-and-wrapper-authoring).

### Contents

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | User-wide routing after install: skill-offer gate, spawn rules, language, and security. Copied to each harness's global instructions destination. Workflows live in skills and agent bases |
| [`MODELS.csv`](MODELS.csv) | CSV of per-harness model and effort pins. Not copied into harnesses; wrappers and install-time config carry the pins |
| [`docs/USAGE.md`](docs/USAGE.md) | Harness-agnostic invocation guide for every shipped skill and the three spawn-only agents |
| [`agents/planner-ai-tools.md`](agents/planner-ai-tools.md) | `planner-ai-tools` — decomposes, designs, owns acceptance, and delegates production code. Contains type rules; the brief defines the job |
| [`agents/implementer-ai-tools.md`](agents/implementer-ai-tools.md) | `implementer-ai-tools` — writes and edits code for one assignment. Type rules only; the brief is the job |
| [`agents/mechanical-ai-tools.md`](agents/mechanical-ai-tools.md) | `mechanical-ai-tools` — executes specified patches and renames, runs builds and tests, and collects evidence. Contains type rules; the brief defines the job |
| [`agents/SUBAGENT-CONTRACT.md`](agents/SUBAGENT-CONTRACT.md) | Shared spawned-subagent contract: brief, user channel, report, model pin, spawning, and type boundaries. Not installed; read by path |
| [`agents/<harness>/`](agents/) | One wrapper per agent: header pin, contract pointer, base pointer |
| [`skills/`](skills/) | Ten skills, each `skills/<name>/SKILL.md` with semantic XML body. Harnesses list frontmatter; the session executes the workflow and dispatches workers via templates |
| [`scripts/`](scripts/) | `scripts/shell/` install processes ([Scripts](#scripts); rules 25–28); `lint.sh`, `test.sh`, `harness-models.sh`, `aa-metrics.sh` ([Development checks](#development-checks)). Windows: WSL or Git Bash |

### Quick start

Humans and AIs use the same commands ([Scripts](#scripts)):

```bash
# Linux, macOS, WSL, Git Bash (Windows: WSL or Git Bash — no PowerShell)
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# zsh:
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-zsh.sh | zsh
```

After the clone exists, `"$HOME/.ai-tools/scripts/shell/update.sh"` refreshes it. `remove.sh` and `verify.sh` take `--dry-run` and `--help`. Or, in a harness:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

The AI follows the matching process section below and runs that same script.

After installation, see the harness-agnostic [usage guide](docs/USAGE.md) for skill prompts and agent names.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the repository's source of truth for its explanation, rules, and installation, removal, and update processes. `scripts/` provides their executable form (rules 25–28).
2. For work in this repository, this README takes precedence over user-wide and harness-global instructions, including an installed `USER-AGENTS.md`.
3. `USER-AGENTS.md` is an installation artifact for user-wide harness instructions, not this repository's rule file. Its self-imposed **6,000-character** cap is tighter than every current harness constraint, including Antigravity's 12,000-character limit. Every shipped artifact fits the strictest harness that consumes it. Register stricter constraints in [Supported harnesses](#supported-harnesses) and update affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top) versions provide no backward compatibility or migration notes; this README describes only the current state. Repair older layouts through [Update](#update) and its stale-link sweep. Change the version only in the commit or merge that lands the change on `master`. Backward-compatibility records begin with the first stable release.

### Structure and authoring

5. Three agents ship: `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools`. Each has a request-agnostic, harness-agnostic **base** at `agents/<name>.md` and one **wrapper** per harness at `agents/<harness-short-name>/<agent-name>.<ext>`. Bases are **mode-agnostic**: they identify required questions or approvals, while `agents/SUBAGENT-CONTRACT.md` defines the spawned user channel. Type rules prevail over a conflicting brief. Bases route delegated work; the contract governs further spawning (rule 8). An agent serves as a model-tiered worker when spawned with a `<template>` payload.
6. A wrapper consists of a harness-specific header and model pin (`model:`, plus effort when the CSV effort cell is non-empty and the wrapper form can hold it), followed by pointers to `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md` and `$HOME/.ai-tools/agents/<name>.md`, in that order. The base prevails except for the contract's user channel. Additional body text is drift. The **1,000-character** cap includes frontmatter. See the canonical body in [wrapper authoring](#model-selection-and-wrapper-authoring).
7. Skills are harness-agnostic and live entirely in `skills/<name>/SKILL.md`, with frontmatter defined by rule 9 and bodies structured in semantic XML tags (`<skill>`, `<session_workflow>`, `<dispatch_templates>`). They use no per-harness copies, separate skill contracts or bases, root-level `skills/<name>.md`, `SKILL-CONTRACT.md`, or `MAINTAINER.md`; required maintainer text is duplicated. Descriptions contain three parts and at most 500 characters (rule 9); bodies have no character cap but follow rule 15. Skills contain neither **Stake** nor **Continue?** headings. Harnesses retain frontmatter without loading the body. `USER-AGENTS.md` offers skills from that in-memory description (the only USER-AGENTS.md gate); the host session executes the `<session_workflow>` and, on delegated steps, spawns the model-tiered worker named in `Agent:` passing the `<template>` payload from `<dispatch_templates>`. `gh-ai-tools` covers GitHub-hosted resources and administration; repository code work such as commits, branches, rebases, merges, pushes, code review, and pull-request delivery bypasses it and runs directly.
8. **Spawning is open**: every session, skill, and agent may spawn the named agent that owns the work; spawned agents may do the same (`agents/SUBAGENT-CONTRACT.md`). If spawning fails, the run carries work allowed by its type or returns a dispatch request. Code-writing agents run concurrently on separate files; read-only discovery, builds, and tests may always run in parallel. Wrappers pin models for `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools`.
9. Skill frontmatter uses universally accepted `name` and `description`, plus optional keys supported by every harness, such as `argument-hint`. The `description`, which harnesses retain without loading the body, states in order: (1) what the skill does and when to use it, including `/name`; (2) `Impact:` plus what can be billed, deleted, committed, pushed, or otherwise changed—or that impact is absent; (3) `Agent:` with `planner-ai-tools`, `implementer-ai-tools`, or `mechanical-ai-tools`. Keep it within **500 characters** because harnesses budget the skill list: Codex caps it at 2% of context or 8,000 characters, and Claude Code truncates it at 1,536.
10. Wrappers follow each harness's official documentation and individual frontmatter standards. Re-check vendor docs before adding a harness or editing a wrapper — formats change upstream. During wrapper authoring or compilation, standard templates in `templates/wrappers/` must be followed per harness: Grok requires double-quoting strings with colons (`"..."`) due to its strict Rust `serde_yaml` parser; Codex requires standard TOML quoting; other harnesses follow their native format.
11. Vendor model names live in the [`MODELS.csv`](MODELS.csv) and wrapper headers only. Dispatch uses the named agent's already-pinned wrapper. Installation reads the CSV to pin Grok's `[subagents.models]` block; `scripts/lint.sh` reads it during authoring. [Supported harnesses](#supported-harnesses) may show accepted value *shapes*, never the choice. Bases cite **planner** / **implementer** / **mechanical** as types. Spawn calls and skills use agent names.
12. The `MODELS.csv` and wrapper **headers** match in the same commit (new agent, new harness, or model change). Wrapper bodies name neither a row nor a model. Fill each cell by the [selection method](#choosing-the-models) — never memory or unsourced claims.
13. Antigravity's wrapper `model:` is a **subagent tier** (`inherit`/`flash`/`pro`), not a model family name — pin the CSV cell. Accepted shapes live in [Supported harnesses](#supported-harnesses).
14. Every installed agent name, skill directory, slash command, frontmatter `name:`, and file basename ends in `-ai-tools`; bare names such as `planner` and `az` remain uninstalled.
15. Use extreme concision: remove ambiguity and redundancy while preserving every instruction, rule, and intention.
16. Skills, agent bases, contracts, and `USER-AGENTS.md` state what to do. A negative (`never`, `do not`) is used only when it reinforces an essential positive, or when the positive phrasing would lose force or not make sense.
17. Repository files use concise English; chat uses the user's language. Rule 32 assigns content between them.
18. A skill that can be **destructive** or **generate cost** states that impact once in its `description` `Impact:` (rule 9), rather than in a body Stake section. `USER-AGENTS.md` surfaces it **before** execution. Whoever dispatches an agent also surfaces any opening stake disclaimer from its base (`agents/SUBAGENT-CONTRACT.md`).

### Installation contract

19. Install global instructions, agent wrappers, and skill directories as **physical copies**. Never create an installation symlink; migrate a legacy symlink resolving into `$HOME/.ai-tools` to a copy.
20. Never overwrite a conflicting or locally modified destination by default. `--overwrite` explicitly replaces installed artifact paths for the selected harnesses; it never applies to `$HOME/AGENTS.md` or unrelated harness configuration.
21. Never remove anything ai-tools did not create. Removal drops only legacy ai-tools links and copies that still match their source. `--force` also drops those same known artifact destinations when contents differ; it never applies to `$HOME/AGENTS.md` or unrelated harness configuration.
22. Every install/remove/update step is idempotent; on conflict, skip and report unless the user passed the process's explicit replacement or forced-removal flag.
23. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Wrappers hardcode it; any other path breaks them.
24. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: if present, follow it; if missing, ignore it. It is never created, edited, overwritten, truncated, symlinked, or removed.

### Script contract

25. Each process—install, remove, update, and verify—is `scripts/shell/<process>.sh` for Linux, macOS, WSL, and Git Bash, using bash 3.2+ and BSD/GNU tools. Shared logic lives once in `lib.sh`. First-install bootstrap scripts `install-bash.sh` and `install-zsh.sh` are self-contained (no `lib.sh`): they clone `$HOME/.ai-tools` then exec `install.sh`. Windows uses WSL or Git Bash rather than PowerShell or CMD mirrors.
26. `scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.
27. Scripts run to completion: per-item conflicts skip and report. Destructive steps are refused by default and require explicit flags (`--overwrite`, `--discard-local`, `--instructions`, `--force`, `--purge`). Every mutating script supports `--dry-run`. Exit: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
28. Shell scripts are committed executable; `.gitattributes` pins them to LF.

### Work state and reporting

29. Version work under `dev/` as a plan directory `dev/<slug>/`, a single-task file `dev/<slug>.md`, or a campaign directory `dev/improve/<campaign>/`. All are temporary working state and remain only while work is resumable. Comprehension documents and decisions stay tracked in Git during active work and are archived by copying into `dev/tmp/finished/` and applying `git rm` to the tracked original in the final commit, preserving the full rationale on the branch while keeping the repository root clean after merge. Generated state and volatile runtime caches live untracked under `dev/tmp/`.
30. `plan-ai-tools` records the named branch it analyzes as the plan's base, requests the host harness's best planning capability or mode, and aligns scope and trade-offs interactively with the user. It saves the agreed result under `dev/<slug>/` in the repository's plan structure: a base file (`0-<slug>.md`) and sequential stage files (`<n>-<slug>.md`). Each stage is isolated and corresponds to one commit boundary. A change small enough for a single commit is not planned: it belongs to `dev-ai-tools` Task mode.
31. `dev-ai-tools` runs both forms through one sequence: read the working repository's documentation, record the unit of work on disk, implement in short steps with one commit each, write and run behaviour tests before closing a step, update any documentation the step made stale, archive by copy-then-remove, and commit the archival last. Task mode records the current branch when the user requests the task, then iterates with the user before writing `dev/<slug>.md`; from there both modes run unattended, interrupting only for a blocker, a decision uncovered by implementation, or an approval reserved by the Security rules. The dedicated work branch starts from the recorded base branch, and the pull request targets that same branch: the analysis branch in Plan mode or the request-time branch in Task mode. The branch history is symmetric: the first commit introduces the plan or task file, and the last removes it. `improve-ai-tools` repeatedly invokes this sequence in campaign mode under user-defined priorities: a fresh planner writes each user-directed multi-stage plan, a different fresh planner executes and judges it, and accepted commits accumulate locally on `improve/<campaign>` without a push or pull request.
32. **Substance is written to disk; the session carries questions and pointers.** Plans, tasks, and campaigns go where rule 29 puts them. Every report, summary, finding, log, and other transient artifact goes under `dev/tmp/`, created if absent; outside a Git repository, use `$HOME/.ai-tools-plans/tmp/`. `dev/tmp/` is generated state and stays untracked wherever it is created (rule 29): add the ignore rule when the repository lacks it. What reaches the user is the question that needs an answer, the approval that needs a yes, a one-line outcome, and the paths of what was written. Where the harness can open a file in the user's editor, open it rather than pasting its content. Restating on screen what already sits on disk spends the user's context twice and creates a second, diverging copy of the truth. This binds every skill, every agent base, and `USER-AGENTS.md`.

### Model selection and wrapper authoring

[`MODELS.csv`](MODELS.csv) is the authoring and installation lookup: a CSV, one row per harness. Harnesses do not load it; wrappers and install-time config carry the pins. Installation reads it to write Grok's managed `[subagents.models]` block (unreadable CSV → skip and report, never guess). `scripts/lint.sh` checks every wrapper pin against it. Fill and refresh it using the [`/models-ai-tools`](skills/models-ai-tools/SKILL.md) skill. The CSV evaluates model potential rather than a frozen stack.

Family, version, and any official effort come from the harness's official **pricing/models** table for individual plans on that agent surface. Measurements come from [Artificial Analysis (AA)](https://artificialanalysis.ai/) **model** pages: Intelligence Index, Cost per Task, and Time per Task for the model itself. Cost always means AA Cost per Task. Fetch inputs with [`scripts/harness-models.sh`](scripts/harness-models.sh) and [`scripts/aa-metrics.sh`](scripts/aa-metrics.sh), which write CSVs under `dev/tmp/`.

#### MODELS.csv format

CSV text in `MODELS.csv`. Header plus one data row per `agents/<harness>/` directory. Values contain no commas; spaces in a model token are allowed. Empty effort cells mean the wrapper pins the model token only.

```text
harness,planner,planner_effort,implementer,implementer_effort,mechanical,mechanical_effort
```

| Column | Used at install / lint |
|---|---|
| `harness` | Row key; matches `agents/<harness>/` |
| `planner`, `implementer`, `mechanical` | Accepted model token (`model:` in the wrapper; Grok `[subagents.models]`) |
| `planner_effort`, `implementer_effort`, `mechanical_effort` | Official effort token when the family is effort-comparable and the wrapper form can hold it; otherwise empty |

How to change the **session** model lives in [Supported harnesses](#supported-harnesses), not in this CSV.

Wrappers always pin the model token and pin effort only when the matching effort column is non-empty **and** the wrapper form can hold it (`effort:` Claude Code, `model_reasoning_effort` Codex, `[effort=…]` Cursor).

#### Refreshing the models

Run `/models-ai-tools` to rebuild and refresh `MODELS.csv` and keep wrapper headers synchronized. The full reproducible selection methodology, evaluation metrics, thresholds, and fallback rules live in [`skills/models-ai-tools/SKILL.md`](skills/models-ai-tools/SKILL.md). Inputs are gathered via [`scripts/harness-models.sh`](scripts/harness-models.sh) and [`scripts/aa-metrics.sh`](scripts/aa-metrics.sh). The skill displays the proposed table and reports diffs before writing, and updates `MODELS.csv` and affected wrapper headers in the same commit (rule 12).

Pin the role the base names (`You are the **planner** / **implementer** / **mechanical**`) from the `MODELS.csv` in the header. Body (rule 6):

```markdown
On Windows, %USERPROFILE% replaces $HOME.

You are a spawned subagent: your shared contract is `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`.
Read it and follow it — it governs your channel to the user and your report.

Your base file is `$HOME/.ai-tools/agents/<name>.md`.
Read it and follow it in full — it is the absolute rule set for this agent; the contract above prevails only on your channel to the user.
```

Codex carries the same text in `developer_instructions`, with Windows backslashes doubled for TOML.

#### Wrapper templates and frontmatter standards

Canonical templates for creating or compiling wrappers live under `templates/wrappers/` (`claude-code.md`, `grok.md`, `codex.toml`, `copilot.agent.md`, `antigravity.md`, `cursor.md`), accompanied by `templates/wrappers/README.md`. When authoring or compiling wrappers:

- **Harness-specific frontmatter standards**:
  - `grok`: Strict YAML. `description` must be double-quoted (`"..."`) when containing `: ` because Grok's Rust `serde_yaml` parser rejects unquoted scalars with colons. Keys: `name`, `description`, `mcpInheritance: all`. Grok ignores frontmatter `model:`; model pinning is written to `~/.grok/config.toml` under `[subagents.models]` at install time.
  - `codex`: Strict TOML format (`*.toml`). All string values must be quoted. Keys: `name = "..."`, `description = "..."`, `model = "..."`, optional `model_reasoning_effort = "..."`, with prompt body in `developer_instructions = """..."""`.
  - `claude-code`: Markdown YAML frontmatter with `name`, `description`, `model`, optional `effort` (when non-empty in `MODELS.csv`).
  - `copilot`: Extension `*.agent.md` with keys `name`, `description`, `model` (single string scalar, e.g. `"Grok 4.6"`).
  - `antigravity`: Markdown YAML frontmatter with keys `name`, `description`, `model` (tier token: `inherit`, `flash`, or `pro`).
  - `cursor`: Markdown YAML frontmatter with keys `name`, `description`, `model`, `readonly: false`, `is_background: false`.

A skill carries frontmatter (rule 9) and a semantic XML body (`<skill>`, `<session_workflow>`, `<dispatch_templates>`). The host session executes the workflow, conducts user alignment and git delivery, and delegates compute tasks to the model-tiered worker named in `Agent:` passing the `<template>` payload. `USER-AGENTS.md` offers from the in-memory description (the gate). Point at `agents/<name>.md` only as a worker base, never as a skill base. On Windows, `%USERPROFILE%` replaces `$HOME`.

## Scripts

Every process below is an executable script shared by humans and AIs. Each is idempotent, handles conflicts per item by skipping and reporting, and enforces the [Safety rules](#safety-rules).

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |

Processes: `install-bash` / `install-zsh` (first clone), `install`, `remove`, `update`, and read-only `verify`. `--help` lists flags. On Windows, run those same scripts from WSL or Git Bash.

On top of rules 25–27:

- **Scope** — `--harnesses <list>` accepts comma- or space-separated folder names under `agents/`. Omit the flag to select detected harnesses; pass `--harnesses all` to select all six supported harnesses, including those not detected yet. An AI running a mutating script asks for scope first and passes the explicit answer.
- **Dry run** — `--dry-run` reports every proposed action while preserving state; it supplies the findings and approval report for unattended runs.
- **Destructive flags** — `--overwrite` on install and update (replace conflicting artifact destinations and prune orphan `*-ai-tools` artifacts in the selected harnesses), `--discard-local` (reset discarding local work in the clone), `--instructions` (remove global instructions on removal), `--force` (remove known artifact destinations and orphan artifacts even when contents no longer match), and `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Physical copies** — instructions, agents, and skills are always copied. Update removes current-version artifacts, then installs from `origin/master`; `--overwrite` is required for conflicting or locally modified installed artifacts.

## Development checks

Development checks live under `scripts/` beside `scripts/shell/` (rules 25–27). [`scripts/lint.sh`](scripts/lint.sh) is a development check, not an installation process: it enforces this repository's mechanically verifiable rules against the tree it runs in, with no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`. Run it from anywhere:

```bash
"$HOME/.ai-tools/scripts/lint.sh"              # check the working tree
"$HOME/.ai-tools/scripts/lint.sh" --base <ref> # also check the version bump against <ref>
```

Check families:

- **wrapper coverage** — every agent has exactly one wrapper per harness, no orphans (rule 5)
- **naming** — agent bases, wrappers, skill directories, and frontmatter `name:` all end in `-ai-tools` (rule 14)
- **skill frontmatter** — every `skills/*/SKILL.md` exists, keys a subset of `name`/`description`/`argument-hint`, and `name:` matches its directory (rule 9)
- **skill description** — every skill `description` is at most 500 characters and states what it does, then `Impact:`, then a valid `Agent:` (rule 9)
- **skill layout** — no `skills/*.md` at the skills root; every `skills/*-ai-tools/SKILL.md` exists; no `SKILL.md` contains `## Continue?` or `## Stake`; `USER-AGENTS.md` contains `## How to route a request`; no `SKILL.md` mentions `SKILL-CONTRACT` or `MAINTAINER.md` (rule 7)
- **wrapper body** — the body is reconstructed from this README's canonical text and compared exactly (rule 6)
- **model parity and effort pinning** — every pinned model and effort resolves through the `MODELS.csv` (rules 11–12); Grok wrappers declare no model
- **description parity** — an agent's `description` is identical across all six wrappers
- **model row coverage** — every harness directory has a `MODELS.csv` row and vice versa (rule 12)
- **size caps** — `USER-AGENTS.md` at most 6,000 characters (rule 3), every wrapper at most 1,000 (rule 6), every skill `description` at most 500 (rule 9)
- **encodings and endings** — line endings (`git ls-files --eol`), executable bits, no binaries in shipped paths (rule 28)
- **`dev/tmp` untracked** — `git ls-files dev/tmp` returns nothing (rule 29)
- **version bump** — only with `--base <ref>`: a change under `agents/`, `skills/`, `scripts/`, `USER-AGENTS.md`, or `MODELS.csv` that lands on `master` requires the README version to change too (rule 4)

Exit codes: `0` clean, `1` aborted on a precondition (unknown flag, `--base` without a value), `2` finished with findings. CI (`.github/workflows/ci.yml`) runs two jobs on `ubuntu-latest`: `lint` runs the version-bump check on pull requests and `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` on every push and pull request; `test-shell` runs `scripts/test.sh`.

When a rule in this README becomes mechanically verifiable, add its check to `scripts/lint.sh` and its rule number to the list above in the same commit — the two caps above (rules 3, 6) are stated here as rules; the linter only enforces them, and this README is the number a reader trusts.

`scripts/test.sh` is likewise a development check outside rules 25–27: it runs `install`, `remove`, `update`, and `verify` against a disposable fake `HOME`, never the real one, and asserts the installation and script contract (rules 19–27). Run it from anywhere:

```bash
"$HOME/.ai-tools/scripts/test.sh"                    # run every case
"$HOME/.ai-tools/scripts/test.sh" --case install --keep   # one case file, keep the sandbox
```

The fixture stages, before any script runs: a pre-populated harness layout for all six harnesses, a local `origin` git remote so no run reaches the network, a foreign file on a destination path, a locally modified copy, an unmanaged Grok block, and a stale link from an older layout. Against it, the suites assert:

- physical copies only, including migration from legacy ai-tools symlinks (rule 19)
- no overwrite by default and selected-harness overwrite with the explicit flag (rule 20)
- never remove what ai-tools did not create (rule 21)
- idempotency and skip-and-report on conflict (rule 22)
- `$HOME/AGENTS.md` untouched (rule 24)
- destructive flags default to refuse, `--dry-run` changes nothing (rule 27)
- exit codes `0`/`1`/`2` (rule 27)

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), and [Update](#update), on top of rules 19–24:

- **Never replace by default** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 20, 22). `--overwrite` is the only authorization to replace those exact artifact destinations and prune orphan `*-ai-tools` artifacts in selected harnesses. A matching copy is left alone.
- **Never** recursively remove a harness's agents or skills root; replace or remove individual artifact paths only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 21). `--force` is the only authorization to remove those exact artifact destinations and orphan artifacts when contents differ. `$HOME/AGENTS.md` remains untouched.
- Never touch vendor bundles (`~/.grok/bundled/`), unrelated user agents or skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/AGENTS.md` (rule 24).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

The safe-copy, legacy-link-removal, and copy-removal primitives are implemented once in [`scripts/shell/lib.sh`](scripts/shell/lib.sh). Scripts refuse unsafe paths; manual intervention must honour the same rules.

## Supported harnesses

One row per harness: global instructions, skills, agents, wrapper folder, and wrapper file form.

| Harness | Global instructions destination | Skills root | Agents root | Wrapper folder · agent file form |
|---|---|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` | `$HOME/.claude/agents/` | `agents/claude-code/` · `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/`fable`/full ID/`inherit`) |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` | `$HOME/.grok/agents/` | `agents/grok/` · `*.md`; **no `model:` in frontmatter** — models pinned in `~/.grok/config.toml` (see [Installation](#installation)) |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` | `$HOME/.codex/agents/` | `agents/codex/` · `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` | `$HOME/.copilot/agents/` | `agents/copilot/` · `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/config/skills/` | `$HOME/.gemini/config/agents/` | `agents/antigravity/` · `*.md`, frontmatter `name`, `description`, `model` (`inherit`/`flash`/`pro`), `subagent`, `mainAgent`, `commandExecutionPolicy` |
| Cursor | Not copied — no documented path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` | `$HOME/.cursor/agents/` | `agents/cursor/` · `*.md`, `model:` accepts bracketed parameters (`<model>[effort=high]`) |

Change the session model (not the wrapper pin):

| Harness | How |
|---|---|
| Claude Code | `/model` in the session |
| Grok Build | `/model` in the session; `[models] default` in `~/.grok/config.toml` |
| OpenAI Codex | `/model` in the session; `--model` at launch |
| GitHub Copilot | `/model` in the session |
| Google Antigravity | model selector in the Agent panel |
| Cursor | model picker under the chat input |

Notes:

- **Antigravity lives under `$HOME/.gemini`**: instructions at `GEMINI.md`, skills and agents at `config/skills/` and `config/agents/`. Do not install into `$HOME/.gemini/skills/` or `$HOME/.gemini/agents/` (retired Gemini CLI roots). The stale-link sweep unlinks leftover ai-tools links there without touching `config/`.
- **Antigravity limits rules files to 12,000 characters.** The repository's stricter self-imposed 6,000-character cap governs `USER-AGENTS.md` (rule 3); Antigravity truncates or rejects files above its own limit.
- **Codex** reads `~/.codex/AGENTS.override.md` first if it exists; otherwise, it reads `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope.
- **Never install into `$HOME/.agents/`.** Several harnesses discover it; copying there as well as into each harness root would double-register every agent.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# zsh:
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-zsh.sh | zsh
```

The bootstrap script is self-contained: it requires `git`, clones `https://github.com/hgsantana/ai-tools.git` to `$HOME/.ai-tools` when that path is free, then execs `install.sh`. If the clone already exists, it prints the `update.sh` command and exits without changing anything. Extra flags after `| bash -s --` reach `install.sh`.

Every `install.sh` step is idempotent and reports conflicts it skips.

1. **Preconditions** — the clone at `$HOME/.ai-tools` exists and validates (rule 23; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery and scope** — report each detected harness from its configuration directory, CLI, or known IDE extension, plus possible AI extensions outside scope. Omitted `--harnesses` selects those detected harnesses; `--harnesses all` selects all six and creates their artifact roots as needed. Report `$HOME/.agents` while leaving it untouched.
3. **Instructions** — copy `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; Antigravity uses `$HOME/.gemini/GEMINI.md`; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **Agents** — copy each wrapper from `agents/<harness>/` into that harness's agents root, per file, never per directory — those roots hold agents from other sources.
5. **Skills** — recursively copy each `skills/*-ai-tools` directory into every scoped skills root (rules 7–9). The copy is for the dispatched agent; harnesses list frontmatter without the host session loading the body.
6. **Grok model pinning** — Grok ignores `model:` in frontmatter and reads `~/.grok/config.toml`. The script maintains a marker-delimited `[subagents.models]` block: names from the tree, models from the `MODELS.csv` (unreadable CSV → skip and report, never guess). A pre-existing unmanaged block is skipped and reported, never edited. Without the pin, agents still load but inherit the session model — the strong-model guarantee is lost. The same fallback applies to any harness that ignores `model:`.
7. **Verify** — every installed instruction, agent, and skill is a physical copy matching its source; `USER-AGENTS.md` fits the repository's 6,000-character cap (rule 3); `MODELS.csv`, `agents/SUBAGENT-CONTRACT.md`, every agent base, and every shipped `skills/<name>/SKILL.md` exist. Any installation symlink is a finding. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches agents or skills at startup. Confirm the three agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`) and a slash command for every shipped skill.

## Removal

Remove installed artifacts from harnesses while retaining the clone. Keeping `$HOME/.ai-tools` allows later installation or update.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # remove agents and skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --force   # also drop modified copies
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

1. **Report** — list every possible ai-tools artifact and legacy link in the scoped roots before changing them.
2. **Agents and skills** — remove copies only while their contents still match their source; also unlink legacy links resolving into ai-tools. A locally modified copy is user work: skip and keep (rule 21), unless `--force`.
3. **Grok** — delete only the marker-delimited ai-tools block in `~/.grok/config.toml`. Preserve unmanaged `[subagents.models]` content and the file itself.
4. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips it.
5. **Instructions** — only with `--instructions`; remove an exact source copy or a legacy ai-tools link, and preserve a modified or foreign destination unless `--force`. Never remove `$HOME/AGENTS.md` (rule 24).
6. **Verify** — report any known ai-tools artifact or legacy link still in the scoped roots; expect none except preserved modified or foreign paths (gone under `--force`).
7. **Purge** — with `--purge` only (prompt; `--yes` skips), delete `$HOME/.ai-tools` while always preserving `$HOME/AGENTS.md`.

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove only that entry, by hand — never wipe the config file. Restart the harness: agents leave its list, skill slash commands leave its menu.

## Update

Remove artifacts using the **current** clone (the user's version), reset that clone to `origin/master`, then install from the fresh tree.

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

1. **Preconditions** — require the clone at `$HOME/.ai-tools`; if missing, [Installation](#installation) instead. Fetch `origin/master` and refuse a discarding reset unless `--discard-local`, **before** touching harness artifacts.
2. **Remove** — using this clone's wrappers, skills, and instructions: agents, skills, the Grok block, the stale-link sweep (`--no-sweep` skips), and instructions (`--no-instructions` keeps them). Drop unmodified copies and legacy ai-tools links; skip and report modified copies.
3. **Reset** — check out `master` and reset `--hard` to `origin/master`. The destructive scope is **the clone only**; `$HOME/AGENTS.md` remains untouched.
4. **Install** — the Installation steps against the fresh tree, listing agents and skills from the tree, never from hardcoded names.
5. **Verify** — the Installation checks.

If the default branch is renamed (e.g. `main`), the scripts follow only after the user or remote confirms it — never a guessed branch.

Then restart or reload the harness and confirm the three agents and a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user sets a remote or re-clones from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there (rule 23). Wrappers hardcode that path; no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then `verify`.
- **Legacy or dangling ai-tools links:** [Update](#update) sweeps stale links after removing current-version artifacts.
- **Installed copies out of date:** copies do not track `git pull` — use [Update](#update).
- **A conflicting or locally modified installed artifact should be replaced:** rerun install or update with `--overwrite` and an explicit `--harnesses` scope. The flag affects only known artifact destinations in that scope.
- **A locally modified installed artifact should be removed:** rerun remove with `--force` and an explicit `--harnesses` scope. The flag affects only known artifact destinations in that scope; names no longer in the tree are not destinations.
- **An agent runs on the wrong (weak) model:** pinning is not applied. Grok: check the managed `[subagents.models]` block in `~/.grok/config.toml` (re-run [Installation](#installation) to restore it). Others: compare the installed wrapper to `$AI_TOOLS/agents/<harness>/` and the `MODELS.csv`.
- **A copied artifact was edited locally:** preserve the edit elsewhere before `--overwrite` or `--force`; installed copies are managed deployment artifacts, while `$HOME/AGENTS.md` remains the supported place for personal instructions.

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is retaining the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, dispatched work that can create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- Use the root `LICENSE` instead of per-file license headers in shipped artifacts. `USER-AGENTS.md` follows the **6,000-character** cap in rule 3, and every artifact follows rule 15. Installation on one's own machine is not redistribution.
