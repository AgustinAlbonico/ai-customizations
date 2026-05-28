#!/usr/bin/env pwsh
# skill-sync: Sync local skill metadata to AGENTS.md Auto-invoke sections.
# Usage: ./sync.ps1 [-DryRun] [-AutoAddMetadata] [-Scope <scope>] [-ProjectRoot <path>] [-NoCreateAgents]

param(
    [switch]$DryRun,
    [switch]$AutoAddMetadata,
    [switch]$NoCreateAgents,
    [string]$Scope = "",
    [string]$ProjectRoot = ""
)

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

function Join-PathParts {
    param([string[]]$Parts)

    $path = $Parts[0]
    for ($i = 1; $i -lt $Parts.Count; $i++) {
        $path = Join-Path $path $Parts[$i]
    }
    return $path
}

function Resolve-ProjectRoot {
    param([string]$startPath, [string]$explicitRoot)

    if (-not [string]::IsNullOrEmpty($explicitRoot)) {
        return (Resolve-Path -LiteralPath $explicitRoot).Path
    }

    $current = Get-Item -LiteralPath $startPath
    if (-not $current.PSIsContainer) {
        $current = $current.Directory
    }

    while ($null -ne $current) {
        if ($current.Name -eq ".agents") {
            return $current.Parent.FullName
        }

        $localSkills = Join-PathParts @($current.FullName, ".agents", "skills")
        if (Test-Path -LiteralPath $localSkills) {
            return $current.FullName
        }

        $agents = Join-Path $current.FullName "AGENTS.md"
        if (Test-Path -LiteralPath $agents) {
            return $current.FullName
        }

        $git = Join-Path $current.FullName ".git"
        if (Test-Path -LiteralPath $git) {
            return $current.FullName
        }

        $current = $current.Parent
    }

    throw "Could not resolve project root. Pass -ProjectRoot <path>."
}

$REPO_ROOT = Resolve-ProjectRoot $SCRIPT_DIR $ProjectRoot

function Get-SkillsDir {
    $agentsSkills = Join-PathParts @($REPO_ROOT, ".agents", "skills")
    if (Test-Path -LiteralPath $agentsSkills) { return $agentsSkills }

    $repoSkills = Join-Path $REPO_ROOT "skills"
    if (Test-Path -LiteralPath $repoSkills) { return $repoSkills }

    throw "No skills directory found. Expected .agents/skills or skills under $REPO_ROOT."
}

$SKILLS_DIR = Get-SkillsDir

function Get-KnownScopePaths {
    return @{
        frontend = @("frontend", "web", "client", "apps/frontend", "apps/web", "apps/client")
        backend  = @("backend", "api", "server", "apps/backend", "apps/api", "apps/server")
        shared   = @("packages/shared", "shared", "common", "packages/common")
        mcp      = @("mcp_server", "mcp", "mcp-server")
        sdk      = @("sdk", "lib", "packages/sdk", "packages/lib")
    }
}

function Resolve-ScopePath {
    param([string]$scope)

    if ($scope -eq "root") { return $REPO_ROOT }

    $scopeConfigPath = Join-PathParts @($REPO_ROOT, ".agents", "skill-scopes.json")
    if (Test-Path -LiteralPath $scopeConfigPath) {
        $scopeConfig = Get-Content -LiteralPath $scopeConfigPath -Raw | ConvertFrom-Json
        if ($scopeConfig.scopes -and $scopeConfig.scopes.PSObject.Properties.Name -contains $scope) {
            $configured = Join-Path $REPO_ROOT $scopeConfig.scopes.$scope
            if (Test-Path -LiteralPath $configured) { return $configured }
        }
    }

    $known = Get-KnownScopePaths
    if ($known.ContainsKey($scope)) {
        foreach ($candidate in $known[$scope]) {
            $path = Join-Path $REPO_ROOT $candidate
            if (Test-Path -LiteralPath $path) { return $path }
        }
    }

    $direct = Join-Path $REPO_ROOT $scope
    if (Test-Path -LiteralPath $direct) { return $direct }

    $matches = Get-ChildItem -LiteralPath $REPO_ROOT -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -eq $scope -and
            $_.FullName -notmatch "[\\/](node_modules|\.git|\.agents)[\\/]?"
        } |
        Sort-Object { $_.FullName.Length }

    if ($matches) { return $matches[0].FullName }

    return ""
}

