param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [switch]$GlobalSkills
)

$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -Path $ProjectPath)) {
    throw "No existe el ProjectPath: $ProjectPath"
}

$commandTarget = Join-Path $ProjectPath ".opencode\command"
$hookTarget = Join-Path $ProjectPath ".opencode\hooks"
$agentsTarget = Join-Path $ProjectPath "AGENTS.ai-customizations.md"

New-Item -ItemType Directory -Force -Path $commandTarget | Out-Null
New-Item -ItemType Directory -Force -Path $hookTarget | Out-Null

Copy-Item -Path (Join-Path $repoRoot "commands\opencode\*.md") -Destination $commandTarget -Force
Copy-Item -Path (Join-Path $repoRoot "hooks\opencode\*.ps1") -Destination $hookTarget -Force
Copy-Item -Path (Join-Path $repoRoot "agents\opencode\AGENTS.md") -Destination $agentsTarget -Force

$npxCommand = Get-Command npx -ErrorAction SilentlyContinue
if ($null -eq $npxCommand) {
    Write-Warning "No se encontro npx. Se copiaron comandos/hooks pero no se instalaron skills."
    exit 0
}

$skillsArgs = @("skills", "add", $repoRoot, "--skill", "*", "--agent", "opencode", "-y")
if ($GlobalSkills) {
    $skillsArgs += "--global"
}

& npx @skillsArgs
if ($LASTEXITCODE -ne 0) {
    throw "Fallo la instalacion de skills para OpenCode"
}

Write-Output "Bootstrap OpenCode completado en: $ProjectPath"
