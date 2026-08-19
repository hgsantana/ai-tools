# update.ps1 case file -- proves the update.ps1 half of README rules 18-20
# and 25 against scripts/powershell/update.ps1. Mirrors tools/test/update.sh
# (canonical, README rule 24): the reset guard refuses to discard local work
# until -DiscardLocal is passed, stale copies are refreshed while locally
# modified copies are kept, newly shipped content is linked, and the clone's
# reset never reaches harness configuration or $HOME\AGENTS.md.
#
# Note on the copy-refresh fixtures (Case-UpdateStaleCopyRefreshed and
# Case-UpdateUpToDateCopy): tools/test/update.sh forces install.sh to install
# everything as a copy via `t_run_no_symlink` (a PATH-shimmed `ln` that
# always fails), because Refresh-Copies (scripts/powershell/lib.ps1) skips
# any destination that is a symlink -- only a genuine copy destination
# exercises it. Windows has no PATH-shimmable equivalent for New-Item
# -ItemType SymbolicLink, and lib.ps1 is frozen for this stage except for
# T-OriginCommit (this file's own dependency, appended below in the same
# stage). Both cases below instead pre-stage the one destination under test
# as a plain Copy-Item copy before running install.ps1 normally: Safe-Link
# then finds that destination already occupied and leaves it exactly as
# staged (a copy, not a link), while every other wrapper still gets a real
# symlink. The net effect on the destination under test is identical to the
# shell fixture's (a plain copy); what differs is that this run never forces
# the *unrelated* instructions symlink to fail the way the shell's
# system-wide `ln` shim incidentally does, so the exit codes asserted below
# were derived by reading scripts/powershell/lib.ps1's control flow rather
# than copied from tools/test/update.sh's numbers. See the stage's
# Implementation log for the full reasoning and the explicit statement that
# none of this was executed locally.
#
# Case-to-case mapping (update.sh -> this file; every case has a
# counterpart, same behaviour under test):
#   case_update_reset_guard_dirty     -> Case-UpdateResetGuardDirty
#   case_update_reset_guard_ahead     -> Case-UpdateResetGuardAhead
#   case_update_discard_local         -> Case-UpdateDiscardLocal
#   case_update_reset_confined        -> Case-UpdateResetConfined
#   case_update_new_content_linked    -> Case-UpdateNewContentLinked
#   case_update_stale_copy_refreshed  -> Case-UpdateStaleCopyRefreshed
#   case_update_modified_copy_kept    -> Case-UpdateModifiedCopyKept
#   case_update_up_to_date_copy       -> Case-UpdateUpToDateCopy
#   case_update_no_reset              -> Case-UpdateNoReset
#   case_update_dry_run               -> Case-UpdateDryRun
#   case_update_missing_clone         -> Case-UpdateMissingClone
#   case_update_fetch_failure         -> Case-UpdateFetchFailure
#   case_update_preconditions         -> Case-UpdatePreconditions

function T-Update([string]$Root) {
  # usage: T-Update <root> [args...] -- runs update.ps1 under test
  $updateArgs = $args
  T-Run $Root (Join-Path $Root 'home\.ai-tools\scripts\powershell\update.ps1') @updateArgs
}

# --- Reset guard (rule 25) ---------------------------------------------------

