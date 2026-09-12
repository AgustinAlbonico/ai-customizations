# Pack Curado de Skills Potenciadoras — project-foundation

Este pack reúne las 5 skills más prestigiosas del ecosistema abierto (`skills.sh`) para
inyectar criterio de diseño, cuestionamiento socrático y arquitectura modular en las fases
clave de `project-foundation`, evitando interfaces y arquitecturas genéricas.

## Las 5 Skills Esenciales

| Skill | Paquete en skills.sh | Installs | Fase beneficiada | Qué aporta |
|---|---|---|---|---|
| **Design Taste** | `leonxlnx/taste-skill@design-taste-frontend` | ~470K | Fase 06 (UX/UI) | Mata el diseño genérico de IA; layouts modernos, tipografía editorial, micro-interacciones. |
| **Impeccable** | `pbakaus/impeccable@impeccable` | ~270K | Fase 06 (UX/UI) | Ojo crítico de consistencia visual, jerarquía y espaciados (por Paul Bakaus). |
| **Web Guidelines** | `vercel-labs/agent-skills@web-design-guidelines` | ~620K | Fase 06 (UX/UI) | Directrices oficiales de Vercel: densidad de información, contraste, ergonomía web. |
| **Grill Me** | `mattpocock/skills@grill-me` | ~1.1M | Fases 00 y 02 (Intake / Producto) | Interrogatorio socrático de Matt Pocock para detectar fallas lógicas antes de arrancar. |
| **Codebase Architecture** | `mattpocock/skills@improve-codebase-architecture` | ~910K | Fase 07 (System Design) | Análisis crítico de modularidad, boundaries limpios y desacoplamiento. |

## Instalación

### Opción 1: Automática desde project-foundation
- Durante la **Fase 00 (Intake)**, el orquestador te pregunta una sola vez si querés activar el pack. Si aprobás, se instalan solas en segundo plano.
- O ejecutando en cualquier momento:
  ```text
  /project-foundation install-pack
  ```

### Opción 2: Script directo
```powershell
# Windows
.\skills\project-foundation\assets\install-curated-pack.ps1

# Linux / macOS
./skills/project-foundation/assets/install-curated-pack.sh
```

### Opción 3: Manual con npx
```bash
npx -y skills add leonxlnx/taste-skill@design-taste-frontend -g -y
npx -y skills add pbakaus/impeccable@impeccable -g -y
npx -y skills add vercel-labs/agent-skills@web-design-guidelines -g -y
npx -y skills add mattpocock/skills@grill-me -g -y
npx -y skills add mattpocock/skills@improve-codebase-architecture -g -y
```

## Mecanismo de Inyección (Just-In-Time)

1. Las skills se instalan con el flag `-g` (globales). Se instalan una sola vez y quedan disponibles para todos tus proyectos.
2. Cada contrato de fase declara qué skills potenciadoras aprovecha.
3. Al entrar en esa fase (ej: Fase 06 UX/UI), el orquestador o subagente verifica si la skill está presente:
   - **Presente**: carga sus directrices de alto nivel y las aplica en la redacción del artefacto.
   - **Ausente**: el orquestador ofrece instalarla al vuelo con `npx skills add ... -g -y` o continúa con los templates base sin romperse (degradación suave).
