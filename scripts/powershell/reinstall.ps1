#!/usr/bin/env pwsh
# ai-tools reinstallation — README "Reinstallation" as an executable procedure:
# a full removal + installation pass against a fresh origin/master.
# Links are never upgraded in place — re-creating them is the fix.
# Mirrors scripts/shell/reinstall.sh (canonical). Windows PowerShell 5.1+ / pwsh.
#
# usage: reinstall.ps1 [-Harnesses <list>] [-DiscardLocal] [-NoInstructions] [-NoSweep] [-DryRun]
#   -Harnesses <list>  comma-separated harnesses in scope; default: every detected harness
#   -DiscardLocal      allow the reset to origin/master to discard local commits
#                      and uncommitted edits inside $HOME\.ai-tools (shown first)
#   -NoInstructions    do not refresh the global instructions links
#   -NoSweep           skip the stale-link sweep (links from older alpha layouts)
#   -DryRun            report what would be done without changing anything
# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
param(
  [string]$Harnesses = '',
  [switch]$DiscardLocal,
  [switch]$NoInstructions,
  [switch]$NoSweep,
  [switch]$DryRun
)

. (Join-Path $PSScriptRoot 'lib.ps1')
$script:DryRun = [bool]$DryRun

# 1. Update the source first, so destinations match the published agent set.
Ensure-Clone
if ($script:FreshClone) { Info 'fresh clone — already at origin/master, reset skipped' }
else { Update-Source ([bool]$DiscardLocal) }

Report-Discovery
Set-Scope $Harnesses

# 2. Remove: agents, skills, grok block, stale links, optionally instructions.
Uninstall-Agents
Remove-Skills
Remove-GrokModels
if (-not $NoSweep) { Sweep-StaleLinks }
if (-not $NoInstructions) { Remove-Instructions }

# 3. Install against the fresh tree.
if ($NoInstructions) { Info 'instructions refresh skipped (-NoInstructions)' }
else { Install-Instructions }
Ensure-UserAgentsMd
Install-Agents
Install-Skills
Install-GrokModels

# 4. Verify: full install checks, and no stale links left behind.
Verify-Install (-not $NoInstructions)
Info 'restart or reload harnesses, then confirm the agents and skill slash commands appear'
Finish
