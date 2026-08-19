# Skill wrapper, skill base, shared contract

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |

## Goal

Split every `skills/<name>/SKILL.md` the way agents are already split: a small **wrapper** (`skills/<name>/SKILL.md`) carrying frontmatter, a scope line, and pointers; a **base** (`skills/<name>.md`) carrying the behaviour; and `skills/SKILL-CONTRACT.md`, read by path, carrying what every agent-backed skill repeats verbatim — the model check, the three-route offer, and the route mechanics. A routing-policy change becomes one edit instead of eight.

## Premise verification (ROADMAP story 3)

Checked against each harness's **official** documentation on **2026-08-19**. Question: does the harness preload skill bodies into the session context, or only name/description, reading the body on invocation?

| Harness | Preloads the body? | What the official doc says | Source | Retrieved |
|---|---|---|---|---|
| `claude-code` | **No** | "In a regular session, skill descriptions are loaded into context so Claude knows what's available, but full skill content only loads when invoked." Exception: "Subagents with preloaded skills work differently: the full skill content is injected at startup." Also: `description` + `when_to_use` "is truncated at 1,536 characters in the skill listing"; tip "Keep `SKILL.md` under 500 lines"; once loaded, the body "stays in context across turns, so every line is a recurring token cost" | <https://code.claude.com/docs/en/skills.md> | 2026-08-19 |
| `codex` | **No** | "ChatGPT and Codex start with each skill's name and description, then load the full `SKILL.md` instructions when they decide to use that skill." The initial list "uses at most 2% of the model's context window, or 8,000 characters when the context window is unknown… This budget applies only to the initial skills list." | <https://developers.openai.com/codex/skills> → 308 → <https://learn.chatgpt.com/docs/build-skills.md> | 2026-08-19 |
| `copilot` | **No** | "When performing tasks, Copilot will decide when to use your skills based on your prompt and the skill's description"; "When Copilot chooses to use a skill, the `SKILL.md` file will be injected in the agent's context." No size limit documented | <https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills> | 2026-08-19 |
| `antigravity` | **No** | Three phases: "When a conversation starts, the agent sees a list of available skills with their names and descriptions"; "If a skill looks relevant to your task, the agent reads the full `SKILL.md` content"; then it follows the instructions. No `SKILL.md` size limit documented (the 12,000-character cap is on **rules files**, not skills) | <https://antigravity.google/docs/ide/skills/> | 2026-08-19 |
| `gemini` | **No** | "Gemini CLI scans the discovery tiers and injects the name and description of all enabled skills into the system prompt"; on activation "The `SKILL.md` body and folder structure is added to the conversation history." Progressive disclosure stated; no numeric limit | <https://raw.githubusercontent.com/google-gemini/gemini-cli/main/docs/cli/skills.md> (mirrored at <https://geminicli.com/docs/cli/skills/>) | 2026-08-19 |
| `cursor` | **Partially documented — no preload stated** | "Skills load resources on demand, keeping context usage efficient." Discovery: "When Cursor initializes, it automatically locates skills from designated directories and presents available options to the Agent"; `description` "used by the agent to determine relevance". The doc never states in so many words when the `SKILL.md` body enters context | <https://cursor.com/docs/skills> | 2026-08-19 |
| `grok` | **Not documented** | The official page documents discovery paths and frontmatter only — `description`: "What it does and when to use it. First body paragraph if omitted."; `when-to-use`: "Extra trigger phrases." Nothing about when a body is read or what reaches the system prompt | <https://docs.x.ai/build/features/skills-plugins-marketplaces> | 2026-08-19 |

**Finding.** No harness documents preloading skill bodies. Five state on-invocation loading explicitly; two (`cursor`, `grok`) do not document the mechanics at all, and neither claims a preload. **The token-economy argument for a small wrapper fails** — and in Claude Code the split is token-neutral at best, since a body read through pointers arrives as tool results that also stay in context.

What the harnesses *do* budget is the **description**: Codex caps the whole skill list at 2% of context or 8,000 characters, and Claude Code truncates `description` + `when_to_use` at 1,536 characters. Today's nine descriptions total ≈ 2,900 characters (281–390 each).

