# feature-shaper — Design Document

> **Fecha**: 2026-03-04  
> **Estado**: Diseño completo, listo para implementar  
> **Autor**: Agustín Albonico  

---

## 1. Problema que resuelve

El workflow actual de desarrollo va directo de "idea vaga" a OpenSpec/SDD, saltando la etapa de claridad de negocio. Esto genera especificaciones técnicas con alcance mal definido, criterios de aceptación ausentes o vagos, y flujos alternativos y edge cases sin contemplar.

`feature-shaper` es una herramienta que actúa como etapa intermedia: toma una idea vaga, conduce una conversación adaptativa de negocio, y produce una `feature definition` completa y estructurada, lista para alimentar OpenSpec.

---

## 2. Visión del sistema

El sistema se compone de tres partes independientes que trabajan juntas:

```
/shape "idea vaga"
        ↓
  SKILL.md (protocolo conversacional — 5.5 fases)
        ↓ feature definition completa
  feature-store MCP (persistencia global SQLite)
        ↓
  ~/.feature-store/features.db
  docs/features/<slug>.md  (en el repo actual)
```

Adicionalmente, el usuario puede explorar el catálogo de features visualmente con:

```
feature-store tui
```

---

## 3. Componentes

### 3.1 — `feature-store` (binario Go)

Binario standalone con tres subcomandos:

| Subcomando | Propósito |
|---|---|
| `feature-store mcp` | MCP server (stdio) — expone tools a OpenCode |
| `feature-store tui` | TUI interactiva para navegar el catálogo |
| `feature-store migrate` | Crea/migra la DB (auto-invocado al arrancar) |

**Ubicación en el repo**: `ai-customizations/tools/feature-store/`

**Estructura de directorios**:
```
tools/feature-store/
├── cmd/
│   └── feature-store/
│       └── main.go          ← entry point, registra subcomandos
├── internal/
│   ├── db/
│   │   ├── schema.go        ← definición del schema SQLite
│   │   ├── migrations.go    ← lógica de migrate
│   │   └── queries.go       ← queries tipadas
│   ├── mcp/
│   │   ├── server.go        ← MCP server stdio
│   │   └── handlers.go      ← implementación de cada tool
│   ├── store/
│   │   ├── features.go      ← lógica de negocio de features
│   │   └── projects.go      ← lógica de negocio de proyectos
│   └── tui/
│       ├── app.go           ← entrada a la TUI (Bubble Tea)
│       ├── model.go         ← model principal (Elm Architecture)
│       ├── views/
│       │   ├── catalog.go   ← vista principal (proyectos + features)
│       │   ├── detail.go    ← vista de feature completa
│       │   ├── history.go   ← vista de historial de versiones
│       │   └── search.go    ← búsqueda FTS en vivo
│       └── styles.go        ← colores y estilos Lip Gloss
├── go.mod
└── README.md
```

**Stack tecnológico**:
- **Go** — binario standalone, sin runtime externo
- **github.com/charmbracelet/bubbletea** — framework TUI (Elm Architecture)
- **github.com/charmbracelet/bubbles** — componentes: list, viewport, textinput
- **github.com/charmbracelet/lipgloss** — estilos, colores, borders
- **github.com/mattn/go-sqlite3** o **modernc.org/sqlite** — SQLite driver (preferir modernc para evitar CGO)
- **github.com/mark3labs/mcp-go** — MCP server SDK para Go

**Instalación**: `go install ./cmd/feature-store` → binario en el PATH

---

### 3.2 — Base de datos SQLite

**Ubicación**: `~/.feature-store/features.db` (global, igual que `~/.engram/engram.db`)

**Schema completo**:

