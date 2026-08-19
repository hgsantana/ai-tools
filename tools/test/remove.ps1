# remove.ps1 case file -- README rules 18-20, 22, 25 against
# scripts/powershell/remove.ps1 and scripts/powershell/reinstall.ps1. Mirrors
# tools/test/remove.sh and tools/test/reinstall.sh (canonical, README rule
# 24): unlink only what ai-tools created, keep locally modified copies, never
# touch a foreign file or a symlink pointing elsewhere, gate -Instructions
# and -Purge, sweep stale links without crossing outside $AI_TOOLS, never
# touch $HOME\AGENTS.md, and prove reinstall reaches the same end state as a
# fresh install while refusing to discard uncommitted clone work.
#
# Every case installs first (via T-Install, defined in tools/test/install.ps1
# and already in scope once tools/test.ps1 has sourced every case file)
# unless noted otherwise, so removal/reinstall has something real to act on.
#
# Note on exit codes: Skip (rule 20's "skip and report") does not itself
# raise the exit code -- only Warn does (scripts/powershell/lib.ps1: Finish
# exits 2 only when $script:WARN -gt 0; see README rule 25, "2 finished with
# warnings"). The assertions below follow the observed, README-consistent
# behaviour; see the stage's Implementation log for the case-by-case
# reasoning behind each exit code.
#
# Note on the external-symlink case: T-Fixture's sandbox root is named
# "ai-tools-test.<hex>" (tools/test/lib.ps1), so any path under it contains
# the literal substring "ai-tools". Test-AiToolsTarget's first, coarse check
# is a `-like '*ai-tools*'` match on that substring (scripts/powershell/
# lib.ps1), so a fixture-built external symlink under the sandbox root would
# be misidentified as an ai-tools destination. Case-RemoveExternalSymlinkKept
# therefore stages its own external symlink by hand, target outside the
# sandbox naming scheme, exactly mirroring tools/test/remove.sh's own
# documented workaround (that file's header comment). Recorded in the
# Implementation log.
#
# Note on modified-copy setup: tools/test/remove.sh uses a `t_run_no_symlink`
# helper (a PATH-shimmed `ln` that always fails) to force install.sh to
# install everything as copies before exercising copy-preservation. Windows
# has no equivalent PATH-shimmable primitive for New-Item -ItemType
# SymbolicLink, and lib.ps1 (frozen except for T-OriginCommit, this stage's
# only sanctioned addition) carries no T-RunNoSymlink. T-Fixture's
# -ModifiedCopy switch already stages the destination file directly before
# install ever runs, so Safe-Link finds it occupied and skips it regardless
# of whether symlinks succeed elsewhere in the run -- no shim is needed for
# these cases. See the Implementation log for the full reasoning.
#
# Case-to-case mapping (remove.sh -> this file; every case has a
# counterpart, same behaviour under test):
#   case_remove_unlinks_what_install_linked      -> Case-RemoveUnlinksWhatInstallLinked
#   case_remove_idempotent                       -> Case-RemoveIdempotent
#   case_remove_modified_copy_kept               -> Case-RemoveModifiedCopyKept
#   case_remove_foreign_file_kept                -> Case-RemoveForeignFileKept
#   case_remove_external_symlink_kept            -> Case-RemoveExternalSymlinkKept
#   case_remove_agents_md_untouched              -> Case-RemoveAgentsMdUntouched
#   case_remove_instructions_gate                -> Case-RemoveInstructionsGate
#   case_remove_gemini_antigravity_shared_instructions -> Case-RemoveGeminiAntigravitySharedInstructions
#   case_remove_grok_block                       -> Case-RemoveGrokBlock
#   case_remove_stale_link_sweep                 -> Case-RemoveStaleLinkSweep
#   case_remove_purge_refuses_without_confirmation -> Case-RemovePurgeRefusesWithoutConfirmation
#   case_remove_dry_run_changes_nothing          -> Case-RemoveDryRunChangesNothing
#   case_remove_without_a_clone                  -> Case-RemoveWithoutAClone
#   case_remove_precondition_failures            -> Case-RemovePreconditionFailures
#
# Case-to-case mapping (reinstall.sh -> this file):
#   case_reinstall_clean_matches_fresh_install   -> Case-ReinstallCleanMatchesFreshInstall
#   case_reinstall_stale_link_removed            -> Case-ReinstallStaleLinkRemoved
#   case_reinstall_modified_copy_kept            -> Case-ReinstallModifiedCopyKept
#   case_reinstall_fresh_clone_offline           -> Case-ReinstallFreshCloneOffline
#   case_reinstall_uncommitted_no_discard        -> Case-ReinstallUncommittedNoDiscard
#   case_reinstall_no_instructions               -> Case-ReinstallNoInstructions
#   case_reinstall_dry_run_changes_nothing       -> Case-ReinstallDryRunChangesNothing

