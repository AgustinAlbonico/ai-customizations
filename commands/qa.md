---
description: Ejecuta pruebas E2E y QA manual usando Playwright para verificar la ultima funcionalidad implementada
---

Activa el skill "e2e-qa-tester" y ejecuta una prueba de la ultima tarea completada.

## Flujo a Seguir

1. **Identificar la tarea a probar**:
   - Revisa el historial de la conversacion actual
   - Busca la ultima tarea marcada como completada
   - Si no puedes identificarla, pregunta al usuario

2. **Buscar credenciales de prueba**:
   - Busca archivo `CREDENTIALS.md` en el proyecto
   - Ubicaciones comunes: raiz, `docs/`, `.credentials/`, `testing/`
   - Si NO encuentras el archivo, pregunta al usuario por las credenciales
   - NUNCA intentes adivinar credenciales

3. **Verificar conexion a la aplicacion**:
   - Verificar si puerto 5173 esta en uso: `Test-NetConnection -ComputerName 127.0.0.1 -Port 5173`
   - Si 5173 no esta disponible, verificar 3000, 4200, 8080
   - Si ningun puerto esta activo, preguntar al usuario

4. **Presentar plan de prueba (OBLIGATORIO)**:
   Usa la herramienta `question` para mostrar:
   ```
   ## Plan de Prueba
   
   **Tarea identificada**: [descripcion]
   **Flujo a probar**: [pasos]
   **Credenciales**: [rol del CREDENTIALS.md]
   **URL**: http://127.0.0.1:[puerto]
   
   ¿Procedo con esta prueba?
   ```
   
   **NO proceder hasta recibir confirmacion del usuario.**

5. **Ejecutar la prueba con Playwright MCP**:
   - Navegar a la URL (headless)
   - Si hay login, completar con credenciales del CREDENTIALS.md
   - Ejecutar el flujo identificado
   - Tomar snapshots en puntos clave
   - Verificar resultados esperados

6. **Reportar resultados**:
   ```
   ## Resultado de Prueba E2E
   
   **Estado**: [PASO / FALLO]
   **Pasos ejecutados**: [detalle]
   **Resultado final**: [descripcion]
   **Evidencia**: [screenshots o verificaciones]
   ```

## Reglas Importantes

- **SIEMPRE** buscar CREDENTIALS.md antes de pedir credenciales
- **SIEMPRE** pedir confirmacion antes de ejecutar
- **SIEMPRE** usar modo headless
- **NUNCA** crear/modificar/eliminar usuarios de prueba
- **NUNCA** usar IPv6, siempre 127.0.0.1
