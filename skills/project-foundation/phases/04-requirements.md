---
id: requirements
num: 04
deps: [product, domain]
outputs: ["docs/product/REQUIREMENTS.md"]
---

# Fase 04 — Requirements

## Objetivo

Convertir producto + dominio en requisitos claros y trazables. Cada requisito dice QUÉ debe
cumplir el sistema, nunca CÓMO implementarlo.

## Inputs permitidos

- `PROJECT.md` (completo)
- `docs/product/DOMAIN.md` (completo — los términos canónicos son obligatorios)

## Prohibido leer

- `docs/research/*` — la competencia informa PROJECT.md, no los requisitos.
- `docs/architecture/*`, `docs/product/UX-UI.md` (no existen aún; y si existen de una
  reapertura, seguirán prohibidos como input de esta fase).

## Interacción (máx 2 rondas de 4)

Ronda 1 — prioridades y faltantes (sobre el draft):
- ¿Qué capabilities son P0 (sin ellas no hay producto)? (proponer y confirmar)
- NFRs de negocio que falten: performance percibida, disponibilidad, privacidad, auditoría
  (preguntar solo los relevantes al tipo de sistema).

Ronda 2 — validación de redacción derivada:
- Presentar los FR redactados como WHAT y pedir correcciones.
- Confirmar que ningún FR es en realidad una decisión técnica disfrazada.

## Delegación

- Draft inicial: [../agents/requirements-drafter.md](../agents/requirements-drafter.md)
  (escritor; recibe PROJECT.md + DOMAIN.md; escribe REQUIREMENTS.md).
- El orquestador revisa el draft contra las exit criteria ANTES de entrevistar, para que las
  preguntas salgan de gaps reales.

## Formato de IDs (estables, nunca renumerar)

```text
FR-<ÁREA>-NNN    Requisito funcional (ej: FR-APP-001)
NFR-<ÁREA>-NNN   Requisito no funcional (ej: NFR-SEC-001)
BR-NNN           Referencia a reglas de negocio de DOMAIN.md (fuente: DOMAIN.md)
```

Áreas: 2-4 letras mayúsculas, derivadas del dominio (AUTH, APP, ADM, BILLING...). Definir la
lista de áreas al inicio del documento y no ampliarla sin nota en history.

## Template de REQUIREMENTS.md

```markdown
# Requirements — <producto>

## Áreas definidas
| Área | Significado |

## Functional Requirements
| ID | Priority | Requirement (QUÉ, con actor) | Capability origen | BRs |
P0 = sin esto no hay producto; P1 = necesarios para buena experiencia; P2 = deseables.

## Non-Functional Requirements
| ID | Requirement (en lenguaje de negocio: "el usuario no debe esperar >2s", no "latencia <200ms") |

## Restricciones de negocio (referencias a BR y a PROJECT.md)

## Trazabilidad mínima
| Capability | FRs |

## Open questions
```

## Criterios de calidad

- Cada FR tiene actor + comportamiento verificable; redactable como criterio de aceptación.
- Cero mención de tecnologías, schemas, endpoints o patrones.
- Todo término usado está en DOMAIN.md (si apareció uno nuevo → volver a domain o agregarlo
  al glosario con confirmación).
- NFRs solo los que surgieron del producto/entrevista, no un checklist genérico.

## Exit criteria

- Todo P0 mapea a una capability de PROJECT.md.
- Sin FR duplicados ni solapados (fusionar antes que renumerar).
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.requirements:
  status: completed
  outputs: ["docs/product/REQUIREMENTS.md"]
  summary: {fr: 34, nfr: 6, p0: 12, areas: 5}
history += {event: "requirements completed"}
current_phase: use_cases
```
