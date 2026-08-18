#!/usr/bin/env pwsh
# ai-tools installation — README "Installation" as an executable procedure.
# Mirrors scripts/shell/install.sh (canonical). Windows PowerShell 5.1+ / pwsh.
#
# usage: install.ps1 [-Harnesses <list>] [-NoInstructions] [-DryRun]
#   -Harnesses <list>  comma-separated harnesses to install into
#                      (claude-code,grok,codex,copilot,cursor,gemini,antigravity);
#                      default: every detected harness
#   -NoInstructions    skip linking USER-AGENTS.md as global instructions
#   -DryRun            report what would be done without changing anything
# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
param(
  [string]$Harnesses = '',
  [switch]$NoInstructions,
  [switch]$DryRun
)

. (Join-Path $PSScriptRoot 'lib.ps1')
$script:DryRun = [bool]$DryRun

Ensure-Clone
Report-Discovery
Set-Scope $Harnesses

if ($NoInstructions) { Info 'instructions install skipped (-NoInstructions)' }
else { Install-Instructions }
Ensure-UserAgentsMd
Install-Agents
Install-Skills
Install-GrokModels

Verify-Install (-not $NoInstructions)
Info 'restart or reload harnesses that cache agents or skills, then check the agent list and skill slash commands'
Finish
