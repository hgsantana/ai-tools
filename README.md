# ai-tools

> **Version 0.0.76-ALPHA** — under active development. Suitable for testing; alpha versions provide neither guarantees nor backward compatibility (rule 4).

## Overview

A toolkit of **skills** and **user-wide instructions** for Claude Code, GitHub Copilot, and Google Antigravity.

This repository is installed at `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows). Installation links artifacts (falling back to copies when symlinks are unavailable) into each harness's user configuration.

How it operates:

1. **A harness toolkit.** Skills and `AI-TOOLS-AGENTS.md` are what supported harnesses load after install.
2. **Machine-local install.** `$HOME/.ai-tools` is the only supported clone. Installed instructions and skills reference that path.
3. **User-wide instructions.** [`AI-TOOLS-AGENTS.md`](AI-TOOLS-AGENTS.md) is linked (or fallback-copied) as the global instructions file for every supported harness. It provides global execution, interaction, and security protocols without replacing harness flows (rule 3). Includes Copilot `applyTo: "**"` and Cursor `alwaysApply: true` so destinations attach automatically.
4. **Session-first skills.** Skills provide session-directed workflows in semantic XML. The host session executes them on its model and interacts with the user; builds, tests, and delegated tasks go to subagents or fresh implementers per skill protocol. See [`docs/USAGE.md`](docs/USAGE.md).
5. **Frontmatter only in the host session.** Harnesses keep skill `name` and `description` in the skill list without loading the body. Skills are invoked explicitly by slash-command or skill name.

### Documentation & Contents

| Path | What it is |
|---|---|
| [`AI-TOOLS-AGENTS.md`](AI-TOOLS-AGENTS.md) | User-wide instructions installed into each harness's global instructions destination |
| [`docs/USAGE.md`](docs/USAGE.md) | Harness-agnostic invocation guide and examples for every shipped skill |
| [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) | Development checks, linter checks catalog, test suite fixtures, and CI |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common issues, diagnostics, recovery steps, and harness activation |
| [`skills/`](skills/) | Shipped skills in semantic XML (`skills/<name>/SKILL.md`) |
| [`scripts/`](scripts/) | Installation, update, removal, verification, lint, and test scripts ([Scripts](#scripts); rules 18–21) |
| `docs/<skill>/<slug>/` | Transient plans, reports, and campaign state in progress (rule 22) |

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

The AI follows the matching process section below and runs that same script. After installation, see the harness-agnostic [usage guide](docs/USAGE.md) for skill prompts.

## Repository rules

Normative for every human and every AI maintaining this repository.

### Source of truth

1. This `README.md` is the repository's source of truth for its explanation, rules, and installation, removal, and update processes. `scripts/` provides their executable form (rules 18–21).
2. For work in this repository, this README takes precedence over user-wide and harness-global instructions, including an installed `AI-TOOLS-AGENTS.md`.
3. `AI-TOOLS-AGENTS.md` is an installation artifact for user-wide harness instructions, not this repository's rule file. After YAML frontmatter (`applyTo: "**"` and `alwaysApply: true` for Copilot and Cursor attachment), a title, and a short preamble, its body is semantic XML under `<user_instructions>` ([Semantic XML grammar](#semantic-xml-grammar)) with no markdown sub-headings, and every internal cross-reference is a deterministic XML tag reference. Its self-imposed **10,000-character** cap is tighter than every current harness constraint, including Antigravity's 12,000-character limit. Every shipped artifact fits the strictest harness that consumes it. Register stricter constraints in [Supported harnesses](#supported-harnesses) and update affected artifacts in the same commit.
4. Pre-release (`0.x`/ALPHA at the top) versions provide no backward compatibility or migration notes; this README describes only the current state. Repair older layouts through [Update](#update) and its stale-link sweep. Every pull request that changes `skills/`, `scripts/`, or `AI-TOOLS-AGENTS.md` changes the version against its base branch; stacked pull requests each bump once. Backward-compatibility records begin with the first stable release.

### Structure and authoring

5. Skills are harness-agnostic and live entirely in `skills/<name>/SKILL.md`, with frontmatter defined by rule 6 and bodies structured in semantic XML tags (`<skill>`, `<session_workflow>`, `<dispatch_templates>`). They use no per-harness copies, separate skill contracts or bases, root-level `skills/<name>.md`, `SKILL-CONTRACT.md`, or `MAINTAINER.md`; required maintainer text is duplicated. Descriptions explain what the skill does and when to use it within 500 characters (rule 6); bodies have no character cap but follow rule 8. Skills contain neither **Stake** nor **Continue?** headings. Harnesses retain frontmatter without loading the body; the host session executes the `<session_workflow>`. Skills run on the session model; a `<template>`'s `executor` decides where its payload runs ([Semantic XML grammar](#semantic-xml-grammar)). `agy-ai-tools`, `claude-ai-tools`, and `copilot-ai-tools` each hardcode their harness's tier table. Optional blocks `<status_protocol>` and `<return_protocol>` hold protocol that steps and templates cite ([Semantic XML grammar](#semantic-xml-grammar)). `gh-ai-tools` covers GitHub-hosted resources and administration; repository code work such as commits, branches, rebases, merges, pushes, code review, and pull-request delivery bypasses it and runs directly.
6. Skill frontmatter uses universally accepted `name` and `description`, plus optional keys supported by every harness, such as `argument-hint`. The `description`, which harnesses retain without loading the body, explains what the skill does and when to use it, including `/<name>`, without metadata prefixes or agent fields. Keep it within **500 characters** because harnesses budget the skill list: Claude Code truncates it at 1,536.
7. Every installed skill directory, slash command, and frontmatter `name:` ends in `-ai-tools`; bare names such as `plan` and `az` remain uninstalled.
8. Use extreme concision: remove ambiguity and redundancy while preserving every instruction, rule, and intention.
9. Skills and `AI-TOOLS-AGENTS.md` state what to do in the [Semantic XML grammar](#semantic-xml-grammar): every cross-reference is a backticked tag reference that resolves (`<template role="...">`, `<step id="...">`), every variable is a `{PLACEHOLDER}`, every `<rule>` has an `id`, and every `<template>` names its `role` and `executor`. Skills never duplicate the harness native subagent API list. Prose citations of this README use section anchors, never rule numbers. A negative (`never`, `do not`) is used only when it reinforces an essential positive, or when the positive phrasing would lose force or not make sense.
10. Repository files use concise English; chat uses the user's language. Rule 23 assigns content between them.
11. Skills contain neither **Stake** nor **Continue?** headings; destructive actions, cost generation, and mutations require explicit user approval per user-wide `<security_guardrails>`.

### Semantic XML grammar

The semantic-XML bodies (`AI-TOOLS-AGENTS.md` and every `SKILL.md`) follow one grammar, enforced by `scripts/lint.sh` (rule 9):

- **Angle brackets** appear only as structural tags from the vocabulary below, or as a backticked reference to one: `` `<template role="stage-implementer">` ``, `` `<step id="2">` ``, `` `<security_guardrails>` ``. Once backticked spans are removed, every body is balanced XML.
- **Variables** are brace placeholders: `{SLUG}`, `{BASE_BRANCH}`, `{COMMANDS}`. Every placeholder a `<template>` uses is declared in its `<input>`, and every declared one is used; the session substitutes them before spawning.
- **References** carrying an attribute (`role`, `id`, `code`, `type`) resolve to a definition in the same file, in user-wide instructions, or in the skill named by the word before the backtick: `` dev-ai-tools `<status_protocol>` ``, `` `<rule id="payload-assembly">` ``. A bare reference names a vocabulary tag.
- **Identity**: every `<rule>` carries a kebab-case `id`, unique in its file; every `<template>` carries a functional `role` and an `executor`; `<step>` ids are numeric per workflow; `<case>`, `<response>`, `<signal>`, and `<state>` carry `id`, `type`, or `code`.
- **Executors**: templates declare an `executor` (such as `default-worker`, the harness default subagent) and where each runs. Work the session does itself is a `<step>`, never a template.
- **Agent tiers**: `agy-ai-tools`, `claude-ai-tools`, and `copilot-ai-tools` each hardcode a `junior`, `mid-level`, and `senior` model and effort for their harness; there is no central manifest or local model configuration.
- **Protocol** is a block, not prose: return tokens live in `<return_protocol>`/`<signal>` and stage states in `<status_protocol>`/`<state>`. A template whose outcome the caller branches on ends with one cited `<signal>`; any other template returns a one-line outcome with paths.

Vocabulary. A new tag is registered here and in `scripts/lint.sh` (`XML_VOCAB`) in the same commit; children of `<input>` are free payload fields and need no registration.

| Tag | File | Meaning |
|---|---|---|
| `<user_instructions>` | AI-TOOLS-AGENTS | root |
| `<system_overview>`, `<unit_tests>`, `<language_rules>`, `<user_interaction>`, `<security_guardrails>`, `<conventional_commits>` | AI-TOOLS-AGENTS | top-level sections |
| `<chat>`, `<disk>`, `<subagents>` | AI-TOOLS-AGENTS | language destinations |
| `<default>`, `<fallback>` | AI-TOOLS-AGENTS | native-tool question rule and its chat fallback |
| `<skill name>` | skills | root |
| `<overview>`, `<session_workflow>`, `<boundaries>` | skills | what the session runs |
| `<dispatch_templates>` / `<template role executor>` / `<job>`, `<input>`, `<instructions>`, `<constraints>` / `<constraint>` | skills | the payload a template carries |
| `<status_protocol>` / `<states>` / `<state code>` | all | stage-file states |
| `<return_protocol>` / `<signal code>` | all | the worker's last line |
| `<step id name>` | all | one numbered workflow step; `name` optional |
| `<rule id>` | all | one addressable rule |

### Installation contract

12. Install global instructions and skill directories as **symbolic links**. Fall back to physical copies only when the OS or filesystem refuses symlinks, and report every copy.
13. Never overwrite a conflicting or locally modified destination by default. `--overwrite` explicitly replaces installed artifact paths for the selected harnesses; it never applies to `$HOME/.ai-tools/USER-AGENTS.md` or unrelated harness configuration.
14. Never remove anything ai-tools did not create. Removal drops only legacy ai-tools links and copies that still match their source. `--force` also drops those same known regular-file or directory destinations when contents differ; it never unlinks a foreign symlink and never applies to `$HOME/.ai-tools/USER-AGENTS.md` or unrelated harness configuration.
15. Every install/remove/update step is idempotent; on conflict, skip and report unless the user passed the process's explicit replacement or forced-removal flag.
16. `$HOME/.ai-tools` is the only supported clone location — user-level, never inside a project. Installed instructions and skills reference it; any other path breaks them.
17. `$HOME/.ai-tools/USER-AGENTS.md` (`%USERPROFILE%\.ai-tools\USER-AGENTS.md` on Windows) is user-owned: if present, follow it; if missing, ignore it. It is never created, edited, overwritten, truncated, symlinked, or removed.

### Script contract

18. Each process—install, remove, update, and verify—is `scripts/shell/<process>.sh` for Linux, macOS, WSL, and Git Bash, using bash 3.2+ and BSD/GNU tools. Shared logic lives once in `lib.sh`. First-install bootstrap scripts `install-bash.sh` and `install-zsh.sh` are self-contained (no `lib.sh`): they clone `$HOME/.ai-tools` then exec `install.sh`. Windows uses WSL or Git Bash rather than PowerShell or CMD mirrors.
19. `scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.
20. Scripts run to completion: per-item conflicts skip and report. Destructive steps are refused by default and require explicit flags (`--overwrite`, `--discard-local`, `--instructions`, `--force`, `--purge`). Every mutating process script (install, remove, update) supports `--dry-run`; the bootstrap scripts only clone, then pass their arguments to `install.sh` (they do not parse `--help` first). Exit: `0` no warnings (skipped items may remain), `1` aborted on a precondition, `2` finished with warnings.
21. Entry-point scripts (`scripts/*.sh`, `scripts/shell/*.sh`) are committed executable; case files under `scripts/test/` are sourced and are not. `.gitattributes` pins everything under `scripts/` to LF.

