# Stage 3: Scripts without agents

## Objective

`install.sh`, `update.sh`, `remove.sh`, and `verify.sh` handle only global instructions and skills. They no longer:

- copy, refresh, prune, remove, or verify agent wrappers
- write or remove the Grok `[subagents.models]` block
- list agent roots in reports, sweeps, or removal verification

The test suite uses skill and instructions fixtures only. README sections describing these processes change in the same commit (README rule 26).

`agents/` and `MODELS.csv` still exist in this stage, and `ensure_clone`/`require_clone` still require them. Stage 4 deletes the files and changes validation.

## Files

- Create: none
- Modify:
  - `scripts/shell/lib.sh`
  - `scripts/shell/install.sh`
  - `scripts/shell/update.sh`
  - `scripts/shell/remove.sh`
  - `scripts/test/lib.sh`
  - `scripts/test/install.sh`
  - `scripts/test/update.sh`
  - `scripts/test/remove.sh`
  - `scripts/test/reinstall.sh`
  - `scripts/test/verify.sh`
  - `scripts/test/smoke.sh`
  - `README.md`: Scripts; Development checks test fixture paragraph; Safety rules; Supported harnesses (first table and notes); Installation; Removal; Update; Troubleshooting
- Remove: none (`scripts/shell/verify.sh` needs no change)

## Steps

### scripts/shell/lib.sh

1. Delete `agents_root`.
2. `scoped_roots`: echo only `skills_root "$h"` per scoped harness, then `sort -u`.
3. Delete `install_agents`.
4. Delete the whole "Grok model pinning" section: its comment, `MODEL_TABLE`, `GROK_TOML`, `GROK_BEGIN`, `GROK_END`, `category_for`, `models_csv_field`, `model_for`, `model_effort_for`, `grok_models_toml`, `install_grok_models`, and `remove_grok_models`.
5. Delete `in_scope`; its only callers were the Grok functions.
6. Delete `prune_orphan_agents` and `uninstall_agents`.
7. `sweep_stale_links`:
   - Delete the "Whole-directory links from an older alpha install" loop (`$HOME/.claude/agents`, `$HOME/.grok/agents`).
   - The retired-root loop covers only `$HOME/.gemini/skills`.
   - Its comment reads: "Retired Gemini CLI skills root (not a harness). Do not touch Antigravity's $HOME/.gemini/config/skills or GEMINI.md."
8. `refresh_copies`: delete the agent loop (`src`, `root=$(agents_root …)`, the `agents/$h/$base` refresh) and keep the skills loop. Trim the locals to those still used.
9. `verify_install`:
   - Delete the model table check, the subagent contract check, the agent base loop, and the per-harness agent copy and orphan-agent loops.
   - Keep the instructions size, skill source, instructions copy, skill copy, and orphan-skill checks. Trim the locals.
10. Leave `ensure_clone` and `require_clone` unchanged (stage 4).

### scripts/shell/install.sh, update.sh, remove.sh

11. `install.sh`:
    - Delete the `install_agents` and `install_grok_models` lines.
    - The final info line becomes `restart or reload harnesses that cache skills, then check the skill slash commands`.
12. `update.sh`:
    - Delete `uninstall_agents`, `remove_grok_models`, `install_agents`, and `install_grok_models`.
    - The final info line becomes `restart or reload harnesses that cache skills`.
13. `remove.sh`:
    - Delete `uninstall_agents` and `remove_grok_models`.
    - The final info line becomes `restart or reload harnesses; the skill slash commands should disappear`.
    - The usage line for `--force` keeps "known artifact destinations and orphan artifacts".

### scripts/test/lib.sh (fixture)

