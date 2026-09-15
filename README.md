# ai-tools

> **Version 0.0.51-ALPHA** — under active development. Suitable for testing; alpha versions provide neither guarantees nor backward compatibility (rule 4).

## Overview

A toolkit of **skills** and **user-wide instructions** for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, and Cursor.

This repository is the source of those tools. It is installed on the user's machine at `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows). Installation copies artifacts into each harness's user configuration.

How it operates:

1. **A harness toolkit.** Skills and `USER-AGENTS.md` are what the supported harnesses load after install.
2. **Machine-local install.** `$HOME/.ai-tools` is the only supported clone. Installed instructions and skills reference that path.
3. **User-wide instructions.** [`USER-AGENTS.md`](USER-AGENTS.md) is copied as the global instructions file for every supported harness that has a destination. After install it is the user-wide routing file; it is not this repository's rule file (rule 3). Cursor has no documented destination.
4. **Session-first skills.** Skills provide session-directed workflows in semantic XML. The host session executes them on its own model, interacts with the user, and coordinates git delivery. Builds, tests, script runs, and bulk fact collection go to the harness's default subagent; only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers, on a model the user picks from one question.
5. **Frontmatter only in the host session.** Harnesses keep skill `name` and `description` in the skill list without loading the body. The host session offers skills from that in-memory description and reads the body only when it runs the skill.

### Contents

