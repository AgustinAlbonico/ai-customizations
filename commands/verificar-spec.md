---
description: Verificar un spec funcional con Playwright MCP y documentar errores
---

Usa la skill `playwright-spec-verifier` para verificar el spec `$ARGUMENTS`.

Segui la skill exactamente: resuelve la ruta del archivo, lee el spec, verifica servidores sin levantarlos, proba el flujo con Playwright MCP, revisa network/console/snapshots, y documenta los errores en `iteracion 1/errores/` con el mismo nombre del spec.

No revises codigo de implementacion salvo que el usuario lo autorice explicitamente.
