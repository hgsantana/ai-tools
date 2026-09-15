# README ruleset sync

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |

## Goal

Make `README.md` match the repository after the three stacked phases: PR #21 (agents removed), PR #22 (skills on the session model), PR #23 (centralized `<execution_protocol>`, `Execution` column), and commit `3ff0ed8`. The repository is the ruleset. Where README and the tree disagree, README follows. The exception is a plain defect, which is listed under Open questions and not codified.

Also add the cheap, deterministic lint checks for README rules that can be verified mechanically, and cross-check every `rule N` citation in the repository against the final README.

Out of scope:

- `skills/**`: the user is editing it in parallel. No stage lists a skill file, and any fix that needs a skill edit is an open question.
- Behaviour changes to `scripts/shell/*` and `.github/workflows/ci.yml`.
- `docs/USAGE.md`.
- `ROADMAP.md`, except the one sentence stage 5 retires.

## Base branch

`plan/user-agents-skills-only`, analysed at `3ff0ed8`. At analysis time, every `skills/*/SKILL.md` in the working tree was byte-identical to `HEAD` (checked with `git show HEAD:<path> | cmp`).

## Numbering decision

No rule is added, removed, or split. New conventions go into the existing rules 3, 4, 6, 7, 9, 11, 20, 21, 23, 24, and 25, so rules 1-25 keep their numbers and their topics. Existing citations therefore need no renumbering. Stage 6 still cross-checks every citation against the final rule text. See open question 1 for the alternative.

## Verification protocol (every stage)

`skills/` has uncommitted user work in progress, so no stage runs a check in the real tree. Every probe, lint run, and test run happens in a scratch clone:

```bash
REPO=/home/wsl/.ai-tools
V=$(mktemp -d)/ai-tools
git clone -q "$REPO" "$V"                 # committed HEAD of the work branch, no user WIP
for p in <the stage's declared files>; do cp "$REPO/$p" "$V/$p"; done
git -C "$V" -c user.name=probe -c user.email=probe@example.invalid commit -qam probe
"$V/scripts/lint.sh"                       # exit 0, 0 warnings
"$V/scripts/test.sh"                       # exit 0
(cd "$V" && shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh)  # only SC1071 on install-zsh.sh
```

Execution note: work runs in the worktree `/home/wsl/.ai-tools-wt/readme-ruleset-sync` on `plan/readme-ruleset-sync`. There, use `REPO=/home/wsl/.ai-tools-wt/readme-ruleset-sync` and `git clone -q -b plan/readme-ruleset-sync "$REPO" "$V"`, then copy the declared files from the worktree. Never run checks in `/home/wsl/.ai-tools`.

Negative probes edit files inside `$V` only, including `$V/skills/...`. Never edit, stage, stash, restore, or check out anything under the real `skills/`. Commit each stage path by path, and never with `git add -A` or `git commit -a`.

Baseline at `3ff0ed8`:

- lint: 369 ok, 1 skipped, 0 warnings.
- test.sh: 305 ok.
- shellcheck: SC1071 only.

## Execution graph

Strictly sequential: 1 → 2 → 3 → 4 → 5 → 6.

- Stages 1 and 2 both edit `README.md`, in different sections. Rules go first so that stage 2's check descriptions can cite the final rule text.
- Stages 3, 4, and 5 each edit `scripts/lint.sh`, `README.md` (Development checks), and nothing under `skills/`.
- Stage 5 is optional (open question 6). If it is dropped, stage 6 depends on stage 4.
- Stage 6 runs last. It verifies citations against the final README and bumps the version once for the whole branch, because `lint.sh --base` requires a bump when `scripts/` changes.

## Stages index

