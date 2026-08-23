# ai-tools

> **Version 0.0.29-ALPHA** — under active development. Usable for testing; no guarantees, and no backward compatibility between alpha versions (rule 4).

## What is this repository

A toolkit of **skills**, **three agents**, and **instructions**, written once for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, and Cursor.

Clone it to `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows) and link it into each harness's user config so every tool loads the same set. Skills are the entry point; three spawn-only agents run the work. Wrappers pin models from [`MODELS.md`](MODELS.md) at authoring.

### What is inside

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | Install artifact: user-wide harness instructions — routing, the three agents' roles, language, security. Workflows live in skill and agent bases, not here |
| [`MODELS.md`](MODELS.md) | Authoring/install map: model per agent per harness. Vendor names live here and in wrapper headers (rules 11–12); user-editable, reset by an [update](#update) |
| [`agents/planner-ai-tools.md`](agents/planner-ai-tools.md) | `planner-ai-tools` — decomposes, designs, owns acceptance; no production code. Type rules only; the brief is the job |
| [`agents/implementer-ai-tools.md`](agents/implementer-ai-tools.md) | `implementer-ai-tools` — writes and edits code for one assignment. Type rules only; the brief is the job |
| [`agents/mechanical-ai-tools.md`](agents/mechanical-ai-tools.md) | `mechanical-ai-tools` — specified patches, renames, builds, tests, evidence; no design. Type rules only; the brief is the job |
| [`agents/SUBAGENT-CONTRACT.md`](agents/SUBAGENT-CONTRACT.md) | Shared spawned-subagent contract: brief, channel to the user, report, model pin, spawn nothing, stay inside the type. Not installed; read by path |
| [`agents/<harness>/`](agents/) | One wrapper per agent: header pin, contract pointer, base pointer |
| [`skills/`](skills/) | Ten skills: installed `skills/<name>/SKILL.md` plus `skills/<name>.md` (the workflow). The three agents have no skill. Each names one agent: the planner role is carried by the session, every other role is dispatched (rule 8) |
| [`skills/SKILL-CONTRACT.md`](skills/SKILL-CONTRACT.md) | Planner gate, route offer, and dispatch for agent-backed skills. Not installed; read by path |
| [`skills/MAINTAINER.md`](skills/MAINTAINER.md) | Shared update/remove/reinstall workflow. Not installed |
| [`scripts/`](scripts/) | `install`, `remove`, `update`, `reinstall`, `verify` — bash ([Scripts](#scripts); rules 25–28). Windows: WSL or Git Bash |

### How to install, remove, update, or reinstall

Same command for a human or an AI ([Scripts](#scripts)):

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

1. This `README.md` is the single source of truth for this repository: explanation, rules, and processes (install, remove, update, reinstall). Their executable form is `scripts/` (rules 25–28).
2. AIs working on this repository take instructions **about this repository** only from this README. User-wide or harness-global files — including an installed `USER-AGENTS.md` — yield to it here.
3. `USER-AGENTS.md` is an install artifact: user-wide harness instructions, not a rule file for this repository. It is capped at a self-imposed **8,000 characters**, deliberately tighter than any harness constraint, to force concision. Every shipped artifact must fit every supported harness that consumes it: the tightest constraint governs (today: Antigravity's 12,000-character cap on rules files, looser than the self-imposed cap). Register constraints in [Supported harnesses](#supported-harnesses); a stricter one updates those notes and the affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top): no backward compatibility. This README describes the current state only; breaking changes carry no migration notes. Fix an older layout with [Reinstallation](#reinstallation) and its stale-link sweep. The version at the top of this README changes only when the change lands on `master` — never on any other branch, and never in uncommitted work. Bump in the commit or merge that introduces it onto `master`. Backward-compatibility records begin at the first stable release.

### Structure and authoring

5. Only three agents ship: `planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`. Each has a harness-agnostic **base** at `agents/<name>.md` (type rules, request-agnostic) and one **wrapper** per harness at `agents/<harness-short-name>/<agent-name>.<ext>`. A base is **mode-agnostic**: it says to ask or to require approval, never how that reaches them — `agents/SUBAGENT-CONTRACT.md` owns the channel when spawned, and that type rules prevail if the brief conflicts. A base routes delegated work between the three roles; whether the run may spawn at all is the contract's (rule 8). Skills pass a complete brief (the **Workflow** plus the user's request).
6. Wrapper header: harness syntax and the pin (`model:`; effort only when the map cell has one). Body, in this order: pointer to `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`; pointer to `$HOME/.ai-tools/agents/<name>.md` (prevails except on the channel to the user). Anything else is drift. Cap **1,000 characters**, frontmatter included. Canonical body: [wrapper authoring](#model-map-and-wrapper-authoring).
7. Skills are harness-agnostic — no per-harness copies. Split: installed **wrapper** `skills/<name>/SKILL.md`; **base** `skills/<name>.md` (the workflow); agent-backed skills also load `skills/SKILL-CONTRACT.md` by path, never installed. Wrapper body, in this order: one-line scope; SKILL-CONTRACT pointer (agent-backed only); skill-base pointer (prevails over the contract). Anything else is drift. Cap **2,000 characters**, frontmatter included. No supported harness preloads skill bodies; the cap is concision (rule 15). Canonical body: [skill authoring](#model-map-and-wrapper-authoring).
8. **Spawn depth is one**: only the user's session spawns agents, and a spawned agent spawns nothing — it returns the work it cannot carry as a dispatch request (`agents/SUBAGENT-CONTRACT.md`). Harnesses that do allow a deeper chain gain nothing from it; the design assumes the shallowest. A skill still runs on **any** session model and never refuses over one, and work that needs a pin is dispatched to a named agent, whose wrapper already pins the model. The **planner** role orchestrates, so it cannot be dispatched — a dispatched planner would have no way to spawn its workers. An agent-backed skill naming `planner-ai-tools` gates instead: stake, compare the session model with that harness's `planner` cell in `MODELS.md`, then **run it here** — this session carrying the role and spawning the workers — **change the session model**, or **stop**. Every other agent-backed skill dispatches: stake, then **dispatch the agent** or **stop**, and that agent carries its work alone.
9. Skill frontmatter: only universally accepted keys (`name`, `description`) plus optional keys every supported harness tolerates (e.g. `argument-hint`). A key any supported harness rejects does not belong in a shared file. `description` is at most **500 characters**: harnesses budget the skill *list*, not the body — Codex caps it at 2% of the context window or 8,000 characters, Claude Code truncates a description at 1,536.
10. Wrappers follow each harness's official documentation. Re-check vendor docs before adding a harness or editing a wrapper — formats change upstream.
11. Vendor model names live in [`MODELS.md`](MODELS.md) and wrapper headers only. Dispatch uses the named agent's already-pinned wrapper. Grok install and `tools/lint.sh` read the map at install / authoring. [Supported harnesses](#supported-harnesses) may show accepted value *shapes*, never the choice. Bases cite **planner** / **implementer** / **mechanical** as roles (`USER-AGENTS.md` → *The three agents*). Spawn and skills use agent names.
12. `MODELS.md` and wrapper **headers** match in the same commit (new agent, new harness, or model change). Wrapper bodies name neither a row nor a model. Fill each cell by the [selection method](#choosing-the-models) — never memory or unsourced claims.
13. A harness whose CLI accepts model identifiers in a namespace of its own carries a **CLI slug annotation** in [`MODELS.md`](MODELS.md), beside the map and separate from the wrapper cell. Build it from that CLI's official documentation, re-read on the pass that fills the row (rule 10) — that page names the accepted slugs and the subcommand that lists them live. A skill invoking such a CLI takes `--model` from the annotation. Derive each row: resolve the category from that harness's map row and the selection pass behind it, then translate the resolved family + version and reasoning tier into the CLI's slug, a cell naming no tier translating to the family's middle published slug. When two or more categories land on the same slug, the **implementer's** is the base — the planner moves one reasoning tier up and the mechanical one tier down, within the tiers that CLI publishes for the family; with no tier above or below, that category repeats the base. Today: Antigravity, whose wrapper `model:` is a subagent tier (`inherit`/`flash`/`pro`) while `agy --model` takes a full slug.
14. Everything installed from this repo — agent name, skill directory, slash command, frontmatter `name:`, file basename — ends in `-ai-tools`. Never install a bare name (`planner`, `az`).
15. Extreme conciseness: no ambiguity or redundancy, and no omitted instruction, rule, or intention in exchange for brevity.
16. Skills, agent bases, contracts, and `USER-AGENTS.md` state what to do. A negative (`never`, `do not`) is used only when it reinforces an essential positive, or when the positive phrasing would lose force or not make sense.
17. Disk in this repository is concise English. Chat is in the user's language.
18. A skill or agent that can be **destructive** or **generate cost** opens with a stake disclaimer — one short block before any workflow, naming what can be billed and what can be deleted, removed, or destroyed (when each applies). Whoever invokes it — the skill offering the routes, or the agent spawning it — surfaces that warning **before** anything runs.

### Installation contract

19. **Symlink** when possible; copy only when the OS or filesystem refuses, and report every copy.
20. Never overwrite user files on install, update, or reinstall — only ai-tools links or unmodified ai-tools copies.
21. Never remove anything ai-tools did not create.
22. Every install/remove/update/reinstall step is idempotent; on conflict, skip and report — do not fail or overwrite.
23. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Wrappers hardcode it; any other path breaks them.
24. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: created empty only when missing at install; never edited, overwritten, truncated, symlinked, or removed.

### Script contract

25. Each process — install, remove, update, reinstall, verify — is `scripts/shell/<process>.sh` (Linux, macOS, WSL, Git Bash; bash 3.2+, BSD/GNU tools). Shared logic lives in `lib.sh`, never duplicated across scripts. No PowerShell or CMD mirror: on Windows, use WSL or Git Bash.
26. `scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.
27. Scripts run to completion: per-item conflicts skip and report. Destructive steps need explicit flags (`--discard-local`, `--instructions`, `--purge`) and default to refuse. Every mutating script supports `--dry-run`. Exit: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
28. Shell scripts are committed executable; `.gitattributes` pins them to LF.

