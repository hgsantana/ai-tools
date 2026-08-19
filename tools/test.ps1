#!/usr/bin/env pwsh
# ai-tools sandboxed test suite (PowerShell) — a development check, not an
# installation process (outside the contract of README rules 23-25), same
# standing as tools/test.sh. Mirrors tools/test.sh, which stays canonical
# (README rule 24): same case list, fixture shape, and assertion vocabulary.
# Proves the install/verify contract mechanically, against a disposable fake
# $HOME, never against the real one.
#
# Windows only: scripts/powershell build destination paths as
# `Join-Path $HOME '.claude\agents'`, which resolves to one literal file
# name (not a directory) on a non-Windows host, so this suite refuses to run
# anywhere else — this is also why the CI job that runs it is scheduled on
# windows-latest only. Windows PowerShell 5.1 has no $IsWindows automatic
# variable; its absence is treated as "running on Windows" (5.1 only ships
# there).
#
# usage: tools/test.ps1 [-Case <name>[,<name>...]] [-Keep] [-Runner <path>] [-Help]
#   -Case <name>   run one or more cases, comma-separated. <name> is a
#                  case-file basename under tools/test/ (with or without
#                  ".ps1"), running every Case-* function that file defines,
#                  or a single Case-* function name, to isolate one case
#   -Keep          do not delete sandboxes when a case finishes; print paths
#   -Runner <path> PowerShell executable to run scripts under test with
#                  (default: the current host's own executable, so the same
#                  suite runs under both pwsh and powershell.exe depending
#                  on how tools/test.ps1 itself was launched)
#   -Help          show this usage and the discovered cases
#
# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with failures.
param(
  [string]$Case = '',
  [switch]$Keep,
  [string]$Runner = '',
  [switch]$Help
)

$onWindows = $true
if (Test-Path Variable:\IsWindows) { $onWindows = $IsWindows }
if (-not $onWindows) {
  [Console]::Error.WriteLine('ERROR: tools/test.ps1 only runs on Windows -- scripts/powershell builds destination paths as Join-Path $HOME ''.claude\agents'', meaningless elsewhere (scripts/powershell has its own suite; this one does not run on macOS/Linux)')
  exit 1
}

$script:AI_TOOLS = (Get-Item (Join-Path $PSScriptRoot '..')).FullName
$env:AI_TOOLS = $script:AI_TOOLS
. (Join-Path $script:AI_TOOLS 'scripts\powershell\lib.ps1')
. (Join-Path $PSScriptRoot 'test\lib.ps1')

if (-not $Runner) {
  $proc = Get-Process -Id $PID -ErrorAction SilentlyContinue
  if ($proc -and $proc.Path) { $Runner = $proc.Path } else { $Runner = 'pwsh' }
}
$script:T_Runner = $Runner
$script:T_Keep = [bool]$Keep

# --- $HOME control — verify before building anything (step 3) --------------
# Proves that overriding HOME/USERPROFILE/HOMEDRIVE/HOMEPATH before spawning
# a child process under $Runner makes that child's own $HOME resolve inside
# a disposable path, before T-Fixture builds anything and before any script
# under test runs — same reasoning as T-SandboxGuard: never let a script
# under test see the caller's real $HOME.

function T-DetectHomeOverrideForm([string]$RunnerPath) {
  # Returns 'env' when the plain env-var override (used by -File) works,
  # 'assign' when the caller must instead assign $HOME inline via -Command,
  # or $null when neither form resolves inside the probe path.
  $probe = Join-Path $env:TEMP ('ai-tools-test-probe.' + [guid]::NewGuid().ToString('N').Substring(0, 12))
  New-Item -ItemType Directory -Path $probe -Force | Out-Null
  try {
    $savedHome = $env:HOME; $savedUserProfile = $env:USERPROFILE
    $savedHomeDrive = $env:HOMEDRIVE; $savedHomePath = $env:HOMEPATH
    try {
      $probeRoot = [System.IO.Path]::GetPathRoot($probe).TrimEnd('\')
      $env:HOME = $probe; $env:USERPROFILE = $probe
      $env:HOMEDRIVE = $probeRoot; $env:HOMEPATH = $probe.Substring($probeRoot.Length)
      $out = (& $RunnerPath -NoProfile -Command '$HOME' 2>&1 | Out-String).Trim()
      if ($out -eq $probe) { return 'env' }
    } finally {
      $env:HOME = $savedHome; $env:USERPROFILE = $savedUserProfile
      $env:HOMEDRIVE = $savedHomeDrive; $env:HOMEPATH = $savedHomePath
    }

    $cmd = "& { `$HOME = '$probe'; `$HOME }"
    $out2 = (& $RunnerPath -NoProfile -Command $cmd 2>&1 | Out-String).Trim()
    if ($out2 -eq $probe) { return 'assign' }

    return $null
  } finally {
    Remove-Item -LiteralPath $probe -Recurse -Force -ErrorAction SilentlyContinue
  }
}

$script:T_HomeForm = T-DetectHomeOverrideForm $script:T_Runner
if (-not $script:T_HomeForm) {
  Fatal "cannot make `$HOME resolve inside a disposable path under $($script:T_Runner) — refusing to run (would risk a script under test touching the real `$HOME)"
}
Info "HOME override form for $($script:T_Runner): $($script:T_HomeForm)"

# --- Case discovery + sourcing (mirrors tools/test.sh) ----------------------
# Every tools/test/*.ps1 other than lib.ps1 is a case file: it defines one
# or more Case-* functions, which this runner dot-sources and calls. Nothing
# registers a case in a central list — a new case file needs no edit here.
#
# Sourced here, at script top level (not inside a function): dot-sourcing a
# file inside a function scopes the functions it defines to that function,
# and they vanish on return, so "& $c" below could never resolve them. One
# sourcing pass at this scope serves both -Help and the run.

function T-DiscoverCaseFiles {
  Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'tools\test') -Filter '*.ps1' -File |
    Where-Object { $_.Name -ne 'lib.ps1' } | Sort-Object Name
}