1. [Rules text](./1-readme-ruleset-sync.md): Repository rules and the Semantic XML grammar match the tree. `README.md` only.
2. [Process and check descriptions](./2-readme-ruleset-sync.md): Contents, Quick start, Scripts, Development checks, Installation, Removal, Update, and Troubleshooting match the scripts, lint, tests, and CI. `README.md` only.
3. [Lint: grammar identity and citation hygiene](./3-readme-ruleset-sync.md): step, case, response, signal, and state attributes; no rule numbers in skills or USER-AGENTS; no USER-AGENTS sub-headings; description names `/name`; README vocabulary table matches `XML_VOCAB`.
4. [Lint: rule citations resolve](./4-readme-ruleset-sync.md): README rules are numbered 1..N without gaps, and every `rule N` citation in tracked docs and scripts is within 1..N.
5. [Lint: harness table parity](./5-readme-ruleset-sync.md): the harness keys and paths in `lib.sh` match the README Scope bullet and the Supported harnesses table. Retires the lint clause of ROADMAP story 12.
6. [Citation cross-check and version](./6-readme-ruleset-sync.md): every citation is checked against the rule text it names, wrong test-comment citations are fixed, and the version becomes 0.0.51-ALPHA.

## Findings

README line numbers refer to `3ff0ed8`. "S1" to "S6" name the stage that applies the action; "OQ" means an open question, with no README change.

