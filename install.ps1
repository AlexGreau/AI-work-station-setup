# Workstation setup for Claude Code / Zed on Windows.
#
# Usage (from the repo folder, in PowerShell):
#   .\install.ps1                         # install skills for all projects (~\.claude\skills)
#   .\install.ps1 -Project C:\code\myrepo  # install skills into one project only
#   .\install.ps1 -SkipZed                 # don't touch Zed settings
#
# If scripts are blocked, run once:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

param(
    [string]$Project = "",
    [switch]$SkipZed
)

$ErrorActionPreference = "Stop"
$RepoDir = $PSScriptRoot

# --- Skills ---------------------------------------------------------------
if ($Project) {
    $SkillsTarget = Join-Path (Resolve-Path $Project) ".claude\skills"
} else {
    $SkillsTarget = Join-Path $HOME ".claude\skills"
}
New-Item -ItemType Directory -Force $SkillsTarget | Out-Null

Get-ChildItem (Join-Path $RepoDir "skills") -Directory | ForEach-Object {
    $dest = Join-Path $SkillsTarget $_.Name
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse $_.FullName $dest
    Write-Host "  skill: $($_.Name)"
}
Write-Host "Skills installed to $SkillsTarget"

# --- Settings + plugins (merged into ~/.claude/settings.json; Claude installs plugins on next start) ---
$ClaudeSettings = Join-Path $HOME ".claude\settings.json"
$repoSettings = Get-Content -Raw (Join-Path $RepoDir "claude\settings.json") | ConvertFrom-Json
if (Test-Path $ClaudeSettings) {
    Copy-Item $ClaudeSettings "$ClaudeSettings.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    $settings = Get-Content -Raw $ClaudeSettings | ConvertFrom-Json
} else {
    New-Item -ItemType Directory -Force (Split-Path $ClaudeSettings) | Out-Null
    $settings = [pscustomobject]@{}
}
# Objects (enabledPlugins, extraKnownMarketplaces) merge one level deep; plain values overwrite.
foreach ($p in $repoSettings.PSObject.Properties) {
    if ($p.Value -is [pscustomobject] -and $settings.($p.Name) -is [pscustomobject]) {
        foreach ($sub in $p.Value.PSObject.Properties) {
            $settings.($p.Name) | Add-Member -NotePropertyName $sub.Name -NotePropertyValue $sub.Value -Force
        }
    } else {
        $settings | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
    }
}
# WriteAllText: PS 5.1 Set-Content -Encoding utf8 adds a BOM
[IO.File]::WriteAllText($ClaudeSettings, ($settings | ConvertTo-Json -Depth 20))
Write-Host "Settings and plugins merged into $ClaudeSettings"

# --- Zed settings ---------------------------------------------------------
if (-not $SkipZed) {
    $ZedDir = Join-Path $env:APPDATA "Zed"
    $ZedSettings = Join-Path $ZedDir "settings.json"
    New-Item -ItemType Directory -Force $ZedDir | Out-Null

    if (Test-Path $ZedSettings) {
        $backup = "$ZedSettings.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Copy-Item $ZedSettings $backup
        Write-Host "Backed up existing Zed settings to $backup"
    }
    Copy-Item (Join-Path $RepoDir "zed\settings.windows.json") $ZedSettings -Force
    Write-Host "Zed settings installed to $ZedSettings"

    if (-not (Test-Path "C:\Program Files\Git\bin\bash.exe")) {
        Write-Warning "Git Bash not found. Install Git for Windows (https://git-scm.com) or edit terminal.shell in Zed settings."
    }
}

Write-Host ""
Write-Host "Done. Restart Zed, start a Claude Agent thread, and run /login once on this machine."
