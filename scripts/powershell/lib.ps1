# ai-tools shared helpers — dot-sourced by every script in scripts/powershell/.
# Mirrors scripts/shell/lib.sh (the canonical implementation) for Windows.
# Windows PowerShell 5.1+ and pwsh. Symlinks need Developer Mode or an elevated
# shell; every link falls back to a copy, reported as such.

Set-StrictMode -Version 2
$ErrorActionPreference = 'Continue'

if (-not $env:AI_TOOLS) { $script:AI_TOOLS = Join-Path $HOME '.ai-tools' } else { $script:AI_TOOLS = $env:AI_TOOLS }
$script:REPO_URL = 'https://github.com/hgsantana/ai-tools.git'
$script:ALL_HARNESSES = @('claude-code', 'grok', 'codex', 'copilot', 'cursor', 'gemini', 'antigravity')
$script:EXT_ROOTS = @('.vscode\extensions', '.vscode-server\extensions', '.vscode-insiders\extensions',
  '.vscode-server-insiders\extensions', '.vscodium\extensions') | ForEach-Object { Join-Path $HOME $_ }

$script:DryRun = $false
$script:Scope = @()
$script:FreshClone = $false
$script:Prev = ''
$script:OK = 0; $script:SKIP = 0; $script:WARN = 0

function Ok([string]$msg) { $script:OK++;   Write-Output "ok: $msg" }
function Skip([string]$msg) { $script:SKIP++; Write-Output "SKIP: $msg" }
function Warn([string]$msg) { $script:WARN++; Write-Output "WARN: $msg" }
function Info([string]$msg) { Write-Output "info: $msg" }
function Fatal([string]$msg) { Write-Error "ERROR: $msg"; exit 1 }

function Finish {
  $suffix = ''
  if ($script:DryRun) { $suffix = ' (dry-run: nothing was changed)' }
  Write-Output ("done: {0} ok, {1} skipped, {2} warnings{3}" -f $script:OK, $script:SKIP, $script:WARN, $suffix)
  if ($script:WARN -gt 0) { exit 2 }
  exit 0
}

# --- Harness table (mirrors "Supported harnesses" in README.md) -------------

function Get-AgentsRoot([string]$h) {
  switch ($h) {
    'claude-code' { Join-Path $HOME '.claude\agents' }
    'grok'        { Join-Path $HOME '.grok\agents' }
    'codex'       { Join-Path $HOME '.codex\agents' }
    'copilot'     { Join-Path $HOME '.copilot\agents' }
    'cursor'      { Join-Path $HOME '.cursor\agents' }
    'gemini'      { Join-Path $HOME '.gemini\agents' }
    'antigravity' { Join-Path $HOME '.gemini\config\agents' }
  }
}

function Get-SkillsRoot([string]$h) {
  switch ($h) {
    'claude-code' { Join-Path $HOME '.claude\skills' }
    'grok'        { Join-Path $HOME '.grok\skills' }
    'codex'       { Join-Path $HOME '.codex\skills' }
    'copilot'     { Join-Path $HOME '.copilot\skills' }
    'cursor'      { Join-Path $HOME '.cursor\skills' }
    'gemini'      { Join-Path $HOME '.gemini\skills' }
    'antigravity' { Join-Path $HOME '.gemini\config\skills' }
  }
}

function Get-InstructionsDest([string]$h) {
  switch ($h) {
    'claude-code' { Join-Path $HOME '.claude\CLAUDE.md' }
    'grok'        { Join-Path $HOME '.grok\AGENTS.md' }
    'codex'       { Join-Path $HOME '.codex\AGENTS.md' }
    'copilot'     { Join-Path $HOME '.copilot\instructions\ai-tools.instructions.md' }
    'gemini'      { Join-Path $HOME '.gemini\GEMINI.md' }
    'antigravity' { Join-Path $HOME '.gemini\GEMINI.md' }
    'cursor'      { $null }  # Cursor has no global instructions destination
  }
}

# --- Discovery ---------------------------------------------------------------

