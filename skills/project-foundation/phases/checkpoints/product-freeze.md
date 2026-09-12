# Gate — Product Freeze

Checkpoint entre la definición de producto y el diseño (fases 06+). Lo ejecuta el orquestador;
no es una fase con documento propio, es una decisión de avance.

## Cuándo

Al completarse `use_cases` y antes de habilitar `ux_ui` / `system_design` / `roadmap`.

## Checklist (leer SOLO estos documentos para validarlo)

- [ ] `PROJECT.md`: producto y alcance claros, sin jerga técnica, out-of-scope explícito.
- [ ] `DOMAIN.md`: actores claros, terminología canónica sin conflictos, BRs con ID.
- [ ] `REQUIREMENTS.md`: P0s completos y trazables a capabilities; sin CÓMO.
- [ ] `USE-CASE-MAP.md`: UCs principales definidos; cobertura de FR-P0 completa.
- [ ] Incógnitas críticas: sin `blocked_on` activos que afecten producto/dominio.

## Reglas

1. Si un ítem falla → NO avanzar. Reabrir la fase específica (`review <fase>`) o resolver el
   gap en la propia fase si sigue `in_progress`.
2. Presentar al usuario el resultado en ≤10 líneas + decisión: `congelar producto` / `corregir X`.
3. Solo con confirmación explícita: `checkpoints.product_freeze: {status: passed, passed_at: <ahora>}`.
4. Freeze ≠ inmutabilidad: si más adelante se reabre una fase de producto (00–05), el gate
   vuelve a `pending` (cascada stale) y debe re-validarse.

## Handoff → state.yaml

```yaml
checkpoints.product_freeze: { status: passed, passed_at: <ahora> }
history += {event: "product_freeze passed"}
current_phase: ux_ui
```