| # | Section | README claim | Repository fact | Action |
|---|---|---|---|---|
| 1 | Overview, item 3 (l.15) | USER-AGENTS "is not this repository's rule file (rule 2)" | Rule 3 states that; rule 2 is README precedence | S1: cite rule 3 |
| 2 | Contents, USER-AGENTS row (l.23) | "skill-offer gate, execution protocol, language, and security" | USER-AGENTS also has `<user_interaction>` (the native question tool) | S2: add "native question tool" |
| 3 | Contents, scripts row (l.26) | `scripts/shell/`, `lint.sh`, `test.sh` | `scripts/test/*.sh` case files and `scripts/test/lib.sh` exist and are sourced by `test.sh` | S2: name `scripts/test/` |
| 4 | Contents | Four rows | Tracked `ROADMAP.md` and `dev/` (rule 22) are unlisted | S2: add `ROADMAP.md` and `dev/` rows |
| 5 | Quick start (l.39) | "`remove.sh` and `verify.sh` take `--dry-run` and `--help`" | `verify.sh --dry-run` exits 1 (unknown option). `install.sh`, `remove.sh`, `update.sh` take `--dry-run`; those three plus `verify.sh` take `--help`; bootstrap scripts take neither | S2: correct |
| 6 | Rule 3 (l.55) | USER-AGENTS "is structured entirely in semantic XML tags" | The file opens with an H1 and two prose paragraphs, and the XML body follows. `lint.sh` `xml_body` skips that preamble | S1: "after a title and short preamble, its body is semantic XML"; S3: lint forbids `##` sub-headings |
| 7 | Rule 4 (l.56) | "Change the version only in the commit or merge that lands the change on `master`" | CI runs `lint.sh --base <PR base SHA>` on every pull request whatever its target. The stacked PRs #21-#23 bumped 0.0.47 → 0.0.48 → 0.0.49 → 0.0.50 | S1: per-PR bump against the base (recommendation of OQ2) |
| 8 | Rule 6 (l.61) | `Agent:` is `session` or `session + implementer (model asked once)` | `lint.sh` `check_skill_agent_field` also requires the implementer value exactly when the body has `<implementer_job>` and `<template executor="implementer">`, only in `IMPLEMENTER_SKILLS` (vibe, campaign). USER-AGENTS shows the value in the `Execution` column | S1: state the coupling and the column |
| 9 | Rule 6 (l.61) | Description "including `/name`" | Not linted | S3: lint check |
| 10 | Rule 7 (l.62) | "...frontmatter `name:`, and file basename ends in `-ai-tools`" | No shipped file basename carries the suffix (skills are `SKILL.md`). Suffixed wrapper files were removed in PR #21 | S1: drop "file basename" |
| 11 | Rule 9 (l.64) | Lists grammar duties only | `check_spawn_protocol_citation` (cited as rule 9): every skill with a `<template>` cites USER-AGENTS `<execution_protocol>`, and none repeats the native subagent API list | S1: add the citation requirement |
| 12 | Rule 9 (l.64) | "Prose citations of this README use section anchors, never rule numbers" | Holds today; not linted | S3: lint check |
| 13 | Rule 11 (l.66) | USER-AGENTS "surfaces it before execution" | `<offer_message>` table columns Description (from `Impact:`) and `Execution` (from `Agent:`); lint checks the `Description, Execution` header | S1: name both columns |
| 14 | Grammar, Protocol bullet (l.77) | "a template ends with one cited `<signal>`" | Only `campaign-planner` and `campaign-executor` end with a signal. The other 9 templates end with a plain return line | S1: signal only when the caller branches on the outcome |
| 15 | Grammar, Executors bullet (l.76) | Lists values, API list, fallback, parallelism | `<execution_protocol>` also has `session-model`, `native-spawn` payload rules, and `spawn-announce` | S1: add spawn announcement and payload rule |
| 16 | Grammar, Identity bullet (l.75) | Numeric `<step>` ids; `<case>`, `<response>`, `<signal>`, `<state>` carry id, type, or code | Holds today; `lint.sh` checks only `<rule id>` and `<template role/executor>` | S3: lint check |
| 17 | Grammar table (l.90) | `<step id name>` is a skills tag | USER-AGENTS `<skill_offer>` has `<step id="1">` and `<step id="2">` (no `name`) | S1: its own row, File "all", `name` optional |
| 18 | Grammar table (l.91) | `<template role>` | Every template also needs `executor` (Identity bullet, lint) | S1: `<template role executor>` |
| 19 | Grammar table vs `XML_VOCAB` | "A new tag is registered here and in `XML_VOCAB` in the same commit" | Both hold the same 40 tags today; not linted | S3: parity check |
| 20 | Rule 20 (l.111) | "Every mutating script supports `--dry-run`" | `install-bash.sh` and `install-zsh.sh` clone without `--dry-run` and pass their arguments to `install.sh` | S1: scope to install, remove, update; bootstrap exception |
| 21 | Rule 21 (l.112) | "Shell scripts are committed executable" | `scripts/test/*.sh` are mode 100644 (sourced); lint checks modes only for `scripts/*.sh` and `scripts/shell/*.sh`. `.gitattributes` pins all of `scripts/**` to LF | S1: entry points executable, case files sourced, `scripts/**` LF |
| 22 | Rule 23 (l.117) | `plan-ai-tools` "requests the host harness's best planning capability or mode" | No such step in plan-ai-tools, on HEAD or on `master` | S1: drop |
| 23 | Rule 24 (l.118) | dev "update[s] any documentation the step made stale" | dev-ai-tools `<step id="3">` has no such instruction (also absent on `master`) | OQ4: README unchanged |
| 24 | Rule 24 (l.118) | Plan and Task forms only | dev-ai-tools also has Queue mode (lists `dev/*/0-*.md`, proposes an order) | S1: add Queue mode |
| 25 | Rule 24 (l.118) | No vibe sequence | vibe runs plan-ai-tools steps 1 and 3, asks the model once the plan is on disk, runs dev steps 2-4 with `stage-implementer`, and logs to `dev/<slug>/vibe-decisions.md` | S1: one sentence |
| 26 | Rule 24 (l.118) | Campaign: fresh planning and execution subagents, implementers on the chosen model, local commits | Also: model recorded in `campaign.md` and reused on resume; `no-nested-fallback` (a pass that cannot spawn ends BLOCKED and never takes USER-AGENTS `spawn-fallback`); stops on BLOCKED or two consecutive NONE | S1: add model record, no-nested-fallback, stop conditions |
| 27 | Rule 25 (l.119) | "outside a Git repository, use `$HOME/.ai-tools-plans/tmp/`" | No skill or USER-AGENTS text implements it (USER-AGENTS `<chat>`: "dev/tmp/ in the working repository"); ROADMAP story 10 still treats non-Git execution as an idea | S1: drop the clause |
| 28 | Scripts, Scope bullet (l.133) | Omitted flag selects detected harnesses | `set_scope` aborts with exit 1 when none is detected | S2: add |
| 29 | Development checks intro (l.140) | Checks live beside `scripts/shell/` "(rules 18–20)"; dependencies include `od` | Checks are outside rules 18-20 (`lint.sh` header). `lint.sh` uses no `od`; its header lists git, grep, awk, sed, wc, tr (plus optional `locale`) | S2: "outside rules 18–20"; drop `od` |
| 30 | Check family: skill layout (l.153) | "every `skills/*-ai-tools/SKILL.md` exists" | `check_skill_layout` checks the nine hardcoded shipped skills, a `SKILL.md` in every `skills/*/`, root `<skill name>`, `<session_workflow>`, `<dispatch_templates>`, and the absence of `skills/SKILL-CONTRACT.md` and `skills/MAINTAINER.md` | S2: describe accurately |
| 31 | Check family: encodings and endings (l.156) | "line endings, executable bits, no binaries in shipped paths (rule 21)" | No encoding check exists. The eol check covers tracked `scripts/` only; mode checks cover `scripts/*.sh` and `scripts/shell/*.sh`; the no-binaries check (`skills/`, `scripts/`) has no rule | S2: split into "line endings and modes (rule 21)" and "no binaries" |
| 32 | Check family: version bump (l.161) | "a change ... that lands on `master` requires..." | `check_version_bump` diffs `<ref>...HEAD` for any ref; CI passes the PR base SHA for every PR | S2: "against `<ref>`" (with S1 rule 4) |
| 33 | CI sentence (l.163) | "`lint` runs the version-bump check on pull requests and `shellcheck` ... on every push" | The lint job runs the full `lint.sh` on every push and PR (`--base` only on PRs), then shellcheck. The shellcheck step fails on SC1071 for `install-zsh.sh` | S2: reword; OQ3 (red CI) |
| 34 | test.sh paragraph (l.167-182) | Runs install, remove, update, verify; asserts "rules 12–20"; the fixture stages foreign file, modified copy, and stale link "before any script runs" | Case files: install, reinstall, remove, smoke, update, verify, discovered by glob. `--case` takes a file basename or a `case_*` name. `t_fixture` options are per case (`--foreign-skill`, `--foreign-instructions`, `--modified-copy`, `--stale-link`, `--external-symlink`). No assertion targets rules 16, 18, 19 | S2: correct rule list (12–15, 17, 20), discovery, fixture options |
| 35 | Installation, bootstrap (l.224) | Existing clone → prints update command and exits | A path that exists but is not a clone → abort, exit 1 | S2: add |
| 36 | Installation step 1 (l.228) | "the clone ... exists and validates" | `ensure_clone` clones when missing (refused under `--dry-run`) | S2: add |
| 37 | Installation steps 4-5 (l.231-232) | Copy skills; verify copies, cap, and sources | `install_skills` prunes orphan `*-ai-tools` skills under `--overwrite`; `verify_install` warns on an orphan skill | S2: add both |
| 38 | Installation step 5 (l.232) | USER-AGENTS "fits the repository's 8,000-character cap" | `verify_install` measures bytes (`wc -c`) and labels them chars; lint measures characters (`wc -m`, UTF-8) | OQ5: README unchanged |
| 39 | Removal step 2 (l.247) | Matching copies and legacy links | `remove_skills` also prunes orphan `*-ai-tools` skills, only with `--force` | S2: add |
| 40 | Removal step 5 (l.250) | "report any known ai-tools artifact or legacy link still in the scoped roots" | `verify_removal` reports only symlinks still resolving into the clone | S2: correct |
| 41 | Removal | Nothing on a missing clone | `remove.sh` warns and removes links only (sweep, instructions links) when `$AI_TOOLS` is missing | S2: add |
| 42 | Update (l.269) | On a renamed default branch "the scripts follow only after the user or remote confirms it" | `prepare_reset` and `update_source` hardcode `master` and abort when `origin/master` is missing | S2: "target `master` only; a rename needs a script change" |
| 43 | Troubleshooting (l.283) | `--force`: "names no longer in the tree are not destinations" | `prune_orphan_skills` removes orphan `*-ai-tools` skills under `--force` (and `--overwrite`) | S2: correct |
| 44 | Supported harnesses (l.200-207) | Six rows; keys in the Scope bullet | Matches `lib.sh` `ALL_HARNESSES`, `skills_root`, `instructions_dest` today; not linted | S5: parity check |
| 45 | Header (l.3) | Version 0.0.50-ALPHA | This branch changes `scripts/`; `lint.sh --base` requires a bump | S6: 0.0.51-ALPHA |
| 46 | `scripts/test/install.sh:38` | "Rule 13: running install.sh twice changes nothing" | Idempotency is rule 15 | S6: cite rule 15 |
| 47 | `scripts/test/install.sh:59` | "Rules 13, 15, 18: ... the run still finishes" | Running to completion is rule 20; rule 18 is platform and `lib.sh` | S6: "Rules 13, 15, 20" |
| 48 | `scripts/test/update.sh:145` | "Newly shipped content (rule 13)" | Rule 13 is no-overwrite; the case proves Update step 4 (install from the fresh tree) | S6: cite the section, not a rule number |

