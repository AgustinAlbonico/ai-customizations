---
id: product
num: 02
deps: [intake]
outputs: ["PROJECT.md"]
---

# Fase 02 — Product Definition

## Objetivo

Definir con precisión el producto: problema, propuesta, usuarios, objetivos, valor,
alcance y criterios de éxito. El documento debe ser **completamente entendible sin
conocimientos técnicos**.

## Inputs permitidos

- `.project-foundation/INTAKE.md` (completo)
- `docs/research/COMPETITIVE-ANALYSIS.md` (solo secciones resumen ejecutivo, gaps y
  oportunidades — la lectura completa la hace esta fase una vez, no las siguientes)

## Prohibido

- Stack, tecnologías, arquitectura, datos, endpoints (fases 07/10).
- Terminología de implementación (tablas, schemas, clases).

## Interacción (2-3 rondas de máx 4, adaptativo)

Ronda 1 — Producto y usuarios:
- ¿La propuesta de valor en una oración es X, correcto? (proponer derivada del intake y
  confirmar — no pedir que el usuario la redacte)
- ¿Usuarios/actores principales y qué obtiene cada uno?
- ¿Qué es lo mínimo que debe existir para que tenga valor real?

Ronda 2 — Alcance y éxito:
- Propuesta de in-scope / out-of-scope (mínimo 2 items fuera) — confirmar o ajustar.
- ¿Cómo sabés que funciona / qué métricas de negocio indicarían éxito?
- Restricciones de negocio no técnicas (regulaciones, presupuesto, plazos) si quedaron gaps.

Checkpoint final: presentar resumen de 6 líneas (problema, propuesta, usuarios, alcance,
éxito, capabilities) y pedir confirmación antes de escribir.

## Proceso

1. Leer inputs. Derivar borrador mental de cada sección.
2. Entrevistar SOLO los gaps (reglas de interacción del orquestador).
3. Escribir PROJECT.md con el template. Derivar lo faltante y marcarlo ASUMIDO si no es
   estructural; bloquear y preguntar si lo es.

## Template de PROJECT.md

```markdown
# <Nombre del producto> — Product Definition

## Problema (máx 2 párrafos, lenguaje de negocio)
## Propuesta (qué es, para quién, por qué ahora)
## Value proposition (1-2 oraciones)
## Usuarios
### <Actor> — qué necesita, dolor principal
## Objetivos (medibles con métricas de negocio)
## No-objetivos (explícitos)
## Alcance
### Incluido
### Fuera de alcance (mínimo 2)
## Restricciones (de negocio, no técnicas)
## Success criteria (escenarios Dado/Cuando/Entonces, lenguaje de negocio)
## Core capabilities (lista nombrada y breve — insumo de trazabilidad a FR/UC/FEAT)
## Supuestos (ASUMIDO)
## Open questions
```

## Criterios de calidad

- Cero jerga técnica; un no-técnico lo entiende completo.
- Capabilities con nombres estables (van a ser referenciadas por fases 04, 05 y 08).
- Out-of-scope explícito y defendido.

## Exit criteria

- PROJECT.md completo, todas las secciones (vacío explícito si no aplica).
- Sin términos técnicos de implementación.
- Checkpoint confirmado por el usuario.

## Handoff → state.yaml

```yaml
phases.product:
  status: completed
  outputs: ["PROJECT.md"]
  summary: {capabilities: 9, actors: 3, out_of_scope: 4, open_questions: 2}
history += {event: "product completed"}
current_phase: domain
```
