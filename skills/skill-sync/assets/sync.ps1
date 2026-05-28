#!/usr/bin/env pwsh
# skill-sync: Sync skill metadata to AGENTS.md Auto-invoke sections
# Usage: ./sync.ps1 [-DryRun] [-Scope <scope>]
# Works on Windows, macOS, Linux (PowerShell cross-platform)
#
# Features:
# - Auto-generates metadata for skills missing it (scope, auto_invoke)
# - Updates AGENTS.md Auto-invoke sections from skill metadata
# - Supports DryRun mode

param(
    [switch]$DryRun,
    [switch]$AutoAddMetadata,  # Auto-add metadata to skills missing it
    [string]$Scope = ""
)

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_ROOT = Split-Path (Split-Path (Split-Path $SCRIPT_DIR -Parent) -Parent)
$SKILLS_DIR = Join-Path $REPO_ROOT "skills"

function Get-AgentsPath {
    param([string]$scope)
    switch ($scope) {
        "root"     { return Join-Path $REPO_ROOT "AGENTS.md" }
        "frontend" { return Join-Path $REPO_ROOT "apps\frontend\AGENTS.md" }
        "backend"  { return Join-Path $REPO_ROOT "apps\backend\AGENTS.md" }
        default    { return "" }
    }
}

function Extract-Field {
    param([string]$file, [string]$field)
    $content = Get-Content $file -Raw
    if ($content -match "(?s)^---\r?\n(.*?)\r?\n---") {
        $frontmatter = $matches[1]
        $pattern = "(?m)^$field`:(\s*)(.*)$"
        if ($frontmatter -match $pattern) {
            $value = $matches[2].Trim()
            return $value.Trim('"', "'")
        }
    }
    return ""
}

function Extract-Metadata {
    param([string]$file, [string]$field)
    $content = Get-Content $file -Raw

    if ($content -notmatch '(?s)^---\r?\n(.*?)\r?\n---') { return "" }
    $frontmatter = $matches[1]

    if ($frontmatter -notmatch '(?s)(?:^|\n)metadata:\s*\n((?:[ ]{1,4}.+\n)*)') {
        $pattern = "(?m)^metadata:\s*\n\s{0,4}(.*?)(?:\n[^\s]|$)"
        if ($frontmatter -match $pattern) {
            $metaBlock = $matches[1]
            return Extract-MetadataFromBlock $metaBlock $field
        }
        return ""
    }

    $metaBlock = $matches[1]
    return Extract-MetadataFromBlock $metaBlock $field
}

function Extract-MetadataFromBlock {
    param([string]$block, [string]$field)

    $pattern = "(?m)^$field`:\s*\n"
    if ($block -notmatch $pattern) { return "" }

    $afterMatch = $block.Substring($block.IndexOf($matches[0]) + $matches[0].Length)

    if ($afterMatch -match '^[^\n]+' -and $matches[0] -notmatch '^\s+[-*]') {
        $value = $matches[0].Trim()
        $value = $value.Trim('"', "'")
        if ($value -ne ">" -and $value.Length -gt 0) { return $value }
    }

    $lines = @()
    foreach ($line in ($afterMatch -split '\r?\n')) {
        if ($line -match '^(\s*)-\s+(.*)') {
            $value = $matches[2].Trim().Trim('"', "'")
            if ($value.Length -gt 0) { $lines += $value }
        } elseif ($line -match '^\s*[a-z]' -and $line -notmatch '^\s+') {
            break
        }
    }

    if ($lines.Count -gt 0) {
        return ($lines -join "|")
    }
    return ""
}

function Add-MissingMetadata {
    param([string]$skillFile, [string]$skillName)

    $content = Get-Content $skillFile -Raw

    # Check if metadata block exists
    $hasMetadata = $content -match '(?s)^---\r?\n.*?\n---'

    $frontmatter = ""
    $body = ""

    if ($content -match '(?s)^(---\r?\n)(.*?)(\r?\n---)(.*)') {
        $frontmatter = $matches[2]
        $body = $matches[4]
    } else {
        # No frontmatter at all - create it
        $body = $content
        $frontmatter = ""
    }

    $needsScope = $frontmatter -notmatch '(?m)^scope`:'
    $needsAutoInvoke = $frontmatter -notmatch '(?m)^auto_invoke`:'

    if (-not $needsScope -and -not $needsAutoInvoke) {
        return $false  # Nothing to add
    }

    $newLines = @()
    $added = $false

    # Parse existing metadata lines
    $metaLines = @()
    $inMetadata = $false
    $metaIndent = ""

    if ($frontmatter -match '(?m)^metadata:') {
        $inMetadata = $true
        # Find indent level
        $metaStart = $frontmatter -match '(?m)^(metadata):'
        $metaIndent = if ($matches[1] -match '^(\s*)') { $matches[1] } else { "" }
    }

    if ($needsScope) {
        $newLines += "  scope: [root]"
        $added = $true
        Write-Host "  [AUTO] Added scope: [root]" -Foreground Cyan
    }

    if ($needsAutoInvoke) {
        $newLines += "  auto_invoke:"
        $newLines += "    - ""$skillName"""
        $added = $true
        Write-Host "  [AUTO] Added auto_invoke: ""$skillName""" -Foreground Cyan
    }

    if ($added) {
        if ($inMetadata) {
            # Insert new lines after "metadata:" line
            $frontmatter = $frontmatter -replace '(?m)^(metadata:\s*)$', "`$1`n" + ($newLines -join "`n")
        } else {
            # Add metadata block after first ---
            $metaBlock = "`nmetadata:`n" + ($newLines -join "`n") + "`n"
            $frontmatter = $frontmatter + $metaBlock
        }

        $newContent = "---`n" + $frontmatter + "---`n" + $body
        Set-Content -Path $skillFile -Value $newContent -NoNewline
    }

    return $added
}

