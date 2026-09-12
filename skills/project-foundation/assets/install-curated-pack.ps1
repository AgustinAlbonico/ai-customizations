# install-curated-pack.ps1 — Instala el pack curado de skills para project-foundation
# Uso: .\install-curated-pack.ps1 [-Global]
param(
  [switch]$Global = $true
)

$ErrorActionPreference = "Continue"

$Skills = @(
  @{ Name = "Design Taste Frontend"; Pkg = "leonxlnx/taste-skill@design-taste-frontend" },
  @{ Name = "Impeccable Design"; Pkg = "pbakaus/impeccable@impeccable" },
  @{ Name = "Vercel Web Design Guidelines"; Pkg = "vercel-labs/agent-skills@web-design-guidelines" },
  @{ Name = "Matt Pocock Grill Me"; Pkg = "mattpocock/skills@grill-me" },
  @{ Name = "Matt Pocock Improve Architecture"; Pkg = "mattpocock/skills@improve-codebase-architecture" }
)

Write-Host "`n=== project-foundation: Instalando Pack Potenciador de Skills ===" -ForegroundColor Cyan
Write-Host "Instalando 5 skills de alta reputacion globalmente...`n"

$globalFlag = if ($Global) { "-g" } else { "" }

foreach ($s in $Skills) {
  Write-Host "-> Instalando $($s.Name) ($($s.Pkg))..." -ForegroundColor Yellow
  if ($globalFlag) {
    npx -y skills add $s.Pkg -g -y 2>&1 | Out-Null
  } else {
    npx -y skills add $s.Pkg -y 2>&1 | Out-Null
  }
  if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Instalada correctamente." -ForegroundColor Green
  } else {
    Write-Host "   [WARN] No se pudo instalar automaticamente. Reintentar manual si es necesario." -ForegroundColor DarkYellow
  }
}

Write-Host "`n=== Pack de skills instalado y listo para usar! ===`n" -ForegroundColor Green