```sql
-- Proyectos conocidos (auto-registrado al guardar la primera feature)
CREATE TABLE IF NOT EXISTS projects (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  slug      TEXT UNIQUE NOT NULL,   -- "mi-app", "saas-backend"
  name      TEXT NOT NULL,
  path      TEXT,                   -- directorio raíz del proyecto
  createdAt TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Features (una fila = última versión activa)
CREATE TABLE IF NOT EXISTS features (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  projectSlug    TEXT NOT NULL REFERENCES projects(slug),
  slug           TEXT NOT NULL,          -- "user-auth", "payment-flow"
  title          TEXT NOT NULL,
  type           TEXT NOT NULL,          -- product | technical | business
  status         TEXT NOT NULL DEFAULT 'draft',  -- draft | ready | in-progress | done
  content        TEXT NOT NULL,          -- el .md completo de la feature definition
  version        INTEGER NOT NULL DEFAULT 1,
  topicKey       TEXT UNIQUE,            -- "project-slug/feature-slug" para upserts
  normalizedHash TEXT,                   -- dedup de contenido idéntico
  createdAt      TEXT NOT NULL DEFAULT (datetime('now')),
  updatedAt      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(projectSlug, slug)
);

-- Historial de versiones (snapshot por cada refinamiento)
CREATE TABLE IF NOT EXISTS featureVersions (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  featureId INTEGER NOT NULL REFERENCES features(id) ON DELETE CASCADE,
  version   INTEGER NOT NULL,
  content   TEXT NOT NULL,   -- snapshot completo del .md en esa versión
  changelog TEXT,            -- qué cambió respecto a la versión anterior
  createdAt TEXT NOT NULL DEFAULT (datetime('now'))
);

-- FTS5 para búsqueda semántica
CREATE VIRTUAL TABLE IF NOT EXISTS featuresFts USING fts5(
  title,
  content,
  type,
  status,
  content='features',
  content_rowid='id'
);

-- Trigger: mantener FTS sincronizado con inserts
CREATE TRIGGER IF NOT EXISTS features_ai AFTER INSERT ON features BEGIN
  INSERT INTO featuresFts(rowid, title, content, type, status)
  VALUES (new.id, new.title, new.content, new.type, new.status);
END;

-- Trigger: mantener FTS sincronizado con updates
CREATE TRIGGER IF NOT EXISTS features_au AFTER UPDATE ON features BEGIN
  INSERT INTO featuresFts(featuresFts, rowid, title, content, type, status)
  VALUES ('delete', old.id, old.title, old.content, old.type, old.status);
  INSERT INTO featuresFts(rowid, title, content, type, status)
  VALUES (new.id, new.title, new.content, new.type, new.status);
END;

-- Trigger: mantener FTS sincronizado con deletes
CREATE TRIGGER IF NOT EXISTS features_ad AFTER DELETE ON features BEGIN
  INSERT INTO featuresFts(featuresFts, rowid, title, content, type, status)
  VALUES ('delete', old.id, old.title, old.content, old.type, old.status);
END;
```

---

### 3.3 — MCP Tools expuestas a OpenCode

El MCP server expone exactamente estas 8 tools:

| Tool | Parámetros | Descripción |
|---|---|---|
| `feature_save` | projectSlug, slug, title, type, content, status?, changelog? | Upsert por topicKey. Si existe → incrementa versión, guarda snapshot en featureVersions |
| `feature_get` | slug, projectSlug? | Recupera feature completa (última versión) |
| `feature_search` | query, projectSlug? | Búsqueda FTS5 full-text. Devuelve lista con título, slug, proyecto, status, preview |
| `feature_catalog` | projectSlug, status?, type? | Lista features de un proyecto con filtros opcionales |
| `feature_versions` | slug, projectSlug | Lista historial de versiones (id, versión, changelog, fecha) |
| `feature_get_version` | featureId, version | Recupera el .md de una versión específica |
| `project_register` | slug, name, path? | Registra o actualiza un proyecto |
| `project_list` | — | Lista todos los proyectos con conteo de features |

**Registro en `~/.config/opencode/opencode.json`**:
```json
"feature-store": {
  "type": "local",
  "command": ["feature-store", "mcp"],
  "enabled": true
}
```

---

### 3.4 — TUI

**Punto de entrada**: únicamente `feature-store tui` (standalone). No se integra al workflow de `/shape`.

**Vistas y navegación**:

#### Vista Principal (catálogo)
Layout de dos paneles:
```
┌─────────────────────────────────────────────────────────────────────┐
│  ◆ feature-store                              [/] buscar  [?] ayuda │
├──────────────────┬──────────────────────────────────────────────────┤
│  PROYECTOS       │  FEATURES — mi-saas-app                          │
│  ▶ mi-saas-app 3 │  ● user-auth      product   ✓ ready    v3        │
│    backend-api 7 │  ● payment-flow   business  ◌ draft    v1        │
│    mobile-app  2 │  ● notifications  technical ◎ in-progress v2     │
│                  │                                                   │
├──────────────────┴──────────────────────────────────────────────────┤
│  [enter] abrir  [d] eliminar  [e] exportar  [h] historial  [q] salir│
└─────────────────────────────────────────────────────────────────────┘
```

