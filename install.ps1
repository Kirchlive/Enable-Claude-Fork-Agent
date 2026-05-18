#!/usr/bin/env pwsh
# Enable-Claude-Fork-Agent installer (PowerShell)
# Sets CLAUDE_CODE_FORK_SUBAGENT=1 in ~/.claude/settings.json and installs all bundled skills.
#
# Requires PowerShell 7+. On Windows, install via:  winget install --id Microsoft.Powershell

$ErrorActionPreference = 'Stop'

$Required  = [version]'2.1.117'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $HOME '.claude'
$Settings  = Join-Path $ClaudeDir 'settings.json'
$SkillsDir = Join-Path $ClaudeDir 'skills'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup    = "$Settings.pre-fork-backup-$Timestamp"

Write-Host 'Enable-Claude-Fork-Agent installer'
Write-Host '=================================='
Write-Host ''

# ---- Step 0: Verify PowerShell version ----

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error @"
PowerShell 7+ required (detected: $($PSVersionTable.PSVersion)).
Install via:
  Windows: winget install --id Microsoft.Powershell
  macOS:   brew install --cask powershell
  Linux:   see https://learn.microsoft.com/powershell/scripting/install/installing-powershell
"@
    exit 1
}

# ---- Step 1: Verify Claude Code is installed and version >= 2.1.117 ----

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Error "'claude' CLI not found in PATH.`nInstall Claude Code first: https://code.claude.com/docs/en/install"
    exit 1
}

try {
    $versionLine = (& claude --version 2>$null) | Select-Object -First 1
    if ($versionLine -match '(\d+)\.(\d+)\.(\d+)') {
        $detected = [version]"$($Matches[1]).$($Matches[2]).$($Matches[3])"
        if ($detected -lt $Required) {
            Write-Error "Claude Code $detected detected, but $Required+ is required for fork mode.`nUpdate via: claude --update  (or your install method)"
            exit 1
        }
        Write-Host "Claude Code version: $detected (OK)"
    } else {
        Write-Warning 'Could not detect Claude Code version. Proceeding anyway.'
    }
} catch {
    Write-Warning "Could not run 'claude --version'. Proceeding anyway."
}

# ---- Step 2: Backup existing settings.json ----

New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

if (Test-Path $Settings) {
    Copy-Item -Path $Settings -Destination $Backup
    Write-Host "Backed up existing settings to: $Backup"
} else {
    Write-Host 'No existing settings.json — will create a new one.'
}

# ---- Step 3: Merge env.CLAUDE_CODE_FORK_SUBAGENT=1 (preserves everything else) ----

$data = @{}

if ((Test-Path $Settings) -and ((Get-Item $Settings).Length -gt 0)) {
    $raw = Get-Content -Path $Settings -Raw

    # Best-effort duplicate top-level key detection via brace-depth tracking.
    $pattern = '(?m)^[ \t]+"([^"\\]+)"\s*:'
    $topLevelKeys = @()
    foreach ($match in [regex]::Matches($raw, $pattern)) {
        $depth = 0
        $inString = $false
        $escaped = $false
        for ($i = 0; $i -lt $match.Index; $i++) {
            $c = $raw[$i]
            if ($escaped) { $escaped = $false; continue }
            if ($c -eq '\') { $escaped = $true; continue }
            if ($c -eq '"') { $inString = -not $inString; continue }
            if (-not $inString) {
                if ($c -eq '{') { $depth++ }
                elseif ($c -eq '}') { $depth-- }
            }
        }
        if ($depth -eq 1) {
            $topLevelKeys += $match.Groups[1].Value
        }
    }

    $dupes = $topLevelKeys | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
    if ($dupes) {
        Write-Error "settings.json contains duplicate top-level keys: $($dupes -join ', ')`nFix the duplicate keys manually before re-running this installer."
        exit 1
    }

    try {
        $data = $raw | ConvertFrom-Json -AsHashtable
        if ($null -eq $data) { $data = @{} }
    } catch {
        Write-Error "existing settings.json is not valid JSON: $_"
        exit 1
    }
}

if (-not $data.ContainsKey('env') -or ($data['env'] -isnot [hashtable])) {
    $data['env'] = @{}
}
$data['env']['CLAUDE_CODE_FORK_SUBAGENT'] = '1'

$json = $data | ConvertTo-Json -Depth 32
Set-Content -Path $Settings -Value $json -Encoding UTF8 -NoNewline
Add-Content -Path $Settings -Value "`n" -NoNewline

Write-Host "Merged CLAUDE_CODE_FORK_SUBAGENT=1 into $Settings"

# ---- Step 4: Install all bundled skills (auto-discovered) ----

$SkillsBase = Join-Path $ScriptDir 'skills'

if (-not (Test-Path $SkillsBase)) {
    Write-Error "skills directory not found at $SkillsBase`n(Are you running install.ps1 from the repo root?)"
    exit 1
}

$InstalledCount = 0
foreach ($skillDirInfo in Get-ChildItem -Path $SkillsBase -Directory) {
    $skillName = $skillDirInfo.Name
    $skillFile = Join-Path $skillDirInfo.FullName 'SKILL.md'
    if (-not (Test-Path $skillFile)) {
        Write-Host "  skip $skillName (no SKILL.md)"
        continue
    }
    $skillDest = Join-Path $SkillsDir $skillName
    New-Item -ItemType Directory -Path $skillDest -Force | Out-Null
    Copy-Item -Path $skillFile -Destination (Join-Path $skillDest 'SKILL.md') -Force
    Write-Host "Installed skill: $(Join-Path $skillDest 'SKILL.md')"
    $InstalledCount++
}

if ($InstalledCount -eq 0) {
    Write-Error "no skills found to install in $SkillsBase"
    exit 1
}

# ---- Done ----

Write-Host ''
Write-Host "Installation complete. $InstalledCount skill(s) installed."
Write-Host ''
Write-Host 'Next steps:'
Write-Host '  1. Restart Claude Code (close and reopen — settings load at process startup)'
Write-Host '  2. In a fresh session, run /skills — installed skills should be listed'
Write-Host '  3. Try /fork — the slash command should now be available'
Write-Host "  4. Test: 'Spawn an agent that searches my repo for X'"
Write-Host "     The agent indicator should show 'fork' instead of 'general-purpose'"
Write-Host ''
Write-Host 'Recommended next step for projects using parallel fork fan-outs:'
Write-Host "  Add '.claude/worktrees/' to your project's .gitignore."
Write-Host '  (Worktree forks create nested .git directories that should be excluded.)'
Write-Host ''
Write-Host 'To uninstall:'
Write-Host "  Copy-Item '$Backup' '$Settings'"
foreach ($skillDirInfo in Get-ChildItem -Path $SkillsBase -Directory) {
    $skillName = $skillDirInfo.Name
    $skillFile = Join-Path $skillDirInfo.FullName 'SKILL.md'
    if (Test-Path $skillFile) {
        Write-Host "  Remove-Item -Recurse -Force '$(Join-Path $SkillsDir $skillName)'"
    }
}
