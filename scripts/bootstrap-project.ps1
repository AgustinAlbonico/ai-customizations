param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -Path $ProjectPath)) {
    throw "No existe el ProjectPath: $ProjectPath"
}

$commandTarget = Join-Path $ProjectPath ".opencode\command"
$hookTarget = Join-Path $ProjectPath ".opencode\hooks"

New-Item -ItemType Directory -Force -Path $commandTarget | Out-Null
New-Item -ItemType Directory -Force -Path $hookTarget | Out-Null

Copy-Item -Path (Join-Path $repoRoot "commands\*.md") -Destination $commandTarget -Force
Copy-Item -Path (Join-Path $repoRoot "hooks\*.ps1") -Destination $hookTarget -Force

Write-Output "Bootstrap de proyecto completado en: $ProjectPath"
