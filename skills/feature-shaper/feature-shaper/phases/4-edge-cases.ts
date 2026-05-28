# Fase 4 — Casos Borde (MUY IMPORTANTE)

## Regla

Esta fase es MUY IMPORTANTE. No pasar hasta cubrir los edge cases críticos.

## Técnica de layering

Cuando el usuario responde un edge case, preguntar:
"¿Y si eso ocurre DENTRO del paso [X] del flujo?"

Esto crea árboles de edge cases y descubre escenarios que no se habían contemplado.

## Categorías y patrones

### ERR — Condiciones de error
- "¿Qué pasa si falla [X]?"
- "¿Y si [X] timeout?"
- "¿Qué pasa si [X] devuelve error?"

### EDGE — Estados límite
- "¿Y si no hay ningún registro?"
- "¿Y si hay 10.000 registros?"
- "¿Y si el usuario no tiene permisos?"
- "¿Y si el recurso fue borrado por otro?"

### RACE — Concurrencia
- "¿Qué pasa si dos admins editan lo mismo al mismo tiempo?"
- "¿Qué pasa si llega un webhook duplicado?"
- "¿Y si hace click rápido 5 veces?"

### DEGRAD — Degradación
- "¿Qué pasa si el servicio externo está caído?"
- "¿Qué pasa si la base de datos no responde?"
- "¿Qué pasa si el CDN no funciona?"

### RECOV — Recuperación
- "¿Qué pasa si se pierde conexión a mitad del envío?"
- "¿Qué pasa si el usuario cierra el tab en medio del flujo?"
- "¿Y si los datos vienen corruptos o malformados?"

### NAV — Navegación inesperada
- "¿Y si el usuario usa el back button en medio del flujo?"
- "¿Y si abre otra pestaña y vuelve?"
- "¿Y si tiene varias sesiones abiertas?"

## Checklist final

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

## Si el usuario no tiene respuesta

Registrar como "**ASUMIDO**: si [X] ocurre, se [Y]". No bloquea. Levantar como TODO post-launch.