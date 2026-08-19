# ai-tools sandboxed test helpers (PowerShell) — dot-sourced by tools/test.ps1,
# after scripts/powershell/lib.ps1, and in scope for every case file under
# tools/test/. Mirrors tools/test/lib.sh (canonical, README rule 24).
#
# Every helper here is T- prefixed so nothing shadows a name already owned
# by scripts/powershell/lib.ps1 (Get-LinkTarget, Safe-Link, Ok, Warn, Fatal,
# ...). Helpers are file-scope with no trailing "main" block, so a sibling
# stage can append T-OriginCommit here cleanly.
#
# Sandbox safety is this file's first requirement: T-Run and T-RunStdin
# refuse to run anything unless T-SandboxGuard passes: the sandbox root is
# non-empty, is not a filesystem root, and both HOME and AI_TOOLS resolve
# under it. A HOME that escaped the sandbox would run scripts against the
# caller's real installation — this guard is what makes the suite safe to
# run on a maintainer's machine.

$script:T_Case = ''
$script:T_LastExit = 0
$script:T_LastOutput = ''
$script:T_Root = ''
$script:T_ForeignAgentPath = ''
$script:T_ForeignInstructionsPath = ''
$script:T_ModifiedCopyPath = ''
$script:T_GrokUnmanagedPath = ''
$script:T_StaleLinkPath = ''
$script:T_ExternalSymlinkPath = ''

# --- Fixture -------------------------------------------------------------

$script:T_HARNESS_DIRS = @(
  '.claude\agents', '.claude\skills',
  '.grok\agents', '.grok\skills',
  '.codex\agents', '.codex\skills',
  '.copilot\agents', '.copilot\skills', '.copilot\instructions',
  '.cursor\agents', '.cursor\skills',
  '.gemini\agents', '.gemini\skills', '.gemini\config\agents', '.gemini\config\skills'
)