function Get-AgentsPath {
    param([string]$scope)

    $scopePath = Resolve-ScopePath $scope
    if ([string]::IsNullOrEmpty($scopePath)) { return "" }
    return Join-Path $scopePath "AGENTS.md"
}

function Ensure-AgentsFile {
    param([string]$agentsPath, [string]$scope)

    if (Test-Path -LiteralPath $agentsPath) { return $true }

    if ($NoCreateAgents) { return $false }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create: $agentsPath"
        return $true
    }

    $title = if ($scope -eq "root") { "# AGENTS.md" } else { "# $scope AGENTS.md" }
    $content = "$title`n`nProject-specific AI agent instructions for the ``$scope`` scope.`n"
    Set-Content -LiteralPath $agentsPath -Value $content -NoNewline
    Write-Host "[OK] Created AGENTS.md for scope: $scope" -Foreground Green
    return $true
}

function Normalize-Frontmatter {
    param([string]$frontmatter)

    $lines = @()
    foreach ($line in ($frontmatter -split '\r?\n')) {
        if ($line -match '^(\s*)([a-z_]+):\s*(.+?)\s{2,}([a-z_]+):\s*(.+)$') {
            $indent = $matches[1]
            $field1 = $matches[2]
            $value1 = $matches[3]
            $field2 = $matches[4]
            $value2 = $matches[5]
            $lines += "$indent${field1}: $value1"
            $lines += "$indent${field2}: $value2"
        } elseif ($line -match '^(\s*-\s+.+?)\s{2,}([a-z_]+):\s*(.+)$') {
            $listPart = $matches[1]
            $field2 = $matches[2]
            $value2 = $matches[3]
            $lines += $listPart
            $lines += "  ${field2}: $value2"
        } else {
            $lines += $line
        }
    }
    return ($lines -join "`n")
}

function Get-Frontmatter {
    param([string]$file)

    $content = Get-Content -LiteralPath $file -Raw
    if ($content -match "(?s)^---\r?\n(.*?)\r?\n---") {
        return Normalize-Frontmatter $matches[1]
    }
    return ""
}

function Extract-Field {
    param([string]$file, [string]$field)

    $frontmatter = Get-Frontmatter $file
    if ([string]::IsNullOrEmpty($frontmatter)) { return "" }

    $pattern = "(?m)^$field`:\s*(.*)$"
    if ($frontmatter -match $pattern) {
        return $matches[1].Trim().Trim('"', "'")
    }
    return ""
}

function Get-MetadataBlock {
    param([string]$frontmatter)

    $lines = $frontmatter -split '\r?\n'
    $metadataLines = @()
    $inMetadata = $false

    foreach ($line in $lines) {
        if (-not $inMetadata -and $line -match '^metadata:\s*$') {
            $inMetadata = $true
            continue
        }

        if ($inMetadata) {
            if ($line -match '^\S' -and $line.Trim().Length -gt 0) { break }
            $metadataLines += $line
        }
    }

    return ($metadataLines -join "`n")
}

function Clean-InlineYamlValue {
    param([string]$value)

    $clean = $value.Trim().Trim('"', "'")
    $clean = $clean -replace '^\[(.*)\]$', '$1'
    return $clean.Trim()
}

function Extract-MetadataFromBlock {
    param([string]$block, [string]$field)

    $block = Normalize-Frontmatter $block
    $lines = $block -split '\r?\n'

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -notmatch "^\s*$field`:\s*(.*)$") { continue }

        $inlineValue = $matches[1].Trim()
        if ($inlineValue.Length -gt 0 -and $inlineValue -ne ">" -and $inlineValue -notmatch '^-') {
            return Clean-InlineYamlValue $inlineValue
        }

        $items = @()
        for ($j = $i + 1; $j -lt $lines.Count; $j++) {
            $next = $lines[$j]
            if ($next -match '^\s*-\s+(.*)$') {
                $items += $matches[1].Trim().Trim('"', "'")
                continue
            }
            if ($next.Trim().Length -eq 0) { continue }
            break
        }

        if ($items.Count -gt 0) { return ($items -join "|") }
        return ""
    }

    return ""
}

