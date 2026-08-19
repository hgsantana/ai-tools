# install.ps1 case file — README rules 17-22, 25 against
# scripts/powershell/install.ps1 and scripts/powershell/verify.ps1. Mirrors
# tools/test/install.sh and tools/test/verify.sh (canonical, README rule
# 24); each case builds its own fixture via T-Fixture and passes an explicit
# -Harnesses list so assertions can name exact destination paths.
#
# Case-to-case mapping (shell name -> this file, same case, PowerShell
# naming): see the stage's Implementation log for the full table.

function T-Install([string]$Root) {
  # usage: T-Install <root> [args...] -- runs install.ps1 under test
  $installArgs = $args
  T-Run $Root (Join-Path $Root 'home\.ai-tools\scripts\powershell\install.ps1') @installArgs
}

function T-Verify([string]$Root) {
  # usage: T-Verify <root> [args...] -- runs verify.ps1 under test
  $verifyArgs = $args
  T-Run $Root (Join-Path $Root 'home\.ai-tools\scripts\powershell\verify.ps1') @verifyArgs
}

function Case-InstallFresh {
  # Rule 17: fresh install links every wrapper, skill and the instructions.
  $script:T_Case = 'Case-InstallFresh'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0

  foreach ($f in Get-ChildItem -LiteralPath (Join-Path $aiTools 'agents\claude-code') -File -Filter '*-ai-tools*') {
    T-AssertSymlink (Join-Path $root "home\.claude\agents\$($f.Name)") $aiTools
  }
  foreach ($d in Get-ChildItem -LiteralPath (Join-Path $aiTools 'skills') -Directory -Filter '*-ai-tools') {
    T-AssertSymlink (Join-Path $root "home\.claude\skills\$($d.Name)") $aiTools
  }
  T-AssertSymlink (Join-Path $root 'home\.claude\CLAUDE.md') $aiTools
  T-AssertLine 'linked:'
  T-AssertNoLine 'WARN:'

  T-Cleanup $root
}