### Model map and wrapper authoring

[`MODELS.md`](MODELS.md) is an authoring and install lookup: one row per harness, one column per agent role, plus how a human changes the session model. It does not restate the arithmetic below. Family + version, and official effort when the table names it, come from the harness's official **pricing/models** table for individual plans on this agent surface. Measurements come from [Artificial Analysis (AA)](https://artificialanalysis.ai/) **model** pages (Intelligence Index, Cost per Task, Time per Task) — the model itself, not a model-plus-harness run. Cost is AA Cost per Task only. Fetch those inputs with [`tools/harness-models.sh`](tools/harness-models.sh) and [`tools/aa-metrics.sh`](tools/aa-metrics.sh); they write CSVs under `dev/tmp/`. The map judges potential, not a frozen stack.

Wrappers pin the model token always, and pin effort only when the cell has an official effort **and** the wrapper form can hold it (`effort:` Claude Code, `model_reasoning_effort` Codex, `[effort=…]` Cursor).

#### Choosing the models

A map row is reproducible research, never recollection. Re-run on every model release. Record source URLs, retrieval date, and benchmark versions.

**Terms**

| Term | Meaning |
|---|---|
| **Family** | One official family + version from step 1 |
| **Official effort** | A level the harness's individual-plan pricing/models table names for that surface and model. If the table names none, the family has no official effort. A label that exists only on Artificial Analysis (reasoning, non-reasoning, Adaptive Reasoning) is not one |
| **Complete row** | An AA **model** row with independently finished numeric Intelligence Index, Cost per Task, and Time per Task > 0 — no `*`, no lab-claim stand-in |
| **Effort-comparable** | The family has a complete row for **two or more** official efforts. One complete official row, or none, is not comparable; a later rematch adds ` · effort` when more levels are measured |
| **Score** | `(Intelligence Index / Cost per Task) / Time per Task` — higher first |