14. `T_HARNESS_DIRS`: drop every `*/agents` entry. It keeps `.claude/skills .grok/skills .codex/skills .copilot/skills .copilot/instructions .cursor/skills .gemini/config/skills`.
15. Replace `T_FOREIGN_AGENT_PATH` / `--foreign-agent` with `T_FOREIGN_SKILL_PATH` / `--foreign-skill`. It stages a directory `$home/.claude/skills/plan-ai-tools/` holding `SKILL.md` with the content `not an ai-tools file`.
16. `--modified-copy`: `T_MODIFIED_COPY_PATH="$home/.claude/skills/dev-ai-tools"`. Stage it with `cp -R "$home/.ai-tools/skills/dev-ai-tools" "$T_MODIFIED_COPY_PATH"`, then append `local edit that matches no revision` to `$T_MODIFIED_COPY_PATH/SKILL.md`.
17. Delete `--unmanaged-grok-block` and `T_GROK_UNMANAGED_PATH` (declaration, reset, and option).
18. `--stale-link`: `T_STALE_LINK_PATH="$home/.claude/skills/old-layout-ai-tools"`, linked to `$home/.ai-tools/skills/plan-ai-tools`.
19. `--external-symlink`:
    - Create the directory `$root/external-skill/` with `SKILL.md` containing `outside ai-tools`.
    - Set `T_EXTERNAL_SYMLINK_PATH="$home/.claude/skills/az-ai-tools"` and link it to that directory.
20. `t_origin_commit`:
    - Delete the wrapper marker append; keep the `USER-AGENTS.md` and `skills/plan-ai-tools/SKILL.md` markers and the new test skill.
    - The test skill description becomes `Test-only skill added by t_origin_commit for marker $label. Impact: none.`
    - Update the function comment to match.
21. Update the usage comments of `t_fixture` to the new option names.

### Case files

22. Every case that read an agent path now uses the skill-based fixture. For directory copies, assert with `t_assert_regular_directory`, `t_assert_same_content` (a directory compare), and `grep` on `…/SKILL.md`. Required mapping:

**install.sh**

- `case_install_fresh`: delete the agents loop.
- `case_install_foreign_file_skipped`: `--foreign-skill`. Expect `SKIP: exists, not overwriting: $T_FOREIGN_SKILL_PATH`, check that `$T_FOREIGN_SKILL_PATH/SKILL.md` keeps `not an ai-tools file`, and check that `$root/home/.claude/skills/dev-ai-tools` is a regular directory.
- `case_install_symlink_elsewhere_skipped`: unchanged logic, new fixture path.
- `case_install_overwrite_conflicts`:
  - Fixtures: `--foreign-skill --foreign-instructions`.
  - Replace `$root/home/.claude/skills/az-ai-tools` with a symlink to a fresh `$root/external-skill/` directory whose `SKILL.md` contains `external target stays intact`.
  - After `--overwrite`: both skill paths are regular directories matching `$root/home/.ai-tools/skills/<name>`, the instructions match `USER-AGENTS.md`, and the external `SKILL.md` still holds its text.
- `case_install_legacy_symlinks_migrated`: drop the agent link and its assertions.
- `case_install_grok_models`, `case_install_grok_unmanaged_block`, `case_install_grok_no_model_row`: delete.
- `case_install_antigravity_instructions`: drop the `config/agents` and `.gemini/agents` assertions; keep `GEMINI.md`, the `config/skills` directories, and `.gemini/skills/plan-ai-tools` absent. Delete the `.gemini/skills/planner-ai-tools` assertion. Update the comment to "GEMINI.md plus config/skills" and the retired root `~/.gemini/skills`.
- `case_install_all_includes_undetected_harnesses`: assert regular directories `.claude/skills/plan-ai-tools`, `.grok/skills/plan-ai-tools`, `.codex/skills/plan-ai-tools`, `.copilot/skills/plan-ai-tools`, `.cursor/skills/plan-ai-tools`, `.gemini/config/skills/plan-ai-tools`.
- `case_bootstrap_clones_then_installs`: assert the regular directory `$home/.claude/skills/plan-ai-tools`.

**verify.sh and smoke.sh**

- `case_verify_agent_absent` becomes `case_verify_skill_absent`: `rm -rf "$root/home/.claude/skills/plan-ai-tools"`; expect exit 2 and `WARN: skill absent: $dest`.
- `case_verify_agent_differs` becomes `case_verify_skill_differs`: replace that directory's `SKILL.md` content with `unrelated file`; expect exit 2 and `WARN: skill differs from source: $dest`.
- `case_verify_rejects_legacy_symlinks`: drop the agent link.
- `smoke.sh`: expect `WARN: skill absent:`.

**reinstall.sh**

