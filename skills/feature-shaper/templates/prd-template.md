# Requerimientos del Sistema: [Nombre de Feature]

## 1. Introducción

### 1.1 Propósito
Este documento especifica los requerimientos funcionales y no funcionales para el desarrollo de [nombre de feature]. [Breve descripción del problema que resuelve y para quién].

### 1.2 Alcance
El módulo comprende:
- [Componente 1]
- [Componente 2]
- [Componente N]

### 1.3 Caso de uso principal
[Descripción del escenario principal de uso en 1-2 oraciones]

---

## 2. Arquitectura general

### 2.1 Stack Tecnológico
- **Frontend:** [tech]
- **Backend:** [tech]
- **Base de datos:** [DB + ORM]
- **Integración externa:** [si aplica]

### 2.2 Modelo de Datos Conceptual
```
[Entidad] (existente)
  └── [Entidad nueva] (1:N)
        ├── [relación]
        └── [relación]
```

---

## 3. Roles y Permisos

### 3.1 [Rol A]
| Acción | Permitido |
|--------|-----------|
| [Acción] | ✓ |
| [Acción] | ✗ |

### 3.2 [Rol B]
| Acción | Permitido |
|--------|-----------|
| [Acción] | ✓ |
| [Acción] | ✗ |

---

## 4. Requerimientos Funcionales

### RF-001: [Nombre del requerimiento]
**Descripción:** [Qué hace el requerimiento]

**Datos requeridos:**
- [Dato 1]
- [Dato 2]

**Comportamiento:**
1. [Paso 1]
2. [Paso 2]
3. [Paso 3]

**Validaciones:**
- [Validación 1]
- [Validación 2]

**Errores:**
- [Condición de error] → [Mensaje/acción]

**Estados:** [Si aplica]

---

## 5. Casos borde

| Escenario | Comportamiento |
|----------|----------------|
| [Condición] | [Qué ocurre] |
| [Condición] | [Qué ocurre] |

---

## 6. Requerimientos No Funcionales

### RNF-001: Seguridad
- [Requerimiento]

### RNF-002: Performance
- [Requerimiento]

### RNF-003: Escalabilidad
- [Requerimiento]

### RNF-004: Disponibilidad
- [Requerimiento]

### RNF-005: Usabilidad
- [Requerimiento]

### RNF-006: Mantenibilidad
- [Requerimiento]

---

## 7. API Endpoints (Backend)

### 7.1 Públicos
```
GET    /api/recurso
POST   /api/recurso
```

### 7.2 Administración
```
GET    /api/admin/recurso
POST   /api/admin/recurso
PUT    /api/admin/recurso/:id
DELETE /api/admin/recurso/:id
```

---

## 8. Consideraciones de Implementación

### 8.1 Integración con Monorepo Existente
- [Consideración 1]
- [Consideración 2]

### 8.2 Configuración de Servicios Externos
- [Servicio]: [cómo se integra]

### 8.3 Variables de Entorno Adicionales
```
[NUEVA_VAR]= [descripción]
```

---

## 9. Fases de Desarrollo Sugeridas

### Fase 1: MVP
- [Feature subset inicial]

### Fase 2: Funcionalidad Completa
- [Features adicionales]

### Fase 3: Optimización
- [Mejoras de performance, UX, edge cases]

---

## 10. Criterios de Aceptación Generales

1. [Criterio 1]
2. [Criterio 2]
3. [Criterio 3]