Write-Host "Skill Sync - Updating AGENTS.md Auto-invoke sections"
Write-Host "========================================================"
Write-Host ""

$skillFiles = Get-ChildItem -Path $SKILLS_DIR -Recurse -Filter "SKILL.md" -Depth 2 | Where-Object {
    $_.Directory.Name -ne "assets" -and $_.Directory.Name -ne "references" -and $_.Directory.Name -ne "scripts"
}

$scopeTable = @{}

# Phase 1: Auto-add metadata if requested
if ($AutoAddMetadata) {
    Write-Host "Phase 1: Auto-adding metadata to skills missing it"
    Write-Host "----------------------------------------------------"

    foreach ($skillFile in $skillFiles | Sort-Object FullName) {
        $skillName = Extract-Field $skillFile.FullName "name"
        $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
        $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"

        if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) {
            Write-Host "Skill: $skillName" -Foreground Yellow
            if (-not $DryRun) {
                $added = Add-MissingMetadata $skillFile.FullName $skillName
                if (-not $added) {
                    Write-Host "  [SKIP] Already has metadata" -Foreground Gray
                }
            } else {
                if ([string]::IsNullOrEmpty($scopeRaw)) {
                    Write-Host "  [DRY] Would add scope: [root]" -Foreground Cyan
                }
                if ([string]::IsNullOrEmpty($autoInvokeRaw)) {
                    Write-Host "  [DRY] Would add auto_invoke: ""$skillName""" -Foreground Cyan
                }
            }
        }
    }

    Write-Host ""
}

# Phase 2: Build scope table from metadata
Write-Host "Phase 2: Building routing tables from metadata"
Write-Host "----------------------------------------------"

foreach ($skillFile in $skillFiles | Sort-Object FullName) {
    $skillName = Extract-Field $skillFile.FullName "name"
    $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
    $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"

    if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) {
        continue
    }

    $scopes = $scopeRaw -split '[,\s]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    foreach ($s in $scopes) {
        if (-not [string]::IsNullOrEmpty($Scope) -and $s -ne $Scope) { continue }

        if (-not $scopeTable.ContainsKey($s)) {
            $scopeTable[$s] = @()
        }

        $actions = $autoInvokeRaw -split '\|' | ForEach-Object { $_.Trim() }
        $scopeTable[$s] += [PSCustomObject]@{
            SkillName = $skillName
            Actions   = $actions
        }
    }
}

# Phase 3: Update AGENTS.md files
Write-Host ""
Write-Host "Phase 3: Updating AGENTS.md files"
Write-Host "------------------------------------"

foreach ($scope in $scopeTable.Keys | Sort-Object) {
    $agentsPath = Get-AgentsPath $scope

    if ([string]::IsNullOrEmpty($agentsPath) -or -not (Test-Path $agentsPath)) {
        Write-Host "[WARN] No AGENTS.md found for scope: $scope"
        continue
    }

    $parentDir = Split-Path (Split-Path $agentsPath -Parent) -Leaf
    Write-Host "Processing: $scope -> $parentDir/AGENTS.md"

    $section = "### Auto-invoke Skills`n`nWhen performing these actions, ALWAYS invoke the corresponding skill FIRST:`n`n| Action | Skill |`n|--------|-------|`n"

    $allRows = @()
    foreach ($entry in $scopeTable[$scope]) {
        foreach ($action in $entry.Actions) {
            if (-not [string]::IsNullOrEmpty($action)) {
                $allRows += [PSCustomObject]@{ Action = $action; Skill = $entry.SkillName }
            }
        }
    }

    $allRows = $allRows | Sort-Object { $_.Action }, { $_.Skill }

    foreach ($row in $allRows) {
        $section += "| $($row.Action) | ``$($row.Skill)`` |`n"
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would update: $agentsPath"
        Write-Host $section
        Write-Host ""
    } else {
        $content = Get-Content $agentsPath -Raw

        if ($content -match '(?s)### Auto-invoke Skills.*?(?=^## |\z)') {
            $newContent = $content -replace '(?s)### Auto-invoke Skills.*?(?=^## |\z)', $section.TrimEnd()
        } else {
            $newContent = $content + "`n" + $section
        }

        Set-Content -Path $agentsPath -Value $newContent -NoNewline
        Write-Host "[OK] Updated Auto-invoke section" -Foreground Green
    }
}

Write-Host ""
Write-Host "Done!" -Foreground Green

# Summary
Write-Host ""
Write-Host "========================================"
Write-Host "Summary"
Write-Host "========================================"

$missing = 0
foreach ($skillFile in $skillFiles | Sort-Object FullName) {
    $skillName = Extract-Field $skillFile.FullName "name"
    $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
    $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"

    if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) {
        Write-Host "$skillName - missing: $(if([string]::IsNullOrEmpty($scopeRaw)){'scope'}{if([string]::IsNullOrEmpty($scopeRaw) -and [string]::IsNullOrEmpty($autoInvokeRaw)){' '}$(if([string]::IsNullOrEmpty($autoInvokeRaw)){'auto_invoke'})" -Foreground Yellow
        $missing++
    }
}

if ($missing -eq 0) {
    Write-Host "All skills have sync metadata" -Foreground Green
} else {
    Write-Host ""
    Write-Host "Run with -AutoAddMetadata to auto-add missing metadata" -Foreground Cyan
}