| Path | What it is |
|---|---|
| [`USER-AGENTS.md`](USER-AGENTS.md) | User-wide routing after install: skill-offer gate, execution protocol, language, native question tool, and security. Copied to each harness's global instructions destination. Workflows live in skills |
| [`docs/USAGE.md`](docs/USAGE.md) | Harness-agnostic invocation guide for every shipped skill |
| [`skills/`](skills/) | Each `skills/<name>/SKILL.md` has a semantic XML body. Harnesses list frontmatter; the session executes the workflow |
| [`scripts/`](scripts/) | `scripts/shell/` install processes ([Scripts](#scripts); rules 18–21); `lint.sh`, `test.sh`, and its sourced `scripts/test/` case files ([Development checks](#development-checks)). Windows: WSL or Git Bash |
| [`ROADMAP.md`](ROADMAP.md) | Advisory story backlog; this README stays the source of truth |
| `dev/` | Plans, tasks, and campaigns in progress, plus untracked `dev/tmp/` (rule 22) |

### Quick start

Humans and AIs use the same commands ([Scripts](#scripts)):

```bash
# Linux, macOS, WSL, Git Bash (Windows: WSL or Git Bash — no PowerShell)
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# zsh:
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-zsh.sh | zsh
```

After the clone exists, `"$HOME/.ai-tools/scripts/shell/update.sh"` refreshes it. `install.sh`, `remove.sh`, and `update.sh` take `--dry-run`; those three and `verify.sh` take `--help`. Or, in a harness:

> Install ai-tools following <https://raw.githubusercontent.com/hgsantana/ai-tools/master/README.md>

The AI follows the matching process section below and runs that same script.

After installation, see the harness-agnostic [usage guide](docs/USAGE.md) for skill prompts.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the repository's source of truth for its explanation, rules, and installation, removal, and update processes. `scripts/` provides their executable form (rules 18–21).
2. For work in this repository, this README takes precedence over user-wide and harness-global instructions, including an installed `USER-AGENTS.md`.
3. `USER-AGENTS.md` is an installation artifact for user-wide harness instructions, not this repository's rule file. After a title and a short preamble, its body is semantic XML under `<user_instructions>` ([Semantic XML grammar](#semantic-xml-grammar)) with no markdown sub-headings, and every internal cross-reference is a deterministic XML tag reference. Its self-imposed **8,000-character** cap is tighter than every current harness constraint, including Antigravity's 12,000-character limit. Every shipped artifact fits the strictest harness that consumes it. Register stricter constraints in [Supported harnesses](#supported-harnesses) and update affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top) versions provide no backward compatibility or migration notes; this README describes only the current state. Repair older layouts through [Update](#update) and its stale-link sweep. Every pull request that changes `skills/`, `scripts/`, or `USER-AGENTS.md` changes the version against its base branch; stacked pull requests each bump once. Backward-compatibility records begin with the first stable release.

### Structure and authoring

5. Skills are harness-agnostic and live entirely in `skills/<name>/SKILL.md`, with frontmatter defined by rule 6 and bodies structured in semantic XML tags (`<skill>`, `<session_workflow>`, `<dispatch_templates>`). They use no per-harness copies, separate skill contracts or bases, root-level `skills/<name>.md`, `SKILL-CONTRACT.md`, or `MAINTAINER.md`; required maintainer text is duplicated. Descriptions contain three parts and at most 500 characters (rule 6); bodies have no character cap but follow rule 8. Skills contain neither **Stake** nor **Continue?** headings. Harnesses retain frontmatter without loading the body. `USER-AGENTS.md` offers skills from that in-memory description (the only USER-AGENTS.md gate); the host session executes the `<session_workflow>`. Skills run on the session model; a `<template>`'s `executor` decides where its payload runs ([Semantic XML grammar](#semantic-xml-grammar)). Only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers, after one implementer-model question guided by their `<implementer_job>`. Optional blocks `<status_protocol>`, `<return_protocol>`, `<plan_file_format>`, and `<implementer_job>` hold protocol that steps and templates cite ([Semantic XML grammar](#semantic-xml-grammar)). `gh-ai-tools` covers GitHub-hosted resources and administration; repository code work such as commits, branches, rebases, merges, pushes, code review, and pull-request delivery bypasses it and runs directly.
6. Skill frontmatter uses universally accepted `name` and `description`, plus optional keys supported by every harness, such as `argument-hint`. The `description`, which harnesses retain without loading the body, states in order: (1) what the skill does and when to use it, including `/name`; (2) `Impact:` plus what can be billed, deleted, committed, pushed, or otherwise changed—or that impact is absent; (3) `Agent:` with `session` when the skill never spawns implementers, or `session + implementer (model asked once)` exactly when its body defines `<implementer_job>` and a `<template executor="implementer">`, which only `vibe-ai-tools` and `campaign-ai-tools` may do; the skill offer's Execution column shows this value. Keep it within **500 characters** because harnesses budget the skill list: Codex caps it at 2% of context or 8,000 characters, and Claude Code truncates it at 1,536.
7. Every installed skill directory, slash command, and frontmatter `name:` ends in `-ai-tools`; bare names such as `plan` and `az` remain uninstalled.
8. Use extreme concision: remove ambiguity and redundancy while preserving every instruction, rule, and intention.
9. Skills and `USER-AGENTS.md` state what to do in the [Semantic XML grammar](#semantic-xml-grammar): every cross-reference is a backticked tag reference that resolves (`<skill_offer>`, `<template role="...">`, `<step id="...">`), every variable is a `{PLACEHOLDER}`, every `<rule>` has an `id`, and every `<template>` names its `role` and `executor`. A skill with a `<template>` cites USER-AGENTS `<execution_protocol>` for spawning and never restates the harness native subagent API list. Prose citations of this README use section anchors, never rule numbers. A negative (`never`, `do not`) is used only when it reinforces an essential positive, or when the positive phrasing would lose force or not make sense.
10. Repository files use concise English; chat uses the user's language. Rule 25 assigns content between them.
11. A skill that can be **destructive** or **generate cost** states that impact once in its `description` `Impact:` (rule 6), rather than in a body Stake section. `USER-AGENTS.md` surfaces it **before** execution in the skill offer table, whose Description column comes from `Impact:` and Execution column from `Agent:`.

### Semantic XML grammar

The semantic-XML bodies (`USER-AGENTS.md` and every `SKILL.md`) follow one grammar, enforced by `scripts/lint.sh` (rule 9):

- **Angle brackets** appear only as structural tags from the vocabulary below, or as a backticked reference to one: `` `<template role="stage-implementer">` ``, `` `<step id="2">` ``, `` `<security_guardrails>` ``. Once backticked spans are removed, every body is balanced XML.
- **Variables** are brace placeholders: `{SLUG}`, `{BASE_BRANCH}`, `{COMMANDS}`. Every placeholder a `<template>` uses is declared in its `<input>`, and every declared one is used; the session substitutes them before spawning.
- **References** carrying an attribute (`role`, `id`, `code`, `type`) resolve to a definition in the same file, or in the file named by the word before the backtick: `` dev-ai-tools `<status_protocol>` ``, `` USER-AGENTS `<security_guardrails>` ``. Qualifiers are `USER-AGENTS` or a skill name. A bare reference names a vocabulary tag.
- **Identity**: every `<rule>` carries a kebab-case `id`, unique in its file; every `<template>` carries a functional `role` and an `executor`; `<step>` ids are numeric per workflow; `<case>`, `<response>`, `<signal>`, and `<state>` carry `id`, `type`, or `code`.
- **Executors**: USER-AGENTS `<execution_protocol>` defines the three valid `executor` values (`default-worker`, `implementer`, `session-subagent`) and where each runs, the harness's native subagent API list, the payload rule (populated payload and file paths, never conversation context), the spawn announcement, the spawn-failure fallback and its skill-level opt-out (campaign passes), and the parallelism rule for concurrent subagents. Work the session does itself is a `<step>`, never a template.
- **Protocol** is a block, not prose: return tokens live in `<return_protocol>`/`<signal>` and stage states in `<status_protocol>`/`<state>`. A template whose outcome the caller branches on ends with one cited `<signal>`; any other template returns a one-line outcome with paths.

Vocabulary. A new tag is registered here and in `scripts/lint.sh` (`XML_VOCAB`) in the same commit; children of `<input>` are free payload fields and need no registration.

| Tag | File | Meaning |
|---|---|---|
| `<user_instructions>` | USER-AGENTS | root |
| `<system_overview>`, `<routing_gate>`, `<execution_protocol>`, `<language_rules>`, `<user_interaction>`, `<security_guardrails>` | USER-AGENTS | top-level sections |
| `<trigger_cases>` / `<case id condition>` | USER-AGENTS | routing cases |
| `<skill_offer>`, `<offer_message>`, `<skill_question>`, `<skill_options>`, `<handling>` / `<response type>` | USER-AGENTS | the gate, its chat message, question, and option templates, and its answers |
| `<chat>`, `<disk>` | USER-AGENTS | language destinations |
| `<default>`, `<fallback>` | USER-AGENTS | native-tool question rule and its chat fallback |
| `<skill name>` | skills | root |
| `<overview>`, `<session_workflow>`, `<boundaries>` | skills | what the session runs |
| `<dispatch_templates>` / `<template role executor>` / `<job>`, `<input>`, `<instructions>`, `<constraints>` / `<constraint>` | skills | the payload a template carries |
| `<status_protocol>` / `<states>` / `<state code>` | skills | stage-file states |
| `<return_protocol>` / `<signal code>` | skills | the worker's last line |
| `<plan_file_format>` / `<structure>` | skills | skill-specific protocol |
| `<implementer_job>` | skills | the implementer's job, from which the session offers 1-3 implementer models |
| `<step id name>` | all | one numbered workflow step; `name` optional (USER-AGENTS `<skill_offer>` omits it) |
| `<rule id>` | all | one addressable rule |

### Installation contract

12. Install global instructions and skill directories as **physical copies**. Never create an installation symlink; migrate a legacy symlink resolving into `$HOME/.ai-tools` to a copy.
13. Never overwrite a conflicting or locally modified destination by default. `--overwrite` explicitly replaces installed artifact paths for the selected harnesses; it never applies to `$HOME/AGENTS.md` or unrelated harness configuration.
14. Never remove anything ai-tools did not create. Removal drops only legacy ai-tools links and copies that still match their source. `--force` also drops those same known artifact destinations when contents differ; it never applies to `$HOME/AGENTS.md` or unrelated harness configuration.
15. Every install/remove/update step is idempotent; on conflict, skip and report unless the user passed the process's explicit replacement or forced-removal flag.
16. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Installed instructions and skills reference it; any other path breaks them.
17. `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) is user-owned: if present, follow it; if missing, ignore it. It is never created, edited, overwritten, truncated, symlinked, or removed.

### Script contract

18. Each process—install, remove, update, and verify—is `scripts/shell/<process>.sh` for Linux, macOS, WSL, and Git Bash, using bash 3.2+ and BSD/GNU tools. Shared logic lives once in `lib.sh`. First-install bootstrap scripts `install-bash.sh` and `install-zsh.sh` are self-contained (no `lib.sh`): they clone `$HOME/.ai-tools` then exec `install.sh`. Windows uses WSL or Git Bash rather than PowerShell or CMD mirrors.
19. `scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.
20. Scripts run to completion: per-item conflicts skip and report. Destructive steps are refused by default and require explicit flags (`--overwrite`, `--discard-local`, `--instructions`, `--force`, `--purge`). Every mutating process script (install, remove, update) supports `--dry-run`; the bootstrap scripts only clone, then pass their arguments to `install.sh`. Exit: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
21. Entry-point scripts (`scripts/*.sh`, `scripts/shell/*.sh`) are committed executable; case files under `scripts/test/` are sourced and are not. `.gitattributes` pins everything under `scripts/` to LF.

### Work state and reporting

22. Version work under `dev/` as a plan directory `dev/<slug>/`, a single-task file `dev/<slug>.md`, or a campaign directory `dev/improve/<campaign>/`. All are temporary working state and remain only while work is resumable. Comprehension documents and decisions stay tracked in Git during active work and are archived by copying into `dev/tmp/finished/` and applying `git rm` to the tracked original in the final commit, preserving the full rationale on the branch while keeping the repository root clean after merge. Generated state and volatile runtime caches live untracked under `dev/tmp/`.
23. `plan-ai-tools` records the checked-out branch it analyzes as the plan's base and aligns scope and trade-offs interactively with the user. It saves the agreed result under `dev/<slug>/` in the repository's plan structure: a base file (`0-<slug>.md`) and sequential stage files (`<n>-<slug>.md`). Each stage is isolated and corresponds to one commit boundary. A change small enough for a single commit is not planned: it belongs to `dev-ai-tools` Task mode.
24. `dev-ai-tools` runs both forms through one sequence: read the working repository's documentation, record the unit of work on disk, implement in short steps with one commit each, write and run behaviour tests before closing a step, update any documentation the step made stale, archive by copy-then-remove, and commit the archival last. Task mode records the current branch when the user requests the task, then iterates with the user before writing `dev/<slug>.md`. Queue mode lists unfinished base plans, proposes an order, and runs the accepted plans in turn. From there, every mode runs unattended, interrupting only for a blocker, a decision uncovered by implementation, or an approval reserved by the Security rules. The dedicated work branch starts from the recorded base branch, and the pull request targets that same branch: the analysis branch in Plan mode or the request-time branch in Task mode. The branch history is symmetric: the first commit introduces the plan or task file, and the last removes it. `vibe-ai-tools` plans interactively through `plan-ai-tools`, asks the implementer-model question once the plan is on disk, then runs this sequence with implementers writing stage code, logging in-scope decisions to `dev/<slug>/vibe-decisions.md`. `campaign-ai-tools` repeatedly invokes this sequence in campaign mode under user-defined priorities: a fresh subagent on the session model writes each user-directed multi-stage plan, a different fresh subagent on the session model executes and judges it with implementers on the model the user chose when the campaign started, and accepted commits accumulate locally on `improve/<campaign>` without a push or pull request. The campaign records the implementer model in `dev/improve/<campaign>/campaign.md` and reuses it on resume. A pass that cannot spawn its implementer or a default worker never does that work itself and ends blocked, so USER-AGENTS `spawn-fallback` never applies inside a pass. The campaign stops after a blocked pass or two consecutive planning passes with nothing to plan.
25. **Substance is written to disk; the session carries questions and pointers.** Plans, tasks, and campaigns go where rule 22 puts them. Every report, summary, finding, log, and other transient artifact goes under `dev/tmp/`, created if absent. `dev/tmp/` is generated state and stays untracked wherever it is created (rule 22): add the ignore rule when the repository lacks it. What reaches the user is the question that needs an answer, the approval that needs a yes, a one-line outcome, and the paths of what was written. Where the harness can open a file in the user's editor, open it rather than pasting its content. Restating on screen what already sits on disk spends the user's context twice and creates a second, diverging copy of the truth. This binds every skill and `USER-AGENTS.md`.

## Scripts

Every process below is an executable script shared by humans and AIs. Each is idempotent, handles conflicts per item by skipping and reporting, and enforces the [Safety rules](#safety-rules).

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |

Processes: `install-bash` / `install-zsh` (first clone), `install`, `remove`, `update`, and read-only `verify`. `--help` lists flags. On Windows, run those same scripts from WSL or Git Bash.

On top of rules 18–20:

- **Scope** — `--harnesses <list>` accepts comma- or space-separated harness keys (`claude-code`, `grok`, `codex`, `copilot`, `cursor`, `antigravity`). Omit the flag to select detected harnesses (the script aborts with exit `1` when none is detected); pass `--harnesses all` to select all six supported harnesses, including those not detected yet. An AI running a mutating script asks for scope first and passes the explicit answer.
- **Dry run** — `--dry-run` reports every proposed action while preserving state; it supplies the findings and approval report for unattended runs.
- **Destructive flags** — `--overwrite` on install and update (replace conflicting artifact destinations and prune orphan `*-ai-tools` artifacts in the selected harnesses), `--discard-local` (reset discarding local work in the clone), `--instructions` (remove global instructions on removal), `--force` (remove known artifact destinations and orphan artifacts even when contents no longer match), and `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Physical copies** — instructions and skills are always copied. Update removes current-version artifacts, then installs from `origin/master`; `--overwrite` is required for conflicting or locally modified installed artifacts.

## Development checks

Development checks live under `scripts/` beside `scripts/shell/`, outside the contract of rules 18–20. [`scripts/lint.sh`](scripts/lint.sh) is a development check, not an installation process: it enforces this repository's mechanically verifiable rules against the tree it runs in, with no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `tr`. Run it from anywhere:

```bash
"$HOME/.ai-tools/scripts/lint.sh"              # check the working tree
"$HOME/.ai-tools/scripts/lint.sh" --base <ref> # also check the version bump against <ref>
```

Check families:

- **naming** — skill directories end in `-ai-tools` (rule 7)
- **skill frontmatter** — every `skills/*/SKILL.md` exists, keys a subset of `name`/`description`/`argument-hint`, and `name:` matches its directory (rule 6)
- **skill description** — every skill `description` is at most 500 characters and states what it does, then `Impact:`, then `Agent:`, and names its own `/<name>` (rule 6)
- **agent field** — `Agent:` is `session`, or `session + implementer (model asked once)` exactly when the skill defines `<implementer_job>` and a `<template executor="implementer">`; only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers (rule 6)
- **skill layout** — no `skills/*.md` at the skills root and no `skills/SKILL-CONTRACT.md` or `skills/MAINTAINER.md`; the nine shipped skills `lint.sh` names are present; every `skills/*/` has a `SKILL.md` with a root `<skill name>`, `<session_workflow>`, and `<dispatch_templates>`, and no `## Continue?` or `## Stake` heading or mention of `SKILL-CONTRACT`/`MAINTAINER.md`; `USER-AGENTS.md` contains `<routing_gate>` and `<execution_protocol>` with rules `default-worker`, `implementer`, and `session-subagent`, its offer table uses the `Execution` column, and it has no `<agents>`, `<dispatch_protocol>`, or `<worker>` tag (rules 5, 11)
- **spawn protocol citation** — every skill with a `<template>` cites USER-AGENTS `<execution_protocol>`, and no skill repeats the harness native subagent API list (rule 9)
- **rule anchors** — no `SKILL.md` or `USER-AGENTS.md` cites a README rule number (rule 9)
- **size caps** — `USER-AGENTS.md` at most 8,000 characters (rule 3), every skill `description` at most 500 (rule 6)
- **instructions headings** — `USER-AGENTS.md` has no `##` sub-heading (rule 3)
- **line endings and modes** — every tracked `scripts/` file resolves to `eol=lf` with LF in index and working tree, and `scripts/*.sh` and `scripts/shell/*.sh` are mode `100755` (rule 21)
- **no binaries** — every tracked file under `skills/` and `scripts/` is text
- **`dev/tmp` untracked** — `git ls-files dev/tmp` returns nothing (rule 22)
- **xml grammar** — every semantic-XML body is balanced once backticked spans are removed, uses only vocabulary tags outside `<input>`, gives every `<rule>` a unique `id`, every `<step>` a numeric `id`, and `<case>`, `<response>`, `<signal>`, `<state>` their `id`, `type`, or `code`, and every `<template>` a `role` and a valid `executor` — one of the three USER-AGENTS `<execution_protocol>` defines as a rule id — never an `agent` attribute (rule 9, [Semantic XML grammar](#semantic-xml-grammar))
- **xml references** — every backticked tag reference resolves: attribute references to a definition in the same or the qualified file, bare references to the vocabulary (rule 9)
- **placeholder parity** — every `{PLACEHOLDER}` a `<template>` uses is declared in its `<input>`, and every declared one is used (rule 9)
- **vocabulary parity** — the Semantic XML grammar table and `XML_VOCAB` list the same tags (rule 9)
- **version bump** — only with `--base <ref>`: when `skills/`, `scripts/`, or `USER-AGENTS.md` changed between `<ref>` and `HEAD`, the README version line must differ from `<ref>`'s (rule 4)
- **rule citations** — Repository rules are numbered 1..N without gaps, and every `rule N` citation in `README.md`, `ROADMAP.md`, `docs/USAGE.md`, `.gitattributes`, and `scripts/` names an existing rule (rule 1)
- **harness table** — `lib.sh` harness keys, skills roots, and instructions destinations appear in the README Scope bullet and Supported harnesses table (rule 19)

Exit codes: `0` clean, `1` aborted on a precondition (unknown flag, `--base` without a value), `2` finished with findings. CI (`.github/workflows/ci.yml`) runs two jobs on `ubuntu-latest` for every push and pull request. `lint` runs `scripts/lint.sh`, adding `--base` with the pull request's base SHA on pull requests, then `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`. `test-shell` runs `scripts/test.sh`.

When a rule in this README becomes mechanically verifiable, add its check to `scripts/lint.sh` and its rule number to the list above in the same commit — the caps above (rules 3, 6) are stated here as rules; the linter only enforces them, and this README is the number a reader trusts.

`scripts/test.sh` is likewise a development check outside rules 18–20: it runs `install`, `remove`, `update`, and `verify` against a disposable fake `HOME`, never the real one, and asserts rules 12–15, 17, and 20. Every `scripts/test/*.sh` other than `lib.sh` is a case file defining `case_*` functions, discovered by glob; `--case` takes a case-file basename or one function name. Run it from anywhere:

```bash
"$HOME/.ai-tools/scripts/test.sh"                    # run every case
"$HOME/.ai-tools/scripts/test.sh" --case install --keep   # one case file, keep the sandbox
```

Each case builds its own fixture: a harness layout for all six harnesses and a local `origin` git remote so no run reaches the network, plus, per case, a foreign skill or instructions file, a locally modified copy, a stale link from an older layout, or a symlink pointing outside the clone. Against it, the suites assert:

- physical copies only, including migration from legacy ai-tools symlinks (rule 12)
- no overwrite by default and selected-harness overwrite with the explicit flag (rule 13)
- never remove what ai-tools did not create (rule 14)
- idempotency and skip-and-report on conflict (rule 15)
- `$HOME/AGENTS.md` untouched (rule 17)
- destructive flags default to refuse, `--dry-run` changes nothing (rule 20)
- exit codes `0`/`1`/`2` (rule 20)

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), and [Update](#update), on top of rules 12–17:

- **Never replace by default** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 13, 15). `--overwrite` is the only authorization to replace those exact artifact destinations and prune orphan `*-ai-tools` artifacts in selected harnesses. A matching copy is left alone.
- **Never** recursively remove a harness's skills root; replace or remove individual artifact paths only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 14). `--force` is the only authorization to remove those exact artifact destinations and orphan artifacts when contents differ. `$HOME/AGENTS.md` remains untouched.
- Never touch vendor bundles (`~/.grok/bundled/`), unrelated user skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/AGENTS.md` (rule 17).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

The safe-copy, legacy-link-removal, and copy-removal primitives are implemented once in [`scripts/shell/lib.sh`](scripts/shell/lib.sh). Scripts refuse unsafe paths; manual intervention must honour the same rules.

## Supported harnesses

One row per harness: global instructions destination and skills root.

| Harness | Global instructions destination | Skills root |
|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` |
| Grok Build | `$HOME/.grok/AGENTS.md` | `$HOME/.grok/skills/` |
| OpenAI Codex | `$HOME/.codex/AGENTS.md` | `$HOME/.codex/skills/` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/config/skills/` |
| Cursor | Not copied — no documented path for global User Rules; Cursor reads project-root `AGENTS.md` natively | `$HOME/.cursor/skills/` |

Notes:

- **Antigravity lives under `$HOME/.gemini`**: instructions at `GEMINI.md`, skills at `config/skills/`. Do not install into `$HOME/.gemini/skills/` (retired Gemini CLI root). The stale-link sweep unlinks leftover ai-tools links there without touching `config/`.
- **Antigravity limits rules files to 12,000 characters.** The repository's stricter self-imposed 8,000-character cap governs `USER-AGENTS.md` (rule 3); Antigravity truncates or rejects files above its own limit.
- **Codex** reads `~/.codex/AGENTS.override.md` first if it exists; otherwise, it reads `~/.codex/AGENTS.md`. Never create, edit, or remove an existing `AGENTS.override.md` — it is user-authored and out of scope.
- **Never install into `$HOME/.agents/`.** Several harnesses discover it; copying there as well as into each harness root would double-register every skill.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# zsh:
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-zsh.sh | zsh
```

The bootstrap script is self-contained: it requires `git`, clones `https://github.com/hgsantana/ai-tools.git` to `$HOME/.ai-tools` when that path is free, then execs `install.sh`. If the clone already exists, it prints the `update.sh` command and exits without changing anything; a path that exists but is not a clone aborts with exit `1`. Extra flags after `| bash -s --` reach `install.sh`.

Every `install.sh` step is idempotent and reports conflicts it skips.

1. **Preconditions** — the clone at `$HOME/.ai-tools` exists and validates; `install.sh` clones it when missing, except under `--dry-run` (rule 16; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery and scope** — report each detected harness from its configuration directory, CLI, or known IDE extension, plus possible AI extensions outside scope. Omitted `--harnesses` selects those detected harnesses; `--harnesses all` selects all six and creates their skill roots as needed. Report `$HOME/.agents` while leaving it untouched.
3. **Instructions** — copy `USER-AGENTS.md` to each scoped harness's global instructions destination (`--no-instructions` skips). Cursor has none; Antigravity uses `$HOME/.gemini/GEMINI.md`; an existing `~/.codex/AGENTS.override.md` is reported, never touched.
4. **Skills** — recursively copy each `skills/*-ai-tools` directory into every scoped skills root (rules 5–6). Harnesses list frontmatter; the host session reads the body only when it runs the skill. With `--overwrite`, orphan `*-ai-tools` skills no longer in the tree are pruned from the scoped roots.
5. **Verify** — every installed instruction and skill is a physical copy matching its source; `USER-AGENTS.md` fits the repository's 8,000-character cap (rule 3); every shipped `skills/<name>/SKILL.md` exists. Any installation symlink or an orphan `*-ai-tools` skill is a finding. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches skills at startup. Confirm a slash command for every shipped skill.

## Removal

Remove installed artifacts from harnesses while retaining the clone. Keeping `$HOME/.ai-tools` allows later installation or update.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # remove skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --force   # also drop modified copies
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # full removal
```

1. **Report** — list every possible ai-tools artifact and legacy link in the scoped roots before changing them.
2. **Skills** — remove copies only while their contents still match their source; also unlink legacy links resolving into ai-tools. A locally modified copy is user work: skip and keep (rule 14), unless `--force`. Orphan `*-ai-tools` skills no longer in the tree are removed only with `--force`.
3. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips it.
4. **Instructions** — only with `--instructions`; remove an exact source copy or a legacy ai-tools link, and preserve a modified or foreign destination unless `--force`. Never remove `$HOME/AGENTS.md` (rule 17).
5. **Verify** — report any link in the scoped roots that still resolves into the clone; expect none.
6. **Purge** — with `--purge` only (prompt; `--yes` skips), delete `$HOME/.ai-tools` while always preserving `$HOME/AGENTS.md`.

When `$HOME/.ai-tools` is missing, copies cannot be compared: the script warns and removes only ai-tools links.

If `$AI_TOOLS/skills` was added to a harness scan path (Grok `[skills] paths`), remove only that entry, by hand — never wipe the config file. Restart the harness: skill slash commands leave its menu.

## Update

Remove artifacts using the **current** clone (the user's version), reset that clone to `origin/master`, then install from the fresh tree.

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

1. **Preconditions** — require the clone at `$HOME/.ai-tools`; if missing, [Installation](#installation) instead. Fetch `origin/master` and refuse a discarding reset unless `--discard-local`, **before** touching harness artifacts.
2. **Remove** — using this clone's skills and instructions: skills, the stale-link sweep (`--no-sweep` skips), and instructions (`--no-instructions` keeps them). Drop unmodified copies and legacy ai-tools links; skip and report modified copies.
3. **Reset** — check out `master` and reset `--hard` to `origin/master`. The destructive scope is **the clone only**; `$HOME/AGENTS.md` remains untouched.
4. **Install** — the Installation steps against the fresh tree, listing skills from the tree, never from hardcoded names.
5. **Verify** — the Installation checks.

The scripts target `master` only and abort when `origin/master` is missing; a renamed default branch needs a script change, never a guessed branch.

Then restart or reload the harness and confirm a slash command for every shipped skill.

## Troubleshooting

- **Local changes the user wants to keep:** the scripts refuse the reset and show what would be lost — stash, branch, or explicitly approve `--discard-local`; never reset manually around the guard.
- **`origin/master` missing or fetch failed:** fix remote auth or URL; never invent a remote.
- **Not a clone / no remote:** the user sets a remote or re-clones from `https://github.com/hgsantana/ai-tools.git`; never invent a URL.
- **Clone is not at `$HOME/.ai-tools`:** move it there (rule 16). Installed instructions and skills reference that path; no other location is recoverable by configuration.
- **Skills missing after install/update:** the harness caches skills at startup — fully restart the CLI or IDE, then `verify`.
- **Legacy or dangling ai-tools links:** [Update](#update) sweeps stale links after removing current-version artifacts.
- **Installed copies out of date:** copies do not track `git pull` — use [Update](#update).
- **A conflicting or locally modified installed artifact should be replaced:** rerun install or update with `--overwrite` and an explicit `--harnesses` scope. The flag affects only known artifact destinations in that scope.
- **A locally modified installed artifact should be removed:** rerun remove with `--force` and an explicit `--harnesses` scope. The flag affects only known artifact destinations and orphan `*-ai-tools` skills in that scope.
- **A copied artifact was edited locally:** preserve the edit elsewhere before `--overwrite` or `--force`; installed copies are managed deployment artifacts, while `$HOME/AGENTS.md` remains the supported place for personal instructions.

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is retaining the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, dispatched work that can create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- Use the root `LICENSE` instead of per-file license headers in shipped artifacts. `USER-AGENTS.md` follows the **8,000-character** cap in rule 3, and every artifact follows rule 8. Installation on one's own machine is not redistribution.
