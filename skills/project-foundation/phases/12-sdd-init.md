---
id: sdd_init
num: 12
deps: [agent_setup]
outputs: ["handoff al flujo SDD del entorno"]
---

# Fase 12 — SDD Initialization (handoff final)

## Objetivo

Preparar y disparar la inicialización de SDD en el proyecto. A partir de acá,
`project-foundation` deja de ser dueño de la implementación: las features se trabajan con
el flujo SDD del entorno.

## Precondiciones

1. Repo bootstrapped y con commit inicial/estructura real (fase 10).
2. AGENTS.md presente (fase 11).
3. Sin `blocked_on` activos.

## Proceso

1. Verificar que el entorno tiene flujo SDD disponible (p. ej. Gentle AI: skill/comando
   `sdd-init` o subagente `sdd-init`; en otros entornos, su equivalente).
2. Si existe → invocarlo/enlazarlo para inicializar el contexto SDD del proyecto
   (openspec/config, capabilities, testing capabilities, registry según su protocolo).
3. Si no existe → NO simular SDD. Entregar instrucciones de handoff:
   - Qué hacer primero (inicializar SDD en el entorno elegido).
   - Cómo arrancar cada feature: `/project-foundation feature FEAT-XXX`.
4. Cerrar el pipeline: mensaje final de ≤10 líneas con el estado completo (fases ✓, gates ✓,
   audit veredicto) y la ruta del roadmap.

## Reglas

1. Esta fase NO crea specs, proposals ni tasks: eso es del SDD.
2. Si sdd-init del entorno pregunta decisiones (testing framework, etc.), las responde el
   flujo SDD con el usuario — no este orquestador.
3. Al completar: `phases.sdd_init: completed` y `current_phase` queda en `sdd_init` con
   pipeline finalizado (history registra `pipeline completed`). El state queda como registro.

## Después del pipeline (mensaje final al usuario)

```text
Pipeline completado. Este proyecto quedó listo para features vía SDD:
- Roadmap: docs/product/ROADMAP.md (FEAT-001..NNN)
- Próxima acción recomendada: /project-foundation feature FEAT-001
- El brief generado alimenta: sdd-explore → sdd-new → spec → design → tasks → apply → verify
```

## Exit criteria

- SDD del entorno inicializado, O instrucciones de handoff entregadas (nunca simular SDD).
- Mensaje final de ≤10 líneas mostrado al usuario.
- `history` registra `pipeline completed`. `project-foundation` ya no es dueño de la implementación.

## Handoff → state.yaml

```yaml
phases.sdd_init:
  status: completed
  outputs: []
  summary: {sdd: "initialized|handoff-instructions"}
history += {event: "pipeline completed"}
```
