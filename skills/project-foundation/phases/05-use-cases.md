---
id: use_cases
num: 05
deps: [domain, requirements]
outputs: ["docs/product/USE-CASE-MAP.md", "docs/product/use-cases/"]
---

# Fase 05 — Use Case Modeling

## Objetivo

Modelar los casos de uso: el mapa actor → UCs es el registro canónico; los archivos
individuales documentan los UCs narrativos. Trazabilidad: Requirement → Use Case → Feature
futura.

## Inputs permitidos

- `docs/product/DOMAIN.md` (actores, entidades, BRs)
- `docs/product/REQUIREMENTS.md` (FRs/NFRs)

## Prohibido leer

- `PROJECT.md` salvo para resolver una ambigüedad puntual (es insumo de 02, no de acá).
- `docs/research/*`, y todo lo técnico.

## Interacción (máx 1-2 rondas de 3-4)

- Presentar el mapa derivado (actor → UCs) y pedir confirmación: faltan, sobran, nombres.
- Solo si surge: desambiguar límites de un UC ("¿cancelar incluye reprogramar o es otro UC?").

## Reglas de granularidad

1. Todo UC vive en el USE-CASE-MAP (una línea: `UC-<ÁREA>-NNN <Nombre>`).
2. Archivo individual SOLO para UCs narrativos: aquellos con ≥1 flujo alternativo o ≥1
   excepción no trivial. UCs triviales (consulta simple, lectura) quedan solo en el mapa.
3. IDs estables `UC-<ÁREA>-NNN`; el nombre del archivo es `UC-<ÁREA>-NNN-<slug>.md`.

## Proceso

1. Derivar UCs: cada FR-P0 con interacción de actor genera al menos un UC; FRs no
   interactivos (batch, constraints) se cubren como BR/postcondición de otro UC o quedan
   sin UC con justificación explícita en el mapa.
2. Confirmar mapa con el usuario.
3. Delegar la escritura de los UCs narrativos a [../agents/use-case-writer.md](../agents/use-case-writer.md)
   en lotes (el prompt recibe mapa + DOMAIN + REQUIREMENTS whitelisted).
4. Validar cada archivo contra el template antes de marcar completado.

## Template de USE-CASE-MAP.md

```markdown
# Use Case Map — <producto>

## <Actor>
- UC-APP-001 Book Appointment — narrativo (archivo)
- UC-APP-002 View Schedule — solo mapa

## <Actor>
...

## Cobertura
| FR | UC(s) | Nota (si no tiene UC, por qué)
```

## Template de cada UC (docs/product/use-cases/UC-*.md)

```markdown
# UC-<ÁREA>-NNN — <Nombre>
## Objetivo
## Actor principal / Actores secundarios
## Trigger
## Preconditions
## Main flow (numerado)
## Alternate flows (numerados, con punto de bifurcación)
## Exceptions (numeradas)
## Postconditions (éxito y fallo)
## Business rules (BR-NNN aplicadas)
## Requirements relacionados (FR-/NFR-)
```

## Criterios de calidad

- Flujos en lenguaje de dominio (términos de DOMAIN.md); pasos atómicos; sin UI concreta
  (botones, pantallas) ni tecnología.
- Cada UC referencia solo FRs/BRs existentes; cada FR-P0 aparece en cobertura (con UC o nota).

## Exit criteria

- Mapa completo con cobertura de FR-P0 al 100%.
- Archivos narrativos escritos y validados.
- Checkpoint confirmado.

## Handoff → state.yaml

```yaml
phases.use_cases:
  status: completed
  outputs: ["docs/product/USE-CASE-MAP.md", "docs/product/use-cases/"]
  summary: {actors: 4, use_cases: 14, narrative_files: 9, p0_coverage: "100%"}
history += {event: "use_cases completed"}
```