function Case-UpdateResetGuardDirty {
  $script:T_Case = 'Case-UpdateResetGuardDirty'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $wrapper = Join-Path $homeDir '.ai-tools\README.md'

  Add-Content -LiteralPath $wrapper -Value "`nlocal edit that has never been committed"

  $before = T-Snapshot (Join-Path $homeDir '.claude')

  T-Update $root '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'local changes in'
  T-AssertLine 'the reset would discard the local work above'

  if (Select-String -LiteralPath $wrapper -SimpleMatch -Pattern 'local edit that has never been committed' -Quiet) {
    Ok "$($script:T_Case): local edit still present"
  } else {
    Warn "$($script:T_Case): local edit lost"
  }

  T-AssertUnchanged (Join-Path $homeDir '.claude') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-UpdateResetGuardAhead {
  $script:T_Case = 'Case-UpdateResetGuardAhead'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'

  & git -C $aiTools -c user.name='ai-tools test' -c user.email='test@example.invalid' `
    commit -q --allow-empty -m 'local commit ahead of origin'
  $headBefore = (& git -C $aiTools rev-parse HEAD).Trim()

  T-Update $root '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'local commits ahead of origin/master:'

  $headAfter = (& git -C $aiTools rev-parse HEAD).Trim()
  if ($headAfter -eq $headBefore) { Ok "$($script:T_Case): HEAD unchanged" }
  else { Warn "$($script:T_Case): HEAD moved: $headBefore -> $headAfter" }

  T-Cleanup $root
}

function Case-UpdateDiscardLocal {
  $script:T_Case = 'Case-UpdateDiscardLocal'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $wrapper = Join-Path $aiTools 'README.md'

  Add-Content -LiteralPath $wrapper -Value "`nlocal edit that has never been committed"

  T-Update $root '-Harnesses' 'claude-code' '-DiscardLocal'
  T-AssertExit 0
  T-AssertLine 'ok: source at'

  $originHead = (& git -C $aiTools rev-parse origin/master).Trim()
  $headAfter = (& git -C $aiTools rev-parse HEAD).Trim()
  if ($headAfter -eq $originHead) { Ok "$($script:T_Case): HEAD equals origin/master" }
  else { Warn "$($script:T_Case): HEAD $headAfter != origin/master $originHead" }

  if (Select-String -LiteralPath $wrapper -SimpleMatch -Pattern 'local edit that has never been committed' -Quiet) {
    Warn "$($script:T_Case): local edit still present after discard"
  } else {
    Ok "$($script:T_Case): local edit discarded"
  }

  T-Cleanup $root
}

function Case-UpdateResetConfined {
  $script:T_Case = 'Case-UpdateResetConfined'
  T-Fixture -ForeignAgent
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $agentsMd = Join-Path $homeDir 'AGENTS.md'
  $foreignPath = $script:T_ForeignAgentPath
  $claudeMd = Join-Path $homeDir '.claude\CLAUDE.md'

  Set-Content -LiteralPath $agentsMd -Value 'user content, never touched' -NoNewline
  Set-Content -LiteralPath $claudeMd -Value 'harness config, never touched' -NoNewline

  $beforeAgents = Get-Content -LiteralPath $agentsMd -Raw
  $beforeClaude = Get-Content -LiteralPath $claudeMd -Raw
  $beforeForeign = Get-Content -LiteralPath $foreignPath -Raw

  Add-Content -LiteralPath (Join-Path $aiTools 'README.md') -Value "`nlocal edit"
  & git -C $aiTools -c user.name='ai-tools test' -c user.email='test@example.invalid' add -A
  & git -C $aiTools -c user.name='ai-tools test' -c user.email='test@example.invalid' commit -q -m 'local work'

  T-Update $root '-Harnesses' 'claude-code' '-DiscardLocal'
  # exit 2: Verify-Install warns that the foreign agent file and the
  # pre-filled CLAUDE.md differ from source -- proof they were skipped, not
  # overwritten. The reset itself (rule 25) still succeeded (exit 0 would
  # require the pre-existing foreign content to be gone, which it must not
  # be).
  T-AssertExit 2

  if ((Get-Content -LiteralPath $agentsMd -Raw) -eq $beforeAgents) { Ok "$($script:T_Case): HOME\AGENTS.md untouched" }
  else { Warn "$($script:T_Case): HOME\AGENTS.md changed" }

  if ((Get-Content -LiteralPath $claudeMd -Raw) -eq $beforeClaude) { Ok "$($script:T_Case): harness config untouched" }
  else { Warn "$($script:T_Case): harness config changed" }

  if ((Get-Content -LiteralPath $foreignPath -Raw) -eq $beforeForeign) { Ok "$($script:T_Case): foreign file untouched" }
  else { Warn "$($script:T_Case): foreign file changed" }

  T-Cleanup $root
}

# --- Newly shipped content (rule 18) -----------------------------------------

function Case-UpdateNewContentLinked {
  $script:T_Case = 'Case-UpdateNewContentLinked'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $marker = 'linktest'

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0

  T-OriginCommit $marker

  T-Update $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertSymlink (Join-Path $homeDir ".claude\skills\$marker-ai-tools") (Join-Path $aiTools "skills\$marker-ai-tools")
  T-AssertLine 'already linked:'

  T-Cleanup $root
}

# --- Copy refresh vs. preservation (rules 18-19) -----------------------------

function Case-UpdateStaleCopyRefreshed {
  $script:T_Case = 'Case-UpdateStaleCopyRefreshed'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $marker = 'stalecopy'
  $wrapper = Join-Path $homeDir '.claude\agents\maintainer-ai-tools.md'

  # See file header: pre-stage the destination as a plain copy instead of
  # forcing every destination through a symlink-refusal shim.
  Copy-Item -LiteralPath (Join-Path $aiTools 'agents\claude-code\maintainer-ai-tools.md') -Destination $wrapper

  T-Install $root '-Harnesses' 'claude-code'

  T-OriginCommit $marker

  T-Update $root '-Harnesses' 'claude-code'
  # exit 0: unlike tools/test/update.sh's equivalent case, nothing here
  # forces the instructions symlink to fail, so Verify-Install has nothing
  # left to warn about once the copy is refreshed. See file header.
  T-AssertExit 0
  T-AssertLine 'copy refreshed:'

  if ((Get-FileHash -LiteralPath $wrapper).Hash -eq (Get-FileHash -LiteralPath (Join-Path $aiTools 'agents\claude-code\maintainer-ai-tools.md')).Hash) {
    Ok "$($script:T_Case): copy matches refreshed source"
  } else {
    Warn "$($script:T_Case): copy does not match refreshed source"
  }

  T-Cleanup $root
}

function Case-UpdateModifiedCopyKept {
  $script:T_Case = 'Case-UpdateModifiedCopyKept'
  T-Fixture -ModifiedCopy
  $root = $script:T_Root
  $marker = 'modcopy'
  $wrapper = $script:T_ModifiedCopyPath

  T-Install $root '-Harnesses' 'claude-code'

  T-OriginCommit $marker

  T-Update $root '-Harnesses' 'claude-code'
  # exit 2: the modified copy still differs from the refreshed source after
  # Refresh-Copies skips it, so Verify-Install warns "agent differs from
  # source" -- a real warning, not an artifact of test setup (contrast
  # Case-UpdateStaleCopyRefreshed / Case-UpdateUpToDateCopy above).
  T-AssertExit 2
  T-AssertLine 'SKIP: copy modified locally (or predates'

  if (Select-String -LiteralPath $wrapper -SimpleMatch -Pattern 'local edit that matches no revision' -Quiet) {
    Ok "$($script:T_Case): modified copy preserved"
  } else {
    Warn "$($script:T_Case): modified copy changed"
  }

  T-Cleanup $root
}

function Case-UpdateUpToDateCopy {
  $script:T_Case = 'Case-UpdateUpToDateCopy'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $marker = 'uptodate'
  $wrapper = Join-Path $homeDir '.claude\agents\az-ai-tools.md'

  # Same pre-staged-copy adaptation as Case-UpdateStaleCopyRefreshed.
  Copy-Item -LiteralPath (Join-Path $aiTools 'agents\claude-code\az-ai-tools.md') -Destination $wrapper

  T-Install $root '-Harnesses' 'claude-code'

  # T-OriginCommit only touches maintainer-ai-tools.md; az-ai-tools.md's
  # copy stays equal to its (unchanged) source across the reset.
  T-OriginCommit $marker

  T-Update $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "copy up to date: $wrapper"

  T-Cleanup $root
}

# --- -NoReset / -DryRun -------------------------------------------------------

function Case-UpdateNoReset {
  $script:T_Case = 'Case-UpdateNoReset'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'

  Add-Content -LiteralPath (Join-Path $aiTools 'README.md') -Value "`nlocal edit"
  $beforeHead = (& git -C $aiTools rev-parse HEAD).Trim()

  T-Update $root '-Harnesses' 'claude-code' '-NoReset'

  if ($script:T_LastExit -eq 0 -or $script:T_LastExit -eq 2) {
    Ok "$($script:T_Case): exit $($script:T_LastExit) (0 or 2 acceptable per the run's own findings)"
  } else {
    Warn "$($script:T_Case): unexpected exit $($script:T_LastExit)"
  }
  T-AssertLine 'info: reset skipped (-NoReset)'

  $afterHead = (& git -C $aiTools rev-parse HEAD).Trim()
  if ($afterHead -eq $beforeHead) { Ok "$($script:T_Case): HEAD unchanged" }
  else { Warn "$($script:T_Case): HEAD moved: $beforeHead -> $afterHead" }

  if (Select-String -LiteralPath (Join-Path $aiTools 'README.md') -SimpleMatch -Pattern 'local edit' -Quiet) {
    Ok "$($script:T_Case): local edit intact"
  } else {
    Warn "$($script:T_Case): local edit lost"
  }

  T-Cleanup $root
}

function Case-UpdateDryRun {
  $script:T_Case = 'Case-UpdateDryRun'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'

  T-OriginCommit 'dryrun'
  $headBefore = (& git -C $aiTools rev-parse HEAD).Trim()

  $before = T-Snapshot (Join-Path $homeDir '.claude')

  T-Update $root '-Harnesses' 'claude-code' '-DryRun'
  T-AssertExit 0
  T-AssertLine 'would reset'
  T-AssertLine 'to origin/master'
  T-AssertLine 'dry-run: verification skipped'

  T-AssertUnchanged (Join-Path $homeDir '.claude') $before

  $headAfter = (& git -C $aiTools rev-parse HEAD).Trim()
  if ($headAfter -eq $headBefore) { Ok "$($script:T_Case): HEAD unchanged" }
  else { Warn "$($script:T_Case): HEAD moved: $headBefore -> $headAfter" }

  T-Cleanup $root
}

# --- Preconditions -------------------------------------------------------------

function Case-UpdateMissingClone {
  $script:T_Case = 'Case-UpdateMissingClone'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  Remove-Item -LiteralPath (Join-Path $homeDir '.ai-tools') -Recurse -Force

  # home\.ai-tools no longer exists to execute; run the real repo's script
  # binary instead -- T-Run still confines HOME/AI_TOOLS to the sandbox, and
  # Require-Clone reads the sandboxed AI_TOOLS env var, which is what
  # matters here.
  T-Run $root (Join-Path $script:AI_TOOLS 'scripts\powershell\update.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'is missing or not a clone'

  $item = Get-Item -LiteralPath (Join-Path $homeDir '.ai-tools') -Force -ErrorAction SilentlyContinue
  if ($item) { Warn "$($script:T_Case): unexpectedly created: $(Join-Path $homeDir '.ai-tools')" }
  else { Ok "$($script:T_Case): nothing created: $(Join-Path $homeDir '.ai-tools')" }

  T-Cleanup $root
}

function Case-UpdateFetchFailure {
  $script:T_Case = 'Case-UpdateFetchFailure'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'

  & git -C $aiTools remote set-url origin (Join-Path $root 'does-not-exist.git')

  $start = Get-Date
  T-Update $root '-Harnesses' 'claude-code'
  $elapsed = ((Get-Date) - $start).TotalSeconds

  T-AssertExit 1
  T-AssertLine 'fetch failed'

  if ($elapsed -lt 15) { Ok "$($script:T_Case): returned promptly (${elapsed}s) — no network was attempted" }
  else { Warn "$($script:T_Case): took ${elapsed}s — possible network attempt or hang" }

  T-Cleanup $root
}

function Case-UpdatePreconditions {
  $script:T_Case = 'Case-UpdatePreconditions'
  T-Fixture
  $root = $script:T_Root

  T-Update $root '-Harnesses' 'bogus'
  T-AssertExit 1
  T-AssertLine 'unknown harness: bogus'

  T-Update $root '-Harnesses'
  T-AssertExit 1

  T-Update $root '-Bogus'
  T-AssertExit 1

  T-Cleanup $root
}