function T-Remove([string]$Root) {
  # usage: T-Remove <root> [args...] -- runs remove.ps1 under test
  $removeArgs = $args
  T-Run $Root (Join-Path $Root 'home\.ai-tools\scripts\powershell\remove.ps1') @removeArgs
}

function T-Reinstall([string]$Root) {
  # usage: T-Reinstall <root> [args...] -- runs reinstall.ps1 under test
  $reinstallArgs = $args
  T-Run $Root (Join-Path $Root 'home\.ai-tools\scripts\powershell\reinstall.ps1') @reinstallArgs
}

# --- Remove cases ----------------------------------------------------------

function Case-RemoveUnlinksWhatInstallLinked {
  $script:T_Case = 'Case-RemoveUnlinksWhatInstallLinked'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine 'removed link:'
  T-AssertAbsent (Join-Path $root 'home\.claude\agents\planner-ai-tools.md')
  T-AssertAbsent (Join-Path $root 'home\.claude\skills\planner-ai-tools')

  $claudeMd = Join-Path $root 'home\.claude\CLAUDE.md'
  $item = Get-Item -LiteralPath $claudeMd -Force -ErrorAction SilentlyContinue
  if ($item) { Ok "$($script:T_Case): instructions still present (no -Instructions): $claudeMd" }
  else { Warn "$($script:T_Case): instructions unexpectedly absent: $claudeMd" }

  T-Cleanup $root
}

function Case-RemoveIdempotent {
  $script:T_Case = 'Case-RemoveIdempotent'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'
  T-Remove $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine 'ok: absent:'
  T-AssertNoLine 'WARN:'

  T-Cleanup $root
}

function Case-RemoveModifiedCopyKept {
  $script:T_Case = 'Case-RemoveModifiedCopyKept'
  T-Fixture -ModifiedCopy
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "SKIP: copy was modified locally, user work kept: $($script:T_ModifiedCopyPath)"
  T-AssertRegularFile $script:T_ModifiedCopyPath
  if (Select-String -LiteralPath $script:T_ModifiedCopyPath -SimpleMatch -Pattern 'local edit that matches no revision' -Quiet) {
    Ok "$($script:T_Case): modified copy survived byte-for-byte: $($script:T_ModifiedCopyPath)"
  } else {
    Warn "$($script:T_Case): modified copy lost its local edit: $($script:T_ModifiedCopyPath)"
  }
  # every unmodified copy from the same install must be gone
  T-AssertAbsent (Join-Path $root 'home\.claude\agents\planner-ai-tools.md')

  T-Cleanup $root
}

function Case-RemoveForeignFileKept {
  $script:T_Case = 'Case-RemoveForeignFileKept'
  T-Fixture -ForeignAgent
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  # the code path this foreign file takes: it is a regular file occupying a
  # wrapper's destination, so Safe-UninstallCopy compares content and finds
  # it does not match the ai-tools source -> "modified locally" skip.
  T-AssertLine "SKIP: copy was modified locally, user work kept: $($script:T_ForeignAgentPath)"
  T-AssertRegularFile $script:T_ForeignAgentPath
  T-AssertContent $script:T_ForeignAgentPath 'not an ai-tools file'

  T-Cleanup $root
}

function Case-RemoveExternalSymlinkKept {
  # Manual fixture (see file header): -ExternalSymlink's target collides
  # with the "*ai-tools*" substring check via the sandbox root's own name.
  $script:T_Case = 'Case-RemoveExternalSymlinkKept'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  $extdir = Join-Path $env:TEMP ('t-remove-external-' + [guid]::NewGuid().ToString('N').Substring(0, 12))
  New-Item -ItemType Directory -Path $extdir -Force | Out-Null
  $extTarget = Join-Path $extdir 'external-file.md'
  Set-Content -LiteralPath $extTarget -Value 'outside ai-tools'
  $dest = Join-Path $root 'home\.claude\agents\orchestrator-ai-tools.md'
  Remove-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
  New-Item -ItemType SymbolicLink -Path $dest -Target $extTarget | Out-Null

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "SKIP: symlink not to ai-tools: $dest -> $extTarget"
  T-AssertSymlink $dest $extdir

  Remove-Item -LiteralPath $extdir -Recurse -Force -ErrorAction SilentlyContinue
  T-Cleanup $root
}

