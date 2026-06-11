---
name: playwright-spec-verifier
description: "Trigger: verificar spec, probar spec, /verificar-spec, e2e visual. Ejecuta specs con Playwright MCP y documenta errores en iteracion 1/errores/."
license: MIT
metadata:
  scope: [root]
  auto_invoke:
    - "playwright-spec-verifier"
  author: ai-customizations
  version: "1.1"
---

# Skill: Playwright Spec Verifier

## Activation Contract

Usa esta skill cuando el usuario pida verificar, probar o auditar un spec funcional con Playwright MCP. Entrada esperada: nombre o ruta de un archivo spec, por ejemplo `/verificar-spec 01-registrar-nutricionista.md`.

## Hard Rules

- No revises codigo de implementacion para inferir comportamiento; el navegador, network requests y consola son la fuente de verdad.
- NUNCA levantes backend ni frontend. Si `localhost:3000` o `localhost:5173` no responde, pedi al usuario que los levante y frena.
- Lee solo el spec indicado y `CREDENCIALES_SEED.md`, salvo que el usuario autorice mas contexto.
- Usa credenciales seed, no hardcodees usuarios ni passwords fuera de lo leido.
- Genera datos de prueba unicos con timestamp para evitar choques entre ejecuciones.
- Documenta evidencia concreta: status HTTP, request relevante, mensaje UI, screenshot si aporta.
- Si el archivo de errores ya existe, agrega una seccion nueva de verificacion; no sobrescribas evidencia previa sin permiso.

## Decision Gates

| Situacion | Accion |
| --- | --- |
| No se encuentra el spec | Preguntar una sola vez por la ruta exacta |
| Servidor caido | Pedir al usuario que lo levante y detenerse |
| Actor o ruta ambiguos | Inferir del spec; si no alcanza, preguntar |
| Dependencia fuera del spec | Marcar como no verificada, no expandir alcance |
| Reporte existente | Append con `## Verificacion <fecha>` |
| Error reproducible | Registrar como funcional o UI/UX con impacto |

## Execution Steps

1. Resolver el spec: probar ruta exacta, `iteracion 1/<archivo>` y `iteracion 1/**/<archivo>`. Si no aparece, preguntar.
2. Leer el spec completo y extraer actor, pantalla, camino principal, alternativos, casos borde, endpoints y criterios de aceptacion.
3. Leer `CREDENCIALES_SEED.md` para elegir la cuenta seed del actor.
4. Verificar puertos con `Test-NetConnection` para backend 3000 y frontend 5173. Si fallan, detenerse.
5. Crear una matriz corta de aceptacion: que pidio el spec vs que deberia verse/probarse.
6. Ejecutar Playwright MCP: navegar, loguear, probar flujo feliz, probar alternativos, revisar `network_requests`, consola y snapshots.
7. Guardar 2-3 screenshots solo para estados clave o discrepancias.
8. Crear `iteracion 1/errores/` si falta y escribir o anexar `iteracion 1/errores/<nombre-del-spec>.md`.

## Output Contract

El reporte debe usar esta estructura:

```markdown
# <Titulo del spec>: Errores detectados

> **Fuente**: `<ruta-del-spec>`
> **Fecha**: <fecha actual>
> **Herramienta**: Playwright MCP
> **Evidencia**: <screenshots/request ids si aplica>

---

## Errores funcionales

### N. <titulo corto>

- **Spec**: <que dice el spec>
- **Realidad**: <que paso en la prueba>
- **Impacto**: <por que importa>

---

## Problemas de UI/UX

### N. <titulo corto>

- **Spec**: <que dice el spec>
- **Realidad**: <que se ve en la pantalla>
- **Impacto**: <por que importa>

---

## Funcionalidades que SI funcionan

- <item 1>
- <item 2>

---
```

Al usuario devolve solo: cantidad de OK, cantidad de errores funcionales, cantidad de problemas UI/UX y ruta del archivo generado.

## References

- `CREDENCIALES_SEED.md` — credenciales seed para login por rol.
- `iteracion 1/errores/` — destino de reportes de verificacion.
