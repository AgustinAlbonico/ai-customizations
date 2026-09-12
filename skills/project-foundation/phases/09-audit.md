---
id: audit
num: 09
deps: [design_freeze]
outputs: ["docs/audit/FOUNDATION-AUDIT.md", "docs/audit/TRACEABILITY.md"]
---

# Fase 09 — Project Audit

## Objetivo

Verificación independiente de TODA la definición antes del bootstrap. Detecta gaps,
contradicciones y faltantes de trazabilidad. El veredicto habilita (o no) el bootstrap.

## Inputs permitidos (el auditor los recibe todos — es la única fase que lee todo)

- `PROJECT.md`, `docs/research/COMPETITIVE-ANALYSIS.md` (si existe), `docs/product/DOMAIN.md`,
  `docs/product/REQUIREMENTS.md`, `docs/product/USE-CASE-MAP.md` + `use-cases/`,
  `docs/product/UX-UI.md`, `docs/architecture/SYSTEM-DESIGN.md` + `adr/`, `docs/product/ROADMAP.md`

## Interacción

El auditor es un subagente read-only; NO entrevista al usuario. El orquestador presenta el
veredicto y, si hay hallazgos, proponé con el usuario qué fases reabrir.

## Delegación

- [../agents/foundation-auditor.md](../agents/foundation-auditor.md): ejecuta el checklist
  completo, genera `docs/audit/TRACEABILITY.md` (matriz DERIVADA: FR ↔ UC ↔ FEAT; única
  fuente de verdad = los tres documentos con sus IDs) y escribe FOUNDATION-AUDIT.md.

## Profundidad según audit_depth

- `lite` (prototype/internal): checklist reducido — términos definidos, FR-P0 con UC,
  cobertura de FEAT, contradicciones groseras. Sin matriz de trazabilidad completa.
- `full` (mvp/production): checklist completo + matriz.

## Loop de rework

1. Hallazgos críticos → proponer reabrir fases específicas (`review <fase>`).
2. Corregidas las fases → re-audit.
3. Máximo 2 ciclos de re-audit. Al tercer hallazgo crítico persistente: decisión humana
   explícita — seguir con gaps documentados (constan en FOUNDATION-AUDIT.md y state) o
   reabrir lo que haga falta. Registrar la decisión en history.

## Template de FOUNDATION-AUDIT.md

```markdown
# Foundation Audit — ciclo <N> (<fecha>)

## PROJECT FOUNDATION STATUS
Product        ✓|✗|~
Research       ✓|✗|n/a
Domain         ✓|✗|~
Requirements   ✓|✗|~
Use Cases      ✓|✗|~
UX/UI          ✓|✗|n/a
System Design  ✓|✗|~
Roadmap        ✓|✗|~

Traceability: NN%
Open questions: [...]
Ready for bootstrap: YES | NO

## Hallazgos críticos (bloquean)
| # | Tipo | Descripción | Fase a reabrir |
## Hallazgos menores (no bloquean)
| # | Tipo | Descripción |
## Matriz de trazabilidad → docs/audit/TRACEABILITY.md
```

## Exit criteria

- FOUNDATION-AUDIT.md con veredicto `Ready for bootstrap: YES` (o decisión humana de seguir
  documentada).
- TRACEABILITY.md generado si audit_depth full.

## Handoff → state.yaml

```yaml
phases.audit:
  status: completed
  outputs: ["docs/audit/FOUNDATION-AUDIT.md", "docs/audit/TRACEABILITY.md"]
  summary: {cycles: 1, critical: 0, minor: 3, traceability: "96%", verdict: YES}
history += {event: "audit passed"}
current_phase: bootstrap
```