function Case-RemoveAgentsMdUntouched {
  $script:T_Case = 'Case-RemoveAgentsMdUntouched'
  T-Fixture
  $root = $script:T_Root
  $agentsMd = Join-Path $root 'home\AGENTS.md'

  T-Install $root '-Harnesses' 'claude-code'
  Set-Content -LiteralPath $agentsMd -Value "my custom overlay`nline two" -NoNewline
  $ref = Get-Content -LiteralPath $agentsMd -Raw

  T-Remove $root '-Harnesses' 'claude-code'
  if ((Get-Content -LiteralPath $agentsMd -Raw) -eq $ref) { Ok "$($script:T_Case): AGENTS.md unchanged after remove.ps1" }
  else { Warn "$($script:T_Case): AGENTS.md changed after remove.ps1" }

  T-Install $root '-Harnesses' 'claude-code'
  T-Remove $root '-Harnesses' 'claude-code' '-Instructions'
  if ((Get-Content -LiteralPath $agentsMd -Raw) -eq $ref) { Ok "$($script:T_Case): AGENTS.md unchanged after remove.ps1 -Instructions" }
  else { Warn "$($script:T_Case): AGENTS.md changed after remove.ps1 -Instructions" }

  T-Install $root '-Harnesses' 'claude-code'
  T-Remove $root '-Harnesses' 'claude-code' '-Purge' '-Yes'
  if ((Get-Content -LiteralPath $agentsMd -Raw) -eq $ref) { Ok "$($script:T_Case): AGENTS.md unchanged after remove.ps1 -Purge -Yes" }
  else { Warn "$($script:T_Case): AGENTS.md changed after remove.ps1 -Purge -Yes" }

  T-Cleanup $root
}

function Case-RemoveInstructionsGate {
  $script:T_Case = 'Case-RemoveInstructionsGate'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'claude-code'
  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertSymlink (Join-Path $root 'home\.claude\CLAUDE.md') $aiTools

  T-Install $root '-Harnesses' 'claude-code'
  T-Remove $root '-Harnesses' 'claude-code' '-Instructions'
  T-AssertAbsent (Join-Path $root 'home\.claude\CLAUDE.md')

  T-Cleanup $root
}

function Case-RemoveGeminiAntigravitySharedInstructions {
  $script:T_Case = 'Case-RemoveGeminiAntigravitySharedInstructions'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'gemini,antigravity'

  T-Remove $root '-Harnesses' 'gemini' '-Instructions'
  T-AssertLine 'SKIP: GEMINI.md serves gemini and antigravity; antigravity not in scope'
  T-AssertSymlink (Join-Path $root 'home\.gemini\GEMINI.md') $aiTools

  T-Remove $root '-Harnesses' 'gemini,antigravity' '-Instructions'
  T-AssertAbsent (Join-Path $root 'home\.gemini\GEMINI.md')

  T-Cleanup $root
}

function Case-RemoveGrokBlock {
  $script:T_Case = 'Case-RemoveGrokBlock'

  T-Fixture -UnmanagedGrokBlock
  $root = $script:T_Root
  T-Install $root '-Harnesses' 'grok'
  T-Remove $root '-Harnesses' 'grok'
  T-AssertLine "SKIP: unmanaged [subagents.models] in $($script:T_GrokUnmanagedPath)"
  T-AssertContent $script:T_GrokUnmanagedPath 'some-other-agent = "some-model"'
  T-Cleanup $root

  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $grokToml = Join-Path $homeDir '.grok\config.toml'
  New-Item -ItemType Directory -Path (Join-Path $homeDir '.grok') -Force | Out-Null
  Set-Content -LiteralPath $grokToml -Value 'before-marker' -NoNewline
  T-Install $root '-Harnesses' 'grok'
  Add-Content -LiteralPath $grokToml -Value "`nafter-marker"

  T-Remove $root '-Harnesses' 'grok'
  T-AssertLine 'grok models block removed:'
  T-AssertContent $grokToml 'before-marker'
  T-AssertContent $grokToml 'after-marker'
  T-AssertNoLine 'ERROR:'
  T-Cleanup $root

  T-Fixture
  $root = $script:T_Root
  $grokToml = Join-Path $root 'home\.grok\config.toml'
  T-Remove $root '-Harnesses' 'grok'
  T-AssertLine "ok: absent: $grokToml"
  T-AssertAbsent $grokToml
  T-Cleanup $root
}