**Panel izquierdo**: árbol de proyectos con contador de features. Navegación con ↑↓, Enter selecciona.  
**Panel derecho**: lista de features del proyecto activo. Tab alterna entre paneles.

#### Vista de Feature (detalle)
```
┌─────────────────────────────────────────────────────────────────────┐
│  ◆ user-auth  [product] [ready]  v3                      [b] volver │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  # Sistema de Autenticación de Usuarios                              │
│  ...contenido scrollable con j/k o ↑↓...                            │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│  [h] historial  [e] exportar .md  [d] eliminar  [b] volver          │
└─────────────────────────────────────────────────────────────────────┘
```

#### Vista de Historial
```
┌─────────────────────────────────────────────────────────────────────┐
│  ◆ user-auth — Historial                               [b] volver   │
├─────────────────────────────────────────────────────────────────────┤
│  v3  2026-03-04  Agregado 2FA y flujo de recovery                    │
│  v2  2026-02-28  Refinado criterios de aceptación                    │
│  v1  2026-02-20  Definición inicial                                  │
├─────────────────────────────────────────────────────────────────────┤
│  [enter] ver versión  [b] volver                                     │
└─────────────────────────────────────────────────────────────────────┘
```

#### Búsqueda en vivo
Al presionar `/`, el panel derecho se convierte en un input FTS5. Los resultados se actualizan mientras se escribe y abarcan todos los proyectos. `Esc` cancela y vuelve a la vista anterior.

**Esquema de colores (rica/colorida)**:
| Elemento | Color |
|---|---|
| `product` | Azul `#4FC3F7` |
| `technical` | Verde `#81C784` |
| `business` | Naranja `#FFB74D` |
| `ready` | Verde brillante `#69F0AE` |
| `draft` | Gris `#90A4AE` |
| `in-progress` | Amarillo `#FFD54F` |
| `done` | Verde apagado `#A5D6A7` |
| Proyecto activo | Highlight violeta `#CE93D8` |
| Border activo | Violeta `#9C27B0` |

**Keybindings completos**:
| Tecla | Acción |
|---|---|
| `↑↓` / `j k` | Navegar lista |
| `Tab` | Alternar panel izquierdo/derecho |
| `Enter` | Seleccionar / abrir |
| `/` | Activar búsqueda FTS en vivo |
| `Esc` | Cancelar búsqueda / volver |
| `b` | Volver a vista anterior |
| `h` | Ver historial de versiones |
| `e` | Exportar feature a .md en proyecto actual |
| `d` | Eliminar feature (con confirmación) |
| `?` | Toggle ayuda |
| `q` | Salir |

---

### 3.5 — Skill `feature-shaper` (SKILL.md)

**Ubicación en el repo**: `ai-customizations/skills/feature-shaper/SKILL.md`

El skill conduce el protocolo conversacional completo. Se carga cuando el usuario invoca `/shape` o `/shape-refine`.

#### Protocolo de 5.5 fases

```
FASE 1: Exploración del Contexto
    ↓ checkpoint — usuario confirma contexto entendido
FASE 2: Clasificación de la Feature
    ↓ checkpoint — usuario confirma tipo, capas y complejidad
FASE 3: Definición Adaptiva (preguntas de negocio)
    ↓ checkpoint — usuario aprueba el borrador de negocio
FASE 3.5: Contexto Técnico [OPCIONAL]
    ↓ usuario decide si responder o saltear
FASE 4: Especificación Formal
    ↓ checkpoint — usuario aprueba el .md final
FASE 5: Persistencia y Cierre
```

---

#### FASE 1 — Exploración del Contexto

El agente:
1. Lee el `package.json` / `go.mod` / `pyproject.toml` para entender el stack
2. Lee el `README.md` si existe
3. Llama `feature_catalog` para ver si ya hay features del proyecto (entiende el dominio)
4. Detecta el slug del proyecto actual (nombre del directorio raíz o campo `name` del manifest)

Luego formula **2-3 preguntas contextuales** basadas en lo que encontró. Si el contexto es suficientemente claro, puede saltear las preguntas y mostrar directamente el resumen.

