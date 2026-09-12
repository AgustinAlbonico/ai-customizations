# Gate — Design Freeze

Checkpoint entre la definición completa y la auditoría/bootstrap. Lo ejecuta el orquestador.

## Cuándo

Al completarse `ux_ui`, `system_design` y `roadmap`, y antes de habilitar `audit`.

## Checklist (leer SOLO estos documentos)

- [ ] Producto/Dominio/Requirements/UCs: siguen válidos (sin stale flags activos de
  reaperturas posteriores al product_freeze).
- [ ] `UX-UI.md`: fundamentos globales definidos para el nivel; cubre áreas del UC map.
- [ ] `SYSTEM-DESIGN.md`: C4 context+containers, decisiones de dirección, sin diseño de
  feature (límite duro de la fase 07).
- [ ] `ROADMAP.md`: trazabilidad FR-P0/UC → FEAT completa; dependencias acíclicas.
- [ ] Trazabilidad global (spot-check): 3 pares random FR→UC→FEAT consistentes.
- [ ] Contradicciones: ninguna detectada a simple vista entre docs.
- [ ] Preguntas abiertas críticas: ninguna que bloquee el arranque técnico.

## Reglas

1. Ítem fallido → reabrir la fase correspondiente (`review <fase>`), cascada stale aplica.
2. Presentar resultado en ≤10 líneas + decisión del usuario: `congelar diseño` / `corregir X`.
3. Con confirmación: `checkpoints.design_freeze: {status: passed, passed_at: <ahora>}`.
4. Freeze ≠ inmutabilidad (misma semántica que product freeze).

## Handoff → state.yaml

```yaml
checkpoints.design_freeze: { status: passed, passed_at: <ahora> }
history += {event: "design_freeze passed"}
current_phase: audit
```
