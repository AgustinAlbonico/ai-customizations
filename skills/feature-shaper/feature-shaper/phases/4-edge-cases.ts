# Fase 4 — Casos Borde (MUY IMPORTANTE)

## Regla

Esta fase es MUY IMPORTANTE. No pasar hasta cubrir TODOS los edge cases del checklist.

## Checklist obligatorio (NO omitir ninguno)

- [ ] Fallo en servicio externo
- [ ] Timeout de red
- [ ] Datos vacíos
- [ ] Overflow de datos
- [ ] Permisos insuficientes
- [ ] Navegación inesperada (back button, close tab)
- [ ] Concurrencia
- [ ] Datos corruptos o malformados
- [ ] Recuperación post-error

## Preguntas por categoría (OBLIGATORIAS)

### ERR — Condiciones de error
- "¿Qué pasa si falla la base de datos?"
- "¿Y si hay un timeout en la red?"
- "¿Qué pasa si el servicio externo no responde?"

### EDGE — Estados límite
- "¿Y si no hay ningún registro en el sistema?"
- "¿Y si hay 10.000 registros de golpe?"
- "¿Y si el usuario no tiene permisos para esa acción?"
- "¿Y si el recurso fue borrado por otro usuario?"

### RACE — Concurrencia
- "¿Qué pasa si dos usuarios hacen la misma acción al mismo tiempo?"
- "¿Qué pasa si dos admins editan lo mismo simultáneamente?"
- "¿Qué pasa si hace click rápido varias veces?"

### DEGRAD — Degradación
- "¿Qué pasa si el servicio está en mantenimiento?"
- "¿Qué pasa si el CDN no responde?"
- "¿Qué pasa si la API externa cambió su formato de respuesta?"

### RECOV — Recuperación
- "¿Qué pasa si se pierde la conexión a mitad del envío?"
- "¿Qué pasa si el usuario cierra el tab en medio del flujo?"
- "¿Qué pasa si los datos llegan corruptos o malformados?"
- "¿Qué pasa si el usuario usa el back button en medio?"

### NAV — Navegación inesperada
- "¿Y si el usuario usa el back button en medio del flujo?"
- "¿Y si abre otra pestaña y vuelve?"
- "¿Y si tiene múltiples sesiones abiertas?"

### AUTH — Autenticación y sesiones
- "¿Y si el token expira en medio de una operación?"
- "¿Y si alguien intenta acceder a una URL de otro rol?"
- "¿Y si la sesión está activa en otro dispositivo?"
- "¿Y si el usuario no está autenticado y accede directo a una URL?"

## Técnica de layering

Cuando el usuario responde un edge case, preguntar:
"¿Y si eso ocurre DENTRO del paso [X] del flujo?"

Esto crea árboles de edge cases y descubre escenarios que no se habían contemplado.

## Si el usuario no tiene respuesta

Registrar como "**ASUMIDO**: si [X] ocurre, se [Y]". No bloquea. Levantar como TODO post-launch.

## Fin de fase

Al terminar, recorrer el checklist y confirmar que cada punto fue discutido.
Preguntar: "¿Hay algún edge case que no cubrimos?"