function Extract-Metadata {
    param([string]$file, [string]$field)

    $frontmatter = Get-Frontmatter $file
    if ([string]::IsNullOrEmpty($frontmatter)) { return "" }

    $metadataBlock = Get-MetadataBlock $frontmatter
    if (-not [string]::IsNullOrEmpty($metadataBlock)) {
        $fromMetadata = Extract-MetadataFromBlock $metadataBlock $field
        if (-not [string]::IsNullOrEmpty($fromMetadata)) { return $fromMetadata }
    }

    return Extract-MetadataFromBlock $frontmatter $field
}

function Add-MissingMetadata {
    param([string]$skillFile, [string]$skillName)

    $content = Get-Content -LiteralPath $skillFile -Raw
    $scopeRaw = Extract-Metadata $skillFile "scope"
    $autoInvokeRaw = Extract-Metadata $skillFile "auto_invoke"

    $needsScope = [string]::IsNullOrEmpty($scopeRaw)
    $needsAutoInvoke = [string]::IsNullOrEmpty($autoInvokeRaw)

    if (-not $needsScope -and -not $needsAutoInvoke) { return $false }

    $newLines = @()
    if ($needsScope) {
        $newLines += "  scope: [root]"
        Write-Host "  [AUTO] Added scope: [root]" -Foreground Cyan
    }
    if ($needsAutoInvoke) {
        $newLines += "  auto_invoke:"
        $newLines += "    - ""$skillName"""
        Write-Host "  [AUTO] Added auto_invoke: ""$skillName""" -Foreground Cyan
    }

    if ($content -match '(?s)^(---\r?\n)(.*?)(\r?\n---)(.*)$') {
        $frontmatter = Normalize-Frontmatter $matches[2]
        $body = $matches[4]

        if ($frontmatter -match '(?m)^metadata:\s*$') {
            $insert = "metadata:`n" + ($newLines -join "`n")
            $frontmatter = [regex]::Replace($frontmatter, '(?m)^metadata:\s*$', $insert, 1)
        } else {
            $frontmatter = $frontmatter.TrimEnd() + "`nmetadata:`n" + ($newLines -join "`n")
        }

        $newContent = "---`n" + $frontmatter.TrimEnd() + "`n---" + $body
        Set-Content -LiteralPath $skillFile -Value $newContent -NoNewline
        return $true
    }

    $newContentNoFrontmatter = "---`nmetadata:`n" + ($newLines -join "`n") + "`n---`n" + $content
    Set-Content -LiteralPath $skillFile -Value $newContentNoFrontmatter -NoNewline
    return $true
}

Write-Host "Skill Sync - Updating AGENTS.md Auto-invoke sections"
Write-Host "========================================================"
Write-Host "Project root: $REPO_ROOT"
Write-Host "Skills dir:   $SKILLS_DIR"
Write-Host ""

$skillFiles = Get-ChildItem -LiteralPath $SKILLS_DIR -Recurse -Filter "SKILL.md" -Depth 3 | Where-Object {
    $_.FullName -notmatch "[\\/](assets|references|scripts)[\\/]"
}

$scopeTable = @{}

if ($AutoAddMetadata) {
    Write-Host "Phase 1: Auto-adding metadata to skills missing it"
    Write-Host "----------------------------------------------------"

    foreach ($skillFile in $skillFiles | Sort-Object FullName) {
        $skillName = Extract-Field $skillFile.FullName "name"
        if ([string]::IsNullOrEmpty($skillName)) { $skillName = $skillFile.Directory.Name }

        $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
        $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"

        if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) {
            Write-Host "Skill: $skillName" -Foreground Yellow
            if (-not $DryRun) {
                [void](Add-MissingMetadata $skillFile.FullName $skillName)
            } else {
                if ([string]::IsNullOrEmpty($scopeRaw)) { Write-Host "  [DRY] Would add scope: [root]" -Foreground Cyan }
                if ([string]::IsNullOrEmpty($autoInvokeRaw)) { Write-Host "  [DRY] Would add auto_invoke: ""$skillName""" -Foreground Cyan }
            }
        }
    }

    Write-Host ""
}

Write-Host "Phase 2: Building routing tables from metadata"
Write-Host "----------------------------------------------"

