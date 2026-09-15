# Stage 2: Cloud and maintenance skills on the session model

## Objective

`az-ai-tools`, `gc-ai-tools`, `gh-ai-tools`, `update-ai-tools`, and `remove-ai-tools` run on the session model:

- Each template uses `executor="default-worker"` instead of `agent="…"`.
- Each description ends with `Agent: session.`
- Each skill states its own spawn rule for default workers.
- Update and remove send both the dry run and the approved execution through `script-runner`, because script runs are mechanical work.

## Files

- Create: none
- Modify:
  - `skills/az-ai-tools/SKILL.md`
  - `skills/gc-ai-tools/SKILL.md`
  - `skills/gh-ai-tools/SKILL.md`
  - `skills/update-ai-tools/SKILL.md`
  - `skills/remove-ai-tools/SKILL.md`
- Remove: none

## Steps

### Shared rule (append as the last `<rule>` in `<boundaries>` of all five files, verbatim)

```
    <rule id="default-worker">Spawn each `<template executor="default-worker">` through the harness's native subagent API (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent) with its default agent type and model, passing the populated payload and file paths, never conversation context. Builds, test suites, script runs, and bulk fact collection go there; a single pinpoint command the session needs for its next decision runs in the session. If spawning fails, run the payload in the session and state that in the report.</rule>
```

The user accepted this text (base plan, user answer 1). The in-session fallback applies outside campaign passes only. These five skills never run inside a pass, so their rule needs no campaign sentence.

### az-ai-tools, gc-ai-tools, gh-ai-tools

1. Description: replace the trailing `Agent: implementer-ai-tools.` with `Agent: session.` Re-fold the lines to about 78 columns. Do not change the rest of the wording.
   - az ends with `  Reads run freely; each mutation requires explicit approval. Agent: session.`
   - gc ends with `  freely; each mutation requires explicit approval. Agent: session.`
   - gh ends with `  requires explicit approval. Agent: session.`
2. `<overview>`, second line:
   - az and gc: "Session handles user approvals and mutation guardrails, sending bulk CLI collection to a default worker."
   - gh: keep the overview as it is.
3. `<step id="2">`: replace the line starting "Optionally dispatch `<template role="mechanical-discovery">`" with "Send bulk log or fact collection to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}." gh keeps "bulk fact collection".
4. Template opening tag: `<template role="mechanical-discovery" executor="default-worker">`.
5. `<job>`: "Mechanical worker: …" becomes "Default worker: …", keeping the rest (for example "Default worker: run read-only az commands and collect output.").
6. Append the shared rule.

### update-ai-tools

1. Description: the last line becomes `  requires explicit approval. Agent: session.` The preceding lines stay as they are.
2. `<step id="2" name="dry_run">` becomes:
   ```
      Spawn `<template role="script-runner">` from `<dispatch_templates>` with {FLAGS} set to `--dry-run` plus the scoped flags and {LOG_PATH} set to `dev/tmp/update-dry-run.log`.
      Present each required destructive flag (`--overwrite`, `--discard-local`) separately with what it discards and why.
   ```
3. `<step id="3" name="execution">` becomes:
   ```
      Spawn `<template role="script-runner">` with {FLAGS} set to exactly the approved flags and {LOG_PATH} set to `dev/tmp/update-execution.log`.
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
   ```
4. `<step id="4">`: "reminder to restart harnesses caching agents/skills" becomes "reminder to restart harnesses that cache skills".
5. Template becomes:
   ```
    <template role="script-runner" executor="default-worker">
      <job>Default worker: execute the update shell script and capture output.</job>
      <input>
        <script>scripts/shell/update.sh</script>
        <flags>{FLAGS}</flags>
        <log_path>{LOG_PATH}</log_path>
      </input>
      <instructions>
        Run scripts/shell/update.sh with {FLAGS}.
        Record complete stdout and stderr to {LOG_PATH}.
        Return exit code and log path.
      </instructions>
      <constraints>
        <constraint>Run exactly the given flags; add no destructive flag.</constraint>
      </constraints>
    </template>
   ```
6. Append the shared rule.

### remove-ai-tools

1. Description becomes:
   ```
     Remove this installation per the README: remove skills and optionally
     instructions from harnesses. Use for /remove-ai-tools. Impact: those tools
     become unavailable; the clone remains unless the user separately approves a
     purge. Each destructive step requires explicit approval. Agent: session.
   ```
2. Steps 2 and 3 follow the update pattern:
   - Step 2: `--dry-run` plus the scoped flags, with `dev/tmp/remove-dry-run.log`. It then presents `--instructions`, `--force`, and `--purge` separately, as today.
   - Step 3: the approved flags, with `dev/tmp/remove-execution.log`, plus the existing exit-code lines.
3. The template follows the update pattern with `scripts/shell/remove.sh` and the job "Default worker: execute the remove shell script and capture output."
4. Append the shared rule.

### All five

- No `{APPROVED_FLAGS}` placeholder remains.
- Every template carries `role` and `executor`, and none carries `agent`.

## Tests

- `scripts/lint.sh; echo $?` prints `0`. The output includes `ok: reference resolves: <template executor="default-worker">` for each of the five files, and `ok: template placeholders match their input` for update and remove.
- `git grep -nE '(planner|implementer|mechanical)-ai-tools|agent="|APPROVED_FLAGS' -- skills/az-ai-tools skills/gc-ai-tools skills/gh-ai-tools skills/update-ai-tools skills/remove-ai-tools` prints nothing.
- `git grep -n 'executor="default-worker"' -- skills/az-ai-tools skills/gc-ai-tools skills/gh-ai-tools skills/update-ai-tools skills/remove-ai-tools` shows exactly five template lines, plus five rule lines.
- Every description ends with `Agent: session.`, checked by reading the frontmatter, and lint still reports each within 500 characters.
- `scripts/test.sh` exits 0. The CI shellcheck command reports only the known `SC1071`.

## Acceptance criteria

- [ ] The five skills name no deleted agent and use `executor="default-worker"` on every template
- [ ] Descriptions end with `Agent: session.`; the remove description no longer mentions agents
- [ ] Update and remove run dry run and execution through `script-runner` with `{FLAGS}` and `{LOG_PATH}`
- [ ] Each file carries the `default-worker` boundary rule
- [ ] lint and test exit 0; shellcheck shows no new finding

## Commit message

`refactor(skills): run cloud and maintenance skills on the session model`

## Dependencies

- Requires stages: 1 (ordering only; the two stages touch no shared file)

## Implementation log