**Salida de la fase** — el agente presenta:
```
Entendí lo siguiente sobre el proyecto:
- Stack: Next.js 15 + Prisma + PostgreSQL
- Dominio: SaaS de gestión de inventario B2B
- Features existentes: user-auth (ready), product-catalog (draft)

¿Es correcto? ¿Algo importante que agregar antes de continuar?
```

---

#### FASE 2 — Clasificación de la Feature

El agente clasifica la idea con **dos dimensiones independientes**:

**Dimensión 1 — Tipo** (determina el énfasis de las preguntas de negocio):
- `product` — foco en UX, flujos de usuario, estados de pantalla
- `technical` — foco en contratos, SLAs, dependencias de sistema
- `business` — foco en reglas de negocio complejas, actores, flujos alternativos

**Dimensión 2 — Capas** (detectadas automáticamente del stack y la idea, confirmadas por el usuario):
- `Frontend` → menciona pantallas/UI/formularios, o el stack tiene React/Vue/Next/etc.
- `Backend` → casi siempre presente; APIs, lógica de negocio, procesos
- `Database` → persistencia, entidades nuevas, cambios de schema, relaciones

**Complejidad detectada** (determina cuántas rondas de preguntas en Fase 3):
- `low` — 1 módulo, flujo lineal → 1 ronda
- `medium` — 2-3 módulos, algunos edge cases → 2 rondas
- `high` — 4+ módulos, reglas de negocio complejas, múltiples actores → 3 rondas

**Presentación al usuario**:
```
Clasifiqué tu idea como:

  Tipo:        business
  Complejidad: alta
  Capas:       ◉ Frontend  ◉ Backend  ◉ Database
  Módulos:     inventory, orders, notifications, users

¿Estás de acuerdo? Podés ajustar las capas o el tipo antes de continuar.
```

---

#### FASE 3 — Definición Adaptiva (preguntas de NEGOCIO)

**Reglas**:
- Máximo **4 preguntas por ronda** — nunca más
- Cada pregunta viene **numerada** ("Pregunta 2/4:") y con contexto del por qué importa
- Si una respuesta anterior ya cubre implícitamente una pregunta → se salta
- Si una respuesta genera nueva ambigüedad → se agrega a la siguiente ronda
- **Nunca preguntar nada técnico en esta fase** — sin mencionar endpoints, DB, componentes, etc.

**Al final de cada ronda excepto la última**:
```
Ronda 1 completada. Hasta ahora entiendo:
- [bullet de lo entendido]
- [bullet de lo entendido]
- [bullet de lo entendido]

¿Hay algo incorrecto o querés agregar algo antes de continuar?
```

**Al final de la última ronda**: genera el borrador de feature definition y pide aprobación.

##### Banco de preguntas — 4 pilares

Las preguntas se organizan en 4 pilares que se distribuyen en las rondas según la complejidad:

**Pilar 1 — Contexto / Por qué** (Ronda 1):
- ¿Qué problema concreto resuelve esta feature para el usuario?
- ¿Qué pasa hoy sin esta feature? ¿Cómo lo resuelven actualmente?
- ¿Quién es el usuario principal? ¿Hay otros actores involucrados?
- ¿Hay alguna restricción de negocio que la feature deba respetar?

**Pilar 2 — Alcance** (Ronda 1):
- ¿Qué es lo mínimo que tiene que hacer esta feature para tener valor real?
- ¿Qué cosas relacionadas quedan explícitamente fuera de esta versión?
- ¿Hay features existentes que se ven afectadas o modificadas?
- ¿Esta feature tiene fases o se entrega completa de una vez?

**Pilar 3 — Flujos** (Ronda 2):
- Describí el flujo principal: el usuario hace X, luego Y, luego Z. ¿Cómo termina?
- ¿Qué puede hacer el usuario si algo falla en el medio del flujo?
- ¿Hay flujos alternativos válidos además del camino feliz?
- ¿Qué pasa con los datos o el estado si el usuario abandona a mitad del proceso?
- ¿Hay actores secundarios que interactúan en algún punto del flujo?

**Pilar 4 — Criterios de éxito / AC** (Ronda 2-3):
- ¿Cómo sabés que esta feature funciona correctamente? Dame 2-3 escenarios concretos.
- ¿Hay algún comportamiento que si no funciona, la feature directamente no sirve?
- ¿Qué métricas o indicadores muestran que la feature tuvo el impacto esperado?
- ¿Hay restricciones de performance o confiabilidad que el negocio requiere?

