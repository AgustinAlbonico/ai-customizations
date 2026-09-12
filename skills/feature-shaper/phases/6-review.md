# Fase 6 — Review

## Propósito

Mostrar un resumen ejecutivo de todo lo que se va a implementar, en formato digerible.

## REGLA: nada de document dump

**No mostrar los .md completos.** Solo un resumen ejecutivo.

---

## Formato del resumen

```
# Resumen: [Nombre de Feature]

## Problema que resuelve
[1-3 oraciones]

## Alcance

### Dentro
- [...]

### Fuera (explicit out of scope)
- [...]

## RF principales
| # | Requerimiento | Actor |
|---|---------------|-------|
| RF-01 | [Nombre] | [Actor] |
| RF-02 | [Nombre] | [Actor] |
| RF-03 | [Nombre] | [Actor] |

## Edge cases manejados
| Edge case | Comportamiento |
|-----------|---------------|
| [condición] | [qué pasa] |
| [condición] | [qué pasa] |

## Stack y arquitectura
- **Backend:** [stack]
- **Frontend:** [stack]  
- **DB:** [modelo de datos + ORM]
- **Externos:** [integraciones]

## Modelo de datos
- Entidad: [nombre] → [relación]
- Entidad: [nombre] → [relación]

## API endpoints
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | /api/... | [...] |
| POST | /api/... | [...] |

## Fases de implementación
1. **Fase 1:** [qué]
2. **Fase 2:** [qué]
3. **Fase 3:** [qué]

## Archivos a crear
- `apps/backend/src/...`
- `apps/frontend/src/...`

## Archivos a modificar
- `apps/backend/src/...`
- `apps/frontend/src/...`

---

¿Procedemos a generar los documentos `.md`?
```

## Después de confirmación

Generar:
- `docs/features/<slug>/<slug>-prd.md`
- `docs/features/<slug>/<slug>-plan.md`

Usar templates correspondientes.
