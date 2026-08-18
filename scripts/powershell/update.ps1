#!/usr/bin/env pwsh
# ai-tools update — README "Update" as an executable procedure.
# Mirrors scripts/shell/update.sh (canonical). Windows PowerShell 5.1+ / pwsh.
#
# usage: update.ps1 [-Harnesses <list>] [-DiscardLocal] [-NoReset] [-DryRun]
#   -Harnesses <list>  comma-separated harnesses in scope; default: every detected harness
#   -DiscardLocal      allow the reset to origin/master to discard local commits
#                      and uncommitted edits inside $HOME\.ai-tools (shown first)
#   -NoReset           skip the reset; only re-synchronize from the current tree
#   -DryRun            report what would be done without changing anything
# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
# Use reinstall.ps1 instead when the install is broken, comes from an older
# alpha layout, or the set of harnesses changed.
param(
  [string]$Harnesses = '',
  [switch]$DiscardLocal,
  [switch]$NoReset,
  [switch]$DryRun
)

. (Join-Path $PSScriptRoot 'lib.ps1')
$script:DryRun = [bool]$DryRun

Require-Clone
Set-Scope $Harnesses

if ($NoReset) { Info 'reset skipped (-NoReset); synchronizing from the current tree' }
else { Update-Source ([bool]$DiscardLocal) }

Refresh-Copies
# Link anything newly shipped — every install step is idempotent.
Install-Instructions
Ensure-UserAgentsMd
Install-Agents
Install-Skills
Install-GrokModels

Verify-Install $true
Info 'restart or reload harnesses that cache agents or skills'
Finish