function T-BuildOrigin([string]$OriginDir) {
  # usage: T-BuildOrigin <origin-git-dir>
  # Copies the working tree (excluding .git and plans\, top level only, like
  # the shell side's tar --exclude) into a scratch commit and pushes it to a
  # fresh bare repo at <origin-git-dir>. The tree under test is the *working*
  # tree, including any uncommitted change.
  $scratch = Join-Path $env:TEMP ('ai-tools-test-src-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $scratch -Force | Out-Null

  & git init -q --bare $OriginDir
  if ($LASTEXITCODE -ne 0) { Fatal "T-BuildOrigin: git init --bare failed: $OriginDir" }
  & git -C $OriginDir symbolic-ref HEAD refs/heads/master
  if ($LASTEXITCODE -ne 0) { Fatal "T-BuildOrigin: symbolic-ref failed: $OriginDir" }

  Get-ChildItem -LiteralPath $script:AI_TOOLS -Force |
    Where-Object { $_.Name -ne '.git' -and $_.Name -ne 'plans' } |
    Copy-Item -Destination $scratch -Recurse -Force

  & git -C $scratch init -q
  if ($LASTEXITCODE -ne 0) { Remove-Item -LiteralPath $scratch -Recurse -Force; Fatal "T-BuildOrigin: git init failed: $scratch" }
  & git -C $scratch symbolic-ref HEAD refs/heads/master
  & git -C $scratch config user.name 'ai-tools test'
  & git -C $scratch config user.email 'test@example.invalid'
  & git -C $scratch add -A
  & git -C $scratch commit -q -m 'fixture origin'
  if ($LASTEXITCODE -ne 0) { Remove-Item -LiteralPath $scratch -Recurse -Force; Fatal "T-BuildOrigin: git commit failed: $scratch" }
  & git -C $scratch remote add origin $OriginDir
  & git -C $scratch push -q origin master
  if ($LASTEXITCODE -ne 0) { Remove-Item -LiteralPath $scratch -Recurse -Force; Fatal "T-BuildOrigin: git push failed: $OriginDir" }

  Remove-Item -LiteralPath $scratch -Recurse -Force
}

function T-Fixture {
  # usage: T-Fixture [-ForeignAgent] [-ForeignInstructions] [-ModifiedCopy]
  #                   [-UnmanagedGrokBlock] [-StaleLink] [-ExternalSymlink]
  # Builds a disposable sandbox under $env:TEMP and sets $script:T_Root to
  # its root. Each switch stages one opt-in conflict and records its path in
  # a $script:T_* variable the calling case can read.
  param(
    [switch]$ForeignAgent,
    [switch]$ForeignInstructions,
    [switch]$ModifiedCopy,
    [switch]$UnmanagedGrokBlock,
    [switch]$StaleLink,
    [switch]$ExternalSymlink
  )

  $root = Join-Path $env:TEMP ('ai-tools-test.' + [guid]::NewGuid().ToString('N').Substring(0, 12))
  New-Item -ItemType Directory -Path $root -Force | Out-Null
  $script:T_Root = $root
  $homeDir = Join-Path $root 'home'
  $origin = Join-Path $root 'origin.git'
  New-Item -ItemType Directory -Path $homeDir -Force | Out-Null

  foreach ($dir in $script:T_HARNESS_DIRS) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir $dir) -Force | Out-Null
  }

  T-BuildOrigin $origin

  & git clone -q $origin (Join-Path $homeDir '.ai-tools') 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { Fatal "T-Fixture: cannot clone fixture origin into $homeDir\.ai-tools" }

  $originUri = 'file:///' + ($origin -replace '\\', '/')
  @(
    '[user]'
    "`tname = ai-tools test"
    "`temail = test@example.invalid"
    "[url `"$originUri`"]"
    "`tinsteadOf = https://github.com/hgsantana/ai-tools.git"
  ) | Set-Content -LiteralPath (Join-Path $homeDir '.gitconfig')

  $script:T_ForeignAgentPath = ''
  $script:T_ForeignInstructionsPath = ''
  $script:T_ModifiedCopyPath = ''
  $script:T_GrokUnmanagedPath = ''
  $script:T_StaleLinkPath = ''
  $script:T_ExternalSymlinkPath = ''

  if ($ForeignAgent) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir '.claude\agents') -Force | Out-Null
    $script:T_ForeignAgentPath = Join-Path $homeDir '.claude\agents\planner-ai-tools.md'
    Set-Content -LiteralPath $script:T_ForeignAgentPath -Value 'not an ai-tools file'
  }
  if ($ForeignInstructions) {
    $script:T_ForeignInstructionsPath = Join-Path $homeDir '.claude\CLAUDE.md'
    Set-Content -LiteralPath $script:T_ForeignInstructionsPath -Value 'not an ai-tools file'
  }
  if ($ModifiedCopy) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir '.claude\agents') -Force | Out-Null
    $script:T_ModifiedCopyPath = Join-Path $homeDir '.claude\agents\maintainer-ai-tools.md'
    Copy-Item -LiteralPath (Join-Path $homeDir '.ai-tools\agents\claude-code\maintainer-ai-tools.md') -Destination $script:T_ModifiedCopyPath
    Add-Content -LiteralPath $script:T_ModifiedCopyPath -Value "`nlocal edit that matches no revision"
  }
  if ($UnmanagedGrokBlock) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir '.grok') -Force | Out-Null
    $script:T_GrokUnmanagedPath = Join-Path $homeDir '.grok\config.toml'
    Add-Content -LiteralPath $script:T_GrokUnmanagedPath -Value @('[subagents.models]', 'some-other-agent = "some-model"')
  }
  if ($StaleLink) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir '.claude\agents') -Force | Out-Null
    $script:T_StaleLinkPath = Join-Path $homeDir '.claude\agents\old-layout-ai-tools.md'
    New-Item -ItemType SymbolicLink -Path $script:T_StaleLinkPath -Target (Join-Path $homeDir '.ai-tools\agents\claude-code\planner-ai-tools.md') | Out-Null
  }
  if ($ExternalSymlink) {
    New-Item -ItemType Directory -Path (Join-Path $homeDir '.claude\agents') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $root 'external-file.md') -Value 'outside ai-tools'
    $script:T_ExternalSymlinkPath = Join-Path $homeDir '.claude\agents\orchestrator-ai-tools.md'
    New-Item -ItemType SymbolicLink -Path $script:T_ExternalSymlinkPath -Target (Join-Path $root 'external-file.md') | Out-Null
  }
}