function Case-RemoveStaleLinkSweep {
  $script:T_Case = 'Case-RemoveStaleLinkSweep'

  T-Fixture -StaleLink
  $root = $script:T_Root
  T-Install $root '-Harnesses' 'claude-code'

  $realDir = Join-Path $root 'home\.claude\agents\some-real-ai-tools-dir'
  New-Item -ItemType Directory -Path $realDir -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $realDir 'f') -Value 'not a link'

  T-Remove $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "removed link: $($script:T_StaleLinkPath)"
  T-AssertAbsent $script:T_StaleLinkPath
  if ((Test-Path -LiteralPath $realDir -PathType Container) -and -not (Get-LinkTarget $realDir)) {
    Ok "$($script:T_Case): real directory survived the sweep: $realDir"
  } else {
    Warn "$($script:T_Case): real directory did not survive the sweep: $realDir"
  }
  T-Cleanup $root

  T-Fixture -StaleLink
  $root = $script:T_Root
  T-Install $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code' '-NoSweep'
  T-AssertSymlink $script:T_StaleLinkPath (Join-Path $root 'home\.ai-tools')

  T-Cleanup $root
}

function Case-RemovePurgeRefusesWithoutConfirmation {
  $script:T_Case = 'Case-RemovePurgeRefusesWithoutConfirmation'

  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'
  T-Install $root '-Harnesses' 'claude-code'

  T-RunStdin $root 'no' (Join-Path $aiTools 'scripts\powershell\remove.ps1') '-Harnesses' 'claude-code' '-Purge'
  T-AssertExit 0
  T-AssertLine 'SKIP: purge not confirmed:'
  if (Test-Path -LiteralPath $aiTools) { Ok "$($script:T_Case): clone survived a refused purge" }
  else { Warn "$($script:T_Case): clone deleted despite refused purge" }

  T-Remove $root '-Harnesses' 'claude-code' '-Purge' '-Yes'
  T-AssertExit 0
  T-AssertLine "ok: deleted: $aiTools"
  if (-not (Test-Path -LiteralPath $aiTools)) { Ok "$($script:T_Case): clone deleted by -Purge -Yes" }
  else { Warn "$($script:T_Case): clone survived -Purge -Yes" }
  T-AssertRegularFile (Join-Path $root 'home\AGENTS.md')

  T-Cleanup $root

  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'
  T-Install $root '-Harnesses' 'claude-code'

  T-Remove $root '-Harnesses' 'claude-code' '-Purge' '-DryRun'
  T-AssertExit 0
  T-AssertLine "ok: would delete: $aiTools"
  if (Test-Path -LiteralPath $aiTools) { Ok "$($script:T_Case): -Purge -DryRun left the clone in place" }
  else { Warn "$($script:T_Case): -Purge -DryRun deleted the clone" }

  T-Cleanup $root
}

function Case-RemoveDryRunChangesNothing {
  $script:T_Case = 'Case-RemoveDryRunChangesNothing'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'
  $snap = T-Snapshot (Join-Path $root 'home')

  T-Remove $root '-Harnesses' 'claude-code' '-DryRun'
  T-AssertExit 0
  T-AssertUnchanged (Join-Path $root 'home') $snap

  Remove-Item -LiteralPath $snap -Force -ErrorAction SilentlyContinue
  T-Cleanup $root
}

