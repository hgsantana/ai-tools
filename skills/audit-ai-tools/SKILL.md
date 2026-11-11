---
name: audit-ai-tools
description: >
  Audit a repository for defects and security flaws at general, thorough, or
  exhaustive package depth. The session settles mode and scope, then
  orchestrates clean-context subagents on session model and effort to map
  perimeter and disjoint scopes, inspect code, adversarially refute or
  reproduce candidates in an isolated temp sandbox, and write a calibrated
  report. Use for /audit-ai-tools.
argument-hint: "[general | thorough | exhaustive, optional focus, report path, or worker]"
---

<skill name="audit-ai-tools">
  <overview>
    Perform a read-only, evidence-verified defect and security audit of a repository at one of three specialization depths (`general`, `thorough`, or `exhaustive`), executing the exact same discovery, falsification, and calibration methodology across all three modes while scaling only primary scope granularity. The session is orchestrator only: it reads top-level repository documentation without inspecting source code, settles the audit mode, Scope Auditor worker type (defaulting to `session-subagent`, so every role inherits session model and effort unless overridden), optional focus or exclusions, and report path, snapshots workspace integrity into an OS temp work directory, and dispatches clean-context subagents in bounded waves. A Mapper documents global perimeter defenses and partitions 100% of in-scope files into disjoint primary scopes at the chosen depth. Scope Auditors inspect every file in their primary scope through a seven-lens checklist, extrapolating into external packages solely to verify or falsify hypotheses born in their scope, and record atomic findings with verbatim code quotes directly to disk. A Clusterer deduplicates overlapping discoveries by root defect, Adversarial Verifiers attempt to falsify each batch via static call-chain checks and empirical reproductions inside an isolated temp sandbox copy, and a Consolidator calibrates surviving findings against real deployment topology, groups shared fixes into work packages, writes the final report uncommitted, and verifies zero unintended repository modifications.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard audit terminology:
      - `Audit`: Read-only defect and security investigation governed by `{WORK_DIR}/0-charter.md` and delivered to `{REPORT_PATH}`.
      - `Mode`: Primary scope decomposition depth — `general` (depth 1: master packages / application domains), `thorough` (depth 2: subdomains / direct subpackages of master packages), or `exhaustive` (depth 3: subpackages of subpackages of master packages).
      - `Work directory`: Transient OS temp directory `${TMPDIR:-/tmp}/ai-tools/audit-ai-tools/{SLUG}` holding `0-charter.md`, `0-integrity.txt`, `0-perimeter.md`, `0-scope-manifest.md`, raw candidates, clusters, verified batches, and isolated reproduction sandboxes.
      - `Mapper`: Clean-context subagent inheriting session model and effort; produces `0-perimeter.md` and the disjoint scope partition `0-scope-manifest.md`.
      - `Scope Auditor`: Clean-context agent resolved per `<rule id="auditor-selection">`; inspects one primary scope end-to-end and writes atomic candidate findings to `{WORK_DIR}/findings/candidates/{SCOPE_ID}.md`.
      - `Clusterer`: Clean-context subagent inheriting session model and effort; merges duplicate discoveries caused by outbound extrapolation into root-cause clusters in `{WORK_DIR}/findings/clusters.md`.
      - `Verifier`: Clean-context subagent inheriting session model and effort; adversarially attempts to refute one batch of candidate clusters and runs empirical sandbox checks in `{WORK_DIR}/sandbox/{BATCH_ID}`.
      - `Consolidator`: Clean-context subagent inheriting session model and effort; writes `{REPORT_PATH}`, groups remediation work packages, cleans heavy sandbox build artifacts, and verifies workspace integrity against `0-integrity.txt`.
    </rule>

    <rule id="session-role">The session is orchestrator only:
      - It reads only top-level repository documentation (`README.md`, `AGENTS.md`, operational docs under `docs/`) to capture architecture overview, memory caps, and live-test prohibitions; it never reads application source code.
      - It dispatches every subagent itself, updates wave completion rows in `0-scope-manifest.md` and `findings/clusters.md` sequentially after waves return, and branches solely on `<return_protocol>` signals and status tables; no subagent dispatches another.
      - It never reads candidate files, verified batch files, or subagent conversation transcripts, never summarizes findings from memory, and never stages, commits, or mutates any target repository file (leaving `{REPORT_PATH}` uncommitted even when `{REPORT_PATH}` lies inside the repository, overriding `<rule id="always-commit">` for read-only audits).
    </rule>

    <rule id="auditor-selection">Scope Auditor worker resolution:
      - `Mapper`, `Clusterer`, `Verifier`, and `Consolidator` always run as clean-context subagents inheriting current session model and effort.
      - `{AUDITOR}` for `Scope Auditor` defaults to `session-subagent` (inheriting current session model and effort, prioritizing analytical depth over token cost) without asking, unless the user's request names another valid type from `<rule id="implementer-types">` (`harness-default`, or a tier optionally prefixed by `agy`, `claude`, `codex`, or `copilot`, resolved at dispatch time as in `<rule id="implementer-selection">`; `session` is invalid).
      - Ask via `<user_interaction>` only when a requested worker matches no valid type.
      - Every `Scope Auditor` follows `<rule id="implementer-lifecycle">`: spawned fresh with clean zeroed context for one scope inspection and terminated on return.
    </rule>

    <rule id="audit-modes">Uniform methodology across three scope depths:
      - `general`, `thorough`, and `exhaustive` run the identical mapping, seven-lens inspection, outbound extrapolation, adversarial verification, and consolidation pipeline; only the Mapper's partition depth changes.
      - Transparent language-layout wrapper directories (`src/`, `internal/`, `pkg/`, `app/`, organization namespace prefixes) are unwrapped when stepping down package levels, and colocated test files and directories (`*_test.*`, `*.test.*`, `*.spec.*`, `__tests__/`, `*test/`) always stay paired inside the same scope or virtual slice as the production files they test.
      - At `thorough` and `exhaustive` depths, loose files sitting at a parent package root alongside child subdirectories form a `-core` scope, sibling micro-leaves under 80 combined lines within the same parent coalesce, terminal flat leaves up to 400 lines without child package directories remain intact as single leaf scopes, and terminal flat leaves over 400 lines without child package directories are sliced into cohesive virtual subpackages (pairing each production unit with its colocated tests).
      - `general` (depth 1): one primary scope per master package / application domain at the root of source trees, plus one `root-infra-contracts` scope covering repository-root build/container manifests, CI/CD workflows, API/DB schemas, operational scripts, and quality-gate definitions.
      - `thorough` (depth 2): one primary scope per direct subpackage inside each master package (and decomposed `root-infra-contracts` subdomains: build/container, CI workflows, schemas/gates, scripts), applying the loose-file, coalescing, and over-400-line virtual-slicing rules to flat master packages.
      - `exhaustive` (depth 3): one primary scope per subpackage inside each depth-2 subpackage, applying the loose-file, coalescing, and over-400-line virtual-slicing rules to both flat depth-2 and flat depth-3 terminal packages.
    </rule>

    <rule id="anti-contamination">Independence across audits:
      - During intake, mapping, discovery, and verification, avoid reading prior or sibling audit reports in any language (such as `docs/audit-ai-tools/**`, `*audit*.md`, or external temp audit files) so concurrent or sequential multi-harness audits remain independent and unanchored.
      - This is an avoidance rule rather than a hard ban: inspect existing audit artifacts only when `0-charter.md` records an explicit user instruction to cross-check, compare, or re-verify them.
    </rule>

    <rule id="evidence-and-isolation">Evidence integrity and zero target mutation:
      - Never read `.system_generated/logs/transcript*.jsonl` or intermediate agent logs; inter-agent continuity flows exclusively through finalized files in `{WORK_DIR}`.
      - Enforce strict atomicity: one root defect equals one candidate finding. Multiple call sites or UI symptoms caused by the same root defect stay listed as blast radius inside that single finding, never split into duplicate IDs nor bundled with unrelated defects.
      - Every candidate finding must embed a verbatim 3 to 15 line code snippet copied directly from a file read during that subagent run (re-reading before writing whenever uncertain), citing exact `path:startLine-endLine` and exact symbol names.
      - Target repository worktree remains untouched throughout discovery and verification; empirical reproduction tests or build output checks run only inside isolated non-dereferenced copies under `{WORK_DIR}/sandbox/{BATCH_ID}` with zero symlinks pointing back into the target repository, redirecting build/test caches inside `{WORK_DIR}/sandbox/{BATCH_ID}/.cache`, excluding secrets and `.env` files per `<rule id="no-secrets">`, and obeying `<security_guardrails>`, `<rule id="cloud-approval">`, and repository `AGENTS.md` memory and live-service restrictions.
    </rule>

    <rule id="wave-concurrency">Bounded parallel dispatch:
      - Dispatch at most 6 `Scope Auditor` subagents concurrently per discovery wave and at most 2 `Verifier` subagents concurrently per verification wave to avoid API rate limits and local CPU or memory contention.
    </rule>

    <rule id="transient-docs">Artifact locations:
      - All transient manifests, integrity baselines, raw candidates, clusters, verified batches, and reproduction sandboxes live under `${TMPDIR:-/tmp}/ai-tools/audit-ai-tools/{SLUG}`.
      - `{REPORT_PATH}` defaults to `docs/audit-ai-tools/{SLUG}/audit-{SLUG}.md` (written unpushed and uncommitted at consolidation) unless the user specifies another destination such as an OS temp path for zero repository footprint.
    </rule>
  </boundaries>

  <return_protocol>
    <signal code="MAP_READY">Mapper: perimeter brief and 100%-coverage disjoint scope manifest written.</signal>
    <signal code="SCOPE_AUDITED">Scope Auditor: primary scope inspected and atomic candidate file written.</signal>
    <signal code="CLUSTERS_READY">Clusterer: raw candidates deduplicated into root-cause clusters and verification batches.</signal>
    <signal code="BATCH_VERIFIED">Verifier: batch adversarially evaluated, sandbox checks completed, verdicts written.</signal>
    <signal code="AUDIT_COMPLETE">Consolidator: calibrated report written, sandbox cleaned, workspace integrity verified.</signal>
    <signal code="INTEGRITY_VIOLATION">Consolidator: unexpected file mutation or untracked artifact detected in target repository.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="resolve-entry">
      Derive kebab-case {SLUG} anchored by the repository directory basename (appending request topic words after stripping mode and worker tokens so distinct repositories never collide) and set {WORK_DIR} = `${TMPDIR:-/tmp}/ai-tools/audit-ai-tools/{SLUG}`, {CHARTER_FILE} = `{WORK_DIR}/0-charter.md`, {INTEGRITY_FILE} = `{WORK_DIR}/0-integrity.txt`, {PERIMETER_FILE} = `{WORK_DIR}/0-perimeter.md`, {MANIFEST_FILE} = `{WORK_DIR}/0-scope-manifest.md`, {CANDIDATES_DIR} = `{WORK_DIR}/findings/candidates`, {CLUSTERS_FILE} = `{WORK_DIR}/findings/clusters.md`, {VERIFIED_DIR} = `{WORK_DIR}/findings/verified`, and {SANDBOX_DIR} = `{WORK_DIR}/sandbox`. When {CHARTER_FILE}, {INTEGRITY_FILE}, {PERIMETER_FILE}, and {MANIFEST_FILE} exist for the same canonical workspace root and {CHARTER_FILE} records status `awaiting-fanout` or `auditing`: if the user requested a different mode or a fresh run, ask via `<user_interaction>` whether to resume or restart fresh (removing {WORK_DIR} on restart); when resuming, read settled parameters from {CHARTER_FILE} and jump to `<step id="5">` on `awaiting-fanout` or `<step id="6">` on `auditing`. Otherwise remove any stale `complete` or `aborted` {WORK_DIR} for {SLUG} and continue at `<step id="2">`.
    </step>

    <step id="2" name="settle-audit">
      Read repository documentation (`README.md`, `AGENTS.md`, operational docs under `docs/`) per `<rule id="session-role">`, avoiding prior audit reports per `<rule id="anti-contamination">`. Resolve {AUDITOR} per `<rule id="auditor-selection">`. Map any localized equivalent of `general`, `thorough`, or `exhaustive` in the user's request to its canonical {MODE} token, apply full-repository scope unless focus or exclusions were stated, and default {REPORT_PATH} per `<rule id="transient-docs">` unless an explicit path was given. Prompt via `<user_interaction>` (batched, recommended option first, recommending `thorough` when {MODE} was omitted) only when {MODE} was omitted or the user's request contains genuine ambiguities.
    </step>

    <step id="3" name="write-charter">
      Write the workspace integrity baseline to {INTEGRITY_FILE} (never inside {CHARTER_FILE}): when inside a git worktree, record `git status --porcelain=v1 -uall` plus regular-file SHA-256 digests (`[ -f "$p" ] && [ ! -L "$p" ]`) and symlink `readlink` targets across `git ls-files -z --cached --others --exclude-standard`; outside git, walk the workspace pruning `.venv`, `venv`, `vendor`, `target`, `dist`, `build`, `node_modules`, `__pycache__`, `.idea`, and `.vscode`, recording regular-file SHA-256 digests and symlink `readlink` targets separately. Write {CHARTER_FILE} recording canonical workspace root, status `mapping`, {MODE}, {AUDITOR}, {REPORT_PATH}, report language (English per `<disk>` unless the user explicitly requested another language), scope inclusions (defaulting to full repository) and exclusions, prior-audit avoidance policy per `<rule id="anti-contamination">`, and repository test, memory, and live-service restrictions from `AGENTS.md`.
    </step>

    <step id="4" name="dispatch-mapper">
      Announce the spawn in one chat line. Spawn `<template role="mapper">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {MODE}, {CHARTER_FILE}, {PERIMETER_FILE}, and {MANIFEST_FILE}. Abort and report {WORK_DIR} if it returns without `<signal code="MAP_READY">`. Update status in {CHARTER_FILE} to `awaiting-fanout`.
    </step>

    <step id="5" name="confirm-fanout">
      Read the scope table row count from {MANIFEST_FILE}. When the scope count exceeds 25, announce {MODE}, scope count, and wave count in one chat line and prompt via `<user_interaction>` to proceed, switch mode, or abort:
      1. Proceed: update status in {CHARTER_FILE} to `auditing` and continue to `<step id="6">`.
      2. Switch mode: update {MODE} and set status to `mapping` in {CHARTER_FILE}, remove {PERIMETER_FILE} and {MANIFEST_FILE}, and return to `<step id="4">`.
      3. Abort: set status to `aborted` in {CHARTER_FILE}, report the aborted audit in one line, and stop.
      When the scope count is 25 or fewer, update status in {CHARTER_FILE} to `auditing`.
    </step>

    <step id="6" name="dispatch-scope-waves">
      Read {MANIFEST_FILE} for rows with status `pending`. When all rows are `done`, proceed to `<step id="7">`. Otherwise select up to 6 `pending` rows per `<rule id="wave-concurrency">`, announce the wave in one chat line, and for each selected row spawn one fresh agent of type {AUDITOR} resolved per `<rule id="auditor-selection">` with clean zeroed context using `<template role="scope-auditor">`, passing {SLUG}, {MODE}, {SCOPE_ID}, {SCOPE_PATHS}, {CHARTER_FILE}, {PERIMETER_FILE}, and {CANDIDATE_FILE} = `{CANDIDATES_DIR}/{SCOPE_ID}.md`. When {AUDITOR} cannot be dispatched from this environment, immediately report it in one line without retrying and stop, leaving {WORK_DIR} intact. Each Scope Auditor ends on return:
      1. `<signal code="SCOPE_AUDITED">` with non-empty {CANDIDATE_FILE}: mark row {SCOPE_ID} `done` in {MANIFEST_FILE} once the wave completes.
      2. Missing signal or missing/empty {CANDIDATE_FILE}: remove any partial {CANDIDATE_FILE} and retry that scope once with a fresh agent; if it fails again, report the failed {SCOPE_ID} and {WORK_DIR} in one line and stop.
      Repeat `<step id="6">` until every scope row in {MANIFEST_FILE} is `done`.
    </step>

    <step id="7" name="dispatch-clusterer">
      When {CLUSTERS_FILE} already exists containing a rendered `Batch ID` table header (including 0 batch rows or `pending` rows from an interrupted verification run), proceed to `<step id="8">`. Otherwise announce the spawn in one chat line and spawn `<template role="clusterer">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {CHARTER_FILE}, {MANIFEST_FILE}, {CANDIDATES_DIR}, and {CLUSTERS_FILE}. Abort and report {WORK_DIR} if it returns without `<signal code="CLUSTERS_READY">`.
    </step>

    <step id="8" name="dispatch-verifier-waves">
      Read the verification batch table in {CLUSTERS_FILE}. When 0 batches exist or all batch rows are `done`, proceed to `<step id="9">`. Otherwise select up to 2 `pending` batches per `<rule id="wave-concurrency">`, announce the wave in one chat line, and for each batch spawn `<template role="verifier">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {BATCH_ID}, {CHARTER_FILE}, {PERIMETER_FILE}, {CLUSTERS_FILE}, {SANDBOX_DIR}, and {VERIFIED_FILE} = `{VERIFIED_DIR}/{BATCH_ID}.md`. For each batch on wave return:
      1. `<signal code="BATCH_VERIFIED">` with non-empty {VERIFIED_FILE}: mark row {BATCH_ID} `done` in {CLUSTERS_FILE}.
      2. Missing signal or missing/empty {VERIFIED_FILE}: remove any partial {VERIFIED_FILE} and `{SANDBOX_DIR}/{BATCH_ID}` and retry that batch once with a fresh Verifier; on a second failure, report the failed {BATCH_ID} and {WORK_DIR} in one line and stop.
      Repeat `<step id="8">` until every batch row in {CLUSTERS_FILE} is `done`.
    </step>

    <step id="9" name="dispatch-consolidator">
      Announce the spawn in one chat line. Spawn `<template role="consolidator">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {CHARTER_FILE}, {INTEGRITY_FILE}, {PERIMETER_FILE}, {MANIFEST_FILE}, {CLUSTERS_FILE}, {VERIFIED_DIR}, {SANDBOX_DIR}, and {REPORT_PATH}.
    </step>

    <step id="10" name="outcome">
      Branch on the Consolidator return without staging or committing {REPORT_PATH}:
      1. `<signal code="AUDIT_COMPLETE">`: update status in {CHARTER_FILE} to `complete` and send a one-line outcome from the Consolidator summary line naming {MODE}, scopes audited, confirmed vs plausible vs refuted counts, and a link to {REPORT_PATH}.
      2. `<signal code="INTEGRITY_VIOLATION">` or missing signal: set status in {CHARTER_FILE} to `aborted` and report the integrity or consolidation failure in one line with {WORK_DIR} and {REPORT_PATH} for inspection.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mapper" executor="inherited">
      <job>Map global perimeter defenses and partition 100% of in-scope repository files into disjoint primary scopes for mode {MODE}.</job>
      <input>
        <slug>{SLUG}</slug>
        <mode>{MODE}</mode>
        <charter_file>{CHARTER_FILE}</charter_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <manifest_file>{MANIFEST_FILE}</manifest_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. Read {CHARTER_FILE} for audit {SLUG}, mode {MODE}, scope inclusions and exclusions, and operational constraints. Avoid reading prior or sibling audit reports in any language (such as `docs/audit-ai-tools/**` or `*audit*.md`) unless {CHARTER_FILE} explicitly instructs inspecting them.
        1. Inspect entrypoints, router/middleware wiring, auth/RBAC/tenant enforcement, CORS/CSP/security headers, request size and timeout configs, bundler/base-path settings, container/CI/CD configs, and deployment scaling docs. Write {PERIMETER_FILE} concisely covering: runtime topology and trust boundaries, global defenses that block classes of attacks upstream, environment preconditions (such as instance count, repo visibility, IAM gates, rate limits), and the top cross-package state-mutating flows.
        2. Enumerate all tracked repository files (`git ls-files`, or filesystem walk when outside git), restrict to explicit scope inclusions in {CHARTER_FILE} (all files when full-repository), and exclude only vendor/lock/binary/generated build outputs, prior audit reports (`docs/audit-ai-tools/**`) unless included by {CHARTER_FILE}, and explicit exclusions in {CHARTER_FILE}; record every excluded pattern in {MANIFEST_FILE}.
        3. Partition 100% of remaining in-scope files into disjoint primary scopes according to {MODE}:
           - Unwrap transparent layout containers (`src/`, `internal/`, `pkg/`, `app/`, language namespace wrappers) when descending levels, and always keep colocated tests (`*_test.*`, `*.test.*`, `*.spec.*`, `__tests__/`, `*test/`) inside the same scope or virtual slice as the production code they test.
           - When {MODE} is `general` (depth 1): create one scope per master package / application domain at the root of source trees, plus `root-infra-contracts` for root manifests, CI workflows, schemas, scripts, and quality gates.
           - When {MODE} is `thorough` (depth 2): create one scope per direct subpackage of each master package and decompose `root-infra-contracts` into cohesive subdomains; retain loose files at a master package root alongside subdirectories as a `-core` scope, coalesce sibling micro-leaves under 80 combined lines within the same parent, keep terminal flat leaves up to 400 lines intact, and slice flat master packages over 400 lines without subdirectories into cohesive virtual subpackages (pairing each production unit with its tests).
           - When {MODE} is `exhaustive` (depth 3): create one scope per subpackage of each depth-2 subpackage; retain loose parent-level files alongside subdirectories as a `-core` scope, coalesce sibling micro-leaves under 80 combined lines within the same parent, keep terminal flat leaves up to 400 lines intact, and slice any terminal flat depth-2 or depth-3 package over 400 lines without child package directories into cohesive virtual sub-subpackages (pairing each production unit with its tests).
        4. Programmatically verify exact partition parity: every in-scope non-excluded file must match at least one and at most one scope. Fix overlaps or orphans before writing {MANIFEST_FILE}.
        5. Write {MANIFEST_FILE} with excluded patterns, total file/LOC counts, and a markdown table with columns `#`, `Scope ID` (unique flat kebab-case slug matching `[a-z0-9-]+`, containing no `/` or leading `.`), `Status` (all `pending`), `LOC`, and `Paths` (explicit file list or exact disjoint globs).
        6. Return one line ending with `<signal code="MAP_READY">`.
      </instructions>
      <constraints>
        <constraint>Never modify or create any file inside the target repository; write only {PERIMETER_FILE} and {MANIFEST_FILE}.</constraint>
        <constraint>Guarantee 100% disjoint coverage of in-scope non-excluded files; zero orphaned root configs, schemas, scripts, or loose parent-package files.</constraint>
      </constraints>
    </template>

    <template role="scope-auditor" executor="implementer">
      <job>Audit primary scope {SCOPE_ID} end-to-end under mode {MODE}, extrapolating outward only to verify or refute in-scope hypotheses, and write atomic verbatim-backed candidates.</job>
      <input>
        <slug>{SLUG}</slug>
        <mode>{MODE}</mode>
        <scope_id>{SCOPE_ID}</scope_id>
        <scope_paths>{SCOPE_PATHS}</scope_paths>
        <charter_file>{CHARTER_FILE}</charter_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <candidate_file>{CANDIDATE_FILE}</candidate_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. You are auditing scope {SCOPE_ID} ({SCOPE_PATHS}) of audit {SLUG} (mode {MODE}).
        1. Read {CHARTER_FILE} and {PERIMETER_FILE} first so you account for upstream auth, middleware, bundler, and runtime constraints. Avoid reading prior or sibling audit reports in any language (such as `docs/audit-ai-tools/**`, `*audit*.md`, or external temp audits) during discovery to prevent cross-audit contamination, unless {CHARTER_FILE} explicitly directs inspecting them.
        2. Read 100% of files matched by {SCOPE_PATHS} line by line (production code and colocated tests). Do not skim large files.
        3. Hunt adversarially across seven defect lenses within {SCOPE_PATHS}:
           - Authn, authz, and tenant isolation: missing route/method guards, IDOR, cross-tenant ID decoding without ownership check, legacy string role fallbacks, unauthenticated write or cache side effects on read paths.
           - Arithmetic, bounds, parsing, and input safety: signed/unsigned integer overflow (such as pagination `(page - 1) * limit` producing negative slice bounds), index/nil panics, unbounded reads/allocations, unsafe URL schemes (`javascript:`, `data:`), XSS/CSS/hex/HTML/command/template injection.
           - Concurrency, lifecycle, and partial failures: stale cache generations, data races, production goroutine/timer leaks (distinguishing production paths from test-only wiring), non-atomic multi-service mutations leaving split-brain or orphan state, server timeouts mismatched against max payload sizes.
           - Cross-layer contract fidelity: mismatches between schemas (OpenAPI/Protobuf/GraphQL), HTTP handlers, DB models/indexes, and UI API clients/types (wrong field/ID passed, undocumented status codes, inline base64 stored in URL fields).
           - UI, styling, and accessibility (when applicable): undefined CSS classes referenced in templates/JSX, broken theme tokens, WCAG AA contrast failures computed from actual hex values, missing modal Escape/focus-trap/ARIA handling, swallowed async errors.
           - Build, container, CI, and ops safety (when applicable): `.dockerignore` secret/env leakage, `0.0.0.0` dev/emulator exposure, workflow ref/permission flaws, shell scripts reachable by untrusted inputs.
           - Verification and guardrail gaps: security-critical paths missing from mutation/coverage gates, evidence scripts passing when 0 tests ran, tests asserting mocks instead of real invariants.
        4. Controlled outbound extrapolation: whenever a concrete failure hypothesis originates inside {SCOPE_PATHS}, trace inbound callers and outbound callees, types, schemas, or middlewares in other packages strictly as needed to confirm or falsify reachability, sanitization, and impact. Do not audit unrelated code outside {SCOPE_PATHS}.
        5. Enforce atomic, verbatim-evidenced recording in {CANDIDATE_FILE}:
           - When zero defects are found in {SCOPE_PATHS}, record `No candidate findings.` followed by `Checked and Sound`; never invent filler findings.
           - One root defect equals one candidate block. Group multiple symptoms of the same root cause under `Blast Radius` inside that single block; never bundle distinct defects together.
           - Every candidate block must include: `Candidate ID` ({SCOPE_ID}-C1, ...), `Title`, `Root Owner` (`path:startLine-endLine` and exact symbol — naming the external package when outbound extrapolation located the root defect elsewhere), `Proposed Severity`, `Epistemic Hypothesis` (`Static-Proven` or `External-Dependent`), `Verbatim Code` (exact 3 to 15 lines copied directly from a file read during this subagent run, re-reading before writing whenever uncertain — never paraphrase or recall identifiers from memory), `End-to-End Trace` (entrypoint to sink with `file:line` hops), `Perimeter Check` (why {PERIMETER_FILE} defenses do not neutralize it), and `Verification Sketch` (how a hostile verifier can refute or reproduce it).
           - Include a concise `Checked and Sound` section listing key security/correctness checks in {SCOPE_PATHS} that held up.
        6. Return one line ending with `<signal code="SCOPE_AUDITED">`.
      </instructions>
      <constraints>
        <constraint>Strictly read-only on the target repository and shared manifests: run no builds, tests, containers, or mutations, and write exclusively to {CANDIDATE_FILE}.</constraint>
        <constraint>Never invent, guess, or paraphrase symbol names, config keys, headers, or line numbers; every cited identifier must appear verbatim in a file read during this subagent run.</constraint>
      </constraints>
    </template>

    <template role="clusterer" executor="inherited">
      <job>Deduplicate raw scope candidates by root cause into atomic verification clusters and balanced verifier batches.</job>
      <input>
        <slug>{SLUG}</slug>
        <charter_file>{CHARTER_FILE}</charter_file>
        <manifest_file>{MANIFEST_FILE}</manifest_file>
        <candidates_dir>{CANDIDATES_DIR}</candidates_dir>
        <clusters_file>{CLUSTERS_FILE}</clusters_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. Read {CHARTER_FILE}, {MANIFEST_FILE}, and every candidate file under {CANDIDATES_DIR} for audit {SLUG}.
        1. Extract all candidate findings and all `Checked and Sound` notes across scopes.
        2. Split any candidate that accidentally bundled multiple distinct root causes into separate atomic clusters.
        3. Merge duplicate candidates that point to the same underlying root defect (common when multiple scopes extrapolated into a shared auth, adapter, schema, or selector module), unioning all discovered call sites, affected endpoints/tabs, and verbatim evidence.
        4. Partition the unique root-cause clusters into cohesive verification batches of at most 8 clusters each (grouping clusters that touch the same subsystem or test harness so each Verifier can reuse one sandbox setup).
        5. Write {CLUSTERS_FILE} containing:
           - Summary counts (scopes read, raw candidates, unique clusters, batches),
           - A batch status table with header `| Batch ID | Status | Cluster IDs |` using flat kebab-case IDs (`batch-1`, ...) and status `pending` (render the header with 0 rows when no candidates exist),
           - Every cluster's full consolidated specification (`Cluster ID`, `Title`, `Root Owner`, `Source Candidates`, `Proposed Severity`, `Epistemic Hypothesis`, `Unioned Blast Radius`, `Verbatim Code`, `End-to-End Trace`, `Perimeter Check`, `Verification Sketch`),
           - Aggregated `Checked and Sound` domain coverage notes.
        6. Return one line ending with `<signal code="CLUSTERS_READY">`.
      </instructions>
      <constraints>
        <constraint>Never drop a unique candidate silently during clustering; falsification belongs exclusively to the Verifier phase.</constraint>
        <constraint>Modify nothing in the target repository; write only {CLUSTERS_FILE}.</constraint>
      </constraints>
    </template>

    <template role="verifier" executor="inherited">
      <job>Adversarially attempt to falsify candidate batch {BATCH_ID} against actual code, framework semantics, and isolated sandbox reproductions.</job>
      <input>
        <slug>{SLUG}</slug>
        <batch_id>{BATCH_ID}</batch_id>
        <charter_file>{CHARTER_FILE}</charter_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <clusters_file>{CLUSTERS_FILE}</clusters_file>
        <sandbox_dir>{SANDBOX_DIR}</sandbox_dir>
        <verified_file>{VERIFIED_FILE}</verified_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. Assume every candidate in batch {BATCH_ID} of audit {SLUG} is a hallucinated symbol, a misread framework behavior, an unreachable/test-only path, or an inflated severity until it survives your attempt to disprove it.
        1. Read {CHARTER_FILE}, {PERIMETER_FILE}, and the clusters assigned to {BATCH_ID} in {CLUSTERS_FILE}. Note all test, memory, container, and live-service restrictions in {CHARTER_FILE}, and avoid reading prior or sibling audit reports in any language unless {CHARTER_FILE} explicitly directs inspecting them.
        2. For each cluster in {BATCH_ID}, perform hostile static falsification against the real target repository (read-only):
           - Re-open every cited `file:line`. Verify that the quoted code, symbol names, headers, CSS tokens, and config keys exist verbatim. Flag or correct any discrepancy immediately.
           - Trace all real callers and entrypoints: check whether the code path is dead, reachable only in test wiring, invoked only with hardcoded internal constants, or already neutralized by router normalization, bundler path rewriting (such as Vite `base`), storage/SDK semantics (such as flat object keys or `nosniff` headers), or middleware/IAM guards in {PERIMETER_FILE}.
        3. Where local toolchains permit fast, deterministic empirical proof without touching live cloud resources or violating {CHARTER_FILE} memory/container caps:
           - Create an isolated non-dereferenced copy of tracked repository files at {SANDBOX_DIR}/{BATCH_ID} (`git archive` or `cp -RP` excluding `.git`, `.env*`, credentials, and heavy report dirs; never symlink directories such as `node_modules` from the target repository into the sandbox).
           - Write minimal reproduction unit/handler/fake-adapter tests or inspect a clean build artifact inside {SANDBOX_DIR}/{BATCH_ID}, redirecting build and package caches (`GOCACHE`, `npm_config_cache`, Vite `cacheDir`, `TMPDIR`) inside {SANDBOX_DIR}/{BATCH_ID}/.cache. Never run uncapped heavy containers or live-cloud tests.
        4. Assign each cluster one strict verdict:
           - `CONFIRMED_REPRODUCED`: proven by exact `file:line` trace AND empirical test or build verification in {SANDBOX_DIR}/{BATCH_ID}.
           - `CONFIRMED_STATIC`: proven by an unbroken `file:line` trace with all callers, framework semantics, and perimeter guards verified, where runtime execution requires unavailable external infrastructure.
           - `PLAUSIBLE_EXTERNAL`: static defect or missing guard is real, but trigger depends on unverified live database records, external cloud IAM/WAF/CDN state, or operator configuration.
           - `REFUTED`: disproven by actual code, framework/SDK semantics, perimeter defense, test-only reachability, or sandbox test.
        5. Calibrate severity (`Critical`, `High`, `Medium`, `Low`, `Info`) for surviving clusters against {PERIMETER_FILE} runtime topology (accounting for required attacker privilege, single-instance limits, repo visibility, rate limits, and external preconditions; never rate worst-case theoretical severity when environmental controls constrain impact).
        6. Write {VERIFIED_FILE} with every cluster's verdict, calibrated severity, verified `file:line` citations, verbatim code snippet, reproduction test output or falsification proof, preconditions, and concrete remediation direction.
        7. Return one line ending with `<signal code="BATCH_VERIFIED">`.
      </instructions>
      <constraints>
        <constraint>Never create, edit, or delete files inside the target repository or {CLUSTERS_FILE}; write exclusively inside {SANDBOX_DIR}/{BATCH_ID} and {VERIFIED_FILE}.</constraint>
        <constraint>Never promote a finding with unverified symbol names or paraphrased code, and never run live-cloud or memory-uncapped suites prohibited by {CHARTER_FILE}.</constraint>
      </constraints>
    </template>

    <template role="consolidator" executor="inherited">
      <job>Synthesize verified batches into the final calibrated audit report at {REPORT_PATH}, clean sandbox artifacts, and verify target repository integrity.</job>
      <input>
        <slug>{SLUG}</slug>
        <charter_file>{CHARTER_FILE}</charter_file>
        <integrity_file>{INTEGRITY_FILE}</integrity_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <manifest_file>{MANIFEST_FILE}</manifest_file>
        <clusters_file>{CLUSTERS_FILE}</clusters_file>
        <verified_dir>{VERIFIED_DIR}</verified_dir>
        <sandbox_dir>{SANDBOX_DIR}</sandbox_dir>
        <report_path>{REPORT_PATH}</report_path>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. Read {CHARTER_FILE}, {INTEGRITY_FILE}, {PERIMETER_FILE}, {MANIFEST_FILE}, {CLUSTERS_FILE}, and any verified batch files present under {VERIFIED_DIR} (0 files when 0 batches ran) for audit {SLUG}.
        1. Collect all surviving findings (`CONFIRMED_REPRODUCED`, `CONFIRMED_STATIC`, `PLAUSIBLE_EXTERNAL`) and all `REFUTED` items plus `Checked and Sound` notes. Re-check consistency across batches so no duplicate root defect remains and severities align uniformly with {PERIMETER_FILE}.
        2. Write {REPORT_PATH} in the report language recorded in {CHARTER_FILE} (defaulting strictly to English per `<disk>`) containing:
           - Executive summary and audit metadata: mode, Scope Auditor worker type, scopes audited, raw candidates vs unique clusters vs confirmed/plausible/refuted counts, and empirical sandbox reproductions run.
           - Runtime & threat-model context from {PERIMETER_FILE} explaining severity calibration boundaries.
           - Summary matrix of findings by Severity (`Critical`, `High`, `Medium`, `Low`, `Info`) and Epistemic Status (`Confirmed Reproduced`, `Confirmed Static`, `Plausible External`).
           - Atomic findings ordered by severity: unique ID, title, severity, epistemic status, exact `path:startLine-endLine` references, verbatim code evidence, end-to-end mechanism and reproduction proof, preconditions/blast radius, and actionable fix guidance (or `No surviving findings.` when 0 survive).
           - Prioritized remediation work packages: group surviving findings that share a cohesive root-cause fix into ordered implementation packages (`None` when 0 findings survive).
           - Checked & sound / refuted hypotheses trail: concise summary of areas verified sound and candidate hypotheses falsified during verification.
        3. Remove {SANDBOX_DIR} if present (`rm -rf`) to reclaim disk space while keeping markdown manifests and verified logs intact.
        4. Re-compute the workspace integrity check matching {INTEGRITY_FILE} (`git status --porcelain=v1 -uall` plus regular-file SHA-256 digests and symlink `readlink` targets across `git ls-files -z --cached --others --exclude-standard` when in git, or the matching pruned walk outside git), allowing {REPORT_PATH} as the sole created or modified file when {REPORT_PATH} resides inside the workspace. If any other file was modified, deleted, or created in the target workspace, touch nothing and return `<signal code="INTEGRITY_VIOLATION">`.
        5. Return one single summary line stating `scopes_audited`, `confirmed` (`CONFIRMED_REPRODUCED` plus `CONFIRMED_STATIC`), `plausible` (`PLAUSIBLE_EXTERNAL`), and `refuted` counts plus {REPORT_PATH}, ending with `<signal code="AUDIT_COMPLETE">`.
      </instructions>
      <constraints>
        <constraint>Write every claim strictly from verified artifacts on disk; never invent details or alter target repository files outside {REPORT_PATH}.</constraint>
        <constraint>Never stage or commit {REPORT_PATH} in the target repository.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
