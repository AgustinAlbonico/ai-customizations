---
id: bootstrap
num: 10
deps: [audit]
outputs: ["estructura técnica inicial (según project-starter)"]
---

# Fase 10 — Technical Bootstrap (reusa project-starter)

## Objetivo

Materializar la estructura técnica: stack concreto, repo, dependencias, configs, CI, Docker,
estructura inicial. SIN código de negocio. Esta fase NO reimplementa project-starter: lo
invoca en modo `technical-only`.

## Preflight (obligatorio)

1. Verificar `project-starter` presente en `.agents/skills/`, `skills/` o `~/.agents/skills/`.
   Si falta: sugerir `npx skills add AgustinAlbonico/ai-customizations --skill project-starter
   --agent <agente> -y` y esperar instalación. No continuar sin él.
2. Verificar veredicto del audit: `Ready for bootstrap: YES` (o decisión humana registrada).

## Invocación

Ejecutar project-starter indicándole explícitamente el **modo technical-only** con estos
inputs (el entry gate de project-starter detecta el contexto del pipeline):

- `docs/architecture/SYSTEM-DESIGN.md` → decisiones macro ya tomadas (no re-preguntar)
- `docs/product/REQUIREMENTS.md` → solo NFRs como constraints de stack
- `.project-foundation/state.yaml` → level (define profundidad de sus preguntas)

Regla de handoff: project-starter consume las decisiones de dirección (patrón, repos,
superficies, lenguaje, familia de frameworks, tipos de store) COMO CONSTRAINTS y solo
pregunta lo que falta a nivel librería/concreto (ORM, UI lib, validación, linter, CI...),
usando Context7 para vigencia.

## Interacción

La maneja project-starter (sus reglas: question tool, máx 4 por ronda, checkpoints).
El orquestador NO duplica sus preguntas; solo verifica al final:

- ¿La estructura respeta SYSTEM-DESIGN.md? (spot-check: apps/packages vs containers)
- ¿Cero código de negocio generado?
- ¿README/.env.example/CI presentes según su plan?

## Conflictos

Si project-starter propone algo contradictorio con SYSTEM-DESIGN.md (p. ej. monorepo habiendo
decidido multi-repo): frenar, mostrar el conflicto, y resolver con el usuario. Si cambia algo
de fondo → reabrir fase 07 (`review system_design`) y cascada stale.

## Outputs esperados

- Estructura del repo bootstrapped + documento de decisiones técnicas (el que genera
  project-starter en `docs/tech-decisions/`) + dependencias instaladas + configs + CI.

## Exit criteria

- Estructura existe y refleja las decisiones.
- Sin código de negocio.
- El usuario confirmó el resultado del bootstrap.

## Handoff → state.yaml

```yaml
phases.bootstrap:
  status: completed
  outputs: ["<raíz bootstrapped>", "docs/tech-decisions/<archivo>"]
  summary: {apps: 2, packages: 1, ci: true, docker: true}
history += {event: "bootstrap completed via project-starter (technical-only)"}
current_phase: agent_setup
```
