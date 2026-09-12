---
id: ux_ui
num: 06
deps: [product_freeze]
outputs: ["docs/product/UX-UI.md"]
---

# Fase 06 — UX/UI Foundation

## Objetivo

Definir la experiencia GLOBAL de la aplicación antes de desarrollar features independientes.
Fundamentos de UX/UI, NO diseño pantalla por pantalla.

## Inputs permitidos

- `PROJECT.md` (usuarios, alcance)
- `docs/product/DOMAIN.md` (actores — para perfiles de uso)
- `docs/product/USE-CASE-MAP.md` (para info architecture: qué necesita cubrir la navegación)

## Prohibido leer

- `docs/architecture/*` (el diseño técnico no condiciona la experiencia global).
- Diseño de pantallas concretas de features (eso nace en el SDD de cada feature).

## Interacción (2-3 rondas de máx 4)

Ronda 1 — plataforma y estrategia:
- Plataformas objetivo y enfoque (desktop-first / mobile-first / responsive).
- Aplicaciones de referencia que le gustan al usuario (con qué: su estética, su fluidez,
  su densidad de información). Si no tiene → delegar ux-reference-scan según tipo de producto.

Ronda 2 — personalidad y decisiones de patrón:
- Propuesta de personalidad visual (3 arquetipos con trade-offs, elegir).
- Preferencias de patrones donde haya diferencia real: sidebar vs topbar (según cantidad
  de módulos), tablas vs cards para entidades densas, modals vs drawers vs páginas.
- Accesibilidad: nivel objetivo (básico / AA).

Ronda 3 (solo production): tipografía, spacing, elevación, iconografía — proponer defaults
coherentes y confirmar.

## Delegación (opcional)

- [../agents/ux-reference-scan.md](../agents/ux-reference-scan.md): si el usuario no tiene
  referencias, un explorador web levanta 3-5 apps de referencia del tipo de producto.

## Template de UX-UI.md

```markdown
# UX/UI Foundation — <producto>

## Plataformas y estrategia responsive
## Perfiles de uso (por actor: dispositivo típico, frecuencia, contexto)
## Information architecture (áreas principales de navegación — derivadas del UC map)
## Layout global (navegación, densidad, jerarquía)
## Patrones de interacción (forms, tables, modals/drawers, feedback, loading, errors, empty states)
## Accesibilidad (nivel objetivo y reglas concretas)
## Personalidad visual (arquetipo elegido y por qué)
## Sistema básico: tipografía / spacing / radius / elevación / iconografía / colores
## Referencias (apps + qué tomar de cada una)
## Design principles (máx 7, accionables: "densidad sobre animación", etc.)
## Open questions
```

## Reglas

1. Todo lo no decidido → propuesta con default sensato confirmada en el checkpoint.
2. Los principios y patrones acá definidos son restricciones GLOBALES: el SDD de cada
   feature los consume y no los re-negocia.
3. Sección por sección: si un nivel más bajo no necesita esa sección (prototype sin
   identidad visual), dejar "no aplica en este nivel" explícito.

## Exit criteria

- UX-UI.md completo para el nivel del proyecto.
- Info architecture cubre las áreas del UC map.
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.ux_ui:
  status: completed
  outputs: ["docs/product/UX-UI.md"]
  summary: {platforms: 3, patterns: 8, a11y: AA, personality: "calm-dense"}
history += {event: "ux_ui completed"}
current_phase: system_design
```