**Preguntas de edge cases** (se agregan cuando se detecta complejidad high):
- ¿Qué pasa si dos usuarios hacen la misma acción al mismo tiempo?
- ¿Hay límites? (máximo de items, vencimientos, cuotas, restricciones por plan)
- ¿Qué pasa con los datos históricos cuando se activa la feature?
- ¿Hay casos donde la feature debería bloquearse o restringirse?

##### Énfasis adicional por tipo (1-2 preguntas extra, mezcladas en las rondas)

**`product`**:
- ¿Cuál es el happy path ideal desde la perspectiva del usuario?
- ¿Qué pasa si el usuario sale a la mitad del flujo? (draft, pérdida de datos, warning)

**`technical`**:
- ¿Hay restricciones de retrocompatibilidad que debés respetar?
- ¿Cuál es la estrategia si algo sale mal en producción?

**`business`**:
- ¿Cuáles son los flujos alternativos y de excepción más importantes?
- ¿Hay casos límite conocidos que históricamente generaron bugs o confusión?

##### Estructura de rondas

```
Ronda 1 → Pilar 1 (contexto) + Pilar 2 (alcance) + 1 pregunta de tipo
           máx 4 preguntas, las más abiertas

Ronda 2 → Pilar 3 (flujos) + inicio Pilar 4 (AC)
           máx 4 preguntas, adaptadas a respuestas de Ronda 1
           (solo si complexity=medium o high)

Ronda 3 → Pilar 4 (AC) completo + edge cases detectados
           máx 4 preguntas
           (solo si complexity=high)
```

---

#### FASE 3.5 — Contexto Técnico [OPCIONAL]

El agente siempre ofrece esta fase al finalizar la definición de negocio. El usuario decide si responder o saltear.

**Presentación**:
```
La parte de negocio está completa. ¿Querés agregar contexto técnico de alto nivel
para que OpenSpec tenga más información cuando arranque el diseño?

Son 2-4 preguntas cortas, completamente opcionales.
[Sí, agregar contexto técnico]  [No, pasar directo a la especificación]
```

**Nivel**: adaptativo — el agente selecciona 2-4 preguntas según lo que detectó. Nunca más de 4.

**Banco de preguntas técnicas de alto nivel** (el agente elige las relevantes):

*Siempre disponibles*:
- ¿Tenés alguna preferencia o restricción sobre el stack o tecnologías a usar?
- ¿Hay alguna integración con sistemas externos que ya sabés que va a ser necesaria?
- ¿Hay alguna restricción técnica que el negocio impone? (performance, disponibilidad, seguridad)
- ¿Hay algún módulo o parte del sistema existente que claramente va a estar involucrado?

*Si la feature tiene flujos complejos o múltiples actores*:
- ¿Hay algún proceso que debería ocurrir en background o de forma asíncrona?
- ¿Hay alguna consideración de escala que ya sepas? (muchos usuarios, datos históricos grandes)

*Si la feature modifica features existentes*:
- ¿Hay restricciones de retrocompatibilidad que debés respetar?
- ¿Hay deuda técnica en esa área que podría complicar la implementación?

*Si la feature involucra datos sensibles*:
- ¿Hay consideraciones sobre privacidad o seguridad de los datos?
- ¿Los datos tienen restricciones legales o de compliance?

---

#### FASE 4 — Especificación Formal

El agente toma toda la información recopilada y genera el `.md` completo (ver Sección 4 — Formato del Output). Presenta el documento completo y pregunta:

```
¿Aprobás esta especificación para guardarla?
Podés pedirme ajustes antes de confirmar.
```

El usuario puede pedir ajustes específicos. El agente los incorpora y vuelve a presentar para aprobación.

---

#### FASE 5 — Persistencia y Cierre

1. Llama `project_register` para asegurar que el proyecto existe en la DB
2. Llama `feature_save` con todos los datos
3. Escribe el archivo `docs/features/<slug>.md` en el repo actual
4. Muestra confirmación:

```
✓ Feature guardada: Sistema de Invitaciones (v1)
✓ Archivo creado: docs/features/workspace-invites.md

¿Querés arrancar OpenSpec ahora para especificar esta feature?
(Podés hacerlo después con /sdd-propose)
```

---

#### Flujo de `/shape-refine`

Cuando se invoca para refinar una feature existente:

