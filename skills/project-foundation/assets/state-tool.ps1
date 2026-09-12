# state-tool.ps1 — validador operativo de .project-foundation/state.yaml (best-effort, sin deps)
# Uso: .\state-tool.ps1 -Action <validate|integrity|show> [-ProjectRoot <ruta>]
param(
  [Parameter(Mandatory = $true)][ValidateSet("validate", "integrity", "show")][string]$Action,
  [string]$ProjectRoot = "."
)

$State = Join-Path $ProjectRoot ".project-foundation/state.yaml"
if (-not (Test-Path $State)) { Write-Error "state.yaml no encontrado en $State"; exit 1 }
$Lines = Get-Content $State

$PhaseIds = @("intake","research","product","domain","requirements","use_cases","ux_ui",
  "system_design","roadmap","audit","bootstrap","agent_setup","sdd_init")

switch ($Action) {
  "validate" {
    $ok = $true
    foreach ($key in @("version","workflow","slug","level","current_phase","checkpoints","phases","history")) {
      if (-not ($Lines | Where-Object { $_ -match "^$key`:" })) { Write-Output "FALTA key: $key"; $ok = $false }
    }
    foreach ($p in $PhaseIds) {
      if (-not ($Lines | Where-Object { $_ -match "^\s+$p`:$" })) { Write-Output "FALTA fase: $p"; $ok = $false }
    }
    $level = ($Lines | Where-Object { $_ -match "^level`:" } | Select-Object -First 1) -replace ".*:\s*",""
    if (@("prototype","mvp","production","internal") -notcontains $level) { Write-Output "level invalido: $level"; $ok = $false }
    $cp = ($Lines | Where-Object { $_ -match "^current_phase`:" } | Select-Object -First 1) -replace ".*:\s*",""
    if ($PhaseIds -notcontains $cp) { Write-Output "current_phase invalido: $cp"; $ok = $false }
    if ($ok) { Write-Output "VALIDO" } else { exit 1 }
  }
  "integrity" {
    $ok = $true; $missing = @()
    foreach ($line in $Lines) {
      if ($line -match "outputs:\s*\[?(.*)\]?") {
        $inline = $Matches[1] -replace "[\[\]]",""
        if ($inline.Trim()) {
          foreach ($p in ($inline -split ",")) {
            $p = $p.Trim()
            if ($p -and -not (Test-Path (Join-Path $ProjectRoot $p))) { $missing += $p; $ok = $false }
          }
        }
      }
      elseif ($line -match "^\s*-\s+(docs/.+|PROJECT\.md)$") {
        $p = $Matches[1].Trim()
        if (-not (Test-Path (Join-Path $ProjectRoot $p))) { $missing += $p; $ok = $false }
      }
    }
    if ($ok) { Write-Output "INTEGRIDAD OK" } else { Write-Output ("OUTPUTS FALTANTES: " + ($missing -join " ")); exit 1 }
  }
  "show" {
    Write-Output "== project-foundation =="
    $Lines | Where-Object { $_ -match "^(slug|level|research_mode|audit_depth|current_phase|updated):" }
    Write-Output "-- checkpoints --"
    $Lines | Where-Object { $_ -match "^\s+(product_freeze|design_freeze):" -or $_ -match "^\s+status:" } | Select-Object -First 4
    Write-Output "-- fases --"
    $phase = ""
    foreach ($line in $Lines) {
      if ($line -match "^  ([a-z_]+):\s*\{") { $phase = $Matches[1] }
      elseif ($line -match "^  ([a-z_]+):") { $phase = $Matches[1] }
      if ($line -match "status:\s*(\w+)" -and $phase) { Write-Output "$phase : $($Matches[1])" }
    }
    if ($Lines | Where-Object { $_ -match "stale: true" }) { Write-Output "-- STALE presentes: revisar cascada --" }
  }
}
