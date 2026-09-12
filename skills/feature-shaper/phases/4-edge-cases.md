# Fase 4 — Casos Borde (PRIORIDAD MUY ALTA)

## Propósito

Descubrir escenarios no intentionados que romperían la feature o la harían incompleta.

## Técnica

**Layered edge case probing**: cuando el usuario responde un edge case, preguntar "¿Y si eso ocurre DENTRO del flujo de [otro paso]?" para crear árboles de edge cases.

## Patrones de preguntas

### Condiciones de error
- "¿Qué pasa si [X] falla?"
- "¿Y si [X] timeout?"
- "¿Qué pasa si [X] devuelve un error en vez de datos?"

### Estados límite
- "¿Y si no hay ningún registro?"
- "¿Y si hay 10.000 registros?"
- "¿Y si el usuario no tiene permisos?"
- "¿Y si el recurso fue borrado por otro?"

### Comportamiento inesperado
- "Si el usuario abre la pantalla y se va sin hacer nada, ¿qué debería pasar?"
- "¿Qué pasa si hace click rápido 5 veces?"
- "¿Qué pasa si navega con el back button en el medio del flujo?"

### Integridad de datos
- "¿Qué pasa si se pierde conexión a mitad del envío?"
- "¿Qué pasa si un archivo está corrupto?"
- "¿Y si la API externa cambia su formato de respuesta?"

### Concurrencia y race conditions
- "¿Qué pasa si dos admins editan lo mismo al mismo tiempo?"
- "¿Qué pasa si llega un webhook duplicado?"

### Edge cases técnicos
- "¿Qué pasa si el servicio están caido?"
- "¿Qué pasa si el CDN no responde?"
- "¿Qué pasa si la query tardó 30 segundos?"

## Categorización de edge cases

| Categoría | Descripción |
|---------|-------------|
| **ERR** | Error de usuario o sistema — cómo se reporta, cómo se recovered |
| **EDGE** | Condición límite — vacío, overflow, sin permisos |
| **RACE** | Concurrencia — dos acciones simultáneas |
| **DEGRAD** | Degradación — servicio externo caído |
| **RECOV** | Recuperación — rollback, retry, retry con backoff |

## Regla de oro

Si el usuario no tiene respuesta para un edge case, asumir el camino seguro:
- Registrar en el doc como "**ASUMIDO**: si [X] ocurre, se [Y]" 
- Eso no bloquea; se levanta como TODO post-launch

##checklist final de edge cases

Antes de avanzar a Fase 5, asegurar de cubrir:

- [ ] Fallo en servicio externo
- [ ] Timeout de red
- [ ] Datos vacíos
- [ ] Overflow de datos
- [ ] Permisos insuficientes
- [ ] Navegación inesperada (back button, close tab)
- [ ] Concurrencia
- [ ] Datos corruptos o malformados
- [ ] Recuperación post-error
