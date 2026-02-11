param(
    [switch]$GlobalSkills
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$npxCommand = Get-Command npx -ErrorAction SilentlyContinue

if ($null -eq $npxCommand) {
    throw "No se encontro npx en el PATH"
}

$skillsArgs = @("skills", "add", $repoRoot, "--skill", "*", "--agent", "codex", "-y")
if ($GlobalSkills) {
    $skillsArgs += "--global"
}

& npx @skillsArgs
if ($LASTEXITCODE -ne 0) {
    throw "Fallo la instalacion de skills para Codex"
}

Write-Output "Instalacion de skills para Codex completada"