function Case-InstallIdempotent {
  # Rule 20: running install.ps1 twice changes nothing on the second run.
  $script:T_Case = 'Case-InstallIdempotent'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0

  $before = T-Snapshot (Join-Path $root 'home\.claude')
  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine 'already linked:'
  T-AssertNoLine 'SKIP:'
  T-AssertNoLine 'WARN:'
  T-AssertUnchanged (Join-Path $root 'home\.claude') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-InstallForeignFileSkipped {
  # Rules 18, 20, 25: a foreign regular file on a destination is skipped,
  # not overwritten, and the run still finishes the rest of the wrappers.
  $script:T_Case = 'Case-InstallForeignFileSkipped'
  T-Fixture -ForeignAgent
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 2
  T-AssertLine "SKIP: exists, not overwriting: $($script:T_ForeignAgentPath)"
  T-AssertRegularFile $script:T_ForeignAgentPath
  T-AssertContent $script:T_ForeignAgentPath 'not an ai-tools file'
  T-AssertSymlink (Join-Path $root 'home\.claude\agents\az-ai-tools.md') (Join-Path $root 'home\.ai-tools')

  T-Cleanup $root
}

function Case-InstallSymlinkElsewhereSkipped {
  # A symlink pointing outside ai-tools is skipped, not replaced.
  $script:T_Case = 'Case-InstallSymlinkElsewhereSkipped'
  T-Fixture -ExternalSymlink
  $root = $script:T_Root
  $beforeTarget = Get-LinkTarget $script:T_ExternalSymlinkPath

  # Verify-Install's link check only tests whether the destination resolves
  # a link at all (Get-LinkTarget truthy), never where it points — see
  # scripts/powershell/lib.ps1's Verify-Install: `if (Get-LinkTarget $dest)
  # { Ok "agent link: $dest" }` with no target check. A stray symlink is
  # Skip-ped by Install-Agents but never Warn-ed by the trailing verify
  # pass, so the run exits 0, not 2 — same divergence tools/test/install.sh
  # documents for the shell side.
  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "SKIP: symlink points elsewhere: $($script:T_ExternalSymlinkPath)"
  $afterTarget = Get-LinkTarget $script:T_ExternalSymlinkPath
  if ($afterTarget -eq $beforeTarget) { Ok "$($script:T_Case): symlink target unchanged: $($script:T_ExternalSymlinkPath)" }
  else { Warn "$($script:T_Case): symlink target changed: $($script:T_ExternalSymlinkPath)" }

  T-Cleanup $root
}

function Case-InstallAgentsMdAbsent {
  # Rule 22: $HOME\AGENTS.md is created empty when absent.
  $script:T_Case = 'Case-InstallAgentsMdAbsent'
  T-Fixture
  $root = $script:T_Root
  $agentsMd = Join-Path $root 'home\AGENTS.md'

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "ok: created empty: $agentsMd"
  T-AssertRegularFile $agentsMd
  if ((Get-Item -LiteralPath $agentsMd).Length -eq 0) { Ok "$($script:T_Case): AGENTS.md is empty: $agentsMd" }
  else { Warn "$($script:T_Case): AGENTS.md is not empty: $agentsMd" }

  T-Cleanup $root
}

function Case-InstallAgentsMdPresent {
  # Rule 22: $HOME\AGENTS.md is user-owned and never touched when present.
  $script:T_Case = 'Case-InstallAgentsMdPresent'
  T-Fixture
  $root = $script:T_Root
  $agentsMd = Join-Path $root 'home\AGENTS.md'
  Set-Content -LiteralPath $agentsMd -Value 'user overrides' -NoNewline

  T-Install $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertLine "ok: already present, untouched: $agentsMd"
  T-AssertContent $agentsMd 'user overrides'
  if (Get-LinkTarget $agentsMd) { Warn "$($script:T_Case): AGENTS.md became a symlink: $agentsMd" }
  else { Ok "$($script:T_Case): AGENTS.md is not a symlink: $agentsMd" }

  T-Cleanup $root
}

function Case-InstallDryRun {
  # Rule 25: -DryRun reports without changing anything.
  $script:T_Case = 'Case-InstallDryRun'
  T-Fixture
  $root = $script:T_Root

  $before = T-Snapshot (Join-Path $root 'home')
  T-Install $root '-Harnesses' 'claude-code' '-DryRun'
  T-AssertExit 0
  T-AssertLine 'would link:'
  T-AssertLine '(dry-run: nothing was changed)'
  T-AssertLine 'info: dry-run: verification skipped'
  T-AssertUnchanged (Join-Path $root 'home') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-InstallNoSymlinkFallback {
  # Rule 17: symlink-to-copy fallback when the OS/filesystem refuses
  # symlinks. Unit-level, not end-to-end (see plan step 8): hosted Windows
  # runners usually CAN create symlinks (elevated/Developer Mode), so
  # instead of relying on a genuine OS refusal, this shadows New-Item in the
  # current scope so any -ItemType SymbolicLink call throws — forcing
  # Safe-Link to return 2 and LinkOrCopy to fall back to Copy-Item exactly
  # as it would on a real refusal. This differs from the shell side's `ln`
  # shim (which forces a real subprocess failure) because there is no
  # cheap, portable way to force New-Item's SymbolicLink creation to fail
  # from outside the process on Windows; shadowing the cmdlet reaches the
  # same code path (Safe-Link's catch block) directly.
  $script:T_Case = 'Case-InstallNoSymlinkFallback'
  T-Fixture
  $root = $script:T_Root
  $homeDir = Join-Path $root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  $target = Join-Path $aiTools 'agents\claude-code\az-ai-tools.md'
  $dest = Join-Path $homeDir '.claude\agents\az-ai-tools.md'

  function New-Item {
    param([Parameter(ValueFromRemainingArguments = $true)][object[]]$RestArgs)
    for ($i = 0; $i -lt $RestArgs.Count; $i++) {
      if ("$($RestArgs[$i])" -eq '-ItemType' -and $i + 1 -lt $RestArgs.Count -and "$($RestArgs[$i + 1])" -eq 'SymbolicLink') {
        throw 'symlink refused (test shim)'
      }
    }
    Microsoft.PowerShell.Management\New-Item @RestArgs
  }

  try {
    $outputs = @(LinkOrCopy $target $dest)
    $rc = $outputs[-1]
    $lastMsgIndex = $outputs.Count - 2
    $text = if ($lastMsgIndex -ge 0) { ($outputs[0..$lastMsgIndex] -join "`n") } else { '' }

    if ($rc -eq 0) { Ok "$($script:T_Case): LinkOrCopy returned 0 (copy fallback)" }
    else { Warn "$($script:T_Case): LinkOrCopy returned $rc, expected 0" }
    if ($text -like '*copied (will not track updates):*') { Ok "$($script:T_Case): output contains: copied (will not track updates):" }
    else { Warn "$($script:T_Case): output missing: copied (will not track updates):" }
    T-AssertRegularFile $dest

    # Second half of step 8: Install-Instructions must warn, not copy, when
    # Safe-Link returns 2 (the single instructions destination stays a
    # single source of truth — it is never copied).
    $savedHome = $HOME
    $savedAiTools = $script:AI_TOOLS
    $savedScope = $script:Scope
    try {
      $HOME = $homeDir
      $script:AI_TOOLS = $aiTools
      $script:Scope = @('claude-code')
      $outputs2 = @(Install-Instructions)
      $text2 = ($outputs2 -join "`n")
      if ($text2 -like '*symlink refused for*') { Ok "$($script:T_Case): Install-Instructions warns on refused symlink" }
      else { Warn "$($script:T_Case): Install-Instructions did not warn on refused symlink" }
      T-AssertAbsent (Join-Path $homeDir '.claude\CLAUDE.md')
    } finally {
      $HOME = $savedHome
      $script:AI_TOOLS = $savedAiTools
      $script:Scope = $savedScope
    }
  } finally {
    Remove-Item Function:\New-Item -ErrorAction SilentlyContinue
    T-Cleanup $root
  }
}

function Case-InstallGrokModels {
  # Grok model pinning: names from the tree, models from the fixture's own
  # MODELS.md, resolved through the shipped Get-ModelFor (never a
  # hard-coded vendor name here).
  $script:T_Case = 'Case-InstallGrokModels'
  T-Fixture
  $root = $script:T_Root

  $savedMap = $script:MODELS_MAP
  $script:MODELS_MAP = Join-Path $root 'home\.ai-tools\MODELS.md'
  $plannerModel = Get-ModelFor 'grok' 'planner'
  $implementerModel = Get-ModelFor 'grok' 'implementer'
  $script:MODELS_MAP = $savedMap

  if (-not $plannerModel -or -not $implementerModel) {
    Warn "$($script:T_Case): could not resolve grok models from fixture MODELS.md"
    T-Cleanup $root
    return
  }

  T-Install $root '-Harnesses' 'grok'
  T-AssertExit 0
  $grokToml = Join-Path $root 'home\.grok\config.toml'
  T-AssertLine "ok: grok models block appended: $grokToml"
  T-AssertContent $grokToml "az-ai-tools = `"$plannerModel`""
  T-AssertContent $grokToml "maintainer-ai-tools = `"$implementerModel`""

  T-Install $root '-Harnesses' 'grok'
  T-AssertExit 0
  T-AssertLine "ok: grok models block up to date: $grokToml"

  T-Cleanup $root
}

function Case-InstallGrokUnmanagedBlock {
  # An unmanaged [subagents.models] block is left untouched, not merged into.
  $script:T_Case = 'Case-InstallGrokUnmanagedBlock'
  T-Fixture -UnmanagedGrokBlock
  $root = $script:T_Root
  $before = T-Snapshot $script:T_GrokUnmanagedPath

  T-Install $root '-Harnesses' 'grok'
  T-AssertExit 0
  T-AssertLine "SKIP: unmanaged [subagents.models] already in $($script:T_GrokUnmanagedPath)"
  T-AssertUnchanged $script:T_GrokUnmanagedPath $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-InstallGrokNoModelRow {
  # No usable `grok` row in MODELS.md: pinning is skipped, config untouched.
  $script:T_Case = 'Case-InstallGrokNoModelRow'
  T-Fixture
  $root = $script:T_Root
  $modelsMd = Join-Path $root 'home\.ai-tools\MODELS.md'
  $content = @(Get-Content -LiteralPath $modelsMd | Where-Object { $_ -notmatch '^\|\s*`grok`' })
  Set-Content -LiteralPath $modelsMd -Value $content

  $grokToml = Join-Path $root 'home\.grok\config.toml'
  $before = T-Snapshot $grokToml
  T-Install $root '-Harnesses' 'grok'
  T-AssertExit 0
  T-AssertLine 'SKIP: grok model pinning: no usable'
  T-AssertAbsent $grokToml
  T-AssertUnchanged $grokToml $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-InstallGeminiSharedInstructions {
  # gemini and antigravity share one GEMINI.md, but each keeps its own
  # agents\ and skills\ roots.
  $script:T_Case = 'Case-InstallGeminiSharedInstructions'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'

  T-Install $root '-Harnesses' 'gemini,antigravity'
  T-AssertExit 0
  T-AssertSymlink (Join-Path $root 'home\.gemini\GEMINI.md') $aiTools
  T-AssertSymlink (Join-Path $root 'home\.gemini\agents\planner-ai-tools.md') $aiTools
  T-AssertSymlink (Join-Path $root 'home\.gemini\config\agents\planner-ai-tools.md') $aiTools
  T-AssertSymlink (Join-Path $root 'home\.gemini\skills\planner-ai-tools') $aiTools
  T-AssertSymlink (Join-Path $root 'home\.gemini\config\skills\planner-ai-tools') $aiTools

  T-Cleanup $root
}

function Case-InstallNoInstructions {
  # -NoInstructions skips the instructions destination and its verification.
  $script:T_Case = 'Case-InstallNoInstructions'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'claude-code' '-NoInstructions'
  T-AssertExit 0
  T-AssertAbsent (Join-Path $root 'home\.claude\CLAUDE.md')
  T-AssertNoLine 'WARN:'

  T-Cleanup $root
}

function Case-InstallBogusHarness {
  $script:T_Case = 'Case-InstallBogusHarness'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses' 'bogus'
  T-AssertExit 1
  T-AssertLine 'ERROR: unknown harness'

  T-Cleanup $root
}

function Case-InstallHarnessesMissingValue {
  $script:T_Case = 'Case-InstallHarnessesMissingValue'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Harnesses'
  T-AssertExit 1

  T-Cleanup $root
}

function Case-InstallBogusFlag {
  # install.ps1 has no [CmdletBinding()]/usage function of its own (unlike
  # install.sh's hand-rolled parser): an unrecognised named parameter is a
  # PowerShell parameter-binding error raised by the engine itself before
  # the script body runs, not application text, so only the exit code is
  # asserted here.
  $script:T_Case = 'Case-InstallBogusFlag'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '-Bogus'
  T-AssertExit 1

  T-Cleanup $root
}

function Case-InstallRejectsShellFlagSpelling {
  # The two CLIs are not silently interchangeable: the shell spelling
  # (--dry-run) is not a valid PowerShell parameter name (PowerShell
  # parameters use a single leading dash) and is rejected the same way an
  # unknown flag is.
  $script:T_Case = 'Case-InstallRejectsShellFlagSpelling'
  T-Fixture
  $root = $script:T_Root

  T-Install $root '--dry-run'
  T-AssertExit 1

  T-Cleanup $root
}

function Case-InstallNotAClone {
  $script:T_Case = 'Case-InstallNotAClone'
  T-Fixture
  $root = $script:T_Root
  $aiTools = Join-Path $root 'home\.ai-tools'
  Remove-Item -LiteralPath $aiTools -Recurse -Force
  New-Item -ItemType Directory -Path $aiTools -Force | Out-Null

  # The sandbox's own install.ps1 no longer exists (it lived under the clone
  # just wiped above), so run this suite's own install.ps1 instead; T-Run
  # still points AI_TOOLS at the sandboxed (non-clone) path, which is what
  # Ensure-Clone must reject.
  T-Run $root (Join-Path $script:AI_TOOLS 'scripts\powershell\install.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'is not an ai-tools clone'

  T-Cleanup $root
}

function Case-VerifyClean {
  $script:T_Case = 'Case-VerifyClean'
  T-Fixture
  $root = $script:T_Root

  T-Run $root (Join-Path $root 'home\.ai-tools\scripts\powershell\install.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 0

  $before = T-Snapshot (Join-Path $root 'home')
  T-Verify $root '-Harnesses' 'claude-code'
  T-AssertExit 0
  T-AssertNoLine 'WARN:'
  T-AssertUnchanged (Join-Path $root 'home') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-VerifyAgentAbsent {
  $script:T_Case = 'Case-VerifyAgentAbsent'
  T-Fixture
  $root = $script:T_Root

  T-Run $root (Join-Path $root 'home\.ai-tools\scripts\powershell\install.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 0

  $dest = Join-Path $root 'home\.claude\agents\planner-ai-tools.md'
  Remove-Item -LiteralPath $dest -Force

  $before = T-Snapshot (Join-Path $root 'home')
  T-Verify $root '-Harnesses' 'claude-code'
  T-AssertExit 2
  T-AssertLine "WARN: agent absent: $dest"
  T-AssertUnchanged (Join-Path $root 'home') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-VerifyAgentDiffers {
  $script:T_Case = 'Case-VerifyAgentDiffers'
  T-Fixture
  $root = $script:T_Root

  T-Run $root (Join-Path $root 'home\.ai-tools\scripts\powershell\install.ps1') '-Harnesses' 'claude-code'
  T-AssertExit 0

  $dest = Join-Path $root 'home\.claude\agents\planner-ai-tools.md'
  Remove-Item -LiteralPath $dest -Force
  Set-Content -LiteralPath $dest -Value 'unrelated regular file' -NoNewline

  $before = T-Snapshot (Join-Path $root 'home')
  T-Verify $root '-Harnesses' 'claude-code'
  T-AssertExit 2
  T-AssertLine "WARN: agent differs from source: $dest"
  T-AssertUnchanged (Join-Path $root 'home') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}

function Case-VerifyNoClone {
  $script:T_Case = 'Case-VerifyNoClone'
  T-Fixture
  $root = $script:T_Root
  Remove-Item -LiteralPath (Join-Path $root 'home\.ai-tools\.git') -Recurse -Force

  $before = T-Snapshot (Join-Path $root 'home')
  T-Verify $root '-Harnesses' 'claude-code'
  T-AssertExit 1
  T-AssertLine 'is missing or not a clone'
  T-AssertUnchanged (Join-Path $root 'home') $before
  Remove-Item -LiteralPath $before -Force -ErrorAction SilentlyContinue

  T-Cleanup $root
}