Verified with no change needed:

- Overview items 1, 2, 4, 5.
- Rules 1, 2, 5, 8, 10, 12-19, 22.
- The Semantic XML grammar Variables and References bullets.
- Safety rules.
- The Supported harnesses paths and notes.
- Removal steps 1, 3, 4, 6.
- Update steps 1-5.
- The Troubleshooting entries other than #43.
- The License section and `LICENSE` header.
- `.gitattributes` (rule 21), `scripts/lint.sh` citations (rules 3, 4, 5, 6, 7, 9, 18-20, 21, 22), `scripts/test.sh` (rules 18-20), `smoke.sh`, `remove.sh`, `reinstall.sh`, `verify.sh` headers, and `ROADMAP.md` "Rule 4".
- The shellcheck command in README matches `ci.yml`.

## Rules that lint will still not check (after stage 5)

- Rules 1, 2, 8, 10: precedence, concision, language. Judgement only.
- Rule 3: "every shipped artifact fits the strictest harness" beyond the USER-AGENTS cap, and the external limits it quotes (Antigravity 12,000).
- Rule 4: backward-compatibility policy. The bump is checked only with `--base`.
- Rule 5: no per-harness copies (only `SKILL-CONTRACT`/`MAINTAINER.md` names and root `skills/*.md` are checked); the `gh-ai-tools` scope sentence.
- Rule 6: the description parts' substance; the "optional keys supported by every harness" claim beyond the allowlist; the Codex (2% or 8,000) and Claude Code (1,536) budgets.
- Rule 9: negatives used only to reinforce positives.
- Rule 11: impact stated exactly once and before execution. Lint checks only that `Impact:` is present.
- Rules 12-17 and 20: asserted by `scripts/test.sh`, not lint. Rules 16, 18, 19: neither (bash 3.2 compatibility, single `lib.sh`, same-commit script and README sync), except the harness parity from S5.
- Rules 22-25: work-state and reporting behaviour. Lint checks only that `dev/tmp` is untracked.
- Grammar: the table's File column, "a template ends with a cited signal" (as reworded), and that the session substitutes placeholders before spawning.
- Counts in prose ("all six"), Safety rules, and the Installation, Removal, and Update step descriptions against script behaviour. `test.sh` covers these partially.
- Semantic correctness of a `rule N` citation. S4 checks only the range; S6 cross-checks meaning once, by hand.

