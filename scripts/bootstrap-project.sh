#!/usr/bin/env bash
# bootstrap-project.sh — copia commands y hooks al proyecto destino (macOS/Linux)
# Uso: ./bootstrap-project.sh <ruta-proyecto>
set -u

PROJECT_PATH="${1:-}"
[ -n "$PROJECT_PATH" ] || { echo "ERROR: indicá el ProjectPath: ./bootstrap-project.sh <ruta-proyecto>"; exit 1; }
[ -d "$PROJECT_PATH" ] || { echo "ERROR: no existe el ProjectPath: $PROJECT_PATH"; exit 1; }

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

COMMAND_TARGET="$PROJECT_PATH/.opencode/commands"
HOOK_TARGET="$PROJECT_PATH/.opencode/hooks"

mkdir -p "$COMMAND_TARGET" "$HOOK_TARGET"

cp -f "$REPO_ROOT"/commands/*.md "$COMMAND_TARGET"/
cp -f "$REPO_ROOT"/hooks/*.ps1 "$HOOK_TARGET"/ 2>/dev/null || true

echo "Bootstrap de proyecto completado en: $PROJECT_PATH"
