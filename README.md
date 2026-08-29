# ai-tools

> **Version 0.0.37-ALPHA** — under active development. Suitable for testing; alpha versions provide neither guarantees nor backward compatibility (rule 4).

## Overview

A shared toolkit of **skills**, **three agents**, and **instructions** for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, and Cursor.

Clone it to `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows), then copy its installed artifacts into each harness's user configuration. Skills are the entry points; three spawn-only agents perform the work. Wrappers pin models from [`MODELS.md`](MODELS.md) during authoring.

### Contents

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | Install artifact: user-wide harness instructions — routing (the one `*-ai-tools` gate), the three agents' roles, language, security. Workflows live in skill and agent bases, not here |
| [`MODELS.md`](MODELS.md) | Authoring and installation map: model per agent and harness. Vendor names live here and in wrapper headers (rules 11–12); updates reset local edits |
| [`agents/planner-ai-tools.md`](agents/planner-ai-tools.md) | `planner-ai-tools` — decomposes, designs, owns acceptance, and delegates production code. Contains type rules; the brief defines the job |
| [`agents/implementer-ai-tools.md`](agents/implementer-ai-tools.md) | `implementer-ai-tools` — writes and edits code for one assignment. Type rules only; the brief is the job |
| [`agents/mechanical-ai-tools.md`](agents/mechanical-ai-tools.md) | `mechanical-ai-tools` — executes specified patches, renames, builds, tests, and evidence collection. Contains type rules; the brief defines the job |
| [`agents/SUBAGENT-CONTRACT.md`](agents/SUBAGENT-CONTRACT.md) | Shared spawned-subagent contract: brief, user channel, report, model pin, spawning, and type boundaries. Not installed; read by path |
| [`agents/<harness>/`](agents/) | One wrapper per agent: header pin, contract pointer, base pointer |
| [`skills/`](skills/) | Nine skills, each the installed `skills/<name>/SKILL.md` (the whole skill). The three agents have no skill. `USER-AGENTS.md` routing gates every skill at its **Min. role**; naming a skill is the yes, then planner-min skills carry the planner role in the user's session |
| [`scripts/`](scripts/) | `install`, `remove`, `update`, `reinstall`, `verify` — bash ([Scripts](#scripts); rules 25–28). Windows: WSL or Git Bash |

### Quick start

Humans and AIs use the same commands ([Scripts](#scripts)):

```bash
# Linux, macOS, WSL, Git Bash (Windows: WSL or Git Bash — no PowerShell)
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first install only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

Replace `install` with `remove`, `update`, `reinstall`, or `verify`. Every script takes `--dry-run` and `--help`. Or, in a harness:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