1. **List names.** From the harness's official **pricing/models** table for **individual** plans on this exact agent surface, list every model the most permissive documented first-party individual plan names. Collapse the same family + version into one name (drop effort, Fast/standard, and other mode suffixes: `Grok 4.6 Fast` and `Grok 4.6 High` are both `Grok 4.6`). Record the accepted configuration value, underlying model, plan, surface, and every **official effort** token that table names for that model (`low`, `medium`, `high`, `xhigh`, `max`, or whatever the vendor names). If the table names none, record no official effort. Omit retired, utility, internal, arbitrary BYOK, and auto-routing. An alias or tier counts only when official docs resolve it to one family + version on the research date. Take names and effort from that harness table only — not from a vendor API catalog, a team/enterprise-only list, or Artificial Analysis.
2. **Join measurements.** Filter the AA catalog to the complete step-1 name list (every supported harness together): only families + versions those harnesses list remain — drop every other AA model. Then, for each name, every AA **model** row of that family + version — every measured effort and mode — is its own candidate. Record Intelligence Index, Cost per Task, and Time per Task, one table per harness. Do not use harness-stack scores (Coding Agent Index or any model-plus-agent run). Show gaps as `N/A`; exclude `*` estimates and lab claims from selection. Never substitute per-token or subscription price for Cost per Task. Calculate with downloadable source precision, never rounded display values.
3. **Select.** Drop any candidate missing Intelligence Index, Cost per Task, or Time per Task — only rows with all three remain. Do not impute. Thresholds are inclusive. This step is per harness. When this harness names no official effort for a family, collapse that family's remaining complete rows into one candidate **before** the filters: the unweighted mean of Intelligence Index, Cost per Task, and Time per Task; name it family + version only — not a measured effort or mode. Filter and rank on the collapsed candidate. After the filter, rank survivors by score; break a remaining tie with the lowest Cost per Task, then the lowest Time per Task.
   - **planner** — keep Intelligence Index ≥ that harness's best − `3`, then rank.
   - **implementer** — keep Intelligence Index ≥ that harness's best − `10`. Drop any survivor whose family + version is the planner's. Keep Cost per Task **strictly less** than the planner's. Then rank.
   - **mechanical** — keep Cost per Task between that harness's minimum and `3 ×` that minimum. Drop any survivor whose family + version is the planner's or the implementer's. Keep Cost per Task **strictly less** than the implementer's (and thus than the planner's). Then rank. An empty band after those cuts is a fallback — do not reopen the planner or implementer family.
4. **Fallback — only when measurement cannot decide** (empty band after step 3, no complete candidate, or Cost per Task then Time per Task still ties). Use only the harness's official task guidance: deep reasoning, architecture, and ambiguity for **planner**; agentic software development, implementation, and tool use for **implementer**; simple, repetitive, routine, fast, or cost-sensitive work for **mechanical**. Cite it and label `documented fallback`. If that guidance names **one** model, write that token (and an official effort token when the same guidance names one). If it does not name one model (including Auto/routing, or two names with no single winner), **repeat the previous category's cell**: implementer copies planner; mechanical copies implementer. Do not invent a quantitative winner.
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

A skill wrapper carries frontmatter (rule 9), then exactly:

```markdown
# <Title>

<One sentence: what this skill covers and who defines the work.>

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the planner gate, the route offer, and the dispatch.

Your base file is `$HOME/.ai-tools/skills/<name>.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
```

On Windows, `%USERPROFILE%` replaces `$HOME`. A skill that names no agent omits the contract paragraph.

## Scripts

Every process below is an executable script — the same command for a human or an AI. All are idempotent, skip-and-report per item, and honour the [Safety rules](#safety-rules) by construction.

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |

Processes: `install`, `remove`, `update`, `reinstall`, and read-only `verify`. `--help` lists flags. On Windows, run those same scripts from WSL or Git Bash.

On top of rules 25–27:

- **Scope** — `--harnesses <list>` (comma-separated folder names under `agents/`); default is every detected harness. An AI running a mutating script asks for scope first and passes the flag.
- **Dry run** — `--dry-run` reports every action and changes nothing: the findings/approval report for unattended runs.
- **Destructive flags** — `--discard-local` (reset discarding local work in the clone), `--instructions` (unlink global instructions on removal), `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Symlink fallback** — where the OS refuses symlinks (Windows without Developer Mode or elevation, mounts without symlink support), agents and skills install as copies, reported `copied (will not track updates)`. Global instructions are never copied — offer an include pointer so this repo stays the single source of truth.

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
- **wrapper body** — the body is reconstructed from this README's canonical text and compared exactly (rule 6)
- **skill wrapper body** — every `skills/*/SKILL.md` matches this README's canonical skill wrapper body (rule 7)
- **skill layout** — `skills/SKILL-CONTRACT.md` and `skills/MAINTAINER.md` exist; every skill has exactly one base at `skills/<name>.md`, with no orphans (rule 7)
- **model parity and effort pinning** — every pinned model and effort resolves through `MODELS.md` (rules 11–12); Grok wrappers declare no model
- **description parity** — an agent's `description` is identical across all six wrappers
- **`MODELS.md` row coverage** — every harness directory has a row and vice versa (rule 12)
- **size caps** — `USER-AGENTS.md` at most 8,000 characters (rule 3), every wrapper at most 1,000 (rule 6), every skill wrapper at most 2,000 characters and every skill `description` at most 500 (rules 7, 9)
- **encodings and endings** — line endings (`git ls-files --eol`), executable bits, no binaries in shipped paths (rule 28)
- **version bump** — only with `--base <ref>`: a change under `agents/`, `skills/`, `scripts/`, or `USER-AGENTS.md` that lands on `master` requires the README version to change too (rule 4)

Exit codes: `0` clean, `1` aborted on a precondition (unknown flag, `--base` without a value), `2` finished with findings. CI (`.github/workflows/ci.yml`) runs two jobs on `ubuntu-latest`: `lint` runs the version-bump check on pull requests and `shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh` on every push and pull request; `test-shell` runs `tools/test.sh`.

When a rule in this README becomes mechanically verifiable, add its check to `tools/lint.sh` and its rule number to the list above in the same commit — the two caps above (rules 3, 6) are stated here as rules; the linter only enforces them, and this README is the number a reader trusts.

`tools/test.sh` is a development check too, and outside rules 25–27 the same way: it runs `install`, `remove`, `update`, `reinstall`, and `verify` against a disposable fake `HOME`, never the real one, and asserts the installation and script contract (rules 19–27). Run it from anywhere:

```bash
"$HOME/.ai-tools/tools/test.sh"                    # run every case
"$HOME/.ai-tools/tools/test.sh" --case install --keep   # one case file, keep the sandbox
```

The fixture stages, before any script runs: a pre-populated harness layout for all six harnesses, a local `origin` git remote so no run reaches the network, a foreign file on a destination path, a locally modified copy, an unmanaged Grok block, and a stale link from an older layout. Against it, the suites assert:

- symlink first, copy fallback (rule 19)
- never overwrite a user file (rule 20)
- never remove what ai-tools did not create (rule 21)
- idempotency and skip-and-report on conflict (rule 22)
- `$HOME/AGENTS.md` untouched (rule 24)
- destructive flags default to refuse, `--dry-run` changes nothing (rule 27)
- exit codes `0`/`1`/`2` (rule 27)

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), [Update](#update), and [Reinstallation](#reinstallation), on top of rules 19–24:

- **Never replace** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 20, 22). Silent overwrite is a bug. A destination that is already the correct link is left alone.
- **Never** `rm -rf` a harness agents or skills root; remove individual links only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 21).
- Never touch vendor bundles (`~/.grok/bundled/`), unrelated user agents or skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/AGENTS.md` (rule 24).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

Implemented once — `safe_link`, `link_or_copy`, `safe_unlink`, `safe_uninstall_copy` in [`scripts/shell/lib.sh`](scripts/shell/lib.sh). Scripts refuse the unsafe path; manual intervention must honour the same rules.

## Supported harnesses

One row per harness: global instructions, skills, agents, wrapper folder, and wrapper file form.

| Harness | Global instructions destination | Skills root | Agents root | Wrapper folder · agent file form |
|---|---|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` | `$HOME/.claude/agents/` | `agents/claude-code/` · `*.md`, frontmatter `model:` (`opus`/`sonnet`/`haiku`/`fable`/full ID/`inherit`) |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` | `$HOME/.grok/agents/` | `agents/grok/` · `*.md`; **no `model:` in frontmatter** — models pinned in `~/.grok/config.toml` (see [Installation](#installation)) |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` | `$HOME/.codex/agents/` | `agents/codex/` · `*.toml`, keys `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` | `$HOME/.copilot/agents/` | `agents/copilot/` · `*.agent.md`; `model:` must be a **string** — the CLI rejects the array form VS Code Copilot Chat accepts |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/config/skills/` | `$HOME/.gemini/config/agents/` | `agents/antigravity/` · `*.md`, frontmatter `name`, `description`, `model` (`inherit`/`flash`/`pro`), `subagent`, `mainAgent`, `commandExecutionPolicy` |
| Cursor | Not linked — no documented path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` | `$HOME/.cursor/agents/` | `agents/cursor/` · `*.md`, `model:` accepts bracketed parameters (`<model>[effort=high]`) |

