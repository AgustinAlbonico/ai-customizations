# ai-customizations

Infraestructura personal de IA: skills, agentes, hooks y comandos versionados en un solo repo, con instalacion reproducible y arquitectura agnostica de agente.

## Arquitectura

```text
skills/                     # skills instalables con npx skills (cross-agent)
agents/                     # definiciones de agentes reutilizables
commands/                   # comandos markdown reutilizables
hooks/                      # hooks reutilizables
scripts/                    # scripts de bootstrap/instalacion
```

## Skills disponibles

### `interactive-bug` - Debug interactivo

**Que hace:**
- Debug interactivo de bugs con preguntas adaptativas
- La IA te pregunta lo que necesita (multiple choice o abiertas)
- Arregla en un solo intento sin back-and-forth

**Cuando usarlo:**
- Encontraste un bug pero no queres escribir un reporte detallado
- Queres que la IA te guíe con preguntas específicas
- Necesitas arreglar algo rapido sin pensar en el contexto

**Como usarlo:**
```
/bug "descripcion corta del problema"
```

**Ejemplo:**
```
/bug "el boton de logout no anda"
```

La IA te va a preguntar:
- ¿Qué pasa exactamente cuando haces click?
- ¿Dónde está el botón?
- ¿Funcionaba antes?

Vos respondes (elegis opciones o escribis), y la IA investiga y arregla.

---

### `interactive-task` - Tareas interactivas

**Que hace:**
- Tareas interactivas (features, cambios, refactors) con preguntas adaptativas
- La IA identifica el tipo de tarea y hace las preguntas correctas
- Ejecuta correctamente en un solo intento

**Cuando usarlo:**
- Queres agregar/modificar/refactorizar algo
- No queres escribir especificaciones detalladas
- Preferis que la IA te pregunte lo que necesita

**Como usarlo:**
```
/task "descripcion de la tarea"
```

**Ejemplos:**
```
/task "agregar dark mode"
/task "refactorizar el componente de login"
/task "cambiar el orden de las columnas en la tabla"
```

La IA identifica si es NUEVO, CAMBIO, REFACTOR, CONFIG o MEJORA, y hace preguntas adaptadas.

---

### `tauri-react-nest-lan-migration` - Migracion Tauri

**Que hace:**
- Guia migraciones Web -> Desktop con Tauri para stack React + NestJS + Postgres en LAN
- Estandariza setup, sidecar, validacion y salida a release
- Reduce errores comunes de red local, auth y arranque

**Como funciona:**
1. Planifica la migracion (`/tauri-migrate-plan`)
2. Implementa cambios (`/tauri-migrate-implement`)
3. Verifica setup/login/CRUD + logs (`/tauri-migrate-verify`)
4. Prepara entrega (`/tauri-migrate-release`)

---

### `sonarqube-quality-gate-playbook` - SonarQube

Playbook iterativo para llevar proyectos Node y TypeScript (NestJS + React en monorepo) a cumplir Quality Gates de SonarQube.

---

### `e2e-qa-tester` - Pruebas E2E/QA Manual

**Que hace:**
- Ejecuta pruebas E2E y QA manual usando Playwright MCP
- Verifica la ultima funcionalidad implementada
- Busca credenciales en CREDENTIALS.md automaticamente
- Pide confirmacion antes de ejecutar pruebas

**Cuando usarlo:**
- Acabas de implementar una funcionalidad y queres verificarla
- Necesitas hacer QA manual de un flujo
- Queres probar formularios, autenticacion, o CRUD

**Como usarlo:**
```
/qa
```

**Flujo:**
1. Identifica la ultima tarea completada
2. Busca credenciales en CREDENTIALS.md
3. Verifica conexion al puerto 5173
4. Te presenta el plan de prueba
5. Ejecuta y reporta resultados (PASO/FALLO)


## Instalacion

### Opcion 1: Instalar skills individuales

```powershell
# Bug interactivo
npx skills add AgustinAlbonico/ai-customizations --skill interactive-bug --agent opencode -y

# Task interactivo
npx skills add AgustinAlbonico/ai-customizations --skill interactive-task --agent opencode -y

# Tauri migration
npx skills add AgustinAlbonico/ai-customizations --skill tauri-react-nest-lan-migration --agent opencode -y

# QA E2E
npx skills add AgustinAlbonico/ai-customizations --skill e2e-qa-tester --agent opencode -y

### Opcion 2: Instalar todas las skills

```powershell
# Para un agente especifico
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode -y

# Para multiples agentes
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode --agent claude-code -y

# Para todos los agentes detectados
npx skills add AgustinAlbonico/ai-customizations --all
```

### Opcion 3: Listar skills disponibles

```powershell
npx skills add AgustinAlbonico/ai-customizations --list
```

### Agentes soportados

`opencode`, `codex`, `claude-code`, `cursor`, `antigravity`

## Uso rapido

Despues de instalar, usa los comandos:

```text
/bug "el carrito no actualiza el total"
/task "agregar dark mode"
/qa    # Prueba la ultima funcionalidad implementada

La IA va a hacerte preguntas interactivas con opciones multiple choice o abiertas según lo que necesite saber.

## Script de instalacion agnostico

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -Agents opencode,codex,claude-code
```

Para instalar todas las skills de todos los agentes en modo global:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -AllAgents -GlobalSkills
```

## Bootstrap opcional de proyecto

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-project.ps1 -ProjectPath "C:\ruta\tu-proyecto"
```

## Validacion local

```powershell
npx skills add . --list
```

## Notas

- Cada skill debe tener `SKILL.md` con frontmatter YAML valido (`name` + `description`)
- Este repo guarda customizaciones de IA, no codigo de producto