## Open questions and risks

1. **Renumbering.** This plan folds new conventions into existing rules and keeps rules 1-25 stable. The alternative splits rule 5 (layout) from a new "execution model" rule. That shifts rules 6-25 and touches about 60 citations in `lint.sh`, `scripts/test/*.sh`, `.gitattributes`, `ROADMAP.md`, and README. Recommendation: keep the numbers.
2. **Version policy (rule 4).** The rule says to bump only when landing on `master`, but CI enforces a bump on every PR, and the stack bumped three times. This plan codifies the per-PR bump. The alternative treats CI as the defect: gate `--base` to PRs targeting `master` in `ci.yml` and keep rule 4. Recommendation: codify the per-PR bump (S1 as written).
3. **CI shellcheck is red (defect).** `shellcheck ... scripts/shell/*.sh` fails with SC1071 on `install-zsh.sh`, so the lint job fails on every push and PR. README keeps quoting the CI command and does not claim it passes. Recommendation: a separate `ci:` change that excludes `install-zsh.sh` (or checks it with `zsh -n`).
4. **dev-ai-tools no longer updates stale docs (possible defect).** Rule 24 says each step updates documentation it made stale, but dev-ai-tools `<step id="3">` does not say so (absent on `master` too). Fixing it needs a skill edit, which is out of scope here. Recommendation: restore one clause in dev-ai-tools step 3 after the user's skills work lands; README keeps the clause.
5. **verify.sh size check (defect).** It counts bytes and reports "chars". Lint counts characters. Today: 7,449 bytes, 7,445 characters. Recommendation: fix `verify_install` to count characters like lint (or say bytes) in a separate `fix(scripts):` change; README keeps "8,000-character".
6. **Stage 5 scope.** Harness parity lint overlaps ROADMAP story 12, whose lint clause S5 retires. Recommendation: keep stage 5; it is cheap and directly addresses "harness tables that drift".
7. **Stale docs outside README.** These premises no longer hold:
   - `docs/USAGE.md`: "A leading `/name` confirms that skill's stake, offers other fitting skills", whereas USER-AGENTS case 1 handles the request directly; also "**something else**" versus the "Other" option.
   - ROADMAP story 8 (`dev/tmp/vibe/`; decisions now go to tracked `dev/<slug>/vibe-decisions.md`).
   - Story 9 (dispatch ledger, snapshot liveness).
   - Story 10 (`$HOME/.ai-tools-plans`).

   Recommendation: a separate docs task after this plan.