- `case_reinstall_stale_link_removed`: after update, assert `$root/home/.claude/skills/plan-ai-tools` is a regular directory.
- `case_reinstall_modified_copy_kept`: `grep` on `$T_MODIFIED_COPY_PATH/SKILL.md`.
- `case_reinstall_overwrite_modified_copy`: compare with `$root/home/.ai-tools/skills/dev-ai-tools`; `grep` on `…/SKILL.md`.
- `case_reinstall_all_harnesses`: the same six `skills/plan-ai-tools` directory assertions as the install case.

**update.sh**

- `case_update_reset_confined`: `--foreign-skill`. `foreign_path` becomes `$T_FOREIGN_SKILL_PATH/SKILL.md`. Keep exit 2 and update the comment ("foreign skill directory and pre-filled CLAUDE.md differ from source").
- `case_update_stale_copy_refreshed`: delete the `wrapper` variable and assertions; keep instructions and `skills/plan-ai-tools`.
- `case_update_modified_copy_kept`: `target="$home/.claude/skills/plan-ai-tools/SKILL.md"`. `t_origin_commit` changes that skill, so the copy matches neither revision. Keep exit 2 and `SKIP: copy was modified locally, user work preserved:`.
- `case_update_up_to_date_copy`: use `$home/.claude/skills/az-ai-tools`, which `t_origin_commit` never touches, and expect `copied: $home/.claude/skills/az-ai-tools`. Fix the comment.
- `case_update_overwrite_modified_copy`: edit `$home/.claude/skills/plan-ai-tools/SKILL.md`; after `--overwrite`, the directory matches `$home/.ai-tools/skills/plan-ai-tools`.
- `case_update_preserves_orphan_without_overwrite` / `case_update_prunes_orphan_with_overwrite`: delete every `orphan_agent` line and assertion.

**remove.sh**

- `case_remove_removes_installed_copies`: drop the agent absent assertion.
- `case_remove_modified_copy_kept`: `grep` on `$T_MODIFIED_COPY_PATH/SKILL.md`; the unmodified copy asserted absent is `$root/home/.claude/skills/plan-ai-tools`.
- `case_remove_foreign_file_kept`: `--foreign-skill`, same SKIP line with `$T_FOREIGN_SKILL_PATH`, content check on `…/SKILL.md`.
- `case_remove_force_removes_modified_copy`: absent `$T_MODIFIED_COPY_PATH` and `$root/home/.claude/skills/plan-ai-tools`.
- `case_remove_force_removes_foreign_destination`: `--foreign-skill`.
- `case_remove_force_keeps_external_symlink` / `case_remove_external_symlink_kept`: new fixture. External content check on `$root/external-skill/SKILL.md` (`outside ai-tools`).
- `case_remove_force_dry_run`: `grep` on `…/SKILL.md`.
- `case_remove_grok_block`: delete.
- `case_remove_stale_link_sweep`: the real directory becomes `$root/home/.claude/skills/some-real-ai-tools-dir`. Its comment says "A real directory whose name contains ai-tools must survive the sweep."
- `case_remove_without_a_clone`: assert `$root/home/.claude/skills/plan-ai-tools` is still a regular directory.
- `case_remove_all_harnesses`: assert `skills/plan-ai-tools` absent under all six skills roots.
- `case_remove_preserves_orphan_without_force` / `case_remove_prunes_orphan_with_force`: delete the `orphan_agent` lines.

23. Update each case file's header comment where it names wrappers or agents. Keep rule-number citations as they are; stage 5 renumbers.

### README.md (process sections, rule 26)

24. "Scripts":
    - Scope bullet: "`--harnesses <list>` accepts comma- or space-separated harness keys (`claude-code`, `grok`, `codex`, `copilot`, `cursor`, `antigravity`)."
    - Physical copies bullet: "instructions and skills are always copied."
25. "Development checks", test fixture paragraph: drop "an unmanaged Grok block" → "…a foreign file on a destination path, a locally modified copy, and a stale link from an older layout."
26. "Safety rules":
    - "**Never** recursively remove a harness's skills root; replace or remove individual artifact paths only."
    - "Never touch vendor bundles (`~/.grok/bundled/`), unrelated user skills, a repository's own `AGENTS.md` …".
