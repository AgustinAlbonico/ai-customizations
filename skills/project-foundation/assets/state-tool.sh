#!/usr/bin/env bash
# state-tool.sh — validador operativo de .project-foundation/state.yaml (best-effort, sin deps)
# Uso: state-tool.sh <validate|integrity|show> [project_root]
set -u

ROOT="${2:-.}"
STATE="$ROOT/.project-foundation/state.yaml"

PHASE_IDS="intake research product domain requirements use_cases ux_ui system_design roadmap audit bootstrap agent_setup sdd_init"

die() { echo "ERROR: $1"; exit 1; }

[ -f "$STATE" ] || die "state.yaml no encontrado en $STATE"

cmd_validate() {
  local ok=1
  for key in version workflow slug level current_phase checkpoints phases history; do
    grep -q "^${key}:" "$STATE" || { echo "FALTA key: $key"; ok=0; }
  done
  grep -q "product_freeze:" "$STATE" || { echo "FALTA checkpoints.product_freeze"; ok=0; }
  grep -q "design_freeze:" "$STATE" || { echo "FALTA checkpoints.design_freeze"; ok=0; }
  local missing=""
  for p in $PHASE_IDS; do
    grep -qE "^[[:space:]]+${p}:$" "$STATE" || missing="$missing $p"
  done
  [ -n "$missing" ] && { echo "FALTAN fases:$missing"; ok=0; }
  local lvl; lvl=$(grep -E "^level:" "$STATE" | head -1 | awk '{print $2}')
  case "$lvl" in
    prototype|mvp|production|internal) ;;
    "") echo "FALTA level"; ok=0 ;;
    *) echo "level invalido: $lvl"; ok=0 ;;
  esac
  local cp; cp=$(grep -E "^current_phase:" "$STATE" | head -1 | awk '{print $2}')
  echo "$PHASE_IDS" | grep -qw "$cp" || { echo "current_phase invalido: $cp"; ok=0; }
  [ "$ok" -eq 1 ] && echo "VALIDO" || exit 1
}

cmd_integrity() {
  local ok=1 missing=""
  # rutas declaradas en bloques outputs: [listas] o inline
  while IFS= read -r line; do
    case "$line" in
      *"outputs:"*)
        inline="${line#*outputs:}"
        inline="${inline//[[]/}"; inline="${inline//]/}"
        if [ -n "$(echo "$inline" | tr -d ' ')" ]; then
          for p in $inline; do
            [ -e "$ROOT/$p" ] || { missing="$missing $p"; ok=0; }
          done
        fi
        ;;
      *)
        if printf '%s' "$line" | grep -qE '^[[:space:]]*- (docs/|PROJECT\.md)'; then
          p="$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d ' ')"
          [ -e "$ROOT/$p" ] || { missing="$missing $p"; ok=0; }
        fi
        ;;
    esac
  done < "$STATE"
  if [ "$ok" -eq 1 ]; then echo "INTEGRIDAD OK"; else echo "OUTPUTS FALTANTES:$missing"; exit 1; fi
}

cmd_show() {
  echo "== project-foundation =="
  grep -E "^(slug|level|research_mode|audit_depth|current_phase|updated):" "$STATE"
  echo "-- checkpoints --"
  grep -A1 -E "product_freeze:|design_freeze:" "$STATE" | grep -E "status:" | head -2
  echo "-- fases --"
  awk '/^phases:/{f=1;next} f&&/^[a-z_]+:/{f=0} f&&/^  [a-z_]+:/{gsub(/[: ]/,"");p=$0} f&&/status:/{print p": "$2}' "$STATE"
  grep -q "stale: true" "$STATE" && echo "-- STALE presentes: revisar cascada --"
}

case "${1:-}" in
  validate) cmd_validate ;;
  integrity) cmd_integrity ;;
  show) cmd_show ;;
  *) die "uso: state-tool.sh <validate|integrity|show> [project_root]" ;;
esac