Notes:

- **Antigravity lives under `$HOME/.gemini`**: instructions at `GEMINI.md`, skills and agents at `config/skills/` and `config/agents/`. Do not install into `$HOME/.gemini/skills/` or `$HOME/.gemini/agents/` (retired Gemini CLI roots). The stale-link sweep unlinks leftover ai-tools links there without touching `config/`.
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

1. **Preconditions** — clone to `$HOME/.ai-tools` when missing and validate the tree (rule 23; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery** — report each detected harness (config directory, CLI, or known IDE extension) and possible AI extensions it will never touch. `$HOME/.agents` is reported, never linked into.
3. **Instructions** — link `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; Antigravity uses `$HOME/.gemini/GEMINI.md`; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **User overlay** — create `$HOME/AGENTS.md` empty only when missing (rule 24). Write its contents only if the user later asks for that directly.
5. **Agents** — link each wrapper from `agents/<harness>/` into that harness's agents root, per file, never per directory — those roots hold other agents, and a directory link would shadow them.
6. **Skills** — link each `skills/*-ai-tools` directory into each scoped skills root; the same shared directory serves every harness (rules 7–9). Prefer these links over harness scan paths (Grok `[skills] paths`), which can clobber existing names.
7. **Grok model pinning** — Grok ignores `model:` in frontmatter and reads `~/.grok/config.toml`. The script maintains a marker-delimited `[subagents.models]` block: names from the tree, models from [`MODELS.md`](MODELS.md) (unreadable map → skip and report, never guess). A pre-existing unmanaged block is skipped and reported, never edited. Without the pin, agents still load but inherit the session model — the strong-model guarantee is lost. The same fallback applies to any harness that ignores `model:`.
8. **Verify** — instructions resolve into the clone, `USER-AGENTS.md` fits the 12,000-character cap (rule 3), `agents/SUBAGENT-CONTRACT.md`, `skills/SKILL-CONTRACT.md`, and every agent and skill base exist at the pinned path, and every installed agent and skill is a link or an unmodified copy. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches agents or skills at startup. Confirm the three agents (`planner-ai-tools`, `implementer-ai-tools`, `mechanical-ai-tools`) and a slash command for every shipped skill.

## Removal

Unlink from harnesses — not delete the clone. Leaving `$HOME/.ai-tools` on disk is normal and makes [Update](#update) a reset plus re-link.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # unlink agents and skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

1. **Report** — list every ai-tools link, possible copy, and instructions link in the scoped roots before touching anything.
2. **Agents and skills** — unlink links; remove copies only while their contents still match their source. A locally modified copy is user work: skip and keep (rule 21).
3. **Grok** — delete only the marker-delimited ai-tools block in `~/.grok/config.toml`. Leave an unmanaged `[subagents.models]` untouched; never remove the file.
4. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips it.
5. **Instructions** — only with `--instructions`, and only destinations that are ai-tools links. Edit an include pointer out by hand; never delete that file. **Never `$HOME/AGENTS.md`** (rule 24).
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
3. **Refresh copies** — a copy matching the pre-reset revision is stale, not user work: replace it. One matching neither revision was modified locally: skip and keep (rule 21).
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

Then restart or reload the harness and confirm the three agents and a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user sets a remote or re-clones from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there (rule 23). Wrappers hardcode that path; no other location is recoverable by configuration.
- **Agents missing after install/update:** the harness caches agents at startup — fully restart the CLI or IDE, then `verify`.
- **Dangling links after an upstream rename or layout change:** [Reinstallation](#reinstallation); links are never upgraded in place.
- **Copied agents out of date:** copies do not track `git pull` — [Update](#update). If a copy predates the locally known previous revision, [Reinstallation](#reinstallation).
- **A destination is a non-ai-tools file the user wants replaced:** the scripts always skip and report it; the user removes that file themselves, per path.
- **An agent runs on the wrong (weak) model:** pinning is not applied. Grok: check the managed `[subagents.models]` block in `~/.grok/config.toml` (re-run [Installation](#installation) to restore it). Others: compare the installed wrapper to `$AI_TOOLS/agents/<harness>/` and [`MODELS.md`](MODELS.md).
- **`copied (will not track updates)`:** the OS refused symlinks (on Windows: Developer Mode or an elevated shell, then [Reinstallation](#reinstallation) converts copies to links). Until then, [Update](#update) after every upstream change on that machine.

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is carrying the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, dispatched work that can create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- No per-file license headers in shipped artifacts. `USER-AGENTS.md` is capped at 12,000 characters (rule 3) and every artifact is bound by rule 15. A root `LICENSE` covers redistribution; installing on one's own machine is not redistribution.
