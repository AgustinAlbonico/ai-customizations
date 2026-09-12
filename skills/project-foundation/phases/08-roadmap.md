---
id: roadmap
num: 08
deps: [requirements, use_cases, system_design]
outputs: ["docs/product/ROADMAP.md"]
---

# Fase 08 — Roadmap

## Objetivo

Transformar capabilities + requirements + use cases en entregas: Phase → Epic → Feature,
cada feature con ID, propósito y trazabilidad completa.

## Inputs permitidos

- `PROJECT.md` (capabilities, no-objetivos)
- `docs/product/REQUIREMENTS.md` (FRs con prioridad)
- `docs/product/USE-CASE-MAP.md` (UCs)
- `docs/architecture/SYSTEM-DESIGN.md` (solo para leer dependencias técnicas entre
  componentes — NO para agregar decisiones)

## Prohibido

- `docs/research/*` (el mercado no ordena entregas) y `docs/product/UX-UI.md`.
- Agregar decisiones técnicas nuevas vía el roadmap: si falta algo, es un gap para `review system_design`, no para acá.

## Interacción (1 ronda de máx 3-4)

- Presentar la propuesta de fases de entrega (p. ej. Fase 1 MVP: X, Y; Fase 2: Z) y pedir
  ajuste de prioridades.
- Confirmar features que quedan explícitamente `backlog` (fuera de fase asignada).

## Proceso

1. Derivar features: agrupar FRs/UCs coherentemente. Una feature = un incremento de valor
   demostrable, NO un módulo técnico.
2. Regla de tamaño: si una feature arrastra >8 FRs o >3 UCs narrativos, dividirla (el
   auditor de fase 09 la va a marcar si no).
3. Delegar el armamiento a [../agents/roadmap-drafter.md](../agents/roadmap-drafter.md).
4. Validar: toda FR-P0 pertenece a alguna feature (o hay justificación); dependencias sin
   ciclos.

## Template de ROADMAP.md

Estructura jerárquica `Phase → Epic → Feature`. Los épicos agrupan features relacionadas
dentro de una fase; en fases chicas pueden quedar con UN solo épico. No inventar épicos vacíos.

```markdown
# Roadmap — <producto>

## Phase 1 — MVP (o nombre de la fase)
### Epic: <nombre> (agrupador de valor de negocio)
#### FEAT-001 — <Nombre>
- Propósito: 1-2 líneas de valor de negocio
- Requirements: FR-APP-001, FR-APP-002
- Use cases: UC-APP-001
- Depends on: —
- Status: planned

#### FEAT-002 — ...

## Phase 2 — <nombre>
### Epic: Scheduling
#### FEAT-006 — Book Appointment
- Requirements: FR-APP-001, FR-APP-002
- Use cases: UC-APP-001
- Depends on: FEAT-003
- Status: planned

## Backlog (features sin fase)
## Cobertura
| FR-P0 | Feature |
```

IDs `FEAT-NNN` estables y globales (no por fase). Status inicial: `planned`.

## Exit criteria

- Toda FR-P0 cubierta; todo UC narrativo pertenece a una feature o tiene justificación.
- Dependencias acíclicas y verificables.
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.roadmap:
  status: completed
  outputs: ["docs/product/ROADMAP.md"]
  summary: {phases: 3, features: 14, p0_coverage: "100%"}
history += {event: "roadmap completed"}
```
