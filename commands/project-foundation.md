---
description: Pipeline de definicion de proyecto desde la idea hasta dejarlo listo para SDD
---

Usa la skill `project-foundation` con `$ARGUMENTS` (vacío = reanudar desde el estado).

Seguí la skill exactamente: leé `.project-foundation/state.yaml`, mostrá el dashboard, cargá SOLO el contrato de la fase actual y sus inputs whitelisted, delegá el trabajo pesado a subagentes, validá outputs contra las exit criteria, persistí el estado y mostrá checkpoints cortos.

Con `status` solo mostrá el dashboard. Con `review <fase>` reabrí con cascada stale. Con `feature FEAT-XXX` compilá el brief según `references/feature-intake.md`.

No reimplementes SDD, no salteés gates, no leas todo el proyecto.
