---
id: agent_setup
num: 11
deps: [bootstrap]
outputs: ["AGENTS.md (+ locales si aplica)"]
---

# Fase 11 — Agent Setup (reusa agentmd-generator + opcional project-onboarding)

## Objetivo

Configurar el proyecto para trabajo con agentes: AGENTS.md jerárquico como router de
contexto y, opcionalmente, skills de stack instaladas y ruteadas.

## Precondiciones (no negociables)

AGENTS.md solo se genera cuando:
1. La estructura real ya existe (fase 10 completada).
2. El stack ya está elegido.
3. Los boundaries reales están definidos (apps/packages reales).

## Paso 1 — AGENTS.md (reuso directo)

Invocar `agentmd-generator` tal cual está (es una caja negra: análisis de repo → preguntas
adaptativas → AGENTS.md raíz + locales). Reglas:

- Precondiciones ya cumplidas por esta fase; su fase 1 (repository analysis) va a detectar
  la estructura real.
- NO duplicar documentación de producto dentro de AGENTS.md: si el generador pide contexto,
  pasarle referencias a PROJECT.md/DOMAIN.md, no su contenido.
- Preflight: verificar presencia de `agentmd-generator` (mismas ubicaciones que fase 10);
  si falta, sugerir instalación y esperar.

## Paso 2 — Skills de stack (opcional, encadenado con project-onboarding)

Preguntar UNA vez: "¿Querés que instale skills recomendadas para el stack detectado
(descubrimiento + auditoría + aprobación antes de instalar)?"

- SÍ → invocar `project-onboarding` tal cual (detect-stack → npx skills find → auditoría
  SAFE/REVIEW/BLOCKED → aprobación → instalación → ruteo manual a AGENTS.md).
- NO → registrar en history y continuar. Se puede correr después manualmente.

## Paso 3 — Ruteo

Tras cualquier instalación de skills, el agente actualiza las tablas auto-invoke
de los AGENTS.md según la metadata `scope` + `auto_invoke` de cada skill instalada
(o deja que project-onboarding lo haga en su fase 4). Sin scripts externos: leer
metadata, resolver AGENTS.md destino por scope, agregar fila sin duplicar.

## Interacción

Mínima: la pregunta del paso 2 + las preguntas propias de agentmd-generator (sus reglas
adaptativas). El orquestador no agrega entrevistas propias.

## Exit criteria

- AGENTS.md raíz generado y validado (checklist del propio agentmd-generator).
- Skills de stack instaladas y ruteadas SOLO si el usuario aprobó.
- `.project-foundation/` referenciado o ignorado correctamente en AGENTS.md (es estado
  operacional del pipeline, no documentación de producto).

## Handoff → state.yaml

```yaml
phases.agent_setup:
  status: completed
  outputs: ["AGENTS.md"]
  summary: {agents_md: "root+2", stack_skills: 6, onboarding: "approved"}
history += {event: "agent_setup completed"}
current_phase: sdd_init
```