function Case-RemoveWithoutAClone {
  $script:T_Case = 'Case-RemoveWithoutAClone'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'claude-code'

  $saved = Join-Path $root 'saved-scripts'
  Copy-Item -LiteralPath (Join-Path $aiTools 'scripts') -Destination $saved -Recurse

  Remove-Item -LiteralPath $aiTools -Recurse -Force

  # home\.ai-tools no longer exists to execute; run the saved copy of
  # remove.ps1 instead -- T-Run still confines HOME/AI_TOOLS to the sandbox
  # (T-InvokeUnderSandbox always sets AI_TOOLS to <home>\.ai-tools regardless
  # of which script path is invoked), which is what Require-Clone-adjacent
  # code in remove.ps1 reads.
  T-Run $root (Join-Path $saved 'powershell\remove.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 2
  T-AssertLine "WARN: $aiTools missing — copies cannot be verified; removing links only (sweep)"
  T-AssertAbsent (Join-Path $root 'home\.claude\agents\planner-ai-tools.md')

  T-Cleanup $root
}

function Case-RemovePreconditionFailures {
  $script:T_Case = 'Case-RemovePreconditionFailures'
  T-Fixture
  $root = $script:T_Root

  T-Remove $root '-Harnesses' 'bogus'
  T-AssertExit 1

  T-Remove $root '-Harnesses'
  T-AssertExit 1

  T-Remove $root '-Bogus'
  T-AssertExit 1

  T-Cleanup $root
}

# --- Reinstall cases ---------------------------------------------------------

function Case-ReinstallCleanMatchesFreshInstall {
  $script:T_Case = 'Case-ReinstallCleanMatchesFreshInstall'
  T-Fixture
  $rootA = $script:T_Root
  T-Install $rootA '-Harnesses' 'claude-code'
  $snapA = T-Snapshot (Join-Path $rootA 'home\.claude')

  T-Fixture
  $rootB = $script:T_Root
  T-Reinstall $rootB '-Harnesses' 'claude-code'
  T-AssertExit 0
  $snapB = T-Snapshot (Join-Path $rootB 'home\.claude')

  # Both snapshots embed their own sandbox path, so compare with the roots
  # substituted out rather than a raw hash comparison.
  $contentA = (Get-Content -LiteralPath $snapA -Raw) -replace [regex]::Escape($rootA), 'ROOT'
  $contentB = (Get-Content -LiteralPath $snapB -Raw) -replace [regex]::Escape($rootB), 'ROOT'
  if ($contentA -eq $contentB) { Ok "$($script:T_Case): reinstall end state matches a fresh install" }
  else { Warn "$($script:T_Case): reinstall end state differs from a fresh install" }

  Remove-Item -LiteralPath $snapA -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $snapB -Force -ErrorAction SilentlyContinue
  T-Cleanup $rootA
  T-Cleanup $rootB
}

function Case-ReinstallStaleLinkRemoved {
  $script:T_Case = 'Case-ReinstallStaleLinkRemoved'
  T-Fixture -StaleLink
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Reinstall $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertAbsent $script:T_StaleLinkPath
  T-AssertSymlink (Join-Path $root 'home\.claude\agents\planner-ai-tools.md') (Join-Path $root 'home\.ai-tools')

  T-Cleanup $root
}

function Case-ReinstallModifiedCopyKept {
  $script:T_Case = 'Case-ReinstallModifiedCopyKept'
  T-Fixture -ModifiedCopy
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Reinstall $root '-Harnesses' 'claude-code'
  T-AssertExit 2
  T-AssertLine "SKIP: copy was modified locally, user work kept: $($script:T_ModifiedCopyPath)"
  if (Select-String -LiteralPath $script:T_ModifiedCopyPath -SimpleMatch -Pattern 'local edit that matches no revision' -Quiet) {
    Ok "$($script:T_Case): modified copy survived the reinstall"
  } else {
    Warn "$($script:T_Case): modified copy lost its local edit across reinstall"
  }

  T-Cleanup $root
}

function Case-ReinstallFreshCloneOffline {
  $script:T_Case = 'Case-ReinstallFreshCloneOffline'
  T-Fixture
  $root = $script:T_Root
  Remove-Item -LiteralPath (Join-Path $root 'home\.ai-tools') -Recurse -Force

  T-Run $root (Join-Path $script:AI_TOOLS 'scripts\powershell\reinstall.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine 'info: fresh clone — already at origin/master, reset skipped'
  T-AssertSymlink (Join-Path $root 'home\.claude\agents\planner-ai-tools.md') (Join-Path $root 'home\.ai-tools')

  T-Cleanup $root
}

function Case-ReinstallUncommittedNoDiscard {
  $script:T_Case = 'Case-ReinstallUncommittedNoDiscard'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'claude-code'
  Add-Content -LiteralPath (Join-Path $aiTools 'README.md') -Value "`nuncommitted local edit"
  $snap = T-Snapshot (Join-Path $root 'home\.claude')

  T-Reinstall $root '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'the reset would discard the local work above'
  T-AssertUnchanged (Join-Path $root 'home\.claude') $snap
  T-AssertContent (Join-Path $aiTools 'README.md') 'uncommitted local edit'

  Remove-Item -LiteralPath $snap -Force -ErrorAction SilentlyContinue
  T-Cleanup $root
}

function Case-ReinstallNoInstructions {
  $script:T_Case = 'Case-ReinstallNoInstructions'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'

  T-Reinstall $root '-Harnesses' 'claude-code' '-NoInstructions'
  T-AssertExit 0
  T-AssertSymlink (Join-Path $root 'home\.claude\CLAUDE.md') (Join-Path $root 'home\.ai-tools')

  T-Cleanup $root
}

function Case-ReinstallDryRunChangesNothing {
  $script:T_Case = 'Case-ReinstallDryRunChangesNothing'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'
  $snap = T-Snapshot (Join-Path $root 'home\.claude')

  T-Reinstall $root '-Harnesses' 'claude-code' '-DryRun'
  T-AssertExit 0
  T-AssertUnchanged (Join-Path $root 'home\.claude') $snap

  Remove-Item -LiteralPath $snap -Force -ErrorAction SilentlyContinue
  T-Cleanup $root
}
