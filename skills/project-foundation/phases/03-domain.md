---
id: domain
num: 03
deps: [product]
outputs: ["docs/product/DOMAIN.md"]
---

# Fase 03 — Domain Modeling

## Objetivo

Definir el vocabulario compartido del sistema: actores, entidades, terminología canónica,
relaciones, estados, invariantes y reglas de negocio. Dominio puro, **sin implementación**.

Inspiración: modelado de dominio estilo Matt Pocock — lenguaje preciso, vocabulario
compartido, dominio separado de implementación.

## Inputs permitidos

- `PROJECT.md` (completo)

## Prohibido

- `docs/research/*` (el mercado no define el dominio).
- Cualquier documento técnico (no existen todavía, y no deben existir).
- Términos de implementación: tabla, endpoint, DTO, controller, schema.

## Interacción (1-2 rondas de máx 4)

- Presentar los actores derivados de PROJECT.md y pedir confirmación/agregados.
- Por cada entidad ambigua: "¿X e Y son lo mismo o conceptos distintos?" (una pregunta,
  opciones + abierta).
- Términos con conflicto de naming: proponer término canónico y confirmar
  (p. ej. "Member es el término canónico para socio; prohibido client/customer").
- Reglas de negocio detectables: proponer redacción y pedir confirmación.

## Proceso

1. Extraer candidatos de actores/entidades/conceptos desde PROJECT.md.
2. Entrevistar solo ambigüedades y faltantes estructurales.
3. Escribir DOMAIN.md con IDs de reglas (BR-NNN) para trazabilidad futura.
4. Delegar verificación de consistencia a [../agents/domain-consistency.md](../agents/domain-consistency.md)
   (verificador read-only: términos usados vs definidos, contradicciones). Aplicar fixes
   junto al usuario si hay hallazgos.

## Template de DOMAIN.md

```markdown
# Domain Model — <producto>

## Actores (quién interactúa con el sistema y su rol)
| Actor | Descripción | Fuente de valor |

## Terminología canónica
| Término canónico | Definición precisa | Términos prohibidos/sinónimos |

## Entidades y conceptos (qué existe en el dominio, con descripción)
## Relaciones (entidad — relación — entidad, cardinalidad en lenguaje natural)
## Estados relevantes (solo si hay ciclos de vida: estado y qué lo habilita)
## Invariantes (lo que SIEMPRE debe cumplirse)
## Reglas de negocio
| ID | Regla | Razón de negocio |
BR-001: ...
## Glosario (términos secundarios)
## Open questions
```

## Criterios de calidad

- Todo término usado en PROJECT.md está definido (o agregado) en el glosario/canónica.
- Cada término canónico tiene definición en una oración, sin sinonimia interna.
- Reglas de negocio redactadas como restricciones del negocio, no como validaciones técnicas.

## Exit criteria

- DOMAIN.md completo con BR-IDs estables.
- Verificación de consistencia sin hallazgos críticos (menores documentados).
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.domain:
  status: completed
  outputs: ["docs/product/DOMAIN.md"]
  summary: {actors: 4, entities: 11, business_rules: 23}
history += {event: "domain completed"}
current_phase: requirements
```
