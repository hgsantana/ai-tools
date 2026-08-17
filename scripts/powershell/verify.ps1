#!/usr/bin/env pwsh
# ai-tools verification — the README's install checks, standalone and read-only.
# Mirrors scripts/shell/verify.sh (canonical). Windows PowerShell 5.1+ / pwsh.
#
# usage: verify.ps1 [-Harnesses <list>]
#   -Harnesses <list>  comma-separated harnesses in scope; default: every detected harness
# Read-only. Exit codes: 0 clean, 1 aborted on a precondition, 2 warnings found.
param(
  [string]$Harnesses = ''
)

. (Join-Path $PSScriptRoot 'lib.ps1')

Require-Clone
Set-Scope $Harnesses
Verify-Install $true
Finish
