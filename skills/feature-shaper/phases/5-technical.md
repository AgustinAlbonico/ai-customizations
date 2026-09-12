# Fase 5 — Técnico

## Propósito

Traducir el feature a decisiones técnicas concretas usando el codebase real.

## Paso 1 — Subagente exploratorio (OBLIGATORIO antes de preguntar)

INVOCAR subagente ANTES de hacer preguntas:

```
task {
  subagent_type: "sdd-design",
  prompt: "Explora el codebase actual. Prioriza los directorios de backend y frontend (ej: apps/backend/src/ y apps/frontend/src/, o equivalentes según el repo). Identifica:\n1. Stack tecnológico exacto (versiones, librerías clave)\n2. Patrones de arquitectura (Clean Architecture? Hexagonal? Capas usadas?)\n3. Convenciones de código (nombres, imports, estructura de carpetas)\n4. Estructura de módulos backend (qué módulos existen, cómo se organizan)\n5. APIs existentes (versión, formato, auth)\n6. Modelo de datos (ORM usado, entidades principales)\n7. Integraciones externas (colas, realtime, notificaciones, etc.)\n8. Packages compartidos (shared/common) — qué contienen\n9. Frontend: store, API layer, routing, componentes principales\n10. Cualquier cosa que sería relevante para diseñar un nuevo feature module desde cero\n\nReturn un resumen estructurado con suficiente detalle para tomar decisiones técnicas fundadas. Adaptar los paths al repo real; nunca hardcodear nombres de proyectos o packages concretos."
}
```

## Paso 2 — Preguntas técnicas pós subagente

Con el output del subagente, preguntar SOLO lo necesario:

### 1. Stack confirmar o sugerir
"¿Confirmamos el stack detectado ([stack del subagente]) o hay variante?"
- Confirmar: ___
- Cambiar a: ___

### 2. Arquitectura
"¿Usamos el patrón [Clean Architecture] existente o lo simplificamos?"
- Seguir patrón existente
- Ajustar: ___

### 3. Modelo de datos (alto nivel)
"¿Qué entidades principales necesitás? Aquí mi lectura del dominio basado en los RF: [lista]. ¿Es correcto o falt algo?"

### 4. API endpoints (alto nivel)
"¿Para este feature necesitamos endpoints públicos, admin, o ambos? Acá mi aprox basándome en los RF: [lista]. ¿Algo más?"

### 5. Servicios externos
"¿Qué servicios externos se necesitan? Mi reading: [lista]. ¿Qué agregás o quitás?"

### 6. Order sugerido
"¿En qué orden sugiero implementar basándome en dependecias? [lista fases]. ¿Te parece o lo reorganizamos?"

---

## No preguntar lo que ya está en el codebase

Si el subagente ya respondió algo (ej: "usa NestJS con TypeORM"), no-preguntar eso de nuevo.
Solo llenar los gaps que el subagente no pudo responder.
