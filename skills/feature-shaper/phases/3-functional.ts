# Fase 3 — Requerimientos Funcionales (PRIORIDAD ALTA)

## Propósito

Detallar QUÉ tiene que poder hacer el sistema. Esta es la fase más importante.

## Estructura por RF

Para cada requerimiento funcional:

```
### RF-##: [Nombre descriptivo]
**Descripción:** Qué hace el requerimiento
**Datos requeridos:** Qué datos necesito para esto
**Comportamiento:** Paso a paso qué ocurre
**Validaciones:** Qué se valida antes de completarse
**Errores:** Qué sale mal y cómo se reporta
**Estados:** Si aplica, qué estados tiene y cómo transiciona
```

## Inventario completo

### Actor principal y secundario
¿Quién usa esto? ¿Qué roles están involucrados?

### Pantallas / Vistas
¿Qué vistas/componentes necesita esta feature?

### CRUD operations
¿Qué operaciones hay? (Create, Read, Update, Delete, o combinaciones)

### Integraciones externas
¿Qué sistemas externos se tocan? (APIs, webhooks, servicios)

### Fluxos de datos
¿Cómo viaja la información? ¿De dónde viene y dónde termina?

### Permisos
¿Qué roles pueden hacer qué acciones?

### Estados y transiciones
¿Hay entidades con estados que cambian? Mostrar machine de estados si aplica.

### Notificaciones
¿Se notifica a alguien cuando algo ocurre?

## Técnica de exploración

Si el usuario dice algo vago como "un panel de administración", insistir:
- "Describí qué puede hacer el admin ahí"
- "¿Qué ve el admin? ¿Qué acciones puede tomar?"
- "¿Qué datos ve/variables necesita?"

Un RF bien escrito debería permitir que otro developer lo implemente sin preguntarte nada más.