function T-Cleanup([string]$Root) {
  # usage: T-Cleanup <sandbox-root> -- removes the sandbox unless -Keep.
  # Removal target must sit directly under $env:TEMP with the "ai-tools-test."
  # prefix T-Fixture used.
  $label = if ($script:T_Case) { $script:T_Case } else { 'T-Cleanup' }
  if ($script:T_Keep) { Info "${label}: sandbox kept: $Root"; return }
  $parent = Split-Path -Parent $Root
  $leaf = Split-Path -Leaf $Root
  if ($parent -eq $env:TEMP -and $leaf -like 'ai-tools-test.*') {
    Remove-Item -LiteralPath $Root -Recurse -Force -ErrorAction SilentlyContinue
  } else {
    Warn "${label}: refusing to remove unexpected sandbox path: $Root"
  }
}

# --- Sandboxed runner ------------------------------------------------------

function T-SandboxGuard([string]$Root, [string]$HomeDir, [string]$AiTools) {
  # usage: T-SandboxGuard <root> <home> <ai_tools>
  # Fatal (exit 1) before anything executes unless every path is confined to
  # the sandbox root. This is the suite's single most important check.
  if (-not $Root) { Fatal 'T-SandboxGuard: sandbox root is empty' }
  if ($Root -eq '\' -or $Root -eq '/' -or $Root -match '^[A-Za-z]:\\?$') { Fatal "T-SandboxGuard: sandbox root is a filesystem root: $Root" }
  if (-not ($HomeDir -like "$Root\*" -or $HomeDir -like "$Root/*")) { Fatal "T-SandboxGuard: HOME escaped the sandbox: $HomeDir (root: $Root)" }
  if (-not ($AiTools -like "$Root\*" -or $AiTools -like "$Root/*")) { Fatal "T-SandboxGuard: AI_TOOLS escaped the sandbox: $AiTools (root: $Root)" }
}

function T-PsQuote([string]$s) {
  return "'" + ($s -replace "'", "''") + "'"
}

function T-InvokeUnderSandbox([string]$HomeDir, [string]$Script, [string[]]$ScriptArgs, [string]$StdinText) {
  # Shared by T-Run/T-RunStdin: runs <script> with the sandbox HOME, using
  # whichever override form T-DetectHomeOverrideForm proved works for
  # $script:T_Runner (set once in tools/test.ps1, step 3 — never proceed
  # without that proof). Sets $script:T_LastExit / $script:T_LastOutput.
  $savedHome = $env:HOME; $savedUserProfile = $env:USERPROFILE
  $savedHomeDrive = $env:HOMEDRIVE; $savedHomePath = $env:HOMEPATH
  $savedAiTools = $env:AI_TOOLS
  try {
    $homeRoot = [System.IO.Path]::GetPathRoot($HomeDir).TrimEnd('\')
    $env:HOME = $HomeDir
    $env:USERPROFILE = $HomeDir
    $env:HOMEDRIVE = $homeRoot
    $env:HOMEPATH = $HomeDir.Substring($homeRoot.Length)
    $env:AI_TOOLS = Join-Path $HomeDir '.ai-tools'
    $env:GIT_TERMINAL_PROMPT = '0'
    $env:GIT_CONFIG_NOSYSTEM = '1'

    if ($script:T_HomeForm -eq 'env') {
      if ($StdinText) { $out = $StdinText | & $script:T_Runner -NoProfile -File $Script @ScriptArgs 2>&1 | Out-String }
      else { $out = & $script:T_Runner -NoProfile -File $Script @ScriptArgs 2>&1 | Out-String }
    } else {
      $argsLiteral = (@($ScriptArgs) | ForEach-Object { T-PsQuote $_ }) -join ' '
      $cmd = "& { `$HOME = $(T-PsQuote $HomeDir); & $(T-PsQuote $Script) $argsLiteral }"
      if ($StdinText) { $out = $StdinText | & $script:T_Runner -NoProfile -Command $cmd 2>&1 | Out-String }
      else { $out = & $script:T_Runner -NoProfile -Command $cmd 2>&1 | Out-String }
    }
    $script:T_LastExit = $LASTEXITCODE
    $script:T_LastOutput = $out
  } finally {
    $env:HOME = $savedHome
    $env:USERPROFILE = $savedUserProfile
    $env:HOMEDRIVE = $savedHomeDrive
    $env:HOMEPATH = $savedHomePath
    $env:AI_TOOLS = $savedAiTools
  }
}

function T-Run([string]$Root, [string]$Script) {
  # usage: T-Run <root> <script> [args...]
  # Runs one script confined to the sandbox; captured output and exit code
  # land in $script:T_LastOutput / $script:T_LastExit.
  $scriptArgs = $args
  $homeDir = Join-Path $Root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  T-SandboxGuard $Root $homeDir $aiTools
  T-InvokeUnderSandbox $homeDir $Script $scriptArgs $null
}

function T-RunStdin([string]$Root, [string]$InputText, [string]$Script) {
  # usage: T-RunStdin <root> <stdin-string> <script> [args...]
  # Same as T-Run, feeding <stdin-string> on stdin (for Purge-Clone's
  # Read-Host confirmation).
  $scriptArgs = $args
  $homeDir = Join-Path $Root 'home'
  $aiTools = Join-Path $homeDir '.ai-tools'
  T-SandboxGuard $Root $homeDir $aiTools
  T-InvokeUnderSandbox $homeDir $Script $scriptArgs $InputText
}

# --- Assertions --------------------------------------------------------------
# Each reports through Ok/Warn with the case name and the offending value;
# none aborts the suite.

function T-AssertExit([int]$Expected) {
  if ($script:T_LastExit -eq $Expected) { Ok "$($script:T_Case): exit $Expected" }
  else { Warn "$($script:T_Case): expected exit $Expected, got $($script:T_LastExit)" }
}

function T-AssertLine([string]$Pattern) {
  if ($script:T_LastOutput -and $script:T_LastOutput.Contains($Pattern)) { Ok "$($script:T_Case): output contains: $Pattern" }
  else { Warn "$($script:T_Case): output missing: $Pattern" }
}

function T-AssertNoLine([string]$Pattern) {
  if ($script:T_LastOutput -and $script:T_LastOutput.Contains($Pattern)) { Warn "$($script:T_Case): output unexpectedly contains: $Pattern" }
  else { Ok "$($script:T_Case): output does not contain: $Pattern" }
}

function T-AssertSymlink([string]$Path, [string]$Prefix) {
  $target = Get-LinkTarget $Path
  if ($target) {
    if ($target.StartsWith($Prefix)) { Ok "$($script:T_Case): symlink: $Path -> $target" }
    else { Warn "$($script:T_Case): symlink target unexpected: $Path -> $target (want prefix: $Prefix)" }
  } else {
    Warn "$($script:T_Case): not a symlink: $Path"
  }
}

function T-AssertRegularFile([string]$Path) {
  if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not (Get-LinkTarget $Path)) { Ok "$($script:T_Case): regular file: $Path" }
  else { Warn "$($script:T_Case): not a regular file: $Path" }
}

function T-AssertAbsent([string]$Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if (-not $item) { Ok "$($script:T_Case): absent: $Path" }
  else { Warn "$($script:T_Case): unexpectedly present: $Path" }
}

function T-AssertContent([string]$Path, [string]$Expected) {
  if ((Test-Path -LiteralPath $Path -PathType Leaf) -and (Select-String -LiteralPath $Path -SimpleMatch -Pattern $Expected -Quiet)) {
    Ok "$($script:T_Case): content matches: $Path"
  } else {
    Warn "$($script:T_Case): content mismatch: $Path (want: $Expected)"
  }
}

function T-CollectEntries([string]$Path) {
  # Walks <path> like `find` does by default: symlinked directories are
  # recorded as entries but never descended into (Get-ChildItem -Recurse
  # would follow them on some hosts, unlike GNU find). <path> itself may be
  # a single file, matching how some callers snapshot one file.
  $result = New-Object System.Collections.Generic.List[string]
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if (-not $item) { return $result }
  if (-not $item.PSIsContainer) { $result.Add($item.FullName); return $result }

  $stack = New-Object System.Collections.Generic.Stack[string]
  $stack.Push($item.FullName)
  while ($stack.Count -gt 0) {
    $dir = $stack.Pop()
    foreach ($child in Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue) {
      $isLink = [bool](Get-LinkTarget $child.FullName)
      if ($child.PSIsContainer -and -not $isLink) { $stack.Push($child.FullName) }
      else { $result.Add($child.FullName) }
    }
  }
  return $result
}

function T-Snapshot([string]$Dir) {
  # usage: T-Snapshot <dir> -- echoes the path to a manifest file: a sorted
  # entry listing plus each entry's content (or link target), concatenated.
  # Comparing two snapshots by hash is a cheap "did anything change" check.
  $entries = @(T-CollectEntries $Dir) | Sort-Object
  $lines = New-Object System.Collections.Generic.List[string]
  foreach ($full in $entries) { $lines.Add($full.Substring($Dir.Length).TrimStart('\', '/')) }
  $lines.Add('---')
  foreach ($full in $entries) {
    $t = Get-LinkTarget $full
    if ($t) { $lines.Add($t) }
    else {
      try { $lines.Add([System.IO.File]::ReadAllText($full)) } catch { $lines.Add('') }
    }
  }
  $snap = Join-Path $env:TEMP ('ai-tools-test-snap.' + [guid]::NewGuid().ToString('N').Substring(0, 12))
  Set-Content -LiteralPath $snap -Value ($lines -join "`n") -NoNewline
  return $snap
}

function T-AssertUnchanged([string]$Dir, [string]$Before) {
  # usage: T-AssertUnchanged <dir> <snapshot-path> -- <snapshot-path> is a
  # path previously returned by T-Snapshot, taken before the run under test.
  $after = T-Snapshot $Dir
  if ((Get-FileHash -LiteralPath $Before).Hash -eq (Get-FileHash -LiteralPath $after).Hash) {
    Ok "$($script:T_Case): unchanged: $Dir"
  } else {
    Warn "$($script:T_Case): changed: $Dir"
  }
  Remove-Item -LiteralPath $after -Force -ErrorAction SilentlyContinue
}

# --- Origin mutation (stage 6: update contract) ---------------------------

function T-OriginCommit([string]$Label) {
  # usage: T-OriginCommit <label>
  # Clones the fixture's bare origin ($script:T_Root\origin.git) into a
  # scratch dir, makes one deterministic change -- appends a marker line to
  # agents\claude-code\maintainer-ai-tools.md and adds a new
  # skills\<label>-ai-tools\SKILL.md wrapper plus its skills\<label>-ai-tools.md
  # base (the three-part layout the repo actually ships; verify_install warns
  # on a wrapper with no base) -- commits, and pushes to master, giving the
  # fixture's clone something new to update to. Mirrors t_origin_commit
  # (tools/test/lib.sh, stage 4). Returns nothing; the caller already knows
  # the paths it named via <label>.
  $origin = Join-Path $script:T_Root 'origin.git'
  $scratch = Join-Path $env:TEMP ('ai-tools-test-origin-commit-' + [guid]::NewGuid().ToString('N').Substring(0, 12))

  & git clone -q $origin $scratch 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { Fatal "T-OriginCommit: cannot clone $origin" }
  & git -C $scratch config user.name 'ai-tools test'
  if ($LASTEXITCODE -ne 0) { Fatal 'T-OriginCommit: git config user.name failed' }
  & git -C $scratch config user.email 'test@example.invalid'
  if ($LASTEXITCODE -ne 0) { Fatal 'T-OriginCommit: git config user.email failed' }

  Add-Content -LiteralPath (Join-Path $scratch 'agents\claude-code\maintainer-ai-tools.md') `
    -Value "`n<!-- t_origin_commit marker: $Label -->"

  $skillDir = Join-Path $scratch "skills\$Label-ai-tools"
  New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
  @(
    '---'
    "name: $Label-ai-tools"
    "description: test-only skill added by T-OriginCommit for marker $Label."
    '---'
    ''
    "# $Label"
    ''
    "Test-only skill wrapper. Base: skills/$Label-ai-tools.md. Never shipped."
  ) | Set-Content -LiteralPath (Join-Path $skillDir 'SKILL.md')
  @(
    "Test-only skill base, added by T-OriginCommit for marker $Label. Never shipped."
  ) | Set-Content -LiteralPath (Join-Path $scratch "skills\$Label-ai-tools.md")

  & git -C $scratch add -A
  if ($LASTEXITCODE -ne 0) { Fatal 'T-OriginCommit: git add failed' }
  & git -C $scratch commit -q -m "t_origin_commit: $Label"
  if ($LASTEXITCODE -ne 0) { Fatal 'T-OriginCommit: git commit failed' }
  & git -C $scratch push -q origin master
  if ($LASTEXITCODE -ne 0) { Fatal 'T-OriginCommit: git push failed' }

  Remove-Item -LiteralPath $scratch -Recurse -Force
}
