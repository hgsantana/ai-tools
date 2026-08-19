# ai-tools

> **Version 0.0.23-ALPHA** — under active development. Usable for testing; no guarantees, and no backward compatibility between alpha versions (rule 4).

## What is this repository

A toolkit of **agents**, **skills**, and **instructions**, written once for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, Cursor, and Gemini CLI.

Clone it to `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows) and link it into each harness's user config so every tool loads the same set. Each wrapper pins its model from [`MODELS.md`](MODELS.md), so the category's model is fixed at execution time.

### What is inside

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | Install artifact: each harness's user-wide instructions. What is installed, how to route a request to a skill, agent categories, language, and security. Behaviour owned by a skill or a base is documented there, never here |
| [`MODELS.md`](MODELS.md) | Lookup: which model each category (**planner** / **implementer** / **mechanical**) uses per harness, and how to change the session model. The only place vendor model names live besides wrapper headers (rules 11–12); user-editable, reset by an [update](#update) |
| [`agents/planner-ai-tools.md`](agents/planner-ai-tools.md) | Base: explores the repository, writes a multi-file plan under `plans/`, stops; never implements |
| [`agents/orchestrator-ai-tools.md`](agents/orchestrator-ai-tools.md) | Base: executes accepted plans or an ad-hoc brief unattended; code to **implementer**, evidence to **mechanical** |
| [`agents/az-ai-tools.md`](agents/az-ai-tools.md) | Base: Azure CLI (`az`) — read freely, return mutations for per-action approval, surface cost |
| [`agents/gh-ai-tools.md`](agents/gh-ai-tools.md) | Base: GitHub CLI (`gh`) — read freely, return mutations for per-action approval |
| [`agents/gc-ai-tools.md`](agents/gc-ai-tools.md) | Base: Google Cloud CLI (`gcloud`) — read freely, return mutations for per-action approval, surface cost |
| [`agents/maintainer-ai-tools.md`](agents/maintainer-ai-tools.md) | Base: drives this README's [Update](#update), [Removal](#removal), or [Reinstallation](#reinstallation) via the [scripts](#scripts), returning destructive flags for approval. Never the first install — that is this README's bootstrap, before the agent exists |
| [`agents/SUBAGENT-CONTRACT.md`](agents/SUBAGENT-CONTRACT.md) | Shared contract every wrapper loads before its base: what changes when an agent runs as a spawned subagent — no channel to the user, questions and approvals returned to the spawner, report by file. Not installed; read by path |
| [`agents/<harness>/`](agents/) | Wrappers for the six agents: harness syntax, pinned model, this harness's `MODELS.md` row key, pointer to the shared contract, pointer to the base; nothing else |
| [`skills/`](skills/) | Nine skills: one same-named skill per agent, except `maintainer-ai-tools` (three tasks: `update-ai-tools`, `remove-ai-tools`, `reinstall-ai-tools`); plus `vibe-ai-tools`, which has no agent and carries refine-confirm-deliver inline. Each is split into a `skills/<name>/SKILL.md` wrapper (installed, ≤2,000 characters) and a `skills/<name>.md` base (behaviour). An agent-backed skill's wrapper also points to `skills/SKILL-CONTRACT.md`, which surfaces the stake, checks the session model, and offers three routes — dispatch the agent, run its base in this session, or stop (rule 8). A skill must run on **any** model; model-dependent work is an agent (rules 7–9) |
| [`skills/SKILL-CONTRACT.md`](skills/SKILL-CONTRACT.md) | Shared contract every agent-backed skill wrapper loads before its base: the model check, the three-route offer, and the route mechanics. Not installed; read by path |
| [`scripts/`](scripts/) | `install`, `remove`, `update`, `reinstall`, `verify` — shell, PowerShell, and CMD shims ([Scripts](#scripts); rules 23–26) |

### How to install, remove, update, or reinstall

Same command for a human or an AI ([Scripts](#scripts)):

```bash
# Linux, macOS, WSL, Git Bash — Windows: scripts/powershell/*.ps1 or scripts/cmd/*.cmd
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first install only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

