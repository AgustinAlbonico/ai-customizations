param(
    [string]$Source = ".",
    [string[]]$Agents,
    [switch]$AllAgents,
    [switch]$GlobalSkills
)

$npxCommand = Get-Command npx -ErrorAction SilentlyContinue
if ($null -eq $npxCommand) {
    throw "No se encontro npx en el PATH"
}

$skillsArgs = @("skills", "add", $Source, "--skill", "*", "-y")

if ($AllAgents) {
    $skillsArgs += "--all"
} elseif ($Agents -and $Agents.Count -gt 0) {
    foreach ($agentName in $Agents) {
        $trimmedAgentName = $agentName.Trim()
        if ($trimmedAgentName.Length -gt 0) {
            $skillsArgs += "--agent"
            $skillsArgs += $trimmedAgentName
        }
    }
}

if ($GlobalSkills) {
    $skillsArgs += "--global"
}

& npx @skillsArgs
if ($LASTEXITCODE -ne 0) {
    throw "Fallo la instalacion de skills"
}

Write-Output "Instalacion de skills completada"
