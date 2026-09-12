#!/usr/bin/env bash
# install-curated-pack.sh — Instala el pack curado de skills para project-foundation
# Uso: ./install-curated-pack.sh [--local]

set -u

GLOBAL_FLAG="-g"
if [ "${1:-}" = "--local" ]; then
  GLOBAL_FLAG=""
fi

SKILLS=(
  "leonxlnx/taste-skill@design-taste-frontend"
  "pbakaus/impeccable@impeccable"
  "vercel-labs/agent-skills@web-design-guidelines"
  "mattpocock/skills@grill-me"
  "mattpocock/skills@improve-codebase-architecture"
)

echo "=== project-foundation: Instalando Pack Potenciador de Skills ==="
echo "Instalando 5 skills de alta reputacion..."

for pkg in "${SKILLS[@]}"; do
  echo "-> Instalando $pkg..."
  if [ -n "$GLOBAL_FLAG" ]; then
    npx -y skills add "$pkg" -g -y >/dev/null 2>&1 || echo "   [WARN] Error al instalar $pkg"
  else
    npx -y skills add "$pkg" -y >/dev/null 2>&1 || echo "   [WARN] Error al instalar $pkg"
  fi
  echo "   [OK] Procesado."
done

echo "=== Pack de skills instalado y listo para usar! ==="
