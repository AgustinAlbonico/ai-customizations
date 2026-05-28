# Fase 6 — Review

## Regla

NO mostrar los documentos completos. Solo resumen ejecutivo.

## Formato del resumen

```
# Resumen: [Nombre de Feature]

## Problema que resuelve
[1-3 oraciones]

## Alcance
- Dentro: [lista breve]
- Fuera: [lista breve]

## RF principales
| # | Requerimiento | Actor |
|---|---------------|-------|
| RF-01 | [Nombre] | [Actor] |
| RF-02 | [Nombre] | [Actor] |

## Edge cases manejados
| Edge case | Comportamiento |
|-----------|---------------|
| [condición] | [qué pasa] |
| [condición] | [qué pasa] |

## Stack y arquitectura
- Backend: [stack confirmado]
- Frontend: [stack confirmado]
- DB: [modelo de datos]
- Externos: [integraciones]

## Fases de implementación
1. [Fase 1]
2. [Fase 2]
3. [Fase 3]

## Archivos a crear / modificar
- Crear: [lista]
- Modificar: [lista]

---
¿Procedemos a generar los documentos?
```

## Después de confirmación

1. Crear directorio: `docs/features/<slug>/`
2. Generar `<slug>-prd.md` usando `templates/prd-template.md`
3. Generar `<slug>-plan.md` usando `templates/plan-template.md`
4. Mostrar confirmación:
```
PRD guardado: docs/features/<slug>/<slug>-prd.md
Plan guardado: docs/features/<slug>/<slug>-plan.md
```

## Si pide ajustes

Hacer SOLO los cambios solicitados. No regenerar todo.