Replace `install` with `remove`, `update`, `reinstall`, or `verify`. Every script takes `--dry-run` and `--help`. Or, in a harness:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

The AI follows the matching process section below and runs that same script.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the single source of truth for this repository: explanation, rules, and processes (install, remove, update, reinstall). Their executable form is `scripts/` (rules 23–26).
2. AIs working on this repository take instructions **about this repository** only from this README. User-wide or harness-global files — including an installed `USER-AGENTS.md` — yield to it here.
3. `USER-AGENTS.md` is an install artifact: user-wide harness instructions, not a rule file for this repository. It is capped at a self-imposed **8,000 characters**, deliberately tighter than any harness constraint, to force concision. Every shipped artifact must fit every supported harness that consumes it: the tightest constraint governs (today: Antigravity's 12,000-character cap on rules files, looser than the self-imposed cap). Register constraints in [Supported harnesses](#supported-harnesses); a stricter one updates those notes and the affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top): no backward compatibility. This README describes the current state only; breaking changes carry no migration notes. Fix an older layout with [Reinstallation](#reinstallation) and its stale-link sweep. Bump the version in the same commit as any change to shipped content or process. Backward-compatibility records begin at the first stable release.

### Structure and authoring

5. Every agent has a harness-agnostic **base** at `agents/<name>.md` (full behaviour) and one **wrapper** per harness at `agents/<harness-short-name>/<agent-name>.<ext>`. A base states behaviour **mode-agnostically**: it says to ask the user or to require approval, never how that reaches them. How it reaches them belongs to whoever loads the base — `agents/SUBAGENT-CONTRACT.md` when a wrapper spawns it, the skill's *run it here* route when a session runs it.
6. A wrapper header is only harness syntax (frontmatter or TOML, model pinning, file name). Its body is exactly, in this order: **(1)** the `MODELS.md` pointer naming this harness's row, only when the base cites **planner** / **implementer** / **mechanical**; **(2)** the pointer to `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`; **(3)** the pointer to `$HOME/.ai-tools/agents/<name>.md`, which prevails over the contract except on the channel to the user. Anything else is drift — move it to the base or to the contract. A wrapper is at most **1,000 characters**, frontmatter included: it is what the harness reads to decide whether to route to the agent, so it carries the summary and nothing else — the behaviour lives in the base it points to. Canonical body: [wrapper authoring](#model-map-and-wrapper-authoring).
7. Skills are optional and harness-agnostic — no per-harness copies, no wrappers per harness. A skill is split like an agent: a **wrapper** at `skills/<name>/SKILL.md`, the only installed file, in one directory every harness registers as-is; a **base** at `skills/<name>.md` holding the behaviour; and, for a skill that fronts an agent, `skills/SKILL-CONTRACT.md` — the model check, the three-route offer, and the route mechanics, shared by every agent-backed skill and read by path, never installed. The wrapper body is exactly, in this order: a one-line scope; the pointer to `$HOME/.ai-tools/skills/SKILL-CONTRACT.md` (agent-backed skills only); the pointer to `$HOME/.ai-tools/skills/<name>.md`, which prevails over the contract. Anything else is drift — move it to the base or the contract. A wrapper is at most **2,000 characters**, frontmatter included: it is what the harness reads to decide whether to route to the skill. That cap is concision (rule 14), not token economy — no supported harness preloads skill bodies; every one that documents the mechanics reads the body on invocation. Canonical body: [skill authoring](#model-map-and-wrapper-authoring).
8. A skill must run on **any** model the session provides: it never requires a model or category and never refuses over one. It may read `MODELS.md` and advise which model would serve and how to switch — the user may decline; that is not a gate. If it cannot function without a given model, it must be an agent, whose wrapper pins the model. An agent-backed skill therefore owns the choice of runner and never makes it itself: it states the stake and that model check in one message, then asks for one of three routes — **dispatch the agent** (its wrapper pins the model), **run it here** (this session reads the base and follows it, loading no subagent contract — it is not a subagent), or **stop**.
9. Skill frontmatter: only universally accepted keys (`name`, `description`) plus optional keys every supported harness tolerates (e.g. `argument-hint`). A key any supported harness rejects does not belong in a shared file. `description` is at most **500 characters**: harnesses budget the skill *list*, not the body — Codex caps it at 2% of the context window or 8,000 characters, Claude Code truncates a description at 1,536.
10. Wrappers follow each harness's official documentation. Re-check vendor docs before adding a harness or editing a wrapper — formats change upstream.
11. Vendor model names live in [`MODELS.md`](MODELS.md) and are repeated only in wrapper headers (harnesses read the wrapper). Everyone else — bases, skills, the scripts' Grok pin — reads `MODELS.md` at run time and hard-codes none. [Supported harnesses](#supported-harnesses) may show accepted value *shapes*, never the choice. Bases speak only in categories (**planner**, **implementer**, **mechanical**, defined in `USER-AGENTS.md`); skills cite categories only as advice (rule 8).
12. `MODELS.md` and wrapper headers always match: a new agent, a new harness, or a model change updates the map and every affected wrapper in the same commit. Nothing else needs updating — a wrapper body never varies except by row key (rule 6). Fill each cell by the [selection method](#choosing-the-models) from current Artificial Analysis measurements and official harness model, plan, pricing, and configuration docs — never memory or unsourced claims.
13. Everything installed from this repo — agent name, skill directory, slash command, frontmatter `name:`, file basename — ends in `-ai-tools`. Never install a bare name (`planner`, `az`).
14. Extreme conciseness: no ambiguity or redundancy, and no omitted instruction, rule, or intention in exchange for brevity.
15. Disk in this repository is concise English. Chat is in the user's language.
16. An agent that can be **destructive** or **generate cost** opens its base with a stake disclaimer — one short block before any workflow, naming what can be billed and what can be deleted, removed, or destroyed (when each applies). Whoever invokes it — the skill offering the routes, or the agent spawning it — surfaces that warning **before** anything runs, on either route.

### Installation contract

17. **Symlink** when possible; copy only when the OS or filesystem refuses, and report every copy.
18. Never overwrite user files on install, update, or reinstall — only ai-tools links or unmodified ai-tools copies.
19. Never remove anything ai-tools did not create.
20. Every install/remove/update/reinstall step is idempotent; on conflict, skip and report — do not fail or overwrite.
21. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Wrappers hardcode it; any other path breaks them.
22. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: created empty only when missing at install; never edited, overwritten, truncated, symlinked, or removed.

### Script contract

23. Each process — install, remove, update, reinstall, verify — is `scripts/shell/<process>.sh` (Linux, macOS, WSL, Git Bash; bash 3.2+, BSD/GNU tools) and `scripts/powershell/<process>.ps1` (Windows PowerShell 5.1+ and pwsh). `scripts/cmd/<process>.cmd` only delegates to PowerShell. Shared logic lives in `lib.sh` / `lib.ps1`, never duplicated across scripts.
24. `scripts/shell` is canonical. A behaviour change lands there, in the PowerShell mirror, and in the process sections below, in the same commit.
25. Scripts run to completion: per-item conflicts skip and report. Destructive steps need explicit flags (`--discard-local`, `--instructions`, `--purge`) and default to refuse. Every mutating script supports `--dry-run`. Exit: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
26. Shell and PowerShell scripts are committed executable; `.gitattributes` pins them to LF and CMD shims to CRLF. PowerShell is **UTF-8 with BOM** (Windows PowerShell 5.1 reads BOM-less files as ANSI; one em dash closes a string and breaks the script). CMD shims stay pure ASCII — a BOM there is a command.

### Model map and wrapper authoring

[`MODELS.md`](MODELS.md) is a lookup: one row per harness, one column per category, plus how to change the session model. It does not restate the arithmetic below. Availability and accepted values come from official harness docs; measurements come from [Artificial Analysis](https://artificialanalysis.ai/) **model** pages (Intelligence Index, cost per task, output speed, end-to-end time) — the model itself, not a model-plus-harness run. The map judges potential, not a frozen stack.

Wrappers pin the model token always, and pin effort only when the cell has an official effort **and** the wrapper form can hold it (`effort:` Claude Code, `model_reasoning_effort` Codex, `[effort=…]` Cursor).

#### Choosing the models

A map row is reproducible research, never recollection. Re-run on every model release. Record source URLs, retrieval date, and benchmark versions.

**Terms**

| Term | Meaning |
|---|---|
| **Family** | One official family + version from step 1 |
| **Official effort** | A level the harness documents for that surface and model. A label that exists only on Artificial Analysis (reasoning, non-reasoning, Adaptive Reasoning) is not one |
| **Complete row** | An AA **model** row with independently finished numeric Intelligence Index, Intelligence Index Cost per Task, Output Speed, and End-to-End Response Time — no `*`, no lab-claim stand-in |
| **Effort-comparable** | The family has a complete row for **two or more** official efforts. One complete official row, or none, is not comparable; a later rematch adds ` · effort` when more levels are measured |
| **Score** | `(Intelligence Index / Intelligence Index Cost per Task) × Output Speed` — higher first |

1. **List names.** From the harness's official model, plan, pricing, and configuration docs, list every model on the most permissive documented first-party plan for this exact agent surface. Collapse the same family + version into one name (drop effort, Fast/standard, and other mode suffixes: `Grok 4.6 Fast` and `Grok 4.6 High` are both `Grok 4.6`). Record the accepted configuration value, underlying model, plan, surface, and every official effort token (`low`, `medium`, `high`, `xhigh`, `max`, or whatever the vendor names). Omit retired, utility, internal, arbitrary BYOK, and auto-routing. An alias or tier counts only when official docs resolve it to one family + version on the research date.
2. **Join measurements.** For each name, every AA **model** row of that family + version — every measured effort and mode — is its own candidate. Record the four metrics, one table per harness. Do not use harness-stack scores (Coding Agent Index or any model-plus-agent run). Show gaps as `N/A`; exclude `*` estimates and lab claims from selection. Never substitute per-token or subscription price for Cost per Task. Calculate with downloadable source precision, never rounded display values.
3. **Select.** Do not drop a candidate for a missing metric that category uses. Impute `0` where higher is better, and that category's current maximum + `1` where lower is better. Thresholds are inclusive. Every category uses the same four metrics. After the filter, rank survivors by score; break a remaining tie with the lowest End-to-End Response Time.
   - **planner** — keep Intelligence Index ≥ `best − 5`, then rank.
   - **implementer** — keep ≥ `best − 10`, then rank. If the first family is the planner's, a different effort is not a different model. Compare it with each other family still in the band at the **highest official effort both have as a complete row** (one reaches `xhigh`, the other only `high` → `high`); take the better score. If no other family shares such an effort, keep the planner family.
   - **mechanical** — keep Cost per Task ≤ `10 ×` the harness minimum, then rank. If the first family is the planner's or the implementer's, apply that same highest-common-effort comparison against any unused family still in the band; if none shares a complete official effort, the family may repeat. If it still matches the implementer in **family and official effort**, and the family is effort-comparable, set effort to that family's **lowest official complete row**. If it is not effort-comparable or has no lower complete official effort, keep the family and write no effort.
4. **Fallback — only when measurement cannot decide** (no complete candidate, or the time comparison still ties). Use only the harness's official task guidance: deep reasoning, architecture, and ambiguity for **planner**; agentic software development, implementation, and tool use for **implementer**; simple, repetitive, routine, fast, or cost-sensitive work for **mechanical**. Cite it and label `documented fallback`. If it does not name one model, report the ambiguity — do not invent a quantitative winner or keep the incumbent.
5. **Write.** Put each winner in the map as the accepted model token. Append ` · effort` only when the family is effort-comparable **and** official docs list a token that matches the selected row (or the mechanical lowest-complete-effort adjustment), in the vendor's spelling. Otherwise the model token alone. A measured winner may not be `N/A`. Same commit (rule 12): update every affected wrapper — model token always; effort **only** if the cell has ` · effort` **and** the wrapper form can pin it. Map shape: one row per harness; column 1 is the backticked key matching `agents/<harness>/`; scripts take the first backtick-quoted token as the model. A new harness adds that row, its wrapper folder, and [Supported harnesses](#supported-harnesses) in the same commit.

Every shipped agent runs as **planner** except `maintainer-ai-tools`, which runs as **implementer** (it drives this README's scripts). Each wrapper pins that category from `MODELS.md` in the header the harness requires. Body, in this order (rule 6):

```markdown
On Windows, %USERPROFILE% replaces $HOME.

Category → model comes from `$HOME/.ai-tools/MODELS.md`, row `<harness key>`. Resolve every category through it — your own and any you spawn; never assume a model name.

You are a spawned subagent: your shared contract is `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`.
Read it and follow it — it governs your channel to the user and your report.

Your base file is `$HOME/.ai-tools/agents/<name>.md`.
Read it and follow it in full — it is the absolute rule set for this agent; the contract above prevails only on your channel to the user.
```

`<harness key>` is the wrapper's folder under `agents/` and its `MODELS.md` row. Omit the first paragraph when the base cites no category; the other two are always present. Codex carries the same text in `developer_instructions`, with Windows backslashes doubled for TOML.

A skill wrapper carries frontmatter (rule 9), then exactly:

```markdown
# <Title>

<One sentence: what this skill covers and who defines the work.>

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the model check, the route offer, and the route mechanics.

Your base file is `$HOME/.ai-tools/skills/<name>.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
```

On Windows, `%USERPROFILE%` replaces `$HOME`. A skill that fronts no agent omits the contract paragraph.

## Scripts

Every process below is an executable script — the same command for a human or an AI. All are idempotent, skip-and-report per item, and honour the [Safety rules](#safety-rules) by construction.

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |
| Windows — PowerShell 5.1+ or pwsh | [`scripts/powershell/`](scripts/powershell/) | `& "$env:USERPROFILE\.ai-tools\scripts\powershell\<process>.ps1" [flags]` |
| Windows — CMD | [`scripts/cmd/`](scripts/cmd/) | `%USERPROFILE%\.ai-tools\scripts\cmd\<process>.cmd [flags]` — delegates to PowerShell |

Processes: `install`, `remove`, `update`, `reinstall`, and read-only `verify`. `--help` (shell) or the header comment (PowerShell) lists flags; PowerShell spells a flag `-LikeThis` (`--dry-run` → `-DryRun`).

On top of rules 23–25:

- **Scope** — `--harnesses <list>` (comma-separated folder names under `agents/`); default is every detected harness. An AI running a mutating script asks for scope first and passes the flag.
- **Dry run** — `--dry-run` reports every action and changes nothing: the findings/approval report for unattended runs.
- **Destructive flags** — `--discard-local` (reset discarding local work in the clone), `--instructions` (unlink global instructions on removal), `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Symlink fallback** — where the OS refuses symlinks (Windows without Developer Mode or elevation, mounts without symlink support), agents and skills install as copies, reported `copied (will not track updates)`. Global instructions are never copied — offer an include pointer so this repo stays the single source of truth.

## Development checks

`tools/` holds development tooling — `scripts/` remains exactly the five installation processes (rules 23–25). [`tools/lint.sh`](tools/lint.sh) is a development check, not an installation process: it enforces this repository's mechanically verifiable rules against the tree it runs in, with no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`. Run it from anywhere:

```bash
"$HOME/.ai-tools/tools/lint.sh"              # check the working tree
"$HOME/.ai-tools/tools/lint.sh" --base <ref> # also check the version bump against <ref>
```

Check families:

- **wrapper coverage** — every agent has exactly one wrapper per harness, no orphans (rule 5)
- **naming** — agent bases, wrappers, skill directories, and frontmatter `name:` all end in `-ai-tools` (rule 13)
- **skill frontmatter** — every `skills/*/SKILL.md` exists, keys a subset of `name`/`description`/`argument-hint`, and `name:` matches its directory (rule 9)
- **wrapper body** — the body is reconstructed from this README's canonical text and compared exactly (rule 6)
- **model parity and effort pinning** — every pinned model and effort resolves through `MODELS.md` (rules 11–12); Grok wrappers declare no model
- **description parity** — an agent's `description` is identical across all seven wrappers
- **`MODELS.md` row coverage** — every harness directory has a row and vice versa (rule 12)
- **size caps** — `USER-AGENTS.md` at most 8,000 characters (rule 3), every wrapper at most 1,000 (rule 6)
- **encodings and endings** — PowerShell BOM, pure-ASCII CMD, line endings (`git ls-files --eol`), executable bits, no binaries in shipped paths (rule 26)
- **version bump** — only with `--base <ref>`: a change under `agents/`, `skills/`, `scripts/`, or `USER-AGENTS.md` requires the README version to change too (rule 4)

Exit codes: `0` clean, `1` aborted on a precondition (unknown flag, `--base` without a value), `2` finished with findings. CI (`.github/workflows/lint.yml`) runs `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` on every push and pull request, and runs the version-bump check — `tools/lint.sh --base <PR base>` — only on pull requests; pushes run `tools/lint.sh` with every other check.

`tools/lint.sh` ships **without** a PowerShell mirror, deliberately outside rules 23–25's contract: a mirror only a Windows maintainer exercises drifts in silence, which is exactly the failure this linter exists to catch. Windows contributors run it from Git Bash.

When a rule in this README becomes mechanically verifiable, add its check to `tools/lint.sh` and its rule number to the list above in the same commit — the two caps above (rules 3, 6) are stated here as rules; the linter only enforces them, and this README is the number a reader trusts.

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), [Update](#update), and [Reinstallation](#reinstallation), on top of rules 17–22:

- **Never replace** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 18, 20). Silent overwrite is a bug. A destination that is already the correct link is left alone.
- **Never** `rm -rf` a harness agents or skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 19).
- Never touch vendor bundles (`~/.grok/bundled/`), unrelated user agents or skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/AGENTS.md` (rule 22).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

Implemented once — `safe_link`, `link_or_copy`, `safe_unlink`, `safe_uninstall_copy` in [`scripts/shell/lib.sh`](scripts/shell/lib.sh), mirrored in [`scripts/powershell/lib.ps1`](scripts/powershell/lib.ps1). Scripts refuse the unsafe path; manual intervention must honour the same rules.

## Supported harnesses

One row per harness: global instructions, skills, agents, wrapper folder, and wrapper file form.

| Harness | Global instructions destination | Skills root | Agents root | Wrapper folder · agent file form |
|---|---|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` | `$HOME/.claude/agents/` | `agents/claude-code/` · `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/`fable`/full ID/`inherit`) |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` | `$HOME/.grok/agents/` | `agents/grok/` · `*.md`; **no `model:` in frontmatter** — models pinned in `~/.grok/config.toml` (see [Installation](#installation)) |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` | `$HOME/.codex/agents/` | `agents/codex/` · `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` | `$HOME/.copilot/agents/` | `agents/copilot/` · `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` (shared with Gemini CLI) | `$HOME/.gemini/config/skills/` | `$HOME/.gemini/config/agents/` | `agents/antigravity/` · `*.md`, frontmatter `name`, `description`, `model` (`inherit`/`flash`/`pro`), `subagent`, `mainAgent`, `commandExecutionPolicy` |
| Cursor | Not linked — no documented path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` | `$HOME/.cursor/agents/` | `agents/cursor/` · `*.md`, `model:` accepts bracketed parameters (`<model>[effort=high]`) |
| Gemini CLI | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/skills/` (**not** `$HOME/.gemini/config/skills/`) | `$HOME/.gemini/agents/` | `agents/gemini/` · `*.md`, frontmatter `kind`, `model`, `temperature`, `max_turns`, `timeout_mins` |

Notes:

- **Antigravity and Gemini CLI share `$HOME/.gemini`** but not the same roots: one `GEMINI.md` serves both; skills and agents go to `config/skills/` / `config/agents/` (Antigravity) and `skills/` / `agents/` (Gemini CLI). Scripts install into each selected harness's own roots.
- **Antigravity limits rules files to 12,000 characters** — the tightest instructions-file constraint, so it caps `USER-AGENTS.md` (rule 3). Over it, the file is truncated or rejected there.
- **Codex** reads `~/.codex/AGENTS.override.md` first if it exists, else `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — user-authored, out of scope.
- **Never link into `$HOME/.agents/`.** Several harnesses discover it; linking there as well as into each harness root would double-register every agent.
- When a harness cannot symlink instructions, offer a one-line include pointer instead of copying the file, so this repo stays the single source of truth.

## Installation

```bash
git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"   # first machine only
"$HOME/.ai-tools/scripts/shell/install.sh"
```

Every step is idempotent; conflicts are skipped and reported.

1. **Preconditions** — clone to `$HOME/.ai-tools` when missing and validate the tree (rule 21; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery** — report each detected harness (config directory, CLI, or known IDE extension) and possible AI extensions it will never touch. `$HOME/.agents` is reported, never linked into.
3. **Instructions** — link `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; one `GEMINI.md` serves Gemini CLI and Antigravity; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **User overlay** — create `$HOME/AGENTS.md` empty only when missing (rule 22). Write its contents only if the user later asks for that directly.
5. **Agents** — link each wrapper from `agents/<harness>/` into that harness's agents root, per file, never per directory — those roots hold other agents, and a directory link would shadow them.
6. **Skills** — link each `skills/*-ai-tools` directory into each scoped skills root; the same shared directory serves every harness (rules 7–9). Prefer these links over harness scan paths (Grok `[skills] paths`), which can clobber existing names.
7. **Grok model pinning** — Grok ignores `model:` in frontmatter and reads `~/.grok/config.toml`. The script maintains a marker-delimited `[subagents.models]` block: names from the tree, models from [`MODELS.md`](MODELS.md) (unreadable map → skip and report, never guess). A pre-existing unmanaged block is skipped and reported, never edited. Without the pin, agents still load but inherit the session model — the strong-model guarantee is lost. The same fallback applies to any harness that ignores `model:`.
8. **Verify** — instructions resolve into the clone, `USER-AGENTS.md` fits the 12,000-character cap (rule 3), `agents/SUBAGENT-CONTRACT.md` and every agent base exist at the pinned path, and every installed agent and skill is a link or an unmodified copy. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches agents or skills at startup. Confirm the six agents (`planner-ai-tools`, `orchestrator-ai-tools`, `az-ai-tools`, `gh-ai-tools`, `gc-ai-tools`, `maintainer-ai-tools`) appear in its agent list, plus a slash command for every shipped skill — including `/vibe-ai-tools`, which is a skill only.

## Removal

Unlink from harnesses — not delete the clone. Leaving `$HOME/.ai-tools` on disk is normal and makes [Update](#update) a reset plus re-link.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # unlink agents and skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

1. **Report** — list every ai-tools link, possible copy, and instructions link in the scoped roots before touching anything.
2. **Agents and skills** — unlink links; remove copies only while their contents still match their source. A locally modified copy is user work: skip and keep (rule 19).
3. **Grok** — delete only the marker-delimited ai-tools block in `~/.grok/config.toml`. Leave an unmanaged `[subagents.models]` untouched; never remove the file.
4. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips it.
5. **Instructions** — only with `--instructions`, and only destinations that are ai-tools links. Keep `GEMINI.md` while the other of Gemini CLI / Antigravity is out of scope. Edit an include pointer out by hand; never delete that file. **Never `$HOME/AGENTS.md`** (rule 22).
6. **Verify** — report any ai-tools link still in the scoped roots; expected none.
7. **Purge** — only with `--purge` (prompt; `--yes` skips): delete `$HOME/.ai-tools`. Never includes `$HOME/AGENTS.md`.

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove only that entry, by hand — never wipe the config file. Restart the harness: agents leave its list, skill slash commands leave its menu.

## Update

Bring the clone to `origin/master` and re-synchronize what is installed. Symlinks track new content; copies do not, and are refreshed here.

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

1. **Preconditions** — require the clone at `$HOME/.ai-tools`; if missing, [Installation](#installation) instead.
2. **Reset** — fetch and reset to `origin/master`. If local commits or uncommitted edits would be discarded, print them and stop until re-run with `--discard-local`. `--no-reset` re-synchronizes from the current tree instead. Destructive **inside the clone only**: harness config and `$HOME/AGENTS.md` are never touched by the reset.
3. **Refresh copies** — a copy matching the pre-reset revision is stale, not user work: replace it. One matching neither revision was modified locally: skip and keep (rule 19).
4. **Link anything newly shipped** — re-run the idempotent install steps for the scoped harnesses: existing installs untouched, new agents or skills added, `$HOME/AGENTS.md` created only if missing.
5. **Verify** — the Installation checks.

Use [Reinstallation](#reinstallation) when the install is broken, comes from an older alpha layout, or the set of harnesses changed. If the default branch is renamed (e.g. `main`), the scripts follow only after the user or remote confirms it — never a guessed branch.

## Reinstallation

Full removal + installation against a fresh `origin/master`, when [Update](#update) is not enough: broken or partial install, stale names or layouts from an older alpha, dangling links after upstream renames, or a change in which harnesses are wired. A link is never upgraded in place — re-creating it is the fix.

```bash
"$HOME/.ai-tools/scripts/shell/reinstall.sh"
```

1. **Source first** — clone if missing, otherwise reset to `origin/master` (same `--discard-local` guard as Update), **before** removing or re-linking, so destinations match the published agent set (names and paths can change between versions).
2. **Remove** — agents, skills, the Grok block, the stale-link sweep (`--no-sweep` skips), and the instructions links (`--no-instructions` keeps them). Drop unmodified copies; skip and report modified copies.
3. **Install** — the Installation steps against the fresh tree, listing agents and skills from the tree, never from hardcoded names.
4. **Verify** — the Installation checks, plus no stale links left behind.

Then restart or reload the harness and confirm the six agents appear in its agent list, plus a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user sets a remote or re-clones from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there (rule 21). Wrappers hardcode that path; no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then `verify`.
- **Dangling links after an upstream rename or layout change:** [Reinstallation](#reinstallation); links are never upgraded in place.
- **Copied agents out of date:** copies do not track `git pull` — [Update](#update). If a copy predates the locally known previous revision, [Reinstallation](#reinstallation).
- **A destination is a non-ai-tools file the user wants replaced:** the scripts always skip and report it; the user removes that file themselves, per path.
- **An agent runs on the wrong (weak) model:** pinning is not applied. Grok: check the managed `[subagents.models]` block in `~/.grok/config.toml` (re-run [Installation](#installation) to restore it). Others: compare the installed wrapper to `$AI_TOOLS/agents/<harness>/` and [`MODELS.md`](MODELS.md).
- **`copied (will not track updates)`:** the OS refused symlinks (on Windows: Developer Mode or an elevated shell, then [Reinstallation](#reinstallation) converts copies to links). Until then, [Update](#update) after every upstream change on that machine.

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is carrying the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, agents that create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- No per-file license headers in shipped artifacts. `USER-AGENTS.md` is capped at 12,000 characters (rule 3) and every artifact is bound by rule 14. A root `LICENSE` covers redistribution; installing on one's own machine is not redistribution.
