---
id: system_design
num: 07
deps: [product_freeze]
outputs: ["docs/architecture/SYSTEM-DESIGN.md", "docs/architecture/adr/"]
---

# Fase 07 — System Design

## Objetivo

Definición técnica GLOBAL del sistema: contexto, contenedores, componentes deployables,
comunicación, data stores, decisiones arquitectónicas. Empieza la definición técnica, pero
SOLO a nivel sistema — jamás a nivel feature.

## Inputs permitidos

- `PROJECT.md`, `docs/product/DOMAIN.md`, `docs/product/REQUIREMENTS.md` (NFRs),
  `docs/product/UX-UI.md` (plataformas).

## Límite duro (qué NO se define acá)

Todo lo que pertenece al SDD de una feature: `CreateAppointmentController`, `POST
/appointments`, `CreateAppointmentDto`, schemas de tablas concretas, componentes de UI de
pantallas. Si una decisión solo afecta a una feature, no es de esta fase.

## Interacción (2-3 rondas de máx 4)

Ronda 1 — arquitectura macro:
- Proponer patrón (monolito / modular monolith / microservicios) con trade-offs según
  nivel y equipo; MVP/internal → recomendar monolito o modular monolith y justificar.
- Repositorio (mono/multi), superficies deployables, target de despliegue.

Ronda 2 — tecnología de dirección (NO libs concretas — eso es fase 10):
- Lenguaje principal + familia de frameworks (con Context7/web si hay duda de vigencia).
- Tipo de data stores (relacional / documento / búsqueda...) SIN elegir producto final.
- Estrategia global de auth, comunicación entre componentes, realtime si aplica, colas si aplica.

Ronda 3 — transversales:
- Observabilidad, seguridad global, estrategia de testing global, CI/CD de alto nivel.

Cada recomendación: ventaja principal, desventaja principal, cuándo NO conviene (patrón
heredado de project-starter). Advertir inconsistencias antes de avanzar.

## ADRs — solo si la decisión cumple las 3 condiciones

1. Costosa de revertir. 2. No sería obvia en el futuro. 3. Surge de un trade-off real.

Archivo: `docs/architecture/adr/NNNN-kebab-title.md` con: Contexto / Decisión / Alternativas
consideradas / Consecuencias. Si no las cumple → queda como fila en la tabla de decisiones
de SYSTEM-DESIGN.md, sin ADR.

## Delegación

- [../agents/system-design-drafter.md](../agents/system-design-drafter.md): escribe el
  draft completo a partir de las decisiones de las rondas (el orquestador NO redacta el
  documento entero inline).

## Template de SYSTEM-DESIGN.md

```markdown
# System Design — <producto>

## System context (actores externos y sistemas con los que interactúa)
## C4 — Context (diagrama ASCII)
## C4 — Containers (diagrama ASCII + tabla: container, responsabilidad, tecnología de dirección, comunicación)
## Componentes/deployables principales y responsabilidades
## Data stores (tipo, justificación, qué dominio persiste cada uno)
## Sistemas externos e integraciones
## Arquitectura general (patrón elegido y por qué)
## Deployment (target, modelo de release, ambientes)
## Authentication strategy (global)
## Storage / colas / realtime (si aplica)
## Observabilidad
## Seguridad global
## Testing strategy global (pirámide, tipos, qué se automatiza)
## Repository layout (mono/multi, apps/packages previstos)
## Tecnología de dirección (lenguaje, frameworks, stores — sin libs de detalle)
## Tabla de decisiones (las que NO justifican ADR)
## Open questions
```

## Exit criteria

- SYSTEM-DESIGN.md completo para el nivel; C4 context + containers en ASCII.
- Todo ADR creado cumple las 3 condiciones.
- Cero diseño a nivel feature (límite duro respetado).
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.system_design:
  status: completed
  outputs: ["docs/architecture/SYSTEM-DESIGN.md", "docs/architecture/adr/"]
  summary: {containers: 3, adrs: 2, pattern: "modular-monolith"}
history += {event: "system_design completed"}
current_phase: roadmap
```
