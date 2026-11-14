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
    Perform a read-only, evidence-verified defect and security audit of a repository at one of three specialization depths (`general`, `thorough`, or `exhaustive`), executing the identical discovery, falsification, and calibration methodology across all three modes while scaling primary scope granularity and per-scope LOC ceilings. The session is orchestrator only: it reads top-level repository documentation without inspecting source code, settles the audit mode, Scope Auditor worker type (defaulting to `session-subagent`, so every role inherits session model and effort unless overridden), optional focus or exclusions, and report path, snapshots workspace integrity into an OS temp work directory, and dispatches clean-context subagents in bounded waves. A Mapper documents global perimeter defenses, architectural invariants, and available local verification toolchains, and partitions 100% of in-scope files (including operational runbooks) into disjoint primary scopes within mode LOC budgets. Scope Auditors inspect every file in their primary scope end-to-end through an eight-lens checklist with sibling/CRUD symmetry and full lifecycle checks, extrapolating into external packages solely to verify or falsify hypotheses born in their scope, and record single-fix atomic findings with verbatim code quotes directly to disk. A Clusterer enforces single-fix atomicity and deduplicates overlapping discoveries into toolchain-grouped batches, Adversarial Verifiers attempt to falsify each batch via full-function call-chain checks and reproductions inside an isolated temp sandbox copy, and a Consolidator calibrates surviving findings across a five-tier severity and strict epistemic rubric, groups shared fixes into invariant-safe work packages, writes the final report uncommitted, and verifies zero unintended repository modifications.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard audit terminology:
      - `Audit`: Read-only defect and security investigation governed by `{WORK_DIR}/0-charter.md` and delivered to `{REPORT_PATH}`.
      - `Mode`: Primary scope decomposition depth and per-scope LOC ceiling — `general` (depth 1: master packages / application domains, up to 4,000 LOC per scope), `thorough` (depth 2: direct subpackages of master packages, up to 1,800 LOC per scope), or `exhaustive` (depth 3: subpackages of depth-2 subpackages, up to 800 LOC per scope).
      - `Work directory`: Transient OS temp directory `${TMPDIR:-/tmp}/ai-tools/audit-ai-tools/{SLUG}` holding `0-charter.md`, `0-integrity.txt`, `0-perimeter.md`, `0-scope-manifest.md`, raw candidates, clusters, verified batches, and isolated reproduction sandboxes.
      - `Mapper`: Clean-context subagent inheriting session model and effort; produces `0-perimeter.md` (including documented invariants and local verification toolchains) and the disjoint scope partition `0-scope-manifest.md`.
      - `Scope Auditor`: Clean-context agent resolved per `<rule id="auditor-selection">`; inspects one primary scope end-to-end and writes single-fix atomic candidate findings to `{WORK_DIR}/findings/candidates/{SCOPE_ID}.md`.
      - `Clusterer`: Clean-context subagent inheriting session model and effort; splits any bundled multi-fix candidates, merges duplicate discoveries caused by outbound extrapolation into root-cause clusters, and writes toolchain-grouped batches to `{WORK_DIR}/findings/clusters.md`.
      - `Verifier`: Clean-context subagent inheriting session model and effort; adversarially attempts to refute one batch of candidate clusters and runs empirical sandbox checks in `{WORK_DIR}/sandbox/{BATCH_ID}`.
      - `Consolidator`: Clean-context subagent inheriting session model and effort; writes `{REPORT_PATH}`, groups remediation work packages, cleans sandbox artifacts, and verifies workspace integrity against `0-integrity.txt`.
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

    <rule id="audit-modes">Uniform methodology across three scope depths and LOC ceilings:
      - `general`, `thorough`, and `exhaustive` run the identical mapping, eight-lens inspection, outbound extrapolation, adversarial verification, and consolidation pipeline; only the Mapper's partition depth and per-scope LOC ceiling change.
      - Unwrap transparent language-layout wrapper directories (`src/`, `internal/`, `pkg/`, `app/`, organization namespace prefixes) when descending package levels, keep loose files sitting at a parent or unwrapped root alongside child subdirectories in a `-core` scope, and pair colocated tests (`*_test.*`, `*.test.*`, `*.spec.*`, `__tests__/`, `*test/`) inside the same scope or virtual slice as the production files they test (assigning shared package-wide test helpers to the package's `-core` or primary slice). Keep individual files intact; when one indivisible production unit plus its colocated tests exceeds the mode LOC ceiling on its own, isolate that pair in its own scope.
      - Keep operational documentation and runbooks (`README.md`, `docs/**` excluding transient `docs/*-ai-tools/**` and prior `*audit*.md` reports) in scope alongside root manifests, CI workflows, schemas, scripts, and quality gates so deployment, secret-rotation, rollback, and backup/restore procedures are audited as operational contracts.
      - At `thorough` and `exhaustive` depths, coalesce sibling micro-leaves under 80 combined lines within the same parent, decompose `root-infra-contracts` into cohesive subdomains (build/container, CI workflows, schemas/gates, scripts/runbooks), and slice shallow flat packages that terminate above the mode's target depth (childless depth-1 packages in `thorough`; childless depth-1 or depth-2 packages in `exhaustive`) into cohesive virtual subpackages whenever they exceed 400 lines.
      - `general` (depth 1, max 4,000 LOC per scope): one primary scope per master package / application domain plus `root-infra-contracts`, splitting any scope over 4,000 LOC into cohesive architectural subdomains.
      - `thorough` (depth 2, max 1,800 LOC per scope): one primary scope per direct subpackage inside each master package and decomposed `root-infra-contracts`, slicing any target-depth scope over 1,800 LOC into cohesive virtual subpackages.
      - `exhaustive` (depth 3, max 800 LOC per scope): one primary scope per subpackage inside each depth-2 subpackage and decomposed `root-infra-contracts`, slicing any target-depth scope over 800 LOC into cohesive virtual sub-subpackages.
    </rule>

    <rule id="anti-contamination">Independence across audits:
      - During intake, mapping, discovery, and verification, avoid reading prior or sibling audit reports in any language (such as `docs/audit-ai-tools/**`, `*audit*.md`, or external temp audit files) so concurrent or sequential multi-harness audits remain independent and unanchored.
      - This is an avoidance rule rather than a hard ban: inspect existing audit artifacts only when `0-charter.md` records an explicit user instruction to cross-check, compare, or re-verify them.
    </rule>

    <rule id="evidence-and-isolation">Evidence integrity, single-fix atomicity, and zero target mutation:
      - Never read `.system_generated/logs/transcript*.jsonl` or intermediate agent logs; inter-agent continuity flows exclusively through finalized files in `{WORK_DIR}`.
      - Enforce strict single-fix atomicity: one root defect equals one candidate finding if and only if one cohesive code or config change at one root owner resolves every listed symptom. Multiple call sites or UI symptoms caused by that single root defect stay listed under `Blast Radius` inside one finding; distinct defects in the same file or module whose fixes are independent are emitted as separate findings and rated individually rather than summed into a composite severity.
      - Every candidate finding must embed a verbatim 3 to 15 line code snippet copied directly from a file read during that subagent run (re-reading before writing whenever uncertain), citing exact `path:startLine-endLine` and exact symbol names.
      - Target repository worktree remains untouched throughout discovery and verification; empirical reproduction tests or build output checks run only inside isolated non-dereferenced copies under `{WORK_DIR}/sandbox/{BATCH_ID}` with zero symlinks pointing back into the target repository, redirecting writable build/test/temp caches inside `{WORK_DIR}/sandbox/{BATCH_ID}/.cache`, excluding secrets and `.env` files per `<rule id="no-secrets">`, and obeying `<security_guardrails>`, `<rule id="cloud-approval">`, and repository `AGENTS.md` memory and live-service restrictions.
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
    <signal code="CLUSTERS_READY">Clusterer: raw candidates split/deduplicated into atomic root-cause clusters and verification batches.</signal>
    <signal code="BATCH_VERIFIED">Verifier: batch adversarially evaluated, sandbox checks completed, verdicts written.</signal>
    <signal code="AUDIT_COMPLETE">Consolidator: calibrated report written, sandbox cleaned, workspace integrity verified.</signal>
    <signal code="INTEGRITY_VIOLATION">Consolidator: unexpected file mutation or untracked artifact detected in target repository.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="resolve-entry">
      Derive kebab-case {SLUG} anchored by the repository directory basename (appending request topic words after stripping mode and worker tokens so distinct repositories never collide) and set {WORK_DIR} = `${TMPDIR:-/tmp}/ai-tools/audit-ai-tools/{SLUG}`, {CHARTER_FILE} = `{WORK_DIR}/0-charter.md`, {INTEGRITY_FILE} = `{WORK_DIR}/0-integrity.txt`, {PERIMETER_FILE} = `{WORK_DIR}/0-perimeter.md`, {MANIFEST_FILE} = `{WORK_DIR}/0-scope-manifest.md`, {CANDIDATES_DIR} = `{WORK_DIR}/findings/candidates`, {CLUSTERS_FILE} = `{WORK_DIR}/findings/clusters.md`, {VERIFIED_DIR} = `{WORK_DIR}/findings/verified`, and {SANDBOX_DIR} = `{WORK_DIR}/sandbox`. When {CHARTER_FILE}, {INTEGRITY_FILE}, {PERIMETER_FILE}, and {MANIFEST_FILE} exist for the same canonical workspace root and {CHARTER_FILE} records status `awaiting-fanout` or `auditing`: if the user requested a different mode or a fresh run, ask via `<user_interaction>` whether to resume or restart fresh (running `chmod -R u+w` before removing {WORK_DIR} on restart); when resuming, read settled parameters from {CHARTER_FILE} and jump to `<step id="5">` on `awaiting-fanout` or `<step id="6">` on `auditing`. Otherwise remove any non-resumed stale {WORK_DIR} for {SLUG} (running `chmod -R u+w` first when present) and continue at `<step id="2">`.
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
      Read the scope table row count from {MANIFEST_FILE}. When the scope count exceeds 25, announce {MODE}, scope count, and wave count in one chat line and prompt via `<user_interaction>` to proceed, adjust mode or scope filters, or abort:
      1. Proceed: update status in {CHARTER_FILE} to `auditing` and continue to `<step id="6">`.
      2. Adjust mode or scope: update {MODE} (when switching to a coarser mode) and/or scope inclusions/exclusions in {CHARTER_FILE}, set status to `mapping`, remove {PERIMETER_FILE} and {MANIFEST_FILE}, and return to `<step id="4">`.
      3. Abort: set status to `aborted` in {CHARTER_FILE}, report the aborted audit in one line, and stop.
      When the scope count is 25 or fewer, update status in {CHARTER_FILE} to `auditing`.
    </step>

    <step id="6" name="dispatch-scope-waves">
      Read {MANIFEST_FILE} for rows with status `pending`. When all rows are `done`, proceed to `<step id="7">`. Otherwise select up to 6 `pending` rows per `<rule id="wave-concurrency">`, announce the wave in one chat line, and for each selected row spawn one fresh agent of type {AUDITOR} resolved per `<rule id="auditor-selection">` with clean zeroed context using `<template role="scope-auditor">`, passing {SLUG}, {MODE}, {SCOPE_ID}, {SCOPE_PATHS}, {CHARTER_FILE}, {PERIMETER_FILE}, {MANIFEST_FILE}, and {CANDIDATE_FILE} = `{CANDIDATES_DIR}/{SCOPE_ID}.md`. When {AUDITOR} cannot be dispatched from this environment, immediately report it in one line without retrying and stop, leaving {WORK_DIR} intact. Each Scope Auditor ends on return:
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
      2. Missing signal or missing/empty {VERIFIED_FILE}: remove any partial {VERIFIED_FILE} and `{SANDBOX_DIR}/{BATCH_ID}` (running `chmod -R u+w` first when present) and retry that batch once with a fresh Verifier; on a second failure, report the failed {BATCH_ID} and {WORK_DIR} in one line and stop.
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
      <job>Map global perimeter defenses, architectural invariants, and local verification toolchains, and partition 100% of in-scope repository files into disjoint LOC-bounded primary scopes for mode {MODE}.</job>
      <input>
        <slug>{SLUG}</slug>
        <mode>{MODE}</mode>
        <charter_file>{CHARTER_FILE}</charter_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <manifest_file>{MANIFEST_FILE}</manifest_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. Read {CHARTER_FILE} for audit {SLUG}, mode {MODE}, scope inclusions and exclusions, and operational constraints. Avoid reading prior or sibling audit reports in any language (such as `docs/audit-ai-tools/**` or `*audit*.md`) unless {CHARTER_FILE} explicitly instructs inspecting them.
        1. Inspect entrypoints, router/middleware wiring, auth/RBAC/tenant enforcement, CORS/CSP/security headers, request size and timeout configs, bundler/base-path settings, container/CI/CD configs, and deployment/architecture/runbook docs. Probe installed local compilers, version managers (`mise`, `asdf`, `nvm`, `uv`, `.venv`), test runners, and headless browser binaries matching repository manifests via read-only `command -v` and version checks only (run no project builds, tests, or containers). Write {PERIMETER_FILE} concisely covering: runtime topology and trust boundaries, global defenses blocking classes of attacks upstream, documented architectural invariants and intentional design trade-offs (from `AGENTS.md`, ADRs, health/readiness specs) that constrain valid findings and fixes, environment preconditions (instance count, memory caps, repo visibility, IAM gates, rate limits), top cross-package state-mutating flows, exact local toolchain activation commands/paths for sandbox verification, and specification sources (spec directories such as `docs/specs/`, `specs/`, `openspec/specs/`, or `.kiro/specs/`, API schemas, and documented behavior contracts) with the code areas each governs.
        2. Enumerate workspace files (`git ls-files --cached --others --exclude-standard` in git, or pruned filesystem walk outside git), restrict to explicit scope inclusions in {CHARTER_FILE} (all files when full-repository, keeping `README.md` and `docs/**` operational runbooks in scope), and exclude vendor/lock/binary/generated build outputs, transient `docs/*-ai-tools/**` directories, prior `*audit*.md` reports unless included by {CHARTER_FILE}, and explicit exclusions in {CHARTER_FILE}; record every excluded pattern in {MANIFEST_FILE}.
        3. Partition 100% of remaining in-scope files into disjoint primary scopes for {MODE}. Unwrap transparent layout containers (`src/`, `internal/`, `pkg/`, `app/`, language namespace wrappers), place loose files sitting at a parent or unwrapped root alongside subdirectories into a `-core` scope, and pair colocated tests (`*_test.*`, `*.test.*`, `*.spec.*`, `__tests__/`, `*test/`) inside the same scope or virtual slice as their production units (assigning shared package-wide test helpers to `-core` or the primary slice; isolating a single indivisible unit+test pair that exceeds the {MODE} LOC cap into its own solo scope without splitting one file):
           - `general` (depth 1, max 4,000 LOC per scope): one scope per master package / application domain plus `root-infra-contracts` (manifests, CI workflows, schemas, scripts, quality gates, and `README.md`/`docs/` operational runbooks), splitting any scope over 4,000 LOC into cohesive architectural subdomains.
           - `thorough` (depth 2, max 1,800 LOC per scope) and `exhaustive` (depth 3, max 800 LOC per scope): decompose `root-infra-contracts` into cohesive subdomains (build/container, CI workflows, schemas/gates, scripts/runbooks), coalesce sibling micro-leaves under 80 combined lines within the same parent, slice shallow flat packages terminating above target depth (childless depth-1 packages in `thorough`; childless depth-1 or depth-2 packages in `exhaustive`) when over 400 lines, and slice any target-depth scope exceeding the {MODE} ceiling (1,800 LOC in `thorough`; 800 LOC in `exhaustive`) into cohesive virtual subpackages.
        4. Programmatically verify exact partition parity and LOC compliance: every in-scope non-excluded file matches exactly one scope, no `Paths` entry uses a glob that overlaps excluded or transient paths (use explicit file lists whenever a directory also holds excluded files or `docs/*-ai-tools/**`), and every multi-unit scope fits the {MODE} LOC cap.
        5. Write {MANIFEST_FILE} with excluded patterns, total file/LOC counts, and a markdown table with columns `#`, `Scope ID` (unique flat kebab-case slug matching `[a-z0-9-]+`, containing no `/` or leading `.`), `Status` (all `pending`), `LOC`, and `Paths` (explicit file list or exact disjoint globs).
        6. Return one line ending with `<signal code="MAP_READY">`.
      </instructions>
      <constraints>
        <constraint>Never modify or create any file inside the target repository; write only {PERIMETER_FILE} and {MANIFEST_FILE}.</constraint>
        <constraint>Guarantee 100% disjoint coverage of in-scope non-excluded files within {MODE} LOC caps; zero orphaned root configs, schemas, scripts, operational docs, or loose parent-package files.</constraint>
      </constraints>
    </template>

    <template role="scope-auditor" executor="implementer">
      <job>Audit primary scope {SCOPE_ID} end-to-end under mode {MODE}, extrapolating outward only to verify or refute in-scope hypotheses, and write single-fix atomic verbatim-backed candidates.</job>
      <input>
        <slug>{SLUG}</slug>
        <mode>{MODE}</mode>
        <scope_id>{SCOPE_ID}</scope_id>
        <scope_paths>{SCOPE_PATHS}</scope_paths>
        <charter_file>{CHARTER_FILE}</charter_file>
        <perimeter_file>{PERIMETER_FILE}</perimeter_file>
        <manifest_file>{MANIFEST_FILE}</manifest_file>
        <candidate_file>{CANDIDATE_FILE}</candidate_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files or agent transcripts. You are auditing scope {SCOPE_ID} ({SCOPE_PATHS}) of audit {SLUG} (mode {MODE}).
        1. Read {CHARTER_FILE}, {PERIMETER_FILE}, and the excluded-patterns list in {MANIFEST_FILE} first so you account for upstream defenses, documented architectural invariants, runtime constraints, and exclusions. Avoid reading prior or sibling audit reports in any language (`docs/audit-ai-tools/**`, `*audit*.md`, external temp audits) unless {CHARTER_FILE} explicitly directs inspecting them.
        2. Read 100% of non-excluded files matched by {SCOPE_PATHS} line by line from top to bottom (production code, operational docs, and colocated tests), reading complete functions through trailing sort/filter/cleanup/return blocks without skimming large files.
        3. Hunt adversarially across eight defect lenses within {SCOPE_PATHS}, checking full sibling/CRUD matrix symmetry (auditing every sibling route, CRUD method, CLI entrypoint, or view when an invariant such as tenant/context switching, ownership, validation, or fallback persistence applies across a family) and worst-reachable-state escalation (checking whether colliding sequential/legacy IDs or shared form bindings escalate a surface `404` or key mismatch into cross-entity overwrite or permanent lockout):
           - Authn, authz, and isolation boundaries: missing route/method/RPC guards, mass assignment of caller-supplied identity or lifecycle fields (`id`, role, tenant, deletion/review metadata) overwriting existing records, CRUD/subordinate lookups or mutations omitting tenant equality, cross-tenant ID collisions, authorization denials mapped to `401` session-logout codes instead of `403`, legacy role fallbacks, `CSRF`/open-redirect flaws, and unauthenticated write/cache/memory side effects on read paths.
           - Injection, parsing, bounds, crypto, and resource limits: SQL/NoSQL/ORM/command/template/header/CSP/HTML/DOM/CSS injection, `SSRF`, path/symlink/archive traversal, unsafe deserialization or prototype pollution, unsafe URL schemes (`javascript:`, `data:`), weak crypto/nonce/RNG or timing side channels, signed/unsigned integer overflow and float-parsing hazards (`(page - 1) * limit` negative slice bounds, `NaN`/`Inf`/truncation), Unicode/IDNA case-folding mismatches in allowlists, and multi-copy, decompression, or binary UTF-8 replacement heap amplification relative to runtime memory caps.
           - Concurrency, state machines, and partial-failure lifecycles: data races, lock-ordering deadlocks, non-transactional read-modify-write IDs/counters, generation-less caches re-admitting invalidated keys, unbounded maps/goroutines/timers or FD/connection leaks in production paths, stream/timeout errors committing truncated immutable artifacts, multi-store mutations where partial failure plus retry (`404` after soft-delete, stale-credential re-auth) or soft-delete plus re-onboarding (retained unique bindings) deadlocks state, and entity/UI state-machine transitions (create vs update vs state-change clobbering server lifecycle flags, omitted fields zeroing active flags, controlled/uncontrolled ref or mount/unmount desync on no-op events, stale async closures or out-of-order responses, UTC-vs-local timezone handling).
           - Cross-layer and runtime-protocol fidelity: mismatches across API schemas, handlers, storage hydration (batch/search hydration skipping visibility or soft-delete filters), and client models/forms (display labels bound where canonical IDs are expected, fallback persistence across sibling create/update paths), HTTP/1.1 vs HTTP/2/gRPC body-stream cloning or response-wrapper error/header semantics, and cold-start/degraded handlers bypassing security or CORS middleware.
           - UI, styling, and accessibility (when applicable): undefined or build-purged CSS classes, WCAG AA contrast failures computed from actual foreground/background/hover/dark-mode hex values, missing modal/drawer Escape, initial focus, focus trap, focus restore, and ARIA attributes, dead client permission helpers, missing context-change subscriptions on sibling views, and swallowed or misclassified `5xx`/network errors.
           - Build, container, CI, and operational runbooks (when applicable): `.dockerignore` missing subdirectory `.env*` or key/credential globs, `0.0.0.0` dev/emulator exposure and missing container memory/cleanup traps, workflow unpinned refs, broad permissions, credential persistence, or missing timeouts, config/secret validation gaps, and operator runbooks in `README.md`/`docs/` whose rollout, secret-rotation, rollback, or backup/restore sequences cause outages or revive revoked credentials under real deployment topology.
           - Verification and guardrail gaps: security-critical modules omitted from mutation/coverage gates, evidence or gate scripts exiting green when zero tests ran, reports are missing, or early exits skip downstream suites, vacuous test globs or assertions missing status checks, shared test fixtures mutated without `finally` restoration, test mocks masking real client `TypeError`s, and host env leakage into test runs.
           - Specification conformance (when {PERIMETER_FILE} lists specification sources governing {SCOPE_PATHS}): after reading those sources, implementation that contradicts a requirement or scenario, specified behavior with no implementation, a scenario no test verifies, and, inside a spec file, requirements that contradict each other or describe behavior the code no longer has.
        4. Controlled outbound extrapolation: whenever a concrete failure hypothesis originates inside {SCOPE_PATHS}, trace inbound callers, parent render/loading gates, and outbound callees, sibling CRUD handlers, types, schemas, or middlewares in other packages strictly as needed to confirm or falsify reachability, sanitization, and worst-case impact. Do not audit unrelated code outside {SCOPE_PATHS}.
        5. Enforce single-fix atomic, verbatim-evidenced recording in {CANDIDATE_FILE}:
           - When zero defects are found in {SCOPE_PATHS}, record `No candidate findings.` followed by `Checked and Sound`; real `Info`-level dead-code or hygiene defects are valid candidates, whereas fabricated filler and intentional, documented, unit-tested contracts must never be reported.
           - One root defect equals one candidate block if and only if one cohesive fix at one root owner resolves every symptom in `Blast Radius`; emit separate candidate blocks with individual severities for independent defects in the same file or module.
           - Every candidate block must include: `Candidate ID` ({SCOPE_ID}-C1, ...), `Title`, `Root Owner` (`path:startLine-endLine` and exact symbol — naming the external package when outbound extrapolation located the root defect elsewhere), `Proposed Severity` (`Critical`, `High`, `Medium`, `Low`, or `Info`), `Epistemic Hypothesis` (`Static-Proven` or `External-Dependent`), `Blast Radius` (all affected call sites, sibling routes/views, and failure modes sharing that single fix), `Verbatim Code` (exact 3 to 15 lines copied directly from a file read during this subagent run, re-reading before writing whenever uncertain — never paraphrase or recall identifiers from memory), `End-to-End Trace` (entrypoint to sink with `file:line` hops), `Perimeter Check` (why {PERIMETER_FILE} defenses and documented invariants do not neutralize it), and `Verification Sketch` (how a hostile verifier can refute or reproduce it).
           - Include a concise `Checked and Sound` section listing key security/correctness checks in {SCOPE_PATHS} that held up.
        6. Return one line ending with `<signal code="SCOPE_AUDITED">`.
      </instructions>
      <constraints>
        <constraint>Strictly read-only on the target repository and shared manifests: run no builds, tests, containers, or mutations, and write exclusively to {CANDIDATE_FILE}.</constraint>
        <constraint>Never invent, guess, or paraphrase symbol names, config keys, headers, or line numbers; every cited identifier must appear verbatim in a file read during this subagent run.</constraint>
      </constraints>
    </template>

    <template role="clusterer" executor="inherited">
      <job>Enforce single-fix atomicity and deduplicate raw scope candidates by root cause into atomic verification clusters and toolchain-grouped verifier batches.</job>
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
        2. Enforce the single-fix atomicity test on every candidate: if fixing sub-claim A at one root owner leaves sub-claim B broken (even inside the same file or subsystem), split them into separate atomic clusters with independent proposed severities rather than carrying forward a composite bundle or summed severity.
        3. Merge duplicate candidates that share the exact same underlying root fix (common when multiple scopes extrapolated into a shared auth, adapter, schema, or selector module), unioning all discovered call sites, sibling paths, affected endpoints/views, and verbatim evidence.
        4. Partition the unique root-cause clusters into cohesive verification batches of at most 8 clusters each, grouping clusters by shared runtime/test toolchain (such as backend/CLI runtime, frontend/browser runtime, or purely static manifests/runbooks) so each Verifier reuses one sandbox setup and static-only batches avoid unnecessary sandbox copies.
        5. Write {CLUSTERS_FILE} containing:
           - Summary counts (scopes read, raw candidates, split sub-claims, unique atomic clusters, batches),
           - A batch status table with header `| Batch ID | Status | Cluster IDs |` using flat kebab-case IDs (`batch-1`, ...) and status `pending` (render the header with 0 rows when no candidates exist),
           - Every cluster's full consolidated specification (`Cluster ID`, `Title`, `Root Owner`, `Source Candidates`, `Proposed Severity`, `Epistemic Hypothesis`, `Unioned Blast Radius`, `Verbatim Code`, `End-to-End Trace`, `Perimeter Check`, `Verification Sketch`),
           - Aggregated `Checked and Sound` domain coverage notes.
        6. Return one line ending with `<signal code="CLUSTERS_READY">`.
      </instructions>
      <constraints>
        <constraint>Never drop a unique candidate or sub-claim silently during splitting or clustering; falsification belongs exclusively to the Verifier phase.</constraint>
        <constraint>Modify nothing in the target repository; write only {CLUSTERS_FILE}.</constraint>
      </constraints>
    </template>

    <template role="verifier" executor="inherited">
      <job>Adversarially attempt to falsify candidate batch {BATCH_ID} against complete function context, framework/protocol semantics, and isolated sandbox reproductions.</job>
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
        This payload is the brief; do not read sibling skill files or agent transcripts. Assume every candidate in batch {BATCH_ID} of audit {SLUG} is a hallucinated symbol, a partial-function misread, an intentional tested contract, an unreachable production claim, or an ill-calibrated severity until it survives your attempt to disprove it.
        1. Read {CHARTER_FILE}, {PERIMETER_FILE}, and the clusters assigned to {BATCH_ID} in {CLUSTERS_FILE}. Note all test, memory, container, and live-service restrictions in {CHARTER_FILE} plus documented invariants and local verification toolchains in {PERIMETER_FILE}, and avoid reading prior or sibling audit reports in any language unless {CHARTER_FILE} explicitly directs inspecting them.
        2. For each cluster in {BATCH_ID}, perform hostile static falsification against the real target repository (read-only):
           - Re-open every cited `file:line` and read the entire enclosing function or component from signature to final return (including trailing sort/filter/cleanup blocks and parent loading/mount render gates) plus colocated unit tests. If a cluster still packs sub-claims with mixed validity or independent fixes, split it into suffixed sub-IDs (`-a`, `-b`, ...) with separate verbatim snippets and verdicts. Mark `REFUTED` any candidate that flags an intentional, documented, unit-tested contract, or any production-impact claim whose path is dead or reachable only in tests (preserving genuine `Info` dead-code candidates and Lens-7 test/dev-tooling defects).
           - Trace all real callers, sibling CRUD/CLI entrypoints, and error/retry paths against {PERIMETER_FILE} guards. Never refute or downgrade a multi-path hypothesis after inspecting only one caller or one CRUD method — check every sibling write/read path, trace whether retrying after partial failure succeeds or hits `404`/lockout, and check whether ID collisions or shared form bindings escalate a surface `404` into cross-entity overwrite or permanent lockout.
           - For a specification divergence, establish from tests, history, and documentation which side is stale and direct the remediation at it.
        3. When every cluster in {BATCH_ID} is statically `REFUTED` or concerns static source/template/manifest/runbook defects where target execution is inapplicable, skip creating {SANDBOX_DIR}/{BATCH_ID}. Otherwise, where local toolchains in {PERIMETER_FILE} permit fast, deterministic empirical proof without touching live cloud resources or violating {CHARTER_FILE} memory/container caps:
           - Create an isolated non-dereferenced copy of in-scope workspace files at {SANDBOX_DIR}/{BATCH_ID} (`git archive` on a clean git tree, or `cp -RP` excluding `.git`, `.env*`, credentials, vendor/build outputs, and transient report dirs when outside git or when uncommitted workspace files exist; never symlink `node_modules` or other target-repo directories into the sandbox, and never write into the target repository).
           - Activate the matching local toolchain recorded in {PERIMETER_FILE} and run minimal reproduction unit/handler/fake-adapter/script checks or inspect a clean build artifact inside {SANDBOX_DIR}/{BATCH_ID} using exact production middleware and configuration parameters (never synthetic buffer/limit substitutes), redirecting writable compiler, bundler, test, and temp caches (`GOCACHE`, Vite `cacheDir`, `.pytest_cache`, `TMPDIR`) inside {SANDBOX_DIR}/{BATCH_ID}/.cache while reusing pre-warmed host package caches read-only when available. For browser protocol or stateful DOM lifecycle claims (HTTP/1.1 body-stream cloning, focus/blur/tab transitions, compiled CSS), prefer a locally installed headless browser or loopback HTTP/gRPC server within {CHARTER_FILE} caps over synthetic DOM/fetch mocks. Run `chmod -R u+w` before removing transient heavy caches inside {SANDBOX_DIR}/{BATCH_ID} once checks complete.
        4. Assign each atomic cluster (or split sub-cluster) one strict epistemic verdict:
           - `CONFIRMED_REPRODUCED`: proven by exact `file:line` trace AND executing the target code, compiler/bundler, or target script in {SANDBOX_DIR}/{BATCH_ID} to observe the defective runtime behavior, build output, or exit status (grepping or parsing static source, config, or workflow text is static verification, never `CONFIRMED_REPRODUCED`).
           - `CONFIRMED_STATIC`: proven by an unbroken `file:line` trace with all callers, framework semantics, and perimeter guards verified — used for static source/template/manifest/workflow/runbook defects where runtime execution is inapplicable, and for code paths blocked from execution by missing local toolchains, {CHARTER_FILE} resource caps, or unavailable external infrastructure.
           - `PLAUSIBLE_EXTERNAL`: static defect or missing guard is real, but trigger depends on unverified live database records, external cloud IAM/WAF/CDN state, or operator configuration.
           - `REFUTED`: disproven by full-function code, colocated contract tests, framework/SDK semantics, perimeter defense, unreachable production path, or sandbox execution.
        5. Calibrate severity (`Critical`, `High`, `Medium`, `Low`, `Info`) individually per atomic cluster against {PERIMETER_FILE} runtime topology (accounting for attacker privilege, single-instance limits, repo visibility, rate limits, and external preconditions; never rate worst-case theoretical severity when environmental controls constrain impact, and never sum multiple `Low` defects into a `Medium`):
           - `Critical`: unauthenticated or low-privilege remote code execution, mass cross-tenant/account breach, or irreversible production data destruction.
           - `High`: authenticated privilege escalation, cross-tenant/account data read/write/takeover, unauthorized live exposure of restricted/embargoed data, permanent user/tenant lockout, or deterministic destructive data loss in normal workflows.
           - `Medium`: scoped isolation/authz bypass with preconditions, realistic single-instance or rate-limited DoS (panic, heap amplification OOM, unauthenticated write amplification, unbounded memory/resource leak), broken primary workflow on supported clients/protocols, runbook sequence causing service outage, or bypassed required CI/release gate.
           - `Low`: localized UX/state/counter defect, single-record partial-failure or retry deadlock, WCAG contrast/accessibility gap, defense-in-depth weakness neutralized upstream, or non-gate test/dev-tooling flaw.
           - `Info`: dead code, stale comment/doc without outage risk, redundant request, unused/no-op styling class, or minor hardening/observability hygiene with no direct user or security impact.
        6. Verify that every proposed remediation direction respects {PERIMETER_FILE} documented invariants and introduces no new DoS, security, or compatibility regression. Write {VERIFIED_FILE} with every cluster's (or split sub-cluster's) verdict, calibrated severity, verified `file:line` citations, verbatim code snippet, reproduction output or falsification proof, preconditions, and invariant-safe remediation direction.
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
        1. Collect all surviving findings (`CONFIRMED_REPRODUCED`, `CONFIRMED_STATIC`, `PLAUSIBLE_EXTERNAL`) and all `REFUTED` items plus `Checked and Sound` notes, reconciling any verifier-split sub-clusters in final counts. Deduplicate any overlapping root defect across batches, verify that `CONFIRMED_REPRODUCED` appears solely where target code/build/script execution occurred (converting static text/manifest checks to `CONFIRMED_STATIC`), and align severities uniformly across all five tiers (`Critical`, `High`, `Medium`, `Low`, `Info`) against {PERIMETER_FILE} without composite inflation.
        2. Write {REPORT_PATH} in the report language recorded in {CHARTER_FILE} (defaulting strictly to English per `<disk>`) containing:
           - Executive summary and audit metadata: mode, Scope Auditor worker type, scopes audited, raw candidates vs post-split atomic clusters vs confirmed/plausible/refuted counts, and empirical sandbox reproductions run.
           - Runtime, invariant, & threat-model context from {PERIMETER_FILE} explaining severity calibration boundaries.
           - Summary matrix of findings by Severity (`Critical`, `High`, `Medium`, `Low`, `Info`) and Epistemic Status (`Confirmed Reproduced`, `Confirmed Static`, `Plausible External`).
           - Atomic findings ordered by severity: unique ID, title, severity, epistemic status, exact `path:startLine-endLine` references, verbatim code evidence, end-to-end mechanism and reproduction or static proof, preconditions/blast radius, and invariant-safe actionable fix guidance (or `No surviving findings.` when 0 survive).
           - Prioritized remediation work packages: group surviving findings that share a cohesive subsystem or root-cause fix into ordered implementation packages, each stating the expected behavior, the invariants to preserve, and the check that proves the fix (`None` when 0 findings survive).
           - Checked & sound / refuted hypotheses trail: concise summary of areas verified sound and candidate hypotheses falsified during verification.
        3. Remove {SANDBOX_DIR} if present (`chmod -R u+w` then `rm -rf`) to reclaim disk space while keeping markdown manifests and verified logs intact.
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