function Test-Extension([string]$prefix) {
  foreach ($root in $script:EXT_ROOTS) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    if (Get-ChildItem -LiteralPath $root -Directory -Filter "$prefix*" -ErrorAction SilentlyContinue) { return $true }
  }
  return $false
}

function Test-Command([string]$name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Test-Harness([string]$h) {
  switch ($h) {
    'claude-code' { (Test-Path (Join-Path $HOME '.claude')) -or (Test-Extension 'anthropic.claude-code-') }
    'grok'        { (Test-Path (Join-Path $HOME '.grok')) -or (Test-Command grok) }
    'codex'       { (Test-Path (Join-Path $HOME '.codex')) -or (Test-Command codex) -or (Test-Extension 'openai.chatgpt-') }
    'copilot'     { (Test-Path (Join-Path $HOME '.copilot')) -or (Test-Command copilot) -or (Test-Extension 'github.copilot-chat-') }
    'cursor'      { Test-Path (Join-Path $HOME '.cursor') }
    'gemini'      { (Test-Path (Join-Path $HOME '.gemini')) -or (Test-Command gemini) -or (Test-Extension 'google.geminicodeassist-') }
    'antigravity' { (Test-Path (Join-Path $HOME '.gemini\config')) -or (Test-Command antigravity) }
    default       { $false }
  }
}

function Get-DetectedHarnesses {
  return @($script:ALL_HARNESSES | Where-Object { Test-Harness $_ })
}

function Report-Discovery {
  foreach ($h in $script:ALL_HARNESSES) {
    if (Test-Harness $h) { Info "found: $h" }
  }
  if (Test-Path (Join-Path $HOME '.agents')) { Info "found: $HOME\.agents (shared discovery root — never linked)" }
  # Informational-only: possible AI extensions with no confirmed config convention.
  $known = '^(google\.geminicodeassist|anthropic\.claude-code|openai\.chatgpt|github\.copilot)'
  foreach ($root in $script:EXT_ROOTS) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match 'gemini|claude|codeium|windsurf|antigravity|continue|cody|cursor|tabnine' -and $_.Name -notmatch $known } |
      ForEach-Object { Info "possible AI extension (not offered): $($_.Name) in $root" }
  }
}

function Set-Scope([string]$requested) {
  if (-not $requested) {
    $script:Scope = Get-DetectedHarnesses
    if ($script:Scope.Count -eq 0) { Fatal "no supported harness detected; pass -Harnesses (valid: $($script:ALL_HARNESSES -join ','))" }
  } else {
    $script:Scope = @()
    foreach ($h in ($requested -split '[, ]+' | Where-Object { $_ })) {
      if ($script:ALL_HARNESSES -notcontains $h) { Fatal "unknown harness: $h (valid: $($script:ALL_HARNESSES -join ','))" }
      $script:Scope += $h
    }
  }
  Info "scope: $($script:Scope -join ' ')"
}

function In-Scope([string]$h) { return $script:Scope -contains $h }

function Get-ScopedRoots {
  $roots = @()
  foreach ($h in $script:Scope) { $roots += (Get-AgentsRoot $h); $roots += (Get-SkillsRoot $h) }
  return @($roots | Sort-Object -Unique)
}

# --- Filesystem safety primitives (README "Safety rules") --------------------

function Get-LinkTarget([string]$p) {
  $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'SymbolicLink') {
    $t = $item.Target
    if ($t -is [array]) { $t = $t[0] }
    return [string]$t
  }
  return $null
}

function Test-AiToolsTarget([string]$target) {
  if (-not $target) { return $false }
  if ($target -like '*ai-tools*') { return $true }
  try { $full = [System.IO.Path]::GetFullPath($target) } catch { return $false }
  return $full -like "$($script:AI_TOOLS)*"
}