**Shape decided by the finding** (per the user's decision 2 — the split ships regardless):

- The wrapper gets a size cap, but as a **concision device (rule 14) and never as token economy**: **2,000 characters**, frontmatter included — an order below today's 4,187–8,962. The README must say why, so nobody re-derives a token argument that does not hold.
- A **500-character cap per skill `description`** is the cap that is actually justified by harness limits: nine skills × 500 = 4,500, inside Codex's 8,000-character list budget with room for the user's own skills, and inside Claude Code's 1,536-character truncation per skill.
- No cap on the base or the contract; rule 14 governs them, as it governs agent bases.

## Execution graph

1 before 2, 3, and 4. Stages 2, 3, and 4 are parallel-safe with each other. 5 after 2, 3, and 4. 6 after 5.

## Stages

1. [Shared contract and the rules that define the layout](./skill-wrapper-base-contract-1.md) — create `skills/SKILL-CONTRACT.md`, rewrite README rules 7 and 9 and the `skills/` inventory row, bump the version
2. [Split the five single-agent skills](./skill-wrapper-base-contract-2.md) — `az`, `gc`, `gh`, `planner`, `orchestrator` into wrapper + base
3. [Split the three maintainer skills](./skill-wrapper-base-contract-3.md) — `update`, `remove`, `reinstall` into wrapper + base
4. [Split `vibe-ai-tools`](./skill-wrapper-base-contract-4.md) — wrapper + base, no contract pointer (it fronts no agent)
5. [Installation scripts and process docs](./skill-wrapper-base-contract-5.md) — verify the contract and every skill base exist; shell canonical + PowerShell mirror + README process sections
6. [Linter checks](./skill-wrapper-base-contract-6.md) — wrapper body, pointers, size caps, base and contract presence, README check list

## Notes

- **Facts the stages rely on.** Eight skills are agent-backed (`az`, `gc`, `gh`, `planner`, `orchestrator`, `update`, `remove`, `reinstall`) fronting six agents; `vibe-ai-tools` fronts none. ROADMAP story 3 says "six agent-backed skills" — it is counting the six agents; the file count is eight.
- **What is duplicated today.** Byte-identical across all eight agent-backed skills: `## 3. Offer, then ask` in full, and the last two bullets of `## Route B — run it here`. Near-identical: `## 2. Model check` (differs only in the category word — **planner**, or **implementer** for the three maintainer skills) and the first phrase of each Route A / Route B bullet. That is ≈ 2,150 characters × 8 ≈ 17,000 characters collapsing into one ≈ 2,300-character contract.
- **No rule renumbering.** Rules 8–26 are cited by number across the README, the linter, and shipped artifacts. The new layout and the two caps extend **rules 7 and 9 in place**; no rule is inserted.
- **Version.** One bump for the whole branch, and it lands in the **last** stage (6): `0.0.24-ALPHA` → `0.0.25-ALPHA`. The linter's version-bump check runs against the pull request base, so one bump satisfies it — but bumping in the first commit would let that check pass for the wrong reason, so the bump comes after the content it versions.
- **Version assumption.** `0.0.25-ALPHA` assumes the story-2 branch (`plans/sandboxed-script-tests.md`), which takes `0.0.24-ALPHA`, merges first. If it has not merged when stage 6 runs, re-pin the number against the README on `origin/master` at that moment — never merge a bump blindly.
- **Delivery.** Branch `plan/skill-wrapper-base-contract`, one commit per stage, one pull request (approved by the user).
- **Validation.** No test framework exists in this repository. Every stage validates with `tools/lint.sh`, plus `shellcheck -x -P scripts/shell scripts/shell/*.sh tools/*.sh` and `scripts/shell/verify.sh --help` / a dry-run for the script stage.
- **Queue conflict.** `plans/sandboxed-script-tests*.md` (ROADMAP story 2) is also queued and also touches `scripts/` and `tools/lint.sh`. Whichever ships second rebases; stages 5 and 6 here are small and additive, so prefer landing this branch first or merging `master` before stage 5.
- **Out of scope.** Per-harness skill wrappers (rule 7 keeps one shared directory); any change to the agent layout; the `USER-AGENTS.md` text (it describes skills by purpose, not by file layout — confirm with `grep -n "SKILL" USER-AGENTS.md` before assuming an edit is needed); ROADMAP story 8's decision records.

## Decisions taken

1. **`vibe-ai-tools` is split too** — wrapper + base (stage 4), for symmetry with everything else. It gets **no** contract pointer, and its entry gate stays in its own base: `skills/SKILL-CONTRACT.md` carries only what the agent-backed skills repeat verbatim.
2. **One version bump for the whole branch**, in stage 6, to `0.0.25-ALPHA` (see *Notes*). Rule 4's intent — a released version never contains unversioned content — is satisfied by one bump per pull request; six bumps in one branch make the version meaningless.
