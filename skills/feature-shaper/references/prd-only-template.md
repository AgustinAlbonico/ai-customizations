# Template del PRD

Este template se usa para generar el documento final. Adaptar las secciones según la complejidad — no todas las secciones son obligatorias.

---

```markdown
# [Título del PRD]

> **Fecha**: YYYY-MM-DD
> **Status**: borrador | aprobado
> **Complejidad**: simple | media | alta | muy alta
> **Autor**: generado con prd-creator

---

## Problema

[Descripción clara del problema que se resuelve. Máximo 2 párrafos. Lenguaje de negocio, sin jerga técnica. Responde: ¿qué pasa hoy? ¿por qué es un problema? ¿por qué ahora?]

**Situación actual**: [cómo se resuelve hoy sin esta solución]

---

## Usuarios

### Usuario principal
- **Quién**: [rol o perfil]
- **Necesidad**: [qué necesita resolver]
- **Dolor actual**: [qué le frustra o le cuesta del proceso actual]

### Usuarios secundarios
- **[Rol]**: [cómo interactúa y qué necesita — omitir sección si no aplica]

---

## Objetivos

### Objetivos de negocio
- [Objetivo medible 1 — ej: "reducir el tiempo de procesamiento de pedidos de 2 horas a 15 minutos"]
- [Objetivo medible 2]

### Objetivos de usuario
- [Qué debe poder hacer el usuario que hoy no puede]
- [Qué experiencia debe mejorar]

### No-objetivos (explícitos)
- [Qué NO se busca lograr con esta versión — mínimo 2 items]
- [Qué queda para futuras iteraciones]

---

## Alcance

### Incluido en esta versión
- [Funcionalidad incluida 1]
- [Funcionalidad incluida 2]
- [Funcionalidad incluida 3]

### Fuera de alcance (explícito)
- [Item excluido 1] — [razón breve]
- [Item excluido 2] — [razón breve]

---

## Requisitos Funcionales

### P0 — Críticos (sin estos no hay producto)
- **[RF-001] [Nombre del requisito]**
  Descripción: [qué debe hacer]
  Criterio de aceptación: Dado [contexto], cuando [acción], entonces [resultado]

- **[RF-002] [Nombre del requisito]**
  Descripción: [qué debe hacer]
  Criterio de aceptación: Dado [contexto], cuando [acción], entonces [resultado]

### P1 — Importantes (necesarios para una buena experiencia)
- **[RF-003] [Nombre del requisito]**
  Descripción: [qué debe hacer]
  Criterio de aceptación: Dado [contexto], cuando [acción], entonces [resultado]

### P2 — Deseables (mejoran la experiencia pero pueden esperar)
- **[RF-004] [Nombre del requisito]**
  Descripción: [qué debe hacer]
  Criterio de aceptación: Dado [contexto], cuando [acción], entonces [resultado]

---

## Requisitos No Funcionales

> Solo incluir si surgieron en la entrevista. Expresar en términos de experiencia de usuario, no técnicos.

- **Velocidad**: [ej: "el usuario no debe esperar más de 2 segundos para ver resultados"]
- **Disponibilidad**: [ej: "el sistema debe estar disponible durante horario laboral sin interrupciones"]
- **Capacidad**: [ej: "debe soportar hasta 50 usuarios simultáneos"]
- **Seguridad**: [ej: "solo usuarios autorizados pueden ver datos de clientes"]

---

## Flujos

### Flujo principal
1. El usuario [acción inicial]
2. El sistema [respuesta/resultado]
3. El usuario [siguiente acción]
4. [...]
5. Resultado: [estado final esperado]

### Flujos alternativos
**[Nombre del flujo alternativo]**
Condición: [cuándo ocurre]
1. [paso]
2. [paso]
Resultado: [estado final]

### Flujos de error
**[Nombre del error]**
Condición: [qué lo dispara]
Comportamiento esperado: [qué debe pasar — siempre desde perspectiva del usuario]

---

## Criterios de Éxito

### Criterios de aceptación generales
- [ ] Dado [contexto], cuando [acción], entonces [resultado esperado]
- [ ] Dado [contexto], cuando [acción], entonces [resultado esperado]
- [ ] Dado [contexto], cuando [acción], entonces [resultado esperado]
- [ ] [mínimo 3, máximo 8]

### Comportamientos críticos
> Estas cosas deben funcionar sí o sí para que el producto tenga valor:
- [comportamiento no negociable 1]
- [comportamiento no negociable 2]

### Métricas de impacto
> ¿Cómo sabemos que esto tuvo el efecto esperado?
- [Métrica 1]: [baseline actual] → [target esperado]
- [Métrica 2]: [baseline actual] → [target esperado]

---

## Riesgos

> Solo incluir si la complejidad es alta o muy alta.

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| [Riesgo 1] | Alta/Media/Baja | Alto/Medio/Bajo | [Plan de contingencia] |
| [Riesgo 2] | Alta/Media/Baja | Alto/Medio/Bajo | [Plan de contingencia] |

---

## Preguntas Abiertas

> Decisiones pendientes o ambigüedades detectadas durante la definición.

- [ ] [Pregunta pendiente 1]
- [ ] [Pregunta pendiente 2]

---

*Generado por prd-creator · [fecha]*
```

---

## Reglas de uso del template

| Complejidad | Secciones obligatorias | Secciones opcionales |
|-------------|----------------------|---------------------|
| **simple** | Problema, Usuarios, Objetivos, Alcance, Requisitos Funcionales (P0), Criterios de Éxito | Flujos, Requisitos No Funcionales |
| **media** | Todas las de simple + Flujo principal + P0/P1 | Flujos alternativos, P2, Requisitos No Funcionales |
| **alta** | Todas + Flujos completos + P0/P1/P2 + Riesgos | Preguntas Abiertas |
| **muy alta** | Todas las secciones | — |

### Convenciones de escritura

1. **Lenguaje de negocio** — nunca jerga técnica (ni stack, ni endpoints, ni schemas)
2. **Concreto y medible** — "reducir tiempo de X a Y" en vez de "mejorar performance"
3. **Perspectiva del usuario** — "el usuario puede hacer X" en vez de "el sistema permite X"
4. **Priorización clara** — P0/P1/P2 en requisitos funcionales
5. **Gherkin simplificado** — Dado/Cuando/Entonces para criterios de aceptación
6. **Fuera de alcance obligatorio** — mínimo 2 items, derivados si el usuario no los mencionó