1. Llama `feature_search` con el argumento para encontrar la feature
2. Si hay más de un match → presenta lista para elegir
3. Llama `feature_get` para cargar el contenido actual
4. Presenta resumen de la versión actual:

```
Refinando: Sistema de Invitaciones (v2, ready)
Última actualización: 2026-02-28

Resumen actual:
- Contexto: Permite a admins invitar colaboradores al workspace por email
- Alcance: 4 items incluidos, 2 excluidos explícitamente
- Flujos: flujo principal + 2 alternativos + 2 flujos de error
- AC: 5 criterios definidos

¿Qué querés cambiar o agregar?
```

5. Salta directo a **Fase 3** con todo el contexto cargado
6. Al guardar: `version++`, guarda snapshot en `featureVersions` con `changelog` de lo que cambió

---

### 3.6 — Commands

**Ubicación**: `ai-customizations/commands/`

#### `shape.md`
```markdown
---
description: Transforma una idea de feature en una definición completa de negocio, lista para OpenSpec
---

Cargá el skill "feature-shaper" y comenzá el proceso de shaping.

La idea inicial del usuario ya está disponible como argumento del comando.

Comportamiento especial:
- Si no se pasó argumento: preguntá "¿Sobre qué feature querés trabajar?"
- Si se detecta una feature similar via feature_search: ofrecé refinar en lugar de crear nueva
- Arrancá siempre desde Fase 1 del protocolo (Exploración del Contexto)
```

#### `shape-refine.md`
```markdown
---
description: Refina una feature existente cargando su definición actual y conduciendo una conversación de actualización
---

Cargá el skill "feature-shaper" y comenzá el proceso de refinamiento.

El nombre o slug de la feature está disponible como argumento del comando.

Comportamiento especial:
- Si no se pasó argumento: mostrá las últimas 5 features del proyecto actual y pedí que el usuario elija
- Si hay múltiples matches en feature_search: mostrá lista para elegir
- Saltá directamente a Fase 3 del protocolo con el contexto de la feature ya cargado
```

#### `shape-catalog.md`
```markdown
---
description: Muestra el catálogo de features del proyecto actual con status, tipo y versión
---

Mostrá el catálogo de features del proyecto actual usando feature_catalog.

Detectá el slug del proyecto desde el directorio actual (nombre del directorio o campo name del package.json/go.mod).

Variantes soportadas:
- Sin argumentos: features del proyecto actual
- --all: features de todos los proyectos (usar project_list + feature_catalog por proyecto)
- --status <valor>: filtrar por status (draft/ready/in-progress/done)
- --type <valor>: filtrar por tipo (product/technical/business)

Formato de salida:
📋 Features — <proyecto> (N features)

  ✓ ready       <título>   <tipo>   v<n>  · <fecha>
  ◌ draft       <título>   <tipo>   v<n>  · <fecha>
  ◎ in-progress <título>   <tipo>   v<n>  · <fecha>

Usá /shape-refine "nombre" para refinar. Usá /shape "idea" para agregar una nueva.
```

---

## 4. Formato del Output `.md`

Cada feature definition generada sigue esta estructura exacta:

```markdown
# [Título de la Feature]

> **Proyecto**: nombre-del-proyecto  
> **Tipo**: product | technical | business  
> **Status**: draft | ready  
> **Versión**: 1  
> **Creado**: YYYY-MM-DD  
> **Actualizado**: YYYY-MM-DD  

---

## Contexto

[Por qué existe esta feature. Qué problema resuelve. Sin soluciones técnicas.]

**Usuario principal**: [quién usa esto]  
**Actores secundarios**: [quién más interactúa — omitir si no aplica]  
**Situación actual**: [cómo se resuelve hoy sin esta feature]  

---

## Alcance

### ✅ Incluido en esta versión
- [item incluido]
- [item incluido]

### ❌ Fuera de alcance (explícito)
- [item excluido] — [razón breve]
- [item excluido] — [razón breve]

### 🔗 Features relacionadas o afectadas
- [feature existente que se modifica o de la que depende — omitir sección si no aplica]

---

## Flujos

### Flujo principal
1. El usuario [acción]
2. El sistema [respuesta/resultado]
3. [...]
4. Resultado: [estado final]

### Flujos alternativos
**[Nombre del flujo alternativo]**  
Condición: [cuándo ocurre]  
1. [paso]
2. [paso]

### Flujos de error
**[Nombre del error]**  
Condición: [qué lo dispara]  
Comportamiento esperado: [qué debe pasar]

---

## Criterios de Éxito

### Criterios de aceptación
- [ ] Dado [contexto], cuando [acción], entonces [resultado esperado]
- [ ] Dado [contexto], cuando [acción], entonces [resultado esperado]
- [ ] [mínimo 3, máximo 8]

### Comportamientos críticos
> Estas cosas deben funcionar sí o sí para que la feature tenga valor:
- [comportamiento no negociable]
- [comportamiento no negociable]

### Edge cases identificados
- [caso borde]: [comportamiento esperado]
- [caso borde]: [comportamiento esperado]

---

## Contexto Técnico

> Esta sección captura intenciones técnicas de alto nivel como insumo para OpenSpec.
> No es un diseño técnico — ese viene después.

**Stack / Tecnologías preferidas**: [valor o "stack actual del proyecto"]  
**Integraciones conocidas**: [valor]  
**Restricciones técnicas**: [valor]  
**Módulos involucrados**: [valor]  
**Otras notas**: [valor]

---

## Notas de Negocio

[Decisiones, restricciones o contexto que no encaja en las secciones anteriores pero es importante recordar. Omitir sección si no hay nada relevante.]

---

*Generado por feature-shaper v1 · /shape-refine para refinar*
```