27. "Supported harnesses":
    - Intro: "One row per harness: global instructions destination and skills root."
    - The first table keeps only the columns Harness, Global instructions destination, and Skills root (drop the Agents root and wrapper columns).
    - Antigravity note: "instructions at `GEMINI.md`, skills at `config/skills/`. Do not install into `$HOME/.gemini/skills/` (retired Gemini CLI root). The stale-link sweep unlinks leftover ai-tools links there without touching `config/`."
    - `$HOME/.agents/` note ends "…would double-register every skill."
    - Leave the "Change the session model" table for stage 4.
28. "Installation":
    - Step 2: "…creates their skill roots as needed."
    - Delete step 4 (Agents) and step 6 (Grok model pinning); renumber the steps to 1–5.
    - Skills step: "Recursively copy each `skills/*-ai-tools` directory into every scoped skills root (rules 7–9)."
    - Verify step: "every installed instruction and skill is a physical copy matching its source; `USER-AGENTS.md` fits the repository's 8,000-character cap (rule 3); every shipped `skills/<name>/SKILL.md` exists. Any installation symlink is a finding…"
    - Closing: "Then restart or reload any harness that caches skills at startup. Confirm a slash command for every shipped skill."
29. "Removal":
    - First code comment: `# remove skills`.
    - Step 2 becomes "**Skills** — remove copies only while…".
    - Delete step 3 (Grok) and renumber.
    - Last paragraph ends "Restart the harness: skill slash commands leave its menu."
30. "Update":
    - Step 2: "using this clone's skills and instructions: skills, the stale-link sweep (`--no-sweep` skips), and instructions (`--no-instructions` keeps them)…".
    - Step 4: "…listing skills from the tree, never from hardcoded names."
    - Closing: "…confirm a slash command for every shipped skill."
31. "Troubleshooting":
    - "**Skills missing after install/update:** the harness caches skills at startup — fully restart the CLI or IDE, then `verify`."
    - Delete the wrong-model bullet.
    - Clone-location bullet: "…move it there (rule 23). Installed instructions and skills reference that path; no other location is recoverable by configuration."

## Tests

- `scripts/test.sh` exits 0; no case reports `asserted nothing`.
- `scripts/lint.sh` exits 0.
- The CI shellcheck command reports only the pre-existing `SC1071`.
- `grep -nE 'agents_root|install_agents|uninstall_agents|prune_orphan_agents|category_for|models_csv_field|model_for|model_effort_for|grok_models_toml|install_grok_models|remove_grok_models|GROK_|MODEL_TABLE|in_scope|subagents' scripts` prints nothing.
- `grep -rniE '\bagents?\b|wrapper|MODELS\.csv' scripts/shell scripts/test | grep -vE 'AGENTS(\.override)?\.md|USER-AGENTS|\$HOME/\.agents|agents_md|agentsmd'` prints only the two clone-validation lines in `ensure_clone`/`require_clone` (removed in stage 4).
- Sandbox spot check (manual evidence for the log): `t_fixture`-style run of `install.sh --harnesses all` into a fake `HOME`. No `*/agents` directory is created under the fake `HOME`, and `~/.grok/config.toml` is not created.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds.

## Acceptance criteria

- [ ] No function, call, constant, message, or comment in `scripts/shell/` handles agents, wrappers, `MODELS.csv`, or Grok model pins, except the clone validation left for stage 4
- [ ] Install, update, remove, and verify still cover instructions and skills, including the stale-link sweep for skills roots and the retired `$HOME/.gemini/skills` root
- [ ] Tests use only instructions and skill fixtures; every former install/remove/update/verify contract (copies, conflicts, `--overwrite`, `--force`, `--dry-run`, orphans, sweep, `$HOME/AGENTS.md`, exit codes) is still asserted on skills
- [ ] README Scripts, Safety rules, Supported harnesses, Installation, Removal, Update, and Troubleshooting describe no agent behaviour
- [ ] `scripts/test.sh` and `scripts/lint.sh` exit 0; shellcheck shows no new finding
- [ ] `skills/` and `USER-AGENTS.md` unchanged

## Commit message

```text
refactor(scripts)!: stop installing agents and pinning Grok models

BREAKING CHANGE: install, update, remove, and verify no longer manage agent
wrappers in harness agent roots or the ai-tools block in ~/.grok/config.toml.
```

## Dependencies

- Requires stages: 2

## Implementation log
