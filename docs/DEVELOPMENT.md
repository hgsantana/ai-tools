# Development and Verification

This guide covers the testing, verification, and code quality workflows for developing and maintaining `ai-tools`.

Development checks live under `scripts/` beside `scripts/shell/`, outside the installation script contract of rules 18–20. They introduce no dependencies beyond standard Unix tools (`git`, `grep`, `awk`, `sed`, `wc`, `tr`, and `bash`).

## Linter (`scripts/lint.sh`)

[`scripts/lint.sh`](../scripts/lint.sh) is a static verification check that mechanically enforces repository rules against the working tree. Run it from anywhere:

```bash
"$HOME/.ai-tools/scripts/lint.sh"              # verify working tree
"$HOME/.ai-tools/scripts/lint.sh" --base <ref> # verify working tree and version bump against <ref>
```

### Exit Codes

- `0`: Clean — all checks passed with no warnings.
- `1`: Aborted on precondition failure (e.g., unknown flag, `--base` without a value).
- `2`: Finished with findings or warnings.

### Check Families

1. **naming** — Skill directory names under `skills/` must end in `-ai-tools` (rule 7).
2. **skill frontmatter** — Every `skills/*/SKILL.md` must exist and contain only supported frontmatter keys (`name`, `description`, `argument-hint`) (rule 6).
3. **skill name match** — The `name:` field in frontmatter must match its parent directory name.
4. **skill description** — Every description must be at most 500 characters, describe what the skill does and when to use it, reference its own `/<name>` command, and omit deprecated `Agent:` or `Impact:` metadata (rule 6).
5. **skill layout** — Enforces root-level structure: no orphan markdown at `skills/` root, no `SKILL-CONTRACT.md` or `MAINTAINER.md`, each skill has a `SKILL.md` containing root `<skill name>`, `<session_workflow>`, and `<dispatch_templates>`, without `## Continue?` or `## Stake` headings (rules 5, 11). Validates required protocols in `plan-ai-tools` (`<planning_protocol>`) and `implement-ai-tools` (`<harness_agents>`, `<implementation_protocol>`, `<simple_tasks_protocol>`), and ensures `AI-TOOLS-AGENTS.md` contains proper frontmatter (`applyTo: "**"`, `alwaysApply: true`) and references optional `$HOME/.ai-tools/USER-AGENTS.md`.
6. **spawn protocol citation** — Every skill defining a `<template>` must cite implement-ai-tools `<harness_agents>` rather than duplicating native subagent API lists (rule 9).
7. **rule anchors** — Skills and user instructions must cite README section anchors rather than rule numbers (rule 9).
8. **size caps** — `AI-TOOLS-AGENTS.md` is capped at 10,000 characters (rule 3), and skill descriptions at 500 characters (rule 6).
9. **instructions headings** — `AI-TOOLS-AGENTS.md` must not contain markdown `##` subheadings after its preamble (rule 3).
10. **line endings and modes** — Tracked files under `scripts/` must resolve to `eol=lf`, and executable scripts must have mode `100755` (rule 21).
11. **no binaries** — All tracked files under `skills/` and `scripts/` must be plain text.
12. **`dev/tmp` untracked** — No files under `dev/tmp` may be committed to git (rule 22).
13. **xml grammar** — All semantic XML bodies must be balanced, use vocabulary tags registered in the README [Semantic XML grammar](../README.md#semantic-xml-grammar), provide unique IDs for `<rule>`, numeric IDs for `<step>`, codes/types for `<signal>`, `<state>`, `<response>`, and valid executors for `<template>` (rule 9).
14. **xml references** — All backticked tag references (`<rule id="...">`, `<template role="...">`, qualified references) must resolve to valid definitions in the source files (rule 9).
15. **placeholder parity** — Every `{PLACEHOLDER}` used in a `<template>` body must be declared in its `<input>`, and every declared input placeholder must be used (rule 9).
16. **vocabulary parity** — The structural XML tags in the README grammar table and the linter's `XML_VOCAB` list must match exactly (rule 9).
17. **version bump** — When run with `--base <ref>`, verifies that any modification to shipped files (`skills/`, `scripts/`, `AI-TOOLS-AGENTS.md`) includes a version bump in `README.md` (rule 4).
18. **rule citations** — Repository rules in `README.md` must be sequentially numbered 1..N without gaps, and all rule citations throughout the codebase must reference valid rules (rule 1).
19. **harness table** — Harness keys, skills roots, and instructions destinations in `scripts/shell/lib.sh` must match the README Scope bullet and Supported harnesses table (rule 19).

---

## Test Suite (`scripts/test.sh`)

[`scripts/test.sh`](../scripts/test.sh) executes sandboxed integration tests for the installation, update, removal, and verification processes.

```bash
"$HOME/.ai-tools/scripts/test.sh"                         # run all test cases
"$HOME/.ai-tools/scripts/test.sh" --case install          # run a single test case file
"$HOME/.ai-tools/scripts/test.sh" --case install --keep   # preserve the test sandbox on completion
```

### Sandboxing & Fixtures

Tests run in an isolated temporary directory with a fake `$HOME` and a local `origin` git remote. No test commands ever access the network or touch the real `$HOME` directory.

Each test case constructs a mock environment featuring:
- Mock harness directories for Claude Code, GitHub Copilot, and Google Antigravity.
- Local git repository fixtures simulating upstream updates, branch switches, detached HEAD states, and uncommitted edits.
- Conflicting pre-existing files, alien symlinks, locally modified copies, and obsolete legacy links.

### Tested Assertions

- **Symlinks by default**: Verifies creation of symbolic links, with clean fallback to physical copies only when symlinks are unsupported (rule 12).
- **Conflict protection**: Proves that existing files and symlinks outside the repository are never overwritten without `--overwrite` (rule 13).
- **Safe removal**: Ensures uninstallation removes only artifacts created by ai-tools, leaving user files untouched (rule 14).
- **Idempotency**: Repeated script runs skip already configured items and exit cleanly (rule 15).
- **User instruction immutability**: Confirms `$HOME/.ai-tools/USER-AGENTS.md` is never modified, deleted, or overwritten by any operation (rule 17).
- **Destructive flag safety**: Refuses destructive actions without explicit flags, and confirms `--dry-run` performs no mutations (rule 20).
- **Exit codes**: Consistently asserts exit codes (`0` clean, `1` precondition failure, `2` warnings/skips) (rule 20).

---

## Continuous Integration (CI)

GitHub Actions runs continuous integration checks on every push and pull request via `.github/workflows/ci.yml`:

- **lint**: Runs `scripts/lint.sh` (passing `--base` with the target branch SHA on PRs) followed by `shellcheck` across all shell scripts.
- **test-shell**: Executes the complete integration test suite via `scripts/test.sh`.

