---
name: feature-shaper
description: >
  Transforma ideas vagas en definiciones estructuradas de features mediante conversación adaptativa.
  Usa 5.5 fases (contexto, alcance, funcional, casos borde, técnico, review) para convertir una idea
  en un PRD de negocio y un Plan técnico con arquitectura. Genera dos documentos: <slug>-prd.md y
  <slug>-plan.md. El caso de uso es "quiero un..." o "/shape mi idea".
---

# Skill: feature-shaper

Transforma ideas vagas en definiciones estructuradas de features mediante conversación adaptativa.

## Trigger

`/shape "mi idea"` — Inicia flow de descubrimiento conversacional.

## Output

Dos documentos generados en `docs/features/<slug>/`:

- `<slug>-prd.md` — PRD con formato de negocio
- `<slug>-plan.md` — Plan técnico con decisiones de diseño y arquitectura

Slug: `YYYY-MM-DD-HH-MM-SS-slug-normalizado` (nombre lowercase con guiones, sin acentos).

---

## Flujo de fases

```
[Fase 1] CONTEXTO        → Breve. ¿Qué problema resuelve? ¿A quién?
[Fase 2] ALCANCE         → Breve. Inside vs. Outside.
[Fase 3] FUNCIONAL       → IMPORTANTE. RF detallados.
[Fase 4] CASOS BORDE     → MUY IMPORTANTE. Edge cases.
[Fase 5] TÉCNICO         → IMPORTANTE. Subagente explora codebase.
[Fase 6] REVIEW          → Resumen ejecutivo, no dump de docs.
```

Flujo adaptativo: si en Fase 3 surge un caso borde, ir a Fase 4 y volver. No строго orden.

---

## Reglas de conversación

1. **Una pregunta a la vez**
2. **Opción múltiple cuando sea posible**
3. **Fase 3 y 4 son priority** — invertir tiempo en RF y edge cases
4. **Fase 5 delega subagente** para explorar codebase
5. **Fase 6 resume** — nadie quiere leer specs de 50 páginas
6. **Sub-preguntas siempre bienvenidas**
7. **Graceful degradation** — si no hay respuesta, asumir camino seguro y documentar como "ASUMIDO"

---

## Subagente en Fase 5

Antes de preguntas técnicas:

```
task {
  subagent_type: "sdd-design",
  prompt: "Explora el codebase actual. Prioriza apps/backend/src/ y apps/frontend/src/. Identifica:\n1. Stack tecnológico exacto\n2. Patrones de arquitectura\n3. Convenciones de código\n4. Estructura de módulos backend\n5. APIs REST existentes\n6. Modelo de datos actual\n7. Integraciones externas\n8. Shared package (@nutrifit/shared)\n9. Frontend: store, API layer, routing\n10. Todo lo relevante para diseñar un nuevo feature module\n\nReturn resumen estructurado."
}
```

---

## Templates

- `phases/1-context.ts`
- `phases/2-scope.ts`
- `phases/3-functional.ts`
- `phases/4-edge-cases.ts`
- `phases/5-technical.ts`
- `phases/6-review.ts`
- `templates/prd-template.md` — estructura exacta de reference
- `templates/plan-template.md` — estructura exacta de reference

---

## Output de documentos

- PRD: `docs/features/<slug>/<slug>-prd.md`
- Plan: `docs/features/<slug>/<slug>-plan.md`
- Se generan al final de Fase 6, luego de confirmación
- Cambios post-review: ajustar solo lo afectado