8. **Rule 25 non-Git fallback.** S1 drops `$HOME/.ai-tools-plans/tmp/` because nothing implements it. If the user wants that behaviour, it is a skill change (ROADMAP story 10), not a README rule. Recommendation: drop, as planned.

### User decisions

The user accepted every recommendation above:

1. Keep rules 1-25 numbered as they are; rule 5 is not split.
2. Codify the per-PR version bump in rule 4 (S1 step 3 as written).
3. The shellcheck SC1071 CI failure goes to a separate CI change. README must not claim CI passes.
4. Restore the dev-ai-tools stale-docs clause later, after the user's skills work lands. README keeps rule 24's clause. No skill is edited.
5. The verify.sh byte-versus-character count is fixed separately. README keeps "8,000-character".
6. Keep stage 5.
7. Stale `docs/USAGE.md` text and ROADMAP stories 8-10 go to a separate docs task.
8. Drop rule 25's non-Git fallback from README.

Deferred follow-ups: answers 3, 4, 5, and 7.

### Risks

- **Risk: parallel skills work.** New lint checks (S3) run on `skills/`. The user's uncommitted edits could trip them (for example a non-numeric step id) or make them pass only against HEAD. Stages verify in a scratch clone of committed HEAD. Before stage 3 is committed, compare `skills/` to HEAD again read-only (`git show HEAD:<p> | cmp - <p>`). If it differs, run lint on a scratch copy of the working-tree skills too, and report any finding as a question instead of editing a skill.
- **Risk: branch carries WIP.** `dev-ai-tools` creates `plan/readme-ruleset-sync` from the base, and the uncommitted `skills/` changes follow into the work tree. Stage by explicit path only.
- **Risk: Status table column.** This plan uses `Agent` as instructed. The current plan-ai-tools `<plan_file_format>` names it `Executor`.