# $script:T_CaseMap: file-basename -> sorted array of Case-* functions it
# defines. Lets -Case <name> resolve a case-file basename to every Case-*
# function it defines.
$script:T_CaseMap = @{}
foreach ($f in T-DiscoverCaseFiles) {
  $base = $f.BaseName
  $before = @(Get-ChildItem function:\Case-* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
  . $f.FullName
  $after = @(Get-ChildItem function:\Case-* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
  $new = @($after | Where-Object { $before -notcontains $_ } | Sort-Object)
  $script:T_CaseMap[$base] = $new
}

function T-ResolveCase([string]$Name) {
  # Resolved as a case-file basename (with or without ".ps1") first, then as
  # a single Case-* function name. Returns $null when neither resolves.
  $base = $Name -replace '\.ps1$', ''
  if ($script:T_CaseMap.ContainsKey($base)) { return $script:T_CaseMap[$base] }
  if ($script:T_AllCases -contains $Name) { return @($Name) }
  return $null
}

if ($Help) {
  Write-Output 'usage: test.ps1 [-Case <name>[,<name>...]] [-Keep] [-Runner <path>] [-Help]'
  Write-Output ''
  Write-Output 'Development check: builds a disposable fake $HOME per case and runs the'
  Write-Output 'scripts under scripts/powershell against it (scripts/shell has its own'
  Write-Output 'suite). Not an installation process (README rules 23-25).'
  Write-Output ''
  Write-Output '  -Case <name>   run one or more cases, comma-separated; a case-file'
  Write-Output '                 basename (with or without ".ps1") runs every Case-*'
  Write-Output '                 function it defines, a single Case-* function name'
  Write-Output '                 isolates one case'
  Write-Output '  -Keep          do not delete sandboxes when a case finishes; print paths'
  Write-Output '  -Runner <path> PowerShell executable to run scripts under test with'
  Write-Output ''
  Write-Output 'Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with failures.'
  Write-Output ''
  Write-Output 'Discovered cases (file: functions):'
  foreach ($k in $script:T_CaseMap.Keys | Sort-Object) {
    Write-Output "  ${k}: $($script:T_CaseMap[$k] -join ' ')"
  }
  exit 0
}

$script:T_AllCases = @($script:T_CaseMap.Values | ForEach-Object { $_ } | Sort-Object -Unique)
if ($script:T_AllCases.Count -eq 0) { Fatal 'no Case-* functions discovered under tools/test/*.ps1' }

$requestedCases = @($Case -split '[, ]+' | Where-Object { $_ })
$runCases = @()
if ($requestedCases.Count -gt 0) {
  foreach ($c in $requestedCases) {
    $resolved = T-ResolveCase $c
    if (-not $resolved) { Fatal "unknown case: $c (see -Help)" }
    $runCases += $resolved
  }
} else {
  $runCases = $script:T_AllCases
}

# Vacuity guard, per run: fail loudly rather than reaching Finish with a
# clean (zero-case) count. The $script:T_AllCases check above already covers
# empty discovery; this covers a resolved-but-empty run set.
if ($runCases.Count -eq 0) { Fatal 'no cases resolved to run' }

foreach ($c in $runCases) {
  Info "case: $c"
  $before = $script:OK + $script:WARN
  try {
    & $c
  } catch {
    Warn "${c}: $($_.Exception.Message)"
  }
  # Vacuity guard, per case: a case that ran without moving OK or WARN
  # asserted nothing -- catches silent non-terminating failures (the error
  # records from a failing "& $c" would otherwise never touch the counters)
  # as well as no-op cases.
  $after = $script:OK + $script:WARN
  if ($after -le $before) { Warn "${c}: asserted nothing" }
}

Finish