function Test-SameContent([string]$a, [string]$b) {
  if ((Test-Path -LiteralPath $a -PathType Leaf) -and (Test-Path -LiteralPath $b -PathType Leaf)) {
    return (Get-FileHash -LiteralPath $a).Hash -eq (Get-FileHash -LiteralPath $b).Hash
  }
  if ((Test-Path -LiteralPath $a -PathType Container) -and (Test-Path -LiteralPath $b -PathType Container)) {
    $ra = (Get-Item -LiteralPath $a).FullName
    $rb = (Get-Item -LiteralPath $b).FullName
    $fa = @(Get-ChildItem -LiteralPath $ra -Recurse -File | ForEach-Object { $_.FullName.Substring($ra.Length).TrimStart('\', '/') } | Sort-Object)
    $fb = @(Get-ChildItem -LiteralPath $rb -Recurse -File | ForEach-Object { $_.FullName.Substring($rb.Length).TrimStart('\', '/') } | Sort-Object)
    if (($fa -join "`n") -ne ($fb -join "`n")) { return $false }
    foreach ($rel in $fa) {
      if ((Get-FileHash -LiteralPath (Join-Path $ra $rel)).Hash -ne (Get-FileHash -LiteralPath (Join-Path $rb $rel)).Hash) { return $false }
    }
    return $true
  }
  return $false
}

function Safe-Link([string]$target, [string]$dest) {
  # returns 0 done/already, 1 occupied (reported), 2 symlink refused by the OS
  $cur = Get-LinkTarget $dest
  if ($cur) {
    try { $curFull = [System.IO.Path]::GetFullPath($cur); $wantFull = [System.IO.Path]::GetFullPath($target) }
    catch { $curFull = $cur; $wantFull = $target }
    if ($curFull -eq $wantFull -or $cur -eq $target) { Ok "already linked: $dest"; return 0 }
    Skip "symlink points elsewhere: $dest -> $cur"; return 1
  }
  if (Test-Path -LiteralPath $dest) { Skip "exists, not overwriting: $dest"; return 1 }
  if ($script:DryRun) { Ok "would link: $dest -> $target"; return 0 }
  $parent = Split-Path -Parent $dest
  if (-not (Test-Path -LiteralPath $parent)) {
    try { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    catch { Warn "cannot create parent of: $dest"; return 1 }
  }
  try {
    New-Item -ItemType SymbolicLink -Path $dest -Target $target -ErrorAction Stop | Out-Null
    Ok "linked: $dest -> $target"; return 0
  } catch {
    return 2  # no Developer Mode / no elevation — caller may fall back to copy
  }
}

function LinkOrCopy([string]$target, [string]$dest) {
  $rc = Safe-Link $target $dest
  if ($rc -ne 2) { return $rc }
  try {
    Copy-Item -LiteralPath $target -Destination $dest -Recurse -ErrorAction Stop
    Ok "copied (will not track updates): $dest <- $target"; return 0
  } catch {
    Warn "neither link nor copy possible: $dest"; return 1
  }
}

function Safe-Unlink([string]$dest) {
  # Removes only symlinks resolving into ai-tools.
  if (-not (Test-Path -LiteralPath $dest)) {
    if (-not (Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue)) { Ok "absent: $dest"; return 0 }
  }
  $t = Get-LinkTarget $dest
  if ($null -eq $t) {
    if (Test-Path -LiteralPath $dest) { Skip "not a symlink: $dest"; return 1 }
    Ok "absent: $dest"; return 0
  }
  if (-not (Test-AiToolsTarget $t)) { Skip "symlink not to ai-tools: $dest -> $t"; return 1 }
  if ($script:DryRun) { Ok "would remove link: $dest (-> $t)"; return 0 }
  try {
    (Get-Item -LiteralPath $dest -Force).Delete()  # deletes the link, never the target
    Ok "removed link: $dest (was -> $t)"; return 0
  } catch {
    Warn "could not remove link: $dest"; return 1
  }
}

function Safe-UninstallCopy([string]$dest, [string]$src) {
  # Removes a copy ONLY while its contents still match the ai-tools source.
  if (-not (Test-Path -LiteralPath $dest) -or (Get-LinkTarget $dest)) { return 1 }
  if (Test-SameContent $dest $src) {
    if ($script:DryRun) { Ok "would remove copy: $dest"; return 0 }
    Remove-Item -LiteralPath $dest -Recurse -Force
    Ok "removed copy: $dest"; return 0
  }
  Skip "copy was modified locally, user work kept: $dest"; return 1
}

# --- Source tree -------------------------------------------------------------

function Git-Run([string[]]$gitArgs) {
  & git -C $script:AI_TOOLS @gitArgs 2>&1
  return $LASTEXITCODE
}

function Ensure-Clone {
  if (-not (Test-Path -LiteralPath $script:AI_TOOLS)) {
    if ($script:DryRun) { Fatal "$($script:AI_TOOLS) missing — clone it first: git clone $($script:REPO_URL) `"$($script:AI_TOOLS)`"" }
    & git clone $script:REPO_URL $script:AI_TOOLS
    if ($LASTEXITCODE -ne 0) { Fatal "clone failed: $($script:REPO_URL) -> $($script:AI_TOOLS)" }
    $script:FreshClone = $true
  }
  if (-not ((Test-Path (Join-Path $script:AI_TOOLS 'USER-AGENTS.md')) -and (Test-Path (Join-Path $script:AI_TOOLS 'agents')))) {
    Fatal "$($script:AI_TOOLS) is not an ai-tools clone (move any existing clone here — the only supported location)"
  }
}

function Require-Clone {
  if (-not ((Test-Path (Join-Path $script:AI_TOOLS '.git')) -and (Test-Path (Join-Path $script:AI_TOOLS 'USER-AGENTS.md')))) {
    Fatal "$($script:AI_TOOLS) is missing or not a clone — run scripts\powershell\install.ps1 first"
  }
}

function Update-Source([bool]$discardLocal) {
  # Resets $AI_TOOLS to origin/master. Sets $script:Prev to the pre-reset revision.
  if ((Git-Run @('fetch', 'origin')) -ne 0) { Fatal 'fetch failed — fix the remote or auth and retry' }
  if ((Git-Run @('show-ref', '--verify', '--quiet', 'refs/remotes/origin/master')) -ne 0) {
    Fatal 'origin/master not found after fetch — fix the remote and retry'
  }
  $script:Prev = (& git -C $script:AI_TOOLS rev-parse HEAD).Trim()
  $dirty = & git -C $script:AI_TOOLS status --porcelain
  $ahead = & git -C $script:AI_TOOLS log --oneline origin/master..HEAD 2>$null
  if ($dirty -or $ahead) {
    if ($dirty) { Write-Output "local changes in $($script:AI_TOOLS):"; & git -C $script:AI_TOOLS status --short }
    if ($ahead) { Write-Output 'local commits ahead of origin/master:'; Write-Output $ahead }
    if (-not $discardLocal) { Fatal 'the reset would discard the local work above — stash/branch it, or re-run with -DiscardLocal' }
  }
  if ($script:DryRun) {
    Ok "would reset $($script:AI_TOOLS) to origin/master ($((& git -C $script:AI_TOOLS rev-parse --short origin/master).Trim()))"
    return
  }
  if ((Git-Run @('checkout', '-f', 'master')) -ne 0) { Fatal "cannot check out master in $($script:AI_TOOLS)" }
  if ((Git-Run @('reset', '--hard', 'origin/master')) -ne 0) { Fatal 'reset to origin/master failed' }
  Ok "source at $((& git -C $script:AI_TOOLS rev-parse --short HEAD).Trim()) (was $((& git -C $script:AI_TOOLS rev-parse --short $script:Prev).Trim()))"
}

# --- Install steps -----------------------------------------------------------

function Install-Instructions {
  foreach ($h in $script:Scope) {
    $dest = Get-InstructionsDest $h
    if (-not $dest) { Info "no global instructions destination: $h"; continue }
    if ($h -eq 'codex' -and (Test-Path (Join-Path $HOME '.codex\AGENTS.override.md'))) {
      Info '~\.codex\AGENTS.override.md exists and takes precedence while present (never touched)'
    }
    $rc = Safe-Link (Join-Path $script:AI_TOOLS 'USER-AGENTS.md') $dest
    if ($rc -eq 2) {
      # Instructions must stay a single source of truth: offer a pointer, not a copy.
      Warn "symlink refused for $dest — add a one-line include pointer to $($script:AI_TOOLS)\USER-AGENTS.md instead of a copy"
    }
  }
}

function Ensure-UserAgentsMd {
  # $HOME\AGENTS.md is user-owned: created empty only when missing, never edited.
  $path = Join-Path $HOME 'AGENTS.md'
  if ((Test-Path -LiteralPath $path) -or (Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue)) {
    Ok "already present, untouched: $path"
  } elseif ($script:DryRun) {
    Ok "would create empty: $path"
  } else {
    New-Item -ItemType File -Path $path | Out-Null
    Ok "created empty: $path"
  }
}

function Install-Agents {
  # Per file, never per directory — the roots hold agents from other sources.
  foreach ($h in $script:Scope) {
    $src = Join-Path $script:AI_TOOLS "agents\$h"
    $root = Get-AgentsRoot $h
    if (-not (Test-Path -LiteralPath $src)) { Skip "no wrapper folder: $src"; continue }
    foreach ($f in Get-ChildItem -LiteralPath $src -File -Filter '*-ai-tools*') {
      [void](LinkOrCopy $f.FullName (Join-Path $root $f.Name))
    }
  }
}

function Install-Skills {
  foreach ($h in $script:Scope) {
    $root = Get-SkillsRoot $h
    foreach ($p in Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'skills') -Directory -Filter '*-ai-tools' -ErrorAction SilentlyContinue) {
      [void](LinkOrCopy $p.FullName (Join-Path $root $p.Name))
    }
  }
}

# --- Grok model pinning ------------------------------------------------------
# Grok ignores model: in agent frontmatter; models live in ~\.grok\config.toml.
# Only the marker-delimited block below is ever written or removed.

$script:MODELS_MAP = Join-Path $script:AI_TOOLS 'MODELS.md'
$script:GROK_TOML = Join-Path $HOME '.grok\config.toml'
$script:GROK_BEGIN = '# >>> ai-tools managed subagent models — do not edit inside this block'
$script:GROK_END = '# <<< ai-tools managed subagent models'

function Get-ModelFor([string]$Key, [string]$Category) {
  # Reads MODELS.md, the single source of model names (README rules 11-12).
  $col = switch ($Category) { 'planner' { 2 } 'implementer' { 3 } 'mechanical' { 4 } default { -1 } }
  if ($col -lt 0 -or -not (Test-Path -LiteralPath $script:MODELS_MAP)) { return $null }
  foreach ($line in Get-Content -LiteralPath $script:MODELS_MAP) {
    if ($line -notmatch '^\s*\|') { continue }
    $cells = $line.Trim().Trim('|').Split('|')
    if ($cells.Count -le $col) { continue }
    if ($cells[0].Trim().Trim('`') -ne $Key) { continue }
    $value = $cells[$col].Trim().Trim('`').Trim()
    if ($value) { return $value }
    return $null
  }
  return $null
}

function Get-GrokModelsToml {
  # Names from the tree; models from MODELS.md, row `grok`:
  # every shipped agent runs as planner, except maintainer-ai-tools (implementer).
  $planner = Get-ModelFor 'grok' 'planner'
  $implementer = Get-ModelFor 'grok' 'implementer'
  if (-not $planner -or -not $implementer) { return $null }
  $lines = @('[subagents.models]')
  foreach ($f in Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'agents') -File -Filter '*-ai-tools.md') {
    $name = $f.BaseName
    $model = if ($name -eq 'maintainer-ai-tools') { $implementer } else { $planner }
    $lines += "$name = `"$model`""
  }
  return $lines
}

function Get-GrokBlockLines {
  $models = Get-GrokModelsToml
  if (-not $models) { return $null }
  $lines = @($script:GROK_BEGIN) + $models + @($script:GROK_END)
  return $lines
}

function Remove-GrokBlockFromLines([string[]]$lines) {
  $out = @(); $inside = $false
  foreach ($l in $lines) {
    if ($l -eq $script:GROK_BEGIN) { $inside = $true; continue }
    if ($l -eq $script:GROK_END) { $inside = $false; continue }
    if (-not $inside) { $out += $l }
  }
  return $out
}

function Install-GrokModels {
  if (-not (In-Scope 'grok')) { return }
  $desired = Get-GrokBlockLines
  if (-not $desired) {
    Skip "grok model pinning: no usable ``grok`` row in $($script:MODELS_MAP) — block left untouched"
    return
  }
  $exists = Test-Path -LiteralPath $script:GROK_TOML
  $lines = @(); if ($exists) { $lines = @(Get-Content -LiteralPath $script:GROK_TOML) }
  if ($exists -and ($lines -contains $script:GROK_BEGIN)) {
    $start = [array]::IndexOf($lines, $script:GROK_BEGIN)
    $end = [array]::IndexOf($lines, $script:GROK_END)
    $current = @(); if ($end -ge $start) { $current = $lines[$start..$end] }
    if (($current -join "`n") -eq ($desired -join "`n")) { Ok "grok models block up to date: $($script:GROK_TOML)"; return }
    if ($script:DryRun) { Ok "would refresh grok models block: $($script:GROK_TOML)"; return }
    $out = @(Remove-GrokBlockFromLines $lines) + $desired
    Set-Content -LiteralPath $script:GROK_TOML -Value $out
    Ok "grok models block refreshed: $($script:GROK_TOML)"
    return
  }
  if ($exists -and ($lines -match '^\[subagents\.models\]')) {
    Skip "unmanaged [subagents.models] already in $($script:GROK_TOML) — verify the ai-tools entries manually (README, Installation)"
    return
  }
  if ($script:DryRun) { Ok "would append grok models block: $($script:GROK_TOML)"; return }
  $parent = Split-Path -Parent $script:GROK_TOML
  if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  $out = $lines; if ($out.Count -gt 0) { $out += '' }
  $out += $desired
  Set-Content -LiteralPath $script:GROK_TOML -Value $out
  Ok "grok models block appended: $($script:GROK_TOML)"
}

function Remove-GrokModels {
  if (-not (In-Scope 'grok')) { return }
  if (-not (Test-Path -LiteralPath $script:GROK_TOML)) { Ok "absent: $($script:GROK_TOML)"; return }
  $lines = @(Get-Content -LiteralPath $script:GROK_TOML)
  if ($lines -contains $script:GROK_BEGIN) {
    if ($script:DryRun) { Ok "would remove grok models block: $($script:GROK_TOML)"; return }
    Set-Content -LiteralPath $script:GROK_TOML -Value (Remove-GrokBlockFromLines $lines)
    Ok "grok models block removed: $($script:GROK_TOML)"
  } elseif ($lines -match '^\[subagents\.models\]') {
    Skip "unmanaged [subagents.models] in $($script:GROK_TOML) — not written by ai-tools, left untouched"
  } else {
    Ok "no grok models block in: $($script:GROK_TOML)"
  }
}

# --- Removal steps -----------------------------------------------------------

function Report-Links {
  # Read-only: what removal would touch.
  foreach ($root in Get-ScopedRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    foreach ($item in Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue) {
      $t = Get-LinkTarget $item.FullName
      if ($t -and (Test-AiToolsTarget $t)) { Info "linked: $($item.FullName) -> $t" }
      elseif (-not $t -and $item.Name -like '*-ai-tools*') { Info "possible copy: $($item.FullName)" }
    }
  }
  foreach ($h in $script:Scope) {
    $dest = Get-InstructionsDest $h
    if ($dest) {
      $t = Get-LinkTarget $dest
      if ($t) { Info "instructions: $dest -> $t" }
    }
  }
}

function Uninstall-Agents {
  foreach ($h in $script:Scope) {
    $src = Join-Path $script:AI_TOOLS "agents\$h"
    $root = Get-AgentsRoot $h
    if (-not (Test-Path -LiteralPath $src)) { continue }
    foreach ($f in Get-ChildItem -LiteralPath $src -File -Filter '*-ai-tools*') {
      $dest = Join-Path $root $f.Name
      if (Get-LinkTarget $dest) { [void](Safe-Unlink $dest) }
      elseif (Test-Path -LiteralPath $dest) { [void](Safe-UninstallCopy $dest $f.FullName) }
      else { Ok "absent: $dest" }
    }
  }
}

function Remove-Skills {
  foreach ($h in $script:Scope) {
    $root = Get-SkillsRoot $h
    if (-not (Test-Path -LiteralPath $root)) { continue }
    foreach ($p in Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'skills') -Directory -Filter '*-ai-tools' -ErrorAction SilentlyContinue) {
      $dest = Join-Path $root $p.Name
      if (Get-LinkTarget $dest) { [void](Safe-Unlink $dest) }
      elseif (Test-Path -LiteralPath $dest) { [void](Safe-UninstallCopy $dest $p.FullName) }
      else { Ok "absent: $dest" }
    }
  }
}

function Sweep-StaleLinks {
  # Alpha carries no backward compatibility: remove anything in the scoped roots
  # still resolving into ai-tools, whatever its name or era.
  foreach ($root in Get-ScopedRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    foreach ($item in Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue) {
      $t = Get-LinkTarget $item.FullName
      if ($t -and (Test-AiToolsTarget $t)) { [void](Safe-Unlink $item.FullName) }
    }
  }
  # Whole-directory links from an older alpha install (no-op on real directories)
  foreach ($root in @((Join-Path $HOME '.claude\agents'), (Join-Path $HOME '.grok\agents'))) {
    if (Get-LinkTarget $root) { [void](Safe-Unlink $root) }
  }
}

function Remove-Instructions {
  # Only harness destinations that are links into ai-tools. Never $HOME\AGENTS.md.
  $gemDest = Join-Path $HOME '.gemini\GEMINI.md'
  foreach ($h in $script:Scope) {
    $dest = Get-InstructionsDest $h
    if (-not $dest) { continue }
    if ($dest -eq $gemDest) {
      $other = if ($h -eq 'gemini') { 'antigravity' } else { 'gemini' }
      if ((Test-Harness $other) -and -not (In-Scope $other)) {
        Skip "GEMINI.md serves gemini and antigravity; $other not in scope: $dest kept"
        continue
      }
    }
    [void](Safe-Unlink $dest)
  }
}

function Purge-Clone([bool]$yes) {
  # Deletes $AI_TOOLS itself. Never $HOME\AGENTS.md.
  if (-not (Test-Path -LiteralPath $script:AI_TOOLS)) { Ok "absent: $($script:AI_TOOLS)"; return }
  if ($script:DryRun) { Ok "would delete: $($script:AI_TOOLS)"; return }
  if (-not $yes) {
    $answer = Read-Host "Delete $($script:AI_TOOLS) entirely? Type yes to confirm"
    if ($answer -ne 'yes') { Skip "purge not confirmed: $($script:AI_TOOLS) kept"; return }
  }
  Remove-Item -LiteralPath $script:AI_TOOLS -Recurse -Force
  Ok "deleted: $($script:AI_TOOLS)"
}

# --- Update steps ------------------------------------------------------------

function Refresh-Copies {
  # Copies do not track git; refresh those matching the previous revision ($Prev).
  # A copy matching neither revision is user work: skip and report.
  foreach ($h in $script:Scope) {
    $src = Join-Path $script:AI_TOOLS "agents\$h"
    $root = Get-AgentsRoot $h
    if (-not (Test-Path -LiteralPath $src)) { continue }
    foreach ($f in Get-ChildItem -LiteralPath $src -File -Filter '*-ai-tools*') {
      $dest = Join-Path $root $f.Name
      if (-not (Test-Path -LiteralPath $dest -PathType Leaf) -or (Get-LinkTarget $dest)) { continue }  # links track automatically
      if (Test-SameContent $dest $f.FullName) { Ok "copy up to date: $dest"; continue }
      $prevContent = $null
      if ($script:Prev) { $prevContent = & git -C $script:AI_TOOLS show "$($script:Prev):agents/$h/$($f.Name)" 2>$null }
      if ($prevContent -and (($prevContent -join "`n") -eq ((Get-Content -LiteralPath $dest) -join "`n"))) {
        if ($script:DryRun) { Ok "would refresh copy: $dest" }
        else { Copy-Item -LiteralPath $f.FullName -Destination $dest -Force; Ok "copy refreshed: $dest" }
      } else {
        Skip "copy modified locally (or predates $($script:Prev)): $dest — see README Troubleshooting"
      }
    }
  }
}

# --- Verification ------------------------------------------------------------

function Verify-Install([bool]$checkInstructions = $true) {
  if ($script:DryRun) { Info 'dry-run: verification skipped'; return }

  $size = (Get-Item (Join-Path $script:AI_TOOLS 'USER-AGENTS.md')).Length
  if ($size -le 12000) { Ok "instructions size: $size chars" }
  else { Warn "USER-AGENTS.md exceeds 12000 chars (Antigravity limit): $size" }

  if (Test-Path -LiteralPath $script:MODELS_MAP) { Ok "model map: $($script:MODELS_MAP)" }
  else { Warn "missing model map: $($script:MODELS_MAP) — agents and skills cannot resolve category models" }

  foreach ($base in Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'agents') -File -Filter '*-ai-tools.md') {
    Ok "agent base: $($base.FullName)"
  }

  if (Test-Path (Join-Path $HOME 'AGENTS.md')) { Ok "user overlay present: $(Join-Path $HOME 'AGENTS.md')" }
  else { Warn "missing user overlay: $(Join-Path $HOME 'AGENTS.md')" }

  if ($checkInstructions) {
    foreach ($h in $script:Scope) {
      $dest = Get-InstructionsDest $h
      if (-not $dest) { continue }
      $t = Get-LinkTarget $dest
      if ($t) {
        if (Test-AiToolsTarget $t) { Ok "instructions linked: $dest" }
        else { Warn "instructions link points elsewhere: $dest -> $t" }
      } elseif ((Test-Path -LiteralPath $dest) -and (Test-SameContent $dest (Join-Path $script:AI_TOOLS 'USER-AGENTS.md'))) {
        Ok "instructions copy: $dest"
      } elseif (Test-Path -LiteralPath $dest) {
        Warn "instructions differ from source: $dest"
      } else {
        Warn "instructions missing: $dest"
      }
    }
  }

  foreach ($h in $script:Scope) {
    $root = Get-AgentsRoot $h
    $src = Join-Path $script:AI_TOOLS "agents\$h"
    if (Test-Path -LiteralPath $src) {
      foreach ($f in Get-ChildItem -LiteralPath $src -File -Filter '*-ai-tools*') {
        $dest = Join-Path $root $f.Name
        if (Get-LinkTarget $dest) { Ok "agent link: $dest" }
        elseif ((Test-Path -LiteralPath $dest) -and (Test-SameContent $dest $f.FullName)) { Ok "agent copy: $dest" }
        elseif (Test-Path -LiteralPath $dest) { Warn "agent differs from source: $dest" }
        else { Warn "agent absent: $dest" }
      }
    }
    $root = Get-SkillsRoot $h
    foreach ($p in Get-ChildItem -LiteralPath (Join-Path $script:AI_TOOLS 'skills') -Directory -Filter '*-ai-tools' -ErrorAction SilentlyContinue) {
      if (Test-Path (Join-Path $root "$($p.Name)\SKILL.md")) { Ok "skill: $(Join-Path $root $p.Name)" }
      else { Warn "skill not installed or broken: $(Join-Path $root $p.Name)" }
    }
  }
}

function Verify-Removal {
  if ($script:DryRun) { Info 'dry-run: removal verification skipped'; return }
  $remaining = $false
  foreach ($root in Get-ScopedRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    foreach ($item in Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue) {
      $t = Get-LinkTarget $item.FullName
      if ($t -and (Test-AiToolsTarget $t)) { Warn "still linked: $($item.FullName) -> $t"; $remaining = $true }
    }
  }
  if (-not $remaining) { Ok 'no ai-tools links remain in the scoped roots' }
}