**Reglas de generación**:
- **Contexto**: máx 3 párrafos cortos. Cero soluciones técnicas.
- **Alcance — fuera de alcance**: obligatorio con al menos 2 items. Si el usuario no los mencionó, el agente los propone a partir de lo que quedó implícito en la conversación.
- **Flujos alternativos y de error**: solo si surgieron en el shaping. Omitir las secciones si no aplica.
- **Criterios de aceptación**: formato Gherkin simplificado (Dado/Cuando/Entonces). **Siempre se genera aunque el usuario no los haya mencionado explícitamente** — el agente los deriva de los flujos.
- **Contexto Técnico**: solo aparece si el usuario respondió la Fase 3.5. Si la saltea, omitir la sección completa.
- **Notas de Negocio**: opcional.

---

## 5. Plan de implementación

### Orden de implementación recomendado

El orden importa porque el binario `feature-store` es una dependencia de todo lo demás (el skill necesita las MCP tools para persistir).

```
Paso 1: feature-store — DB + MCP server (sin TUI)
Paso 2: SKILL.md + commands
Paso 3: Registro en opencode.json
Paso 4: Testing end-to-end del flujo completo
Paso 5: feature-store TUI
Paso 6: Documentación + README actualizado
```

### Paso 1: `feature-store` — DB + MCP server

**Archivos a crear**:
```
tools/feature-store/
├── cmd/feature-store/main.go
├── internal/db/schema.go
├── internal/db/migrations.go
├── internal/db/queries.go
├── internal/mcp/server.go
├── internal/mcp/handlers.go
├── internal/store/features.go
├── internal/store/projects.go
└── go.mod
```

**Dependencias Go**:
```
modernc.org/sqlite          v1.x  — SQLite driver sin CGO
github.com/mark3labs/mcp-go v0.x  — MCP server SDK
```

**Criterio de completitud**:
- `feature-store migrate` crea `~/.feature-store/features.db` correctamente
- `feature-store mcp` arranca y responde al protocolo MCP stdio
- Las 8 tools funcionan correctamente (testear con un cliente MCP simple)

### Paso 2: SKILL.md + commands

**Archivos a crear**:
```
skills/feature-shaper/SKILL.md
commands/shape.md
commands/shape-refine.md
commands/shape-catalog.md
```

**Criterio de completitud**:
- El SKILL.md sigue el formato del repo (frontmatter YAML válido con `name` + `description`)
- Los commands siguen el formato del repo (frontmatter YAML + instrucciones en markdown)
- El protocolo de 5.5 fases está documentado con suficiente detalle para que el agente lo siga

### Paso 3: Registro en opencode.json

Agregar a `~/.config/opencode/opencode.json` bajo la clave `"mcp"`:
```json
"feature-store": {
  "type": "local",
  "command": ["feature-store", "mcp"],
  "enabled": true
}
```

### Paso 4: Testing end-to-end