foreach ($skillFile in $skillFiles | Sort-Object FullName) {
    $skillName = Extract-Field $skillFile.FullName "name"
    if ([string]::IsNullOrEmpty($skillName)) { $skillName = $skillFile.Directory.Name }

    $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
    $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"

    if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) { continue }

    $scopes = $scopeRaw -replace '^\[(.*)\]$', '$1'
    $scopes = $scopes -split '[,\s]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    foreach ($s in $scopes) {
        if (-not [string]::IsNullOrEmpty($Scope) -and $s -ne $Scope) { continue }
        if (-not $scopeTable.ContainsKey($s)) { $scopeTable[$s] = @() }
        $actions = $autoInvokeRaw -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        $scopeTable[$s] += [PSCustomObject]@{ SkillName = $skillName; Actions = $actions }
    }
}

Write-Host ""
Write-Host "Phase 3: Updating AGENTS.md files"
Write-Host "------------------------------------"

foreach ($scopeKey in $scopeTable.Keys | Sort-Object) {
    $agentsPath = Get-AgentsPath $scopeKey
    if ([string]::IsNullOrEmpty($agentsPath)) {
        Write-Host "[WARN] No path found for scope: $scopeKey"
        continue
    }

    if (-not (Ensure-AgentsFile $agentsPath $scopeKey)) {
        Write-Host "[WARN] No AGENTS.md found for scope: $scopeKey"
        continue
    }

    $parentDir = Split-Path (Split-Path $agentsPath -Parent) -Leaf
    Write-Host "Processing: $scopeKey -> $parentDir/AGENTS.md"

    $section = "### Auto-invoke Skills`n`nWhen performing these actions, ALWAYS invoke the corresponding skill FIRST:`n`n| Action | Skill |`n|--------|-------|`n"

    $seenRows = @{}
    $allRows = @()
    foreach ($entry in $scopeTable[$scopeKey]) {
        foreach ($action in $entry.Actions) {
            if ([string]::IsNullOrWhiteSpace($action)) { continue }
            $key = "$action`t$($entry.SkillName)"
            if ($seenRows.ContainsKey($key)) { continue }
            $seenRows[$key] = $true
            $allRows += [PSCustomObject]@{ Action = $action; Skill = $entry.SkillName }
        }
    }

    $allRows = $allRows | Sort-Object Action, Skill
    foreach ($row in $allRows) { $section += "| $($row.Action) | ``$($row.Skill)`` |`n" }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would update: $agentsPath"
        Write-Host $section
        Write-Host ""
        continue
    }

    $content = Get-Content -LiteralPath $agentsPath -Raw
    $pattern = '(?ms)^### Auto-invoke Skills.*?(?=^## |\z)'
    if ($content -match $pattern) {
        $newContent = [regex]::Replace($content, $pattern, $section.TrimEnd(), 1)
    } else {
        $separator = if ($content.EndsWith("`n")) { "`n" } else { "`n`n" }
        $newContent = $content + $separator + $section.TrimEnd()
    }

    Set-Content -LiteralPath $agentsPath -Value $newContent -NoNewline
    Write-Host "[OK] Updated Auto-invoke section" -Foreground Green
}

Write-Host ""
Write-Host "Done!" -Foreground Green

Write-Host ""
Write-Host "========================================"
Write-Host "Summary"
Write-Host "========================================"

$missing = 0
foreach ($skillFile in $skillFiles | Sort-Object FullName) {
    $skillName = Extract-Field $skillFile.FullName "name"
    if ([string]::IsNullOrEmpty($skillName)) { $skillName = $skillFile.Directory.Name }

    $scopeRaw = Extract-Metadata $skillFile.FullName "scope"
    $autoInvokeRaw = Extract-Metadata $skillFile.FullName "auto_invoke"
    if ([string]::IsNullOrEmpty($scopeRaw) -or [string]::IsNullOrEmpty($autoInvokeRaw)) {
        $missingParts = @()
        if ([string]::IsNullOrEmpty($scopeRaw)) { $missingParts += "scope" }
        if ([string]::IsNullOrEmpty($autoInvokeRaw)) { $missingParts += "auto_invoke" }
        Write-Host "$skillName - missing: $($missingParts -join ' ')" -Foreground Yellow
        $missing++
    }
}

if ($missing -eq 0) {
    Write-Host "All skills have sync metadata" -Foreground Green
} else {
    Write-Host ""
    Write-Host "Run with -AutoAddMetadata to auto-add missing metadata" -Foreground Cyan
}
