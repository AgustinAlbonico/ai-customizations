# Feature Intake — compilador de feature briefs

Comando: `/project-foundation feature FEAT-XXX`. Compila el contexto necesario para iniciar
el desarrollo de una feature del roadmap mediante SDD. **El brief NO es una fuente de
verdad**: es contexto compilado. La verdad vive en los documentos fuente (IDs estables).

## Precondiciones

0. Si `.scratch/` no está en el `.gitignore` del proyecto target, agregarlo al generar el
   primer brief (los briefs son contexto compilado, no artefactos de repo).

1. `.project-foundation/state.yaml` existe (el pipeline corrió al menos hasta roadmap).
2. `docs/product/ROADMAP.md` existe y contiene la entrada de `FEAT-XXX`.
3. Si la feature tiene dependencias `Depends on` con status distinto de done/shipped:
   advertirlo en el brief (no bloquear; decide el equipo).

## Qué leer (y nada más)

| Fuente | Qué extraer |
|---|---|
| `docs/product/ROADMAP.md` | La entrada completa de FEAT-XXX + las features de las que depende (nombre/propósito) |
| `PROJECT.md` | Solo: problema en 2-3 líneas + value proposition |
| `docs/product/DOMAIN.md` | Actores, entidades, términos, BRs y estados INVOLUCRADOS en los UCs/FRs de la feature (no todo el documento) |
| `docs/product/REQUIREMENTS.md` | Los FR/NFR listados en la entrada del roadmap, completos |
| `docs/product/USE-CASE-MAP.md` + `use-cases/` | Los UCs listados; archivos individuales COMPLETOS si existen |
| `docs/product/UX-UI.md` | Design principles + patrones globales que aplican; patrones específicos del área si los hay |
| `docs/architecture/SYSTEM-DESIGN.md` | Containers/componentes involucrados + decisiones de dirección relevantes + tabla de decisiones aplicables |
| `docs/architecture/adr/` | Solo ADRs que afecten a la feature |
| Open questions | Las registradas en los documentos fuente SOLO para esta feature |

## Reglas de compilación

1. Verbatim para requisitos/reglas (con ID); resumen para contexto (marcado como resumen).
2. Cero contenido nuevo: si falta algo, listar "gaps detectados" — no inventar.
3. Toda sección cita su fuente (`(DOMAIN.md)` / `(UC-APP-001)`), para que el SDD pueda volver
   a la fuente si duda.

## Output

`.scratch/feature-briefs/FEAT-XXX.md` (gitignored; se regenera cuando se necesita):

```markdown
<!-- GENERATED BRIEF — no es fuente de verdad. Fuentes: ROADMAP/DOMAIN/REQUIREMENTS/
     USE-CASES/UX-UI/SYSTEM-DESIGN (IDs estables). Regenerar con /project-foundation feature FEAT-XXX -->

# Feature Brief — FEAT-XXX: <nombre>
- Propósito: (ROADMAP)
- Status/Phase: (ROADMAP)
- Depends on: FEAT-YYY <nombre> — <status> (ROADMAP)

## Contexto de producto (resumen, PROJECT.md)
## Dominio involucrado (actores/entidades/BR/estados — DOMAIN.md)
## Requirements (verbatim con ID — REQUIREMENTS.md)
## Use cases (verbatim — UC-*.md)
## UX/UI aplicable (principios + patrones — UX-UI.md)
## System design aplicable (containers + decisiones — SYSTEM-DESIGN.md / ADRs)
## Open questions heredadas
## Gaps detectados por el compilador (si los hay)
```

## Después del brief

Sugerir el arranque SDD del entorno con el brief como contexto de entrada:
`sdd-explore → sdd-new/proposal → spec → design → tasks → apply → verify`
(en Gentle AI; equivalente en otros entornos). El orquestador NO participa del SDD.
