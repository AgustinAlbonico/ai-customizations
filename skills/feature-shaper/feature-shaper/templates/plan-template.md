# Plan: [Nombre de Feature]

## Objetivo

[Una frase concisa que explique qué problema resuelve esta feature y cuál es el resultado esperado]

---

## Decisiones de diseño

| # | Tema | Decisión |
|---|------|----------|
| 1 | Ubicación | [Dónde vive el módulo: nuevo microservicio, módulo dentro de backend, etc.] |
| 2 | [Tema] | [Decisión] |
| 3 | [Tema] | [Decisión] |
| N | [Tema] | [Decisión] |

---

## Arquitectura general

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND                                 │
│  [componentes / páginas]                                        │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND / MÓDULO                            │
│  [services] → [routes] → [controllers]                          │
│  [integraciones externas]                                        │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
               [Base de datos]
```

---

## Flujos principales

### Flujo 1: [Nombre del flujo]
```
[Actor] → [ Acción ] → [ Sistema ] → [ Resultado ]
```

### Flujo 2: [Nombre del flujo]
```
[Actor] → [ Acción ] → [ Sistema ] → [ Resultado ]
```

---

## Modelo de datos

### Enums
```
[ EnumName ]
  VALUE_A
  VALUE_B
```

### Entidad: [Nombre]
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | UUID | PK |
| [campo] | [tipo] | [desc] |

---

## Fases de implementación

### Fase 1 — [Nombre]
[Descripción de qué se hace en esta fase y por qué]

**Dependencias:** [qué necesita antes]

**Servicios:** [services si aplica]

**Endpoints:** [rutas nuevas]

### Fase 2 — [Nombre]
[...]

---

## Orden de ejecución

```
[Diagrama de dependencias de fases]
```

---

## Archivos a crear

| Archivo | Fase |
|---------|------|
| `path/to/file` | N |
| `path/to/file` | N |

## Archivos a modificar

| Archivo | Cambio | Fase |
|---------|--------|------|
| `path/to/file` | [desc] | N |

---

## Variables de entorno
```
[VARIABLE]= [descripción]
[VARIABLE]= [descripción]
```
