---
name: feature-shaper
description: >
  Transforma ideas vagas en definiciones estructuradas de features mediante conversación adaptativa.
  Usa 6 fases (contexto, alcance, funcional, casos borde, técnico, review) para convertir una idea
  en un PRD de negocio y un Plan técnico con arquitectura. Genera dos documentos: <slug>-prd.md y
  <slug>-plan.md. El caso de uso es "quiero un..." o "/shape mi idea".
---

# Skill: feature-shaper

Transforma ideas vagas en definiciones estructuradas de features.

## Trigger

`/shape "mi idea"` — Inicia el flujo de descubrimiento conversacional.

## Output

Dos documentos generados en `docs/features/<slug>/`:

- `<slug>-prd.md` — PRD con formato de negocio
- `<slug>-plan.md` — Plan técnico con decisiones de diseño y arquitectura

Slug: `YYYY-MM-DD-HH-MM-SS-slug-normalizado` (nombre lowercase con guiones, sin acentos).

---

## Flujo de 6 fases

```
[Fase 1] CONTEXTO        → Breve. ¿Qué problema resuelve? ¿A quién?
[Fase 2] ALCANCE         → Breve. Inside vs. Outside.
[Fase 3] FUNCIONAL       → IMPORTANTE. RF detallados.
[Fase 4] CASOS BORDE     → MUY IMPORTANTE. Edge cases.
[Fase 5] TÉCNICO         → IMPORTANTE. Subagente explora codebase.
[Fase 6] REVIEW          → Resumen ejecutivo + generar docs.
```

Flujo adaptativo: si en Fase 3 surge un caso borde, ir a Fase 4 y volver. No строго orden.

---

## Reglas de conversación

1. **Una pregunta a la vez**
2. **Opción múltiple cuando sea posible**
3. **Fase 3 y 4 son priority** — invertir tiempo en RF y edge cases
4. **Fase 5 delega subagente** para explorar codebase
5. **Fase 6 resume y genera** — resumen ejecutivo + documentos
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

- `phases/1-context.ts` — guía de preguntas Fase 1
- `phases/2-scope.ts` — guía de preguntas Fase 2
- `phases/3-functional.ts` — guía de preguntas Fase 3 (INCLUYE checklist de RF)
- `phases/4-edge-cases.ts` — guía de preguntas Fase 4 (INCLUYE checklist OBLIGATORIO de 17 edge cases)
- `phases/5-technical.ts` — guía preguntas técnicas + subagente
- `phases/6-review.ts` — formato del resumen + generación de documentos
- `templates/prd-template.md` — estructura del PRD
- `templates/plan-template.md` — estructura del Plan técnico

---

## Generación de documentos (Fase 6)

Cuando el usuario confirma en Fase 6:

### Paso 1: Generar slug
`slug = YYYY-MM-DD-HH-MM-SS-$(nombre-normalizado)`

### Paso 2: Crear directorio
`New-Item -ItemType Directory -Path "docs/features/<slug>" -Force`

### Paso 3: Escribir PRD
`write` tool → `docs/features/<slug>/<slug>-prd.md`
Usar `templates/prd-template.md` como estructura base.

### Paso 4: Escribir Plan
`write` tool → `docs/features/<slug>/<slug>-plan.md`
Usar `templates/plan-template.md` como estructura base.

### Paso 5: Confirmación
Mostrar al usuario los paths generados:
```
PRD guardado: docs/features/<slug>/<slug>-prd.md
Plan guardado: docs/features/<slug>/<slug>-plan.md
```

---

## Output de documentos

- PRD: `docs/features/<slug>/<slug>-prd.md`
- Plan: `docs/features/<slug>/<slug>-plan.md`
- Se generan al final de Fase 6, luego de confirmación del usuario
- Cambios post-review: ajustar solo lo afectado, no regenerar todo