### Work state and reporting

22. Version transient work under `docs/<skill>/<slug>/` as plan files, reports, decisions, or campaign state. All are temporary working state: stage 1 of a plan writes its files and the last stage removes `docs/<skill>/<slug>/` with `git rm -r` before the push, so the full rationale stays on the branch while the repository root is clean after merge. On blocked execution, `docs/<skill>/<slug>/` is preserved on the branch for inspection. Generated state, raw tool outputs, binaries like screenshots, and volatile runtime caches live in OS temp (`${TMPDIR:-/tmp}/ai-tools/`).
23. **Substance is written to disk; the session carries questions, briefings, plans, and pointers.** Plans, tasks, and campaigns go where rule 22 puts them under `docs/<skill>/<slug>/`. Raw tool outputs, binaries (such as screenshots), and runtime caches go under the OS temp directory (`${TMPDIR:-/tmp}/ai-tools/`). What reaches the user is the batched questions that need answers, the briefing message, the plan presentation (preferring a link to the plan file when on disk over repeating written content), the approvals that need confirmation, a one-line outcome, and the paths of what was written. Where the harness can open a file in the user's editor, open it rather than pasting its content. Restating on screen what already sits on disk spends the user's context twice and creates a second, diverging copy of the truth. This binds every skill and `AI-TOOLS-AGENTS.md`.

