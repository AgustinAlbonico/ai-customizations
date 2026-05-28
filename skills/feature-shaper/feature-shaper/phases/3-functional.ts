# Fase 3 — Funcional (IMPORTANTE)

## Regla

Esta fase es la más importante. Invertir tiempo. Varias preguntas hasta cubrir todo.

## Estructura de cada RF

```
### RF-##: [Nombre]
**Descripción:** [qué hace el requerimiento]
**Actor:** [quién lo usa]
**Datos requeridos:** [qué datos necesita]
**Comportamiento:**
1. [paso 1]
2. [paso 2]
3. [paso 3]
**Validaciones:** [qué se valida antes de completarse]
**Errores:** [qué sale mal y cómo se reporta]
**Estados:** [si aplica — qué estados y transiciones]
```

## Inventario completo (cubrir TODOS)

### 1. Actores y permisos
- ¿Cuántos roles hay?
- ¿Qué puede hacer cada rol?
- ¿Qué NO puede hacer cada rol?
- ¿Hay jerarquía entre roles?

### 2. Pantallas / Vistas
- ¿Qué pantallas necesita la feature?
- ¿Qué componentes principales?
- ¿Qué ve cada actor en cada pantalla?

### 3. Flujos principales
- Describir el flujo dorado paso a paso
- ¿Qué ocurre desde que el usuario inicia la acción hasta que termina?

### 4. Flujos alternativos
- ¿Qué pasa si hay un error en el medio?
- ¿Qué pasa si el usuario cancela?
- ¿Qué pasa si no tiene permisos?

### 5. Estados y transiciones
- ¿Hay entidades con estados que cambian?
- ¿Cuál es el diagrama de estados?

### 6. Integraciones externas
- ¿Qué APIs/servicios externos se tocan?
- ¿Qué contratos de API?

### 7. Notificaciones
- ¿Se notifica a alguien cuando algo ocurre?
- ¿Email, push, in-app?

## Técnica de exploración

Si el usuario dice algo vago como "un panel de admin":
→ "¿Qué puede hacer el admin ahí específicamente?"
→ "¿Qué ve? ¿Qué acciones puede tomar?"
→ "¿Qué datos necesita?"

Un RF bien escrito debería permitir que otro developer lo implemente sin hacer más preguntas.

## Fin de fase

Al terminar, mostrar resumen de todos los RF y preguntar:
"¿Falta algún requerimiento? ¿Algo no está claro?"