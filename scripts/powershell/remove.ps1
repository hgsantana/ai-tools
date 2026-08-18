#!/usr/bin/env pwsh
# ai-tools removal — README "Removal" as an executable procedure.
# Removal means "unlink from harnesses", not "delete the config repo".
# Mirrors scripts/shell/remove.sh (canonical). Windows PowerShell 5.1+ / pwsh.
#
# usage: remove.ps1 [-Harnesses <list>] [-Instructions] [-NoSweep] [-Purge [-Yes]] [-DryRun]
#   -Harnesses <list>  comma-separated harnesses in scope; default: every detected harness
#   -Instructions      also unlink the global instructions (USER-AGENTS.md links);
#                      never touches $HOME\AGENTS.md
#   -NoSweep           skip the stale-link sweep (links from older alpha layouts)
#   -Purge             delete $HOME\.ai-tools itself after unlinking (asks for
#                      confirmation; -Yes skips the prompt)
#   -DryRun            report what would be done without changing anything
# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
param(
  [string]$Harnesses = '',
  [switch]$Instructions,
  [switch]$NoSweep,
  [switch]$Purge,
  [switch]$Yes,
  [switch]$DryRun
)

. (Join-Path $PSScriptRoot 'lib.ps1')
$script:DryRun = [bool]$DryRun

Set-Scope $Harnesses

if (Test-Path -LiteralPath $script:AI_TOOLS) {
  Report-Links
  Uninstall-Agents
  Remove-Skills
  Remove-GrokModels
} else {
  Warn "$($script:AI_TOOLS) missing — copies cannot be verified; removing links only (sweep)"
}

if (-not $NoSweep) { Sweep-StaleLinks }
if ($Instructions) { Remove-Instructions }

Verify-Removal
if ($Purge) { Purge-Clone ([bool]$Yes) }

Info 'restart or reload harnesses; the agents and skill slash commands should disappear'
Finish