The AI follows the matching process section below and runs that same script.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the repository's source of truth for its explanation, rules, and installation, removal, update, and reinstallation processes. `scripts/` provides their executable form (rules 25–28).
2. For work in this repository, this README takes precedence over user-wide and harness-global instructions, including an installed `USER-AGENTS.md`.
3. `USER-AGENTS.md` is an installation artifact for user-wide harness instructions, not this repository's rule file. Its self-imposed **8,000-character** cap is tighter than every current harness constraint, including Antigravity's 12,000-character limit. Every shipped artifact fits the strictest harness that consumes it. Register stricter constraints in [Supported harnesses](#supported-harnesses) and update affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top) versions provide no backward compatibility or migration notes; this README describes only the current state. Repair older layouts through [Reinstallation](#reinstallation) and its stale-link sweep. Change the version only in the commit or merge that lands the change on `master`. Backward-compatibility records begin with the first stable release.

### Structure and authoring

5. Three agents ship: `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools`. Each has a request-agnostic, harness-agnostic **base** at `agents/<name>.md` and one **wrapper** per harness at `agents/<harness-short-name>/<agent-name>.<ext>`. Bases are **mode-agnostic**: they identify required questions or approvals, while `agents/SUBAGENT-CONTRACT.md` defines the spawned user channel. Type rules prevail over a conflicting brief. Bases route delegated work; the contract governs further spawning (rule 8). Skills pass the complete **Workflow** and user request as the brief.
6. A wrapper consists of a harness-specific header and model pin (`model:`, plus effort when present in the map), followed by pointers to `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md` and `$HOME/.ai-tools/agents/<name>.md`, in that order. The base prevails except for the contract's user channel. Additional body text is drift. The **1,000-character** cap includes frontmatter. See the canonical body in [wrapper authoring](#model-map-and-wrapper-authoring).
7. Skills are harness-agnostic and live entirely in `skills/<name>/SKILL.md`, with rule 9 frontmatter. They use no per-harness copies, separate skill contracts or bases, root-level `skills/<name>.md`, `SKILL-CONTRACT.md`, or `MAINTAINER.md`; required maintainer text is duplicated. Descriptions have two parts and at most 500 characters (rule 9); bodies have no character cap but follow rule 15. Skills contain neither **Stake** nor **Continue?** headings. `USER-AGENTS.md` provides the sole activation gate: surface the named skill's `description` `Impact:` from memory; compare its **Min. role** cell and every higher-role cell to its left in this harness's `$HOME/.ai-tools/MODELS.md` row; then ask one question offering a skill, **run it here**, or **stop**. The gate applies only to shipped `*-ai-tools` skill activation.
8. **Spawning is open**: every session, skill, and agent may spawn the named agent that owns the work; spawned agents may do the same (`agents/SUBAGENT-CONTRACT.md`). If spawning fails, the run carries work allowed by its type or returns a dispatch request. Code-writing agents run concurrently on separate files; read-only discovery, builds, and tests may always run in parallel. Wrappers pin models for `planner-ai-tools`, `implementer-ai-tools`, and `mechanical-ai-tools`. `USER-AGENTS.md` gates every shipped skill: naming one authorizes its Workflow at the **Min. role**; planner-min skills carry `planner-ai-tools`. The user may proceed below the model minimum.
9. Skill frontmatter uses universally accepted `name` and `description`, plus optional keys supported by every harness, such as `argument-hint`. The `description`, which harnesses retain without loading the body, states in order: (1) what the skill does and when to use it, including `/name`; (2) `Impact:` plus what can be billed, deleted, committed, pushed, or otherwise changed—or that impact is absent. Keep it within **500 characters** because harnesses budget the skill list: Codex caps it at 2% of context or 8,000 characters, and Claude Code truncates it at 1,536.
10. Wrappers follow each harness's official documentation. Re-check vendor docs before adding a harness or editing a wrapper — formats change upstream.
11. Vendor model names live in [`MODELS.md`](MODELS.md) and wrapper headers only. Dispatch uses the named agent's already-pinned wrapper. Grok install and `tools/lint.sh` read the map at install / authoring. [Supported harnesses](#supported-harnesses) may show accepted value *shapes*, never the choice. Bases cite **planner** / **implementer** / **mechanical** as roles (`USER-AGENTS.md` → *The three agents*). Spawn and skills use agent names.
12. `MODELS.md` and wrapper **headers** match in the same commit (new agent, new harness, or model change). Wrapper bodies name neither a row nor a model. Fill each cell by the [selection method](#choosing-the-models) — never memory or unsourced claims.
13. Antigravity's wrapper `model:` is a **subagent tier** (`inherit`/`flash`/`pro`), not a model family name — pin the map cell. Accepted shapes live in [Supported harnesses](#supported-harnesses).
14. Every installed agent name, skill directory, slash command, frontmatter `name:`, and file basename ends in `-ai-tools`; bare names such as `planner` and `az` remain uninstalled.
15. Use extreme concision: remove ambiguity and redundancy while preserving every instruction, rule, and intention.
16. Skills, agent bases, contracts, and `USER-AGENTS.md` state what to do. A negative (`never`, `do not`) is used only when it reinforces an essential positive, or when the positive phrasing would lose force or not make sense.
17. Repository files use concise English; chat uses the user's language. Rule 32 assigns content between them.
18. A skill that can be **destructive** or **generate cost** states that once in its `description` `Impact:` (rule 9), rather than in a body Stake section. `USER-AGENTS.md` surfaces it **before** execution. Whoever dispatches an agent also surfaces any opening stake disclaimer from its base (`agents/SUBAGENT-CONTRACT.md`).

### Installation contract

19. Install global instructions, agent wrappers, and skill directories as **physical copies**. Never create an installation symlink; migrate a legacy symlink resolving into `$HOME/.ai-tools` to a copy.
20. Never overwrite a conflicting or locally modified destination by default. `--overwrite` explicitly replaces installed artifact paths for the selected harnesses; it never applies to `$HOME/AGENTS.md` or unrelated harness configuration.
21. Never remove anything ai-tools did not create. Removal drops only legacy ai-tools links and copies that still match their source.
22. Every install/remove/update/reinstall step is idempotent; on conflict, skip and report unless the user passed the process's explicit replacement flag.
23. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Wrappers hardcode it; any other path breaks them.
24. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: if present, follow it; if missing, ignore it. Never created, edited, overwritten, truncated, symlinked, or removed.

### Script contract

25. Each process—install, remove, update, reinstall, and verify—is `scripts/shell/<process>.sh` for Linux, macOS, WSL, and Git Bash, using bash 3.2+ and BSD/GNU tools. Shared logic lives once in `lib.sh`. Windows uses WSL or Git Bash rather than PowerShell or CMD mirrors.
26. `scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.
27. Scripts run to completion: per-item conflicts skip and report. Destructive steps need explicit flags (`--overwrite`, `--discard-local`, `--instructions`, `--purge`) and default to refuse. Every mutating script supports `--dry-run`. Exit: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
28. Shell scripts are committed executable; `.gitattributes` pins them to LF.

### Work state and reporting

29. Version work under `dev/` as either a plan directory `dev/<slug>/` or a single-task file `dev/<slug>.md`. Both are temporary working state and remain only while work is resumable. Generated state lives untracked under `dev/tmp/`. Because ignore rules do not untrack indexed paths, archive by copying into `dev/tmp/finished/` and then applying `git rm` to the tracked original, leaving a local untracked copy.
30. `plan-ai-tools` delegates plan design by requesting that the host harness use the best planning capability or mode it possesses. The resulting plan is saved strictly following the repository's plan structure under `dev/<slug>/`: a base file (`0-<slug>.md`) and sequential stage files (`<n>-<slug>.md`), structuring the delivery into isolated stages where each stage corresponds to one commit boundary. A change small enough for a single commit is not planned: it belongs to `dev-ai-tools` Task mode.
31. `dev-ai-tools` runs both forms through one sequence: read the working repository's documentation, fix the unit of work on disk, implement in short steps with one commit each, write and run behaviour tests before closing a step, update the documentation that step made stale, archive by copy-then-remove, and commit the archival last. Task mode iterates with the user before writing `dev/<slug>.md`; from there both modes run unattended, interrupting only for a blocker, a decision the implementation itself uncovered, or an approval the Security rules reserve. The branch history is symmetric: the first commit introduces the plan or task file, the last removes it.
32. **Substance is written to disk; the session carries questions and pointers.** Plans and tasks go where rule 29 puts them; every report, summary, finding, log, and other transient artifact goes under `dev/tmp/` — created if absent, and `$HOME/.ai-tools-plans/tmp/` outside a git repository. `dev/tmp/` is generated state and stays untracked wherever it is created (rule 29): add the ignore rule when the repository lacks it. What reaches the user is the question that needs an answer, the approval that needs a yes, a one-line outcome, and the paths of what was written. Where the harness can open a file in the user's editor, open it rather than pasting its content. Restating on screen what already sits on disk spends the user's context twice and creates a second, diverging copy of the truth. This binds every skill, every agent base, and `USER-AGENTS.md`.

### Model map and wrapper authoring

[`MODELS.md`](MODELS.md) is the authoring and installation lookup: one row per harness, one column per agent role, and the session-model change method. Family, version, and any official effort come from the harness's official **pricing/models** table for individual plans on that agent surface. Measurements come from [Artificial Analysis (AA)](https://artificialanalysis.ai/) **model** pages: Intelligence Index, Cost per Task, and Time per Task for the model itself. Cost always means AA Cost per Task. Fetch inputs with [`tools/harness-models.sh`](tools/harness-models.sh) and [`tools/aa-metrics.sh`](tools/aa-metrics.sh), which write CSVs under `dev/tmp/`. The map evaluates model potential rather than a frozen stack.

Wrappers pin the model token always, and pin effort only when the cell has an official effort **and** the wrapper form can hold it (`effort:` Claude Code, `model_reasoning_effort` Codex, `[effort=…]` Cursor).

#### Choosing the models

A map row is reproducible research. Re-run the method for every model release and record source URLs, retrieval date, and benchmark versions.

**Terms**

| Term | Meaning |
|---|---|
| **Family** | One official family + version from step 1 |
| **Official effort** | A level the harness's individual-plan pricing/models table names for that surface and model. If the table names none, the family has no official effort. A label that exists only on Artificial Analysis (reasoning, non-reasoning, Adaptive Reasoning) is not one |
| **Complete row** | An AA **model** row with independently finished numeric Intelligence Index, Cost per Task, and Time per Task > 0 — no `*`, no lab-claim stand-in |
| **Effort-comparable** | The family has a complete row for **two or more** official efforts. One complete official row, or none, is not comparable; a later rematch adds ` · effort` when more levels are measured |
| **Score** | `(Intelligence Index / Cost per Task) / Time per Task` — higher first |

1. **List names.** From the harness's official **pricing/models** table for **individual** plans on this exact agent surface, list every model named by the most permissive documented first-party individual plan. Collapse each family + version to one name by removing effort, Fast/standard, and other mode suffixes: `Grok 4.6 Fast` and `Grok 4.6 High` both become `Grok 4.6`. Record the accepted configuration value, underlying model, plan, surface, and every **official effort** token named for that model (`low`, `medium`, `high`, `xhigh`, `max`, or vendor equivalent). Record an empty effort when none is named. Exclude retired, utility, internal, arbitrary BYOK, and auto-routing models. Count an alias or tier only when official documentation resolves it to one family + version on the research date. Source names and effort exclusively from that harness table rather than a vendor API catalog, team/enterprise-only list, or Artificial Analysis.
2. **Join measurements.** Filter the AA catalog to the complete step-1 name list across all supported harnesses. Treat every AA **model** row for each remaining family + version, effort, and mode as a candidate. Record Intelligence Index, Cost per Task, and Time per Task in one table per harness. Use model-level measurements rather than harness-stack scores such as Coding Agent Index. Show gaps as `N/A` and exclude `*` estimates and lab claims from selection. Use AA Cost per Task rather than per-token or subscription prices, and calculate with downloadable source precision.
3. **Select.** Keep candidates with complete Intelligence Index, Cost per Task, and Time per Task values; do not impute. Thresholds are inclusive and selection is per harness. When the harness names no official effort for a family, collapse that family's complete rows **before** filtering into one candidate using the unweighted mean of all three metrics; name it only by family + version. Filter and rank the resulting candidates by score, then break ties by lower Cost per Task and lower Time per Task.
   - **planner** — keep Intelligence Index ≥ that harness's best − `3`, then rank.
   - **implementer** — keep Intelligence Index ≥ that harness's best − `10`. Drop any survivor whose family + version is the planner's. Keep Cost per Task **strictly less** than the planner's. Then rank.
   - **mechanical** — keep Cost per Task between that harness's minimum and `3 ×` that minimum. Drop any survivor whose family + version is the planner's or the implementer's. Keep Cost per Task **strictly less** than the implementer's (and thus than the planner's). Then rank. An empty band after those cuts is a fallback — do not reopen the planner or implementer family.
4. **Fallback—when measurement cannot decide** because step 3 yields an empty band, no complete candidate, or a final Cost per Task and Time per Task tie. Use the harness's official task guidance: deep reasoning, architecture, and ambiguity for **planner**; agentic software development, implementation, and tool use for **implementer**; simple, repetitive, routine, fast, or cost-sensitive work for **mechanical**. Cite it and label `documented fallback`. If guidance names **one** model, use that token and any effort it also names. Otherwise—including Auto/routing or multiple names without a winner—**repeat the previous category's cell**: implementer copies planner; mechanical copies implementer. Never invent a quantitative winner.
5. **Write.** Put each winner in the map as the accepted model token. Append ` · effort` only when the family is effort-comparable **and** official docs list a token that matches the selected row (or the documented-fallback effort the guidance named), in the vendor's spelling. Otherwise the model token alone. A measured winner may not be `N/A`. Same commit (rule 12): update every affected wrapper — model token always; effort **only** if the cell has ` · effort` **and** the wrapper form can pin it. Map shape: one row per harness; column 1 is the backticked key matching `agents/<harness>/`; scripts take the first backtick-quoted token as the model. A new harness adds that row, its wrapper folder, and [Supported harnesses](#supported-harnesses) in the same commit.

Pin the role the base names (`You are the **planner** / **implementer** / **mechanical**`) from `MODELS.md` in the header. Body (rule 6):

```markdown
On Windows, %USERPROFILE% replaces $HOME.

You are a spawned subagent: your shared contract is `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`.
Read it and follow it — it governs your channel to the user and your report.

Your base file is `$HOME/.ai-tools/agents/<name>.md`.
Read it and follow it in full — it is the absolute rule set for this agent; the contract above prevails only on your channel to the user.
```

Codex carries the same text in `developer_instructions`, with Windows backslashes doubled for TOML.

A skill carries frontmatter (rule 9), H1, one-sentence scope, then Workflow. `USER-AGENTS.md` routing surfaces the `description` `Impact:` from memory before the question. Point at `agents/<name>.md` only as the planner base a planner-min yes loads, never as a skill base. On Windows, `%USERPROFILE%` replaces `$HOME`.

## Scripts

Every process below is an executable script shared by humans and AIs. Each is idempotent, handles conflicts per item by skipping and reporting, and enforces the [Safety rules](#safety-rules).

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |

Processes: `install`, `remove`, `update`, `reinstall`, and read-only `verify`. `--help` lists flags. On Windows, run those same scripts from WSL or Git Bash.

On top of rules 25–27:

- **Scope** — `--harnesses <list>` accepts comma- or space-separated folder names under `agents/`. Omit the flag to select detected harnesses; pass `--harnesses all` to select all six supported harnesses, including those not detected yet. An AI running a mutating script asks for scope first and passes the explicit answer.
- **Dry run** — `--dry-run` reports every proposed action while preserving state; it supplies the findings and approval report for unattended runs.
- **Destructive flags** — `--overwrite` on install, update, and reinstall (replace conflicting artifact destinations in the selected harnesses), `--discard-local` (reset discarding local work in the clone), `--instructions` (remove global instructions on removal), and `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Physical copies** — instructions, agents, and skills are always copied. Update refreshes copies that still match the previous source revision; `--overwrite` is required for conflicting or locally modified installed artifacts.

## Development checks

`tools/` holds development tooling — `scripts/` remains exactly the five installation processes (rules 25–27). [`tools/lint.sh`](tools/lint.sh) is a development check, not an installation process: it enforces this repository's mechanically verifiable rules against the tree it runs in, with no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`. Run it from anywhere:

```bash
"$HOME/.ai-tools/tools/lint.sh"              # check the working tree
"$HOME/.ai-tools/tools/lint.sh" --base <ref> # also check the version bump against <ref>
```

Check families:

- **wrapper coverage** — every agent has exactly one wrapper per harness, no orphans (rule 5)
- **naming** — agent bases, wrappers, skill directories, and frontmatter `name:` all end in `-ai-tools` (rule 14)
- **skill frontmatter** — every `skills/*/SKILL.md` exists, keys a subset of `name`/`description`/`argument-hint`, and `name:` matches its directory (rule 9)
- **skill description** — every skill `description` is at most 500 characters and states what the skill does, then `Impact:` plus the Stake (rule 9)
- **skill layout** — no `skills/*.md` at the skills root; every `skills/*-ai-tools/SKILL.md` exists; no `SKILL.md` contains `## Continue?` or `## Stake`; `USER-AGENTS.md` contains `## How to route a request`; no `SKILL.md` mentions `SKILL-CONTRACT` or `MAINTAINER.md` (rule 7)
- **wrapper body** — the body is reconstructed from this README's canonical text and compared exactly (rule 6)
- **model parity and effort pinning** — every pinned model and effort resolves through `MODELS.md` (rules 11–12); Grok wrappers declare no model
- **description parity** — an agent's `description` is identical across all six wrappers
- **`MODELS.md` row coverage** — every harness directory has a row and vice versa (rule 12)
- **size caps** — `USER-AGENTS.md` at most 8,000 characters (rule 3), every wrapper at most 1,000 (rule 6), every skill `description` at most 500 (rule 9)
- **encodings and endings** — line endings (`git ls-files --eol`), executable bits, no binaries in shipped paths (rule 28)
- **`dev/tmp` untracked** — `git ls-files dev/tmp` returns nothing (rule 29)
- **version bump** — only with `--base <ref>`: a change under `agents/`, `skills/`, `scripts/`, or `USER-AGENTS.md` that lands on `master` requires the README version to change too (rule 4)

Exit codes: `0` clean, `1` aborted on a precondition (unknown flag, `--base` without a value), `2` finished with findings. CI (`.github/workflows/ci.yml`) runs two jobs on `ubuntu-latest`: `lint` runs the version-bump check on pull requests and `shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh` on every push and pull request; `test-shell` runs `tools/test.sh`.

When a rule in this README becomes mechanically verifiable, add its check to `tools/lint.sh` and its rule number to the list above in the same commit — the two caps above (rules 3, 6) are stated here as rules; the linter only enforces them, and this README is the number a reader trusts.

`tools/test.sh` is a development check too, and outside rules 25–27 the same way: it runs `install`, `remove`, `update`, `reinstall`, and `verify` against a disposable fake `HOME`, never the real one, and asserts the installation and script contract (rules 19–27). Run it from anywhere:

```bash
"$HOME/.ai-tools/tools/test.sh"                    # run every case
"$HOME/.ai-tools/tools/test.sh" --case install --keep   # one case file, keep the sandbox
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

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), [Update](#update), and [Reinstallation](#reinstallation), on top of rules 19–24:

- **Never replace by default** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 20, 22). `--overwrite` is the only authorization to replace those exact artifact destinations in selected harnesses. A matching copy is left alone.
- **Never** recursively remove a harness agents or skills root; replace or remove individual artifact paths only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 21).
- Never touch vendor bundles (`~/.grok/bundled/`), unrelated user agents or skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/AGENTS.md` (rule 24).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

Implemented once — the safe copy, legacy-link removal, and exact-copy removal primitives in [`scripts/shell/lib.sh`](scripts/shell/lib.sh). Scripts refuse the unsafe path; manual intervention must honour the same rules.

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

Notes:

- **Antigravity lives under `$HOME/.gemini`**: instructions at `GEMINI.md`, skills and agents at `config/skills/` and `config/agents/`. Do not install into `$HOME/.gemini/skills/` or `$HOME/.gemini/agents/` (retired Gemini CLI roots). The stale-link sweep unlinks leftover ai-tools links there without touching `config/`.
- **Antigravity limits rules files to 12,000 characters.** The repository's stricter self-imposed 8,000-character cap governs `USER-AGENTS.md` (rule 3); Antigravity truncates or rejects files above its own limit.
- **Codex** reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — user-authored, out of scope.
- **Never install into `$HOME/.agents/`.** Several harnesses discover it; copying there as well as into each harness root would double-register every agent.

## Installation

```bash
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first machine only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

Every step is idempotent and reports conflicts it skips.

1. **Preconditions** — clone to `$HOME/.ai-tools` when missing and validate the tree (rule 23; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery and scope** — report each detected harness from its configuration directory, CLI, or known IDE extension, plus possible AI extensions outside scope. Omitted `--harnesses` selects those detected harnesses; `--harnesses all` selects all six and creates their artifact roots as needed. Report `$HOME/.agents` while leaving it untouched.
3. **Instructions** — copy `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; Antigravity uses `$HOME/.gemini/GEMINI.md`; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **Agents** — copy each wrapper from `agents/<harness>/` into that harness's agents root, per file, never per directory — those roots hold agents from other sources.
5. **Skills** — recursively copy each `skills/*-ai-tools` directory into every scoped skills root (rules 7–9).
6. **Grok model pinning** — Grok ignores `model:` in frontmatter and reads `~/.grok/config.toml`. The script maintains a marker-delimited `[subagents.models]` block: names from the tree, models from [`MODELS.md`](MODELS.md) (unreadable map → skip and report, never guess). A pre-existing unmanaged block is skipped and reported, never edited. Without the pin, agents still load but inherit the session model — the strong-model guarantee is lost. The same fallback applies to any harness that ignores `model:`.
7. **Verify** — every installed instruction, agent, and skill is a physical copy matching its source; `USER-AGENTS.md` fits the repository's 8,000-character cap (rule 3); `agents/SUBAGENT-CONTRACT.md`, every agent base, and every shipped `skills/<name>/SKILL.md` exist. Any installation symlink is a finding. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches agents or skills at startup. Confirm the three agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`) and a slash command for every shipped skill.

## Removal

Remove installed artifacts from harnesses while retaining the clone. Keeping `$HOME/.ai-tools` allows later installation or update.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # remove agents and skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

1. **Report** — list every possible ai-tools artifact and legacy link in the scoped roots before changing them.
2. **Agents and skills** — remove copies only while their contents still match their source; also unlink legacy links resolving into ai-tools. A locally modified copy is user work: skip and keep (rule 21).
3. **Grok** — delete only the marker-delimited ai-tools block in `~/.grok/config.toml`. Preserve unmanaged `[subagents.models]` content and the file itself.
4. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips it.
5. **Instructions** — only with `--instructions`; remove an exact source copy or a legacy ai-tools link, and preserve a modified or foreign destination. **Never `$HOME/AGENTS.md`** (rule 24).
6. **Verify** — report any known ai-tools artifact or legacy link still in the scoped roots; expected none except preserved modified or foreign paths.
7. **Purge** — with `--purge` only (prompt; `--yes` skips), delete `$HOME/.ai-tools` while always preserving `$HOME/AGENTS.md`.

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove only that entry, by hand — never wipe the config file. Restart the harness: agents leave its list, skill slash commands leave its menu.

## Update

Bring the clone to `origin/master` and re-synchronize the installed physical copies.

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

1. **Preconditions** — require the clone at `$HOME/.ai-tools`; if missing, [Installation](#installation) instead.
2. **Reset** — fetch and reset to `origin/master`. If this would discard local commits or edits, print them and require a rerun with `--discard-local`. `--no-reset` synchronizes from the current tree instead. The destructive scope is **the clone only**; harness configuration and `$HOME/AGENTS.md` remain untouched.
3. **Refresh copies** — an instruction, agent, or skill copy matching the pre-reset revision is stale, not user work: replace it. One matching neither revision was modified locally: skip and keep unless `--overwrite` explicitly replaces selected-harness artifact paths (rule 20).
4. **Copy anything newly shipped** — re-run the idempotent install steps for the scoped harnesses: matching installs remain untouched and new artifacts are added.
5. **Verify** — the Installation checks.

Use [Reinstallation](#reinstallation) when the install is broken, comes from an older alpha layout, or the set of harnesses changed. If the default branch is renamed (e.g. `main`), the scripts follow only after the user or remote confirms it — never a guessed branch.

## Reinstallation

Full removal + installation against a fresh `origin/master`, when [Update](#update) is not enough: broken or partial install, stale names or layouts from an older alpha, legacy links, or a change in which harnesses are wired.

```bash
"$HOME/.ai-tools/scripts/shell/reinstall.sh"
```

1. **Source first** — clone if missing, otherwise reset to `origin/master` (same `--discard-local` guard as Update), **before** removing or copying, so destinations match the published agent set (names and paths can change between versions).
2. **Remove** — agents, skills, the Grok block, the stale-link sweep (`--no-sweep` skips), and instructions (`--no-instructions` keeps them). Drop unmodified copies and legacy ai-tools links; skip and report modified copies.
3. **Install** — the Installation steps against the fresh tree, listing agents and skills from the tree, never from hardcoded names.
4. **Verify** — the Installation checks, plus no stale links left behind.

Then restart or reload the harness and confirm the three agents and a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user sets a remote or re-clones from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there (rule 23). Wrappers hardcode that path; no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then `verify`.
- **Legacy or dangling ai-tools links:** [Reinstallation](#reinstallation) migrates current artifact paths to physical copies and sweeps stale links.
- **Installed copies out of date:** copies do not track `git pull` — use [Update](#update), which refreshes unchanged copies from the previous revision.
- **A conflicting or locally modified installed artifact should be replaced:** rerun install, update, or reinstall with `--overwrite` and an explicit `--harnesses` scope. The flag affects only known artifact destinations in that scope.
- **An agent runs on the wrong (weak) model:** pinning is not applied. Grok: check the managed `[subagents.models]` block in `~/.grok/config.toml` (re-run [Installation](#installation) to restore it). Others: compare the installed wrapper to `$AI_TOOLS/agents/<harness>/` and [`MODELS.md`](MODELS.md).
- **A copied artifact was edited locally:** preserve the edit elsewhere before `--overwrite`; installed copies are managed deployment artifacts, while `$HOME/AGENTS.md` remains the supported place for personal instructions.

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is carrying the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, dispatched work that can create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- Use the root `LICENSE` instead of per-file license headers in shipped artifacts. `USER-AGENTS.md` follows the **8,000-character** cap in rule 3, and every artifact follows rule 15. Installation on one's own machine is not redistribution.
