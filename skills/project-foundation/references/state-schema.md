# Esquema de state.yaml — project-foundation

Fuente única de **metadata operacional**. El contenido real vive en los documentos; el estado
nunca lo duplica.

## Reglas de escritura

1. Se escribe SOLO al: completar una fase, iniciar/reanudar una fase, pasar/fallar un gate,
   reabrir una fase, agregar/quitar un blocker.
2. Cada cambio agrega una línea a `history` (append-only): `{ts, event}`.
3. Nunca borrar fases del mapa ni reescribir history.
4. `summary` por fase: métricas mínimas (conteos, flags), máximo 6 claves. Prohibido copiar
   contenido de documentos.
5. Al reabrir una fase N (`review`): status `in_progress`, `revision++`, y propagar
   `stale: true` a toda fase completada que dependa de N (cascada según el mapa del SKILL.md).
   El usuario decide por cada stale: re-ejecutar (status `in_progress`) o re-validar
   (quitar flag tras revisar el impacto).
6. `blocked_on` solo contiene preguntas que **bloquean avance**: `{question, doc, section}`.
   Las open questions no bloqueantes viven en los documentos.

## Esquema

```yaml
version: 1
workflow: project-foundation@1.0
slug: <kebab-case>              # nombre operativo del proyecto
level: prototype | mvp | production | internal
research_mode: needed | skipped
audit_depth: full | lite
current_phase: <id de fase>
created: <YYYY-MM-DD HH:mm>
updated: <YYYY-MM-DD HH:mm>

checkpoints:
  product_freeze: { status: pending | passed | failed, passed_at: null | fecha }
  design_freeze:  { status: pending | passed | failed, passed_at: null | fecha }

phases:
  <id>:
    status: pending | in_progress | completed | skipped
    stale: false                 # solo true tras cascada de reapertura
    at: <fecha de completado>    # si completed/skipped
    revision: 1                  # incrementa en cada reapertura
    outputs: [rutas relativas]   # solo las principales declaradas por el contrato
    summary: {≤6 claves de métricas}

blocked_on: []                   # [{question, doc, section}]

history:                         # append-only
  - {ts: ..., event: "intake started"}
```

## Ids de fase

`intake, research, product, domain, requirements, use_cases, ux_ui, system_design, roadmap,
audit, bootstrap, agent_setup, sdd_init`

## Semilla inicial (fase 00)

```yaml
version: 1
workflow: project-foundation@1.0
slug: <slug>
level: <nivel>
research_mode: needed
audit_depth: full
current_phase: intake
created: <ahora>
updated: <ahora>
checkpoints:
  product_freeze: { status: pending, passed_at: null }
  design_freeze:  { status: pending, passed_at: null }
phases:
  intake:        { status: in_progress, stale: false, revision: 1 }
  research:      { status: pending, stale: false, revision: 1 }
  product:       { status: pending, stale: false, revision: 1 }
  domain:        { status: pending, stale: false, revision: 1 }
  requirements:  { status: pending, stale: false, revision: 1 }
  use_cases:     { status: pending, stale: false, revision: 1 }
  ux_ui:         { status: pending, stale: false, revision: 1 }
  system_design: { status: pending, stale: false, revision: 1 }
  roadmap:       { status: pending, stale: false, revision: 1 }
  audit:         { status: pending, stale: false, revision: 1 }
  bootstrap:     { status: pending, stale: false, revision: 1 }
  agent_setup:   { status: pending, stale: false, revision: 1 }
  sdd_init:      { status: pending, stale: false, revision: 1 }
blocked_on: []
history:
  - {ts: <ahora>, event: "pipeline created"}
```

## Recuperación de sesión (resumen)

1. Leer state.yaml → 2. `integrity`: verificar que todo `outputs` declarado existe en disco →
3. dashboard compacto (fases × status, gates, blockers, stales) → 4. cargar contrato de
`current_phase` → 5. leer sus inputs whitelisted → 6. continuar.

Casos: output declarado pero inexistente → reabrir esa fase (`in_progress`) y avisar al
usuario. `version` mayor distinta → avisar drift del workflow y proceder con cuidado.
state.yaml corrupto → reconstruir desde los documentos existentes + confirmación del usuario.
