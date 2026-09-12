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

- `/shape "mi idea"` — Flow completo: descubrimiento conversacional en 6 fases → PRD de negocio + Plan técnico en `docs/features/<slug>/`.
- `/prd "mi idea"` — Modo PRD rápido (ex `prd-creator`): PRD de negocio sin plan técnico, en `docs/prd/YYYY-MM-DD-<nombre>.md`.

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
  prompt: "Explora el codebase actual. Prioriza los directorios de backend y frontend (ej: apps/backend/src/ y apps/frontend/src/, o equivalentes según el repo). Identifica:\n1. Stack tecnológico exacto\n2. Patrones de arquitectura\n3. Convenciones de código\n4. Estructura de módulos backend\n5. APIs existentes\n6. Modelo de datos actual\n7. Integraciones externas\n8. Packages compartidos (shared/common)\n9. Frontend: store, API layer, routing\n10. Todo lo relevante para diseñar un nuevo feature module\n\nReturn resumen estructurado."
}
```

> Nota: adaptar los paths al repo real. Nunca hardcodear nombres de proyectos o packages concretos.

---

## Templates y referencias

- `phases/1-context.md`
- `phases/2-scope.md`
- `phases/3-functional.md`
- `phases/4-edge-cases.md`
- `phases/5-technical.md`
- `phases/6-review.md`
- `templates/prd-template.md` — estructura del PRD del flow completo
- `templates/plan-template.md` — estructura del Plan técnico
- `references/prd-only-template.md` — template del modo PRD rápido (heredado de `prd-creator`)
- `references/question-bank.md` — banco de preguntas por complejidad (heredado de `prd-creator`)

---

## Modo PRD rápido (`/prd`)

Genera solo el PRD de negocio, sin plan técnico. Output: `docs/prd/YYYY-MM-DD-<nombre-kebab-case>.md`.

1. **Explorar contexto primero** (obligatorio, sin preguntar): detectar si el proyecto
   es sistema existente o greenfield, recorrer la estructura relevante y armar un mapa
   delta interno (qué existe, qué cambia, qué NO está en alcance). Mostrar resumen breve
   con modo, alcance inicial detectado y lo que queda fuera de foco.
2. **Clasificar complejidad del delta** (no de todo el sistema) para calibrar preguntas:
   simple (0-1 rondas, 0-4 preguntas) · media (1-2 rondas, 4-8) · alta (2-3 rondas, 8-15) ·
   muy alta (3-4 rondas, 15-20). Si el input ya trae contexto suficiente (>150 palabras
   con problema, usuarios y alcance claros), preguntar solo lo que falte.
3. **Entrevistar con `question`** (máx 4 por ronda, mezclando opciones y abiertas).
   Elegir preguntas de `references/question-bank.md`. Cada pregunta debe pasar el filtro:
   ligada al pedido, no respondida ya, su respuesta cambia una decisión del PRD,
   redactada en términos de negocio del flujo afectado. **Nunca preguntar por stack,
   tecnologías ni implementación.**
4. **Checkpoint**: presentar resumen (problema, usuarios, alcance IN/OUT, flujos,
   criterios de éxito) y pedir confirmación antes de redactar.
5. **Generar con `references/prd-only-template.md`**: requisitos priorizados P0/P1/P2
   con criterios de aceptación, criterios de éxito en Gherkin simplificado, al menos
   2 items fuera de alcance (proponerlos si el usuario no los dio), lenguaje de negocio.
6. **Persistir** en `docs/prd/` (crear el directorio si no existe) tras aprobación del usuario.

---

## Output de documentos

- PRD: `docs/features/<slug>/<slug>-prd.md`
- Plan: `docs/features/<slug>/<slug>-plan.md`
- Se generan al final de Fase 6, luego de confirmación
- Cambios post-review: ajustar solo lo afectado