Probar el flujo completo:
1. `/shape "quiero un sistema de notificaciones push"` — shaping desde cero
2. Verificar que el `.md` se genera en `docs/features/`
3. Verificar que la feature aparece en `feature_catalog`
4. `/shape-refine "notificaciones"` — refinamiento
5. Verificar que `version` se incrementó y hay snapshot en `featureVersions`
6. `/shape-catalog` — verificar que muestra la feature con el status correcto

### Paso 5: TUI

**Archivos a crear**:
```
tools/feature-store/internal/tui/
├── app.go
├── model.go
├── views/catalog.go
├── views/detail.go
├── views/history.go
├── views/search.go
└── styles.go
```

**Dependencias Go adicionales**:
```
github.com/charmbracelet/bubbletea  v1.x
github.com/charmbracelet/bubbles    v0.x
github.com/charmbracelet/lipgloss   v1.x
```

### Paso 6: Documentación

- Actualizar `README.md` del repo con la nueva skill y los commands
- Agregar instrucciones de instalación del binario `feature-store`

---

## 6. Contexto del repo (`ai-customizations`)

### Estructura actual
```
ai-customizations/
├── agents/
├── commands/
│   ├── bug.md
│   ├── qa.md
│   ├── task.md
│   └── tauri-migrate*.md
├── hooks/
├── scripts/
├── skills/
│   ├── e2e-qa-tester/
│   ├── interactive-bug/
│   │   └── SKILL.md
│   ├── interactive-task/
│   │   └── SKILL.md
│   ├── sonarqube-quality-gate-playbook/
│   └── tauri-react-nest-lan-migration/
└── README.md
```

### Estructura después de implementar
```
ai-customizations/
├── commands/
│   ├── shape.md          ← nuevo
│   ├── shape-refine.md   ← nuevo
│   ├── shape-catalog.md  ← nuevo
│   └── [existentes...]
├── skills/
│   ├── feature-shaper/   ← nuevo
│   │   └── SKILL.md
│   └── [existentes...]
├── tools/                ← nuevo directorio
│   └── feature-store/    ← binario Go
│       ├── cmd/
│       ├── internal/
│       └── go.mod
└── README.md             ← actualizar
```

### Patrón de commands (referencia: `commands/task.md`)
```markdown
---
description: [descripción corta]
---

[Instrucciones en texto plano para el agente]
```

### Patrón de SKILL.md (referencia: `skills/interactive-task/SKILL.md`)
```markdown
---
name: [nombre-del-skill]
description: [descripción usada para matching — debe ser descriptiva y precisa]
---

# [Nombre del Skill]

[Protocolo operativo en markdown]
```

---

## 7. Configuración del entorno del usuario

- **OS**: Windows 11
- **Shell**: PowerShell (SIEMPRE usar PowerShell, nunca bash/linux commands)
- **Go**: debe estar instalado para compilar el binario
- **Repo**: `C:\Users\agust\Desktop\Programacion\Proyectos\ai-customizations`
- **Config OpenCode**: `C:\Users\agust\.config\opencode\opencode.json`
- **DB Engram (referencia)**: `C:\Users\agust\.engram\engram.db`
- **DB feature-store (a crear)**: `C:\Users\agust\.feature-store\features.db`
- **Package manager**: preferir `bun` sobre `npm`
- **Idioma de respuestas**: SIEMPRE español

### Patrón MCP en opencode.json (referencia: entrada de Engram)
```json
"engram": {
  "type": "local",
  "command": ["engram", "mcp", "--tools=agent"],
  "enabled": true
}
```

---

## 8. Decisiones de diseño y razones

| Decisión | Alternativa descartada | Razón |
|---|---|---|
| Binario Go | Node.js / Python | Binario standalone sin runtime, mismo stack que Engram |
| DB global `~/.feature-store/` | DB por proyecto | Catálogo centralizado, misma arquitectura que Engram |
| Sistema independiente | Usar Engram como backend | Dominio diferente, schema específico, no contaminar Engram |
| TUI standalone | TUI integrada al workflow | El workflow ya tiene checkpoints conversacionales; la TUI es para exploración/gestión |
| Preguntas de negocio únicamente | Preguntas técnicas en Fase 3 | Lo técnico viene después con OpenSpec; el shaping resuelve claridad de negocio |
| Fase 3.5 opcional | Técnico siempre o nunca | Flexible según el estado mental del usuario al momento del shaping |
| `modernc.org/sqlite` | `mattn/go-sqlite3` | Evita CGO, compilación más simple en Windows |

---

*Fin del design document — listo para implementar*