## Scripts

Every process below is an executable script shared by humans and AIs. Each is idempotent, handles conflicts per item by skipping and reporting, and enforces the [Safety rules](#safety-rules).

| Platform | Folder | Invocation |
|---|---|---|
| Linux, macOS, WSL, Git Bash | [`scripts/shell/`](scripts/shell/) | `"$HOME/.ai-tools/scripts/shell/<process>.sh" [flags]` |

Processes: `install-bash` / `install-zsh` (first clone), `install`, `remove`, `update`, and read-only `verify`. `--help` lists flags on `install.sh`, `remove.sh`, `update.sh`, and `verify.sh`. Bootstraps do not parse flags: a free path clones first, then `install.sh` receives the same arguments (so `--help` still clones); an existing clone prints the `update.sh` command and exits. On Windows, run those same scripts from WSL or Git Bash.

On top of rules 18–20:

- **Scope** — `--harnesses <list>` accepts comma- or space-separated harness keys (`claude-code`, `copilot`, `antigravity`). Omit the flag to select detected harnesses (the script aborts with exit `1` when none is detected); pass `--harnesses all` to select all three supported harnesses, including those not detected yet. An AI running a mutating script asks for scope first and passes the explicit answer.
- **Legacy Gemini sweep** — the stale-link sweep still examines the retired Gemini CLI root `$HOME/.gemini/skills` regardless of the selected harnesses; `--no-sweep` skips that too.
- **Dry run** — `--dry-run` reports proposed harness actions without installing, removing, resetting, or purging, and supplies the findings and approval report for unattended runs. Update still runs `git fetch origin` (remote-tracking refs and `FETCH_HEAD` may change). Removal planning uses the current checkout; installation planning uses an archive of `origin/master`, so incoming skills are listed. The finish line notes that Git metadata may have been updated.
- **Destructive flags** — `--overwrite` on install and update (replace conflicting artifact destinations and prune orphan `*-ai-tools` artifacts in the selected harnesses), `--discard-local` (reset discarding local work in the clone), `--instructions` (remove global instructions on removal), `--force` (remove known regular-file or directory destinations and orphan paths even when contents no longer match; never unlinks a symlink whose target is outside ai-tools), and `--purge` (delete the clone). Without the flag the script refuses or skips; it never guesses.
- **Symbolic links** — instructions and skills are installed as symbolic links; physical copies are used only as a fallback when the OS or filesystem refuses symlinks. Update removes current-version artifacts, then installs from `origin/master`; `--overwrite` is required for conflicting or locally modified installed artifacts.

## Development checks

Development checks live under `scripts/` beside `scripts/shell/`, outside the installation script contract of rules 18–20. They enforce repository rules and verify integration without dependencies beyond standard Unix tools (`git`, `grep`, `awk`, `sed`, `wc`, `tr`, `bash`).

```bash
"$HOME/.ai-tools/scripts/lint.sh"              # mechanically verify rules in working tree
"$HOME/.ai-tools/scripts/lint.sh" --base <ref> # verify rules and version bump against <ref>
"$HOME/.ai-tools/scripts/test.sh"             # run all integration test cases in sandbox
"$HOME/.ai-tools/scripts/test.sh" --case <c>  # run a single test case file
```

- [`scripts/lint.sh`](scripts/lint.sh) is a static verification check enforcing naming, frontmatter, descriptions, XML grammar, size caps, references, line endings, and citations. Exit codes: `0` clean, `1` aborted on a precondition, `2` finished with findings.
- [`scripts/test.sh`](scripts/test.sh) executes integration tests against disposable sandbox fixtures with a fake `$HOME` and local git remote, asserting rules 12–15, 17, and 20.
- Continuous integration (`.github/workflows/ci.yml`) runs both `lint.sh` (with `shellcheck`) and `test.sh` on every push and pull request.

For the complete catalog of check families, test fixtures, and assertions, see [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md).

## Safety rules

These bind the scripts and any human or AI intervening manually in [Installation](#installation), [Removal](#removal), and [Update](#update), on top of rules 12–17:

- **Never replace by default** an existing regular file or a symlink pointing outside `$AI_TOOLS`: **skip, report, continue** (rules 13, 15). `--overwrite` is the only authorization to replace those exact artifact destinations and prune orphan `*-ai-tools` artifacts in selected harnesses. A matching copy is left alone.
- **Never** recursively remove a harness's skills root; replace or remove individual artifact paths only.
- Remove a destination only when it is a symlink resolving under `$AI_TOOLS`, or a copy whose contents still match their `$AI_TOOLS` source. A locally modified copy is user work: skip it, do not delete it (rule 14). `--force` is the only authorization to remove those exact regular-file or directory destinations and orphan paths when contents differ; a symlink whose target is outside ai-tools is still skipped. `$HOME/.ai-tools/USER-AGENTS.md` remains untouched.
- Never touch unrelated user skills, a repository's own `AGENTS.md` (that application's architecture), or `$HOME/.ai-tools/USER-AGENTS.md` (rule 17).
- An AI operating the scripts asks which harnesses are in scope and reports discovery before a mutating run; the scripts themselves default to every detected harness.

The safe-link, link-or-copy, and copy-removal primitives are implemented once in [`scripts/shell/lib.sh`](scripts/shell/lib.sh). Scripts refuse unsafe paths, including `$HOME/.ai-tools/USER-AGENTS.md` reached through a parent-directory symlink, an `AI_TOOLS` override that is not `$HOME/.ai-tools`, and empty/root/home clone targets; manual intervention must honour the same rules.

## Supported harnesses

One row per harness: global instructions destination and skills root.

| Harness | Global instructions destination | Skills root |
|---|---|---|
| Claude Code | `$HOME/.claude/CLAUDE.md` | `$HOME/.claude/skills/` |
| GitHub Copilot | `$HOME/.copilot/instructions/ai-tools.instructions.md` | `$HOME/.copilot/skills/` |
| Google Antigravity | `$HOME/.gemini/GEMINI.md` | `$HOME/.gemini/config/skills/` |

Notes:

- **Antigravity lives under `$HOME/.gemini`**: instructions at `GEMINI.md`, skills at `config/skills/`. Do not install into `$HOME/.gemini/skills/` (retired Gemini CLI root). The stale-link sweep always unlinks leftover ai-tools links there, even when Gemini is not in `--harnesses`; `--no-sweep` skips it. The sweep does not touch `config/`.
- **Antigravity limits rules files to 12,000 characters.** The repository's stricter self-imposed 10,000-character cap governs `AI-TOOLS-AGENTS.md` (rule 3); Antigravity truncates or rejects files above its own limit.
- **Copilot** user-level `*.instructions.md` files apply automatically only with YAML `applyTo`. The shared copy starts with `applyTo: "**"` (all files). File equality is not activation; confirm Chat diagnostics after install.
- **Never install into `$HOME/.agents/`.** Several harnesses discover it; copying there as well as into each harness root would double-register every skill.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# zsh:
curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-zsh.sh | zsh
```

The bootstrap script is self-contained: it requires `git`, clones `https://github.com/hgsantana/ai-tools.git` to `$HOME/.ai-tools` when that path is free, then execs `install.sh`. If the clone already exists, it prints the `update.sh` command and exits without changing anything; a path that exists but is not a clone aborts with exit `1`. Extra flags after `| bash -s --` reach `install.sh` after the clone, including `--help` — bootstraps do not list flags themselves.

Every `install.sh` step is idempotent and reports conflicts it skips:

1. **Preconditions** — the clone at `$HOME/.ai-tools` exists and validates; `install.sh` clones it when missing, except under `--dry-run` (rule 16; move any existing clone there — no other location is recoverable by configuration).
2. **Discovery and scope** — report each detected harness from its configuration directory, CLI, or known IDE extension, plus possible AI extensions outside scope. Omitted `--harnesses` selects those detected harnesses; `--harnesses all` selects all three and creates their skill roots as needed. Report `$HOME/.agents` while leaving it untouched.
3. **Instructions** — link `AI-TOOLS-AGENTS.md` into each scoped harness's global instructions destination (`--no-instructions` skips), with fallback to copy if symlinks are unavailable. Antigravity uses `$HOME/.gemini/GEMINI.md`.
4. **Skills** — link each `skills/*-ai-tools` directory into every scoped skills root (rules 5–6), falling back to copy if symlinks are unavailable. Harnesses list frontmatter; the host session reads the body only when it runs the skill. With `--overwrite`, orphan `*-ai-tools` skills no longer in the tree are pruned from the scoped roots.
5. **Verify** — every installed instruction and skill is an ai-tools symlink or matching copy fallback; `AI-TOOLS-AGENTS.md` fits the repository's 10,000-character cap (rule 3); every shipped `skills/<name>/SKILL.md` exists. Skipped under `--dry-run`; re-run anytime with `verify`.

Then restart or reload any harness that caches skills at startup. Confirm a slash command for every shipped skill.

## Removal

Remove installed artifacts from harnesses while retaining the clone. Keeping `$HOME/.ai-tools` allows later installation or update.

```bash
"$HOME/.ai-tools/scripts/shell/remove.sh"                          # remove matching skills
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --force   # also drop modified copies
"$HOME/.ai-tools/scripts/shell/remove.sh" --instructions --purge   # removal plus clone purge; skipped conflicts remain
```

1. **Report** — list every possible ai-tools artifact and legacy link in the scoped roots before changing them.
2. **Skills** — remove copies only while their contents still match their source; also unlink legacy links resolving into ai-tools. A locally modified copy is user work: skip and keep (rule 14), unless `--force`. Orphan `*-ai-tools` skills no longer in the tree are removed only with `--force`.
3. **Stale-link sweep** — remove anything in the scoped roots that still resolves into the clone, whatever its name or era, and leftover ai-tools links in the retired Gemini CLI root `$HOME/.gemini/skills` even when that root is outside `--harnesses`. Alpha keeps no backward compatibility (rule 4); the sweep cleans older layouts. `--no-sweep` skips both the scoped roots and that legacy root.
4. **Instructions** — only with `--instructions`; remove an exact source copy or a legacy ai-tools link. Preserve a modified copy unless `--force`. A foreign symlink is always skipped, including with `--force`. Never remove `$HOME/.ai-tools/USER-AGENTS.md` (rule 17).
5. **Verify** — report any link in the scoped roots that still resolves into the clone, and any selected copy that should have been removed (still matching its source, or still present after `--force`). Exit `0` means no warnings, not that every requested artifact is gone: skipped modified copies can remain, so read the summary.
6. **Purge** — with `--purge` only (prompt; `--yes` skips), delete `$HOME/.ai-tools` while always preserving `$HOME/.ai-tools/USER-AGENTS.md`. Purge is independent of skips: a skipped copy can remain after the clone is gone.

When `$HOME/.ai-tools` is missing, copies cannot be compared: the script warns and removes only ai-tools links. Skill copies are left alone. If a separately retained `remove.sh`/`lib.sh` pair is run with `--instructions --force`, instruction copies at known destinations are still deleted because `--force` does not need the source file. Recover that path by invoking those retained scripts from their directory, not from the missing clone.

If `$AI_TOOLS/skills` was added to a harness scan path, remove only that entry, by hand — never wipe the config file. Restart the harness: skill slash commands leave its menu.

## Update

Remove artifacts using the **current** clone (the user's version), reset that clone to `origin/master`, then install from the fresh tree.

```bash
"$HOME/.ai-tools/scripts/shell/update.sh"
```

1. **Preconditions** — require the clone at `$HOME/.ai-tools`; if missing, [Installation](#installation) instead. Fetch `origin/master` and refuse a discarding reset unless `--discard-local`, **before** touching harness artifacts. The guard inspects the current worktree, commits on `HEAD`, and commits on local `master` even when another branch is checked out.
2. **Remove** — using this clone's skills and instructions: skills, the stale-link sweep (`--no-sweep` skips), and instructions (`--no-instructions` keeps them). Drop unmodified copies and legacy ai-tools links; skip and report modified copies.
3. **Reset** — check out `master` and reset `--hard` to `origin/master`. The destructive scope is **the clone only**; `$HOME/.ai-tools/USER-AGENTS.md` remains untouched.
4. **Install** — the Installation steps against the fresh tree, listing skills from the tree, never from hardcoded names.
5. **Verify** — the Installation checks.

The scripts target `master` only and abort when `origin/master` is missing; a renamed default branch needs a script change, never a guessed branch.

Then restart or reload the harness and confirm a slash command for every shipped skill.

## Troubleshooting

Common operational issues and quick resolutions:

- **Local uncommitted changes prevent update:** Stash changes (`git stash`) or save them to a branch (`git checkout -b <branch>`). Use `--discard-local` only if you intend to discard local clone work.
- **Skills missing after install/update:** Restart the host CLI or IDE to reload cached skill catalogs, then verify with `"$HOME/.ai-tools/scripts/shell/verify.sh"`.
- **Copilot ignores instructions:** Verify `$HOME/.copilot/instructions/ai-tools.instructions.md` starts with YAML `applyTo: "**"`, restart the IDE, and check Chat diagnostics.
- **Symlinks refused / `copied (will not track updates)`:** Enable Developer Mode on Windows or run from an elevated shell. Re-run `update.sh` to refresh copies when upstream updates occur.
- **Conflicts or modifications:** Re-run with `--overwrite` to replace conflicting artifacts, or `--force` on removal to drop modified copies. Personal instructions belong in `$HOME/.ai-tools/USER-AGENTS.md` (never touched).

For detailed diagnostics, recovery procedures, and edge cases, see [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## License

MIT — see [`LICENSE`](LICENSE). Use, modify, fork, redistribute, and sell freely, including in closed-source work; the only condition is retaining the copyright and permission notice with copies or substantial portions. The `AS IS` disclaimer covers what these tools do by design: scripts that unlink and delete harness configuration, dispatched work that can create billable cloud resources, and unattended code execution.

Maintenance consequences:

- The copyright block names the project and its URL. It is reproduced verbatim in third-party notices, so keep both lines — they make a downstream copy traceable back here.
- Use the root `LICENSE` instead of per-file license headers in shipped artifacts. `AI-TOOLS-AGENTS.md` follows the **10,000-character** cap in rule 3, and every artifact follows rule 8. Installation on one's own machine is not redistribution.
