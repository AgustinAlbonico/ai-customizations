---
id: research
num: 01
deps: [intake]
outputs: ["docs/research/COMPETITIVE-ANALYSIS.md", "docs/research/notes/"]
---

# Fase 01 — Competitive / Market Research (condicional)

## Objetivo

Conocer el mercado: competidores, features, pricing, UX, quejas recurrentes, table-stakes,
gaps y posibles diferenciadores. La competencia **INFORMA** el producto; NUNCA genera
requirements automáticamente.

## Skip

Si `research_mode: skipped` → marcar `skipped` en state, una línea en history, pasar a product.
El orquestador puede reabrir esta fase más adelante (`review research` + cambiar research_mode).

## Inputs permitidos

- `.project-foundation/INTAKE.md`
- `.project-foundation/state.yaml`

## Interacción (máx 1 ronda de 2-3 preguntas)

- ¿Mercado/país de referencia? (default: el del usuario)
- ¿Competidores que ya conocés? (si da nombres, priorizarlos)
- Confirmar que está OK hacer investigación web de esta idea (default: sí).

## Delegación (paralelo cuando haya recursos)

| Subagente | Prompt | Output |
|---|---|---|
| explorador web ×N | [../agents/research-competitors.md](../agents/research-competitors.md) | `docs/research/notes/competitor-<nombre>.md` |
| explorador web | [../agents/research-reviews.md](../agents/research-reviews.md) | `docs/research/notes/reviews-<tema>.md` |
| escritor (síntesis) | [../agents/research-synthesis.md](../agents/research-synthesis.md) | `docs/research/COMPETITIVE-ANALYSIS.md` |

Alcance según nivel: mvp → 2-3 competidores + 1 pasada de reviews; production → 4-6 + 2.
Los exploradores corren en paralelo; la síntesis corre sola después, leyendo todas las notes.

## Proceso

1. Confirmar skip o alcance (según research_mode y nivel).
2. Ronda de interacción (arriba).
3. Lanzar exploradores en paralelo → esperar handoffs.
4. Lanzar síntesis con las notes completas.
5. Validar contra exit criteria antes de cerrar.

## Reglas

1. Cada explorador escribe su nota completa a archivo y devuelve solo el handoff.
2. La síntesis NO copia las notas: las condensa con estructura comparativa.
3. La sección "table-stakes" del output es descriptiva del mercado; NO es una lista de
   requirements (fase 04 solo puede tomarlas como contexto vía PROJECT.md).
4. Si la búsqueda web falla o devuelve poco: degradar con `ASUMIDO` y documentar el vacío,
   no inventar datos.

## Template de COMPETITIVE-ANALYSIS.md

```markdown
# Competitive Analysis — <producto>
Resumen ejecutivo (máx 5 líneas).

## Productos analizados
| Producto | Público | Pricing | Estado del análisis |

## Comparativa de features (tabla: feature × producto)

## UX y workflows destacados (por producto: fortalezas / debilidades)

## Reviews y complaints frecuentes (agrupados por tema, con fuente)

## Table-stakes del mercado

## Gaps y oportunidades

## Posibles diferenciadores

## Notas crudas
Links a notes/*.md
```

## Exit criteria

- COMPETITIVE-ANALYSIS.md existe con todas las secciones (vacías explícitas si no hubo dato).
- Cada claim relevante tiene fuente o marca `ASUMIDO`.
- Ningún FR/requirement fue generado en esta fase.

## Handoff → state.yaml

```yaml
phases.research:
  status: completed
  outputs: ["docs/research/COMPETITIVE-ANALYSIS.md"]
  summary: {competitors: 4, complaints_themes: 6, gaps: 3, differentiators: 2}
history += {event: "research completed"}
current_phase: product
```
