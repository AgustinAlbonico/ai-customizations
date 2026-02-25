# Patrones de Prueba E2E

Este archivo contiene patrones comunes para pruebas E2E con Playwright MCP.

## Patrones de Login

### Login Basico

```javascript
// 1. Navegar a la app
playwright_browser_navigate("http://127.0.0.1:5173")

// 2. Ver estado actual
playwright_browser_snapshot()

// 3. Completar login
playwright_browser_fill_form([
  { name: "Email", type: "textbox", ref: "input[type='email']", value: "admin@test.com" },
  { name: "Password", type: "textbox", ref: "input[type='password']", value: "admin123" }
])

// 4. Click en boton login
playwright_browser_click(element="Boton Login", ref="button[type='submit']")

// 5. Verificar login exitoso
playwright_browser_snapshot()  // Buscar elemento que indique sesion iniciada
```

### Login con Selectores Especificos

```javascript
// Si el formulario tiene IDs especificos
playwright_browser_type(element="Campo email", ref="#email-input", text="admin@test.com")
playwright_browser_type(element="Campo password", ref="#password-input", text="admin123")
playwright_browser_click(element="Boton submit", ref="#login-button")
```

## Patrones de Formulario

### Formulario de Creacion

```javascript
// Navegar a formulario
playwright_browser_click(element="Boton Nuevo", ref="button:has-text('Nuevo')")

// Completar campos
playwright_browser_fill_form([
  { name: "Nombre", type: "textbox", ref: "#nombre", value: "Producto Test" },
  { name: "Precio", type: "textbox", ref: "#precio", value: "99.99" },
  { name: "Categoria", type: "combobox", ref: "#categoria", value: "Electronica" }
])

// Enviar
playwright_browser_click(element="Boton Guardar", ref="button:has-text('Guardar')")

// Verificar
playwright_browser_snapshot()  // Buscar mensaje de exito o registro en lista
```

### Formulario con Validaciones

```javascript
// Probar campo requerido vacio
playwright_browser_click(element="Boton Guardar", ref="button:has-text('Guardar')")
playwright_browser_snapshot()  // Verificar mensaje de error

// Probar formato invalido
playwright_browser_type(element="Campo email", ref="#email", text="email-invalido")
playwright_browser_click(element="Boton Guardar", ref="button:has-text('Guardar')")
playwright_browser_snapshot()  // Verificar mensaje de error de formato
```

## Patrones de Navegacion

### Navegar por Menu

```javascript
// Click en menu
playwright_browser_click(element="Menu Usuarios", ref="nav >> text=Usuarios")

// Esperar carga
playwright_browser_wait_for(text="Lista de Usuarios")

// Verificar
playwright_browser_snapshot()
```

### Navegacion con Breadcrumbs

```javascript
// Click en breadcrumb
playwright_browser_click(element="Breadcrumb Inicio", ref="nav >> text=Inicio")

// O navegar hacia atras
playwright_browser_navigate_back()
```

## Patrones de Tabla/Lista

### Verificar Registro en Tabla

```javascript
// Buscar texto especifico en tabla
playwright_browser_snapshot()  // Buscar el nombre del registro

// Si existe, verificar acciones disponibles
playwright_browser_click(element="Fila del registro", ref="tr:has-text('Nombre Registro')")
```

### Paginacion

```javascript
// Ir a siguiente pagina
playwright_browser_click(element="Siguiente pagina", ref="button:has-text('Siguiente')")

// Esperar carga
playwright_browser_wait_for(time=1)

// Verificar cambio
playwright_browser_snapshot()
```

## Patrones de Modal/Dialog

### Abrir y Cerrar Modal

```javascript
// Abrir modal
playwright_browser_click(element="Boton Abrir Modal", ref="button:has-text('Abrir')")

// Verificar modal abierto
playwright_browser_snapshot()  // Buscar elemento del modal

// Cerrar modal
playwright_browser_click(element="Boton Cerrar", ref="button:has-text('Cerrar')")
// O
playwright_browser_press_key(key="Escape")
```

### Confirmar Dialog

```javascript
// Si aparece un dialog de confirmacion
playwright_browser_handle_dialog(accept=true)
```

## Patrones de Dropdown/Select

### Seleccion Simple

```javascript
// Abrir dropdown
playwright_browser_click(element="Dropdown", ref="#mi-dropdown")

// Seleccionar opcion
playwright_browser_select_option(
  element="Select categoria",
  ref="#categoria-select",
  values=["opcion1"]
)
```

### Multi-Select

```javascript
// Seleccionar multiples opciones
playwright_browser_select_option(
  element="Multi-select",
  ref="#tags-select",
  values=["tag1", "tag2", "tag3"]
)
```

## Patrones de Checkbox/Radio

### Checkbox

```javascript
// Marcar checkbox
playwright_browser_fill_form([
  { name: "Acepto terminos", type: "checkbox", ref: "#terminos", value: "true" }
])
```

### Radio Buttons

```javascript
// Seleccionar opcion
playwright_browser_click(element="Radio opcion 1", ref="input[value='opcion1']")
```

## Patrones de Espera

### Esperar Texto

```javascript
// Esperar a que aparezca texto especifico
playwright_browser_wait_for(text="Operacion exitosa")
```

### Esperar Tiempo

```javascript
// Esperar X segundos (usar con moderacion)
playwright_browser_wait_for(time=2)
```

### Esperar Desaparicion

```javascript
// Esperar a que desaparezca loading
playwright_browser_wait_for(textGone="Cargando...")
```

## Patrones de Verificacion

### Verificar Texto Presente

```javascript
playwright_browser_snapshot()
// En el resultado buscar el texto esperado
```

### Verificar Elemento Visible

```javascript
playwright_browser_snapshot()
// Verificar que el elemento aparece en el snapshot
```

### Verificar URL Actual

```javascript
playwright_browser_evaluate(function="() => window.location.href")
// Debe devolver la URL esperada
```

### Verificar Consola sin Errores

```javascript
playwright_browser_console_messages(level="error")
// Verificar que no hay errores
```

## Patrones de Screenshot

### Captura de Evidencia

```javascript
// Captura completa de pagina
playwright_browser_take_screenshot(type="png", filename="evidencia-test.png")

// Captura de elemento especifico
playwright_browser_take_screenshot(
  type="png",
  filename="elemento-test.png",
  element="Formulario",
  ref="#mi-formulario"
)
```

## Flujos Completos de Ejemplo

### Flujo: Crear y Eliminar Registro

```javascript
// 1. Login
playwright_browser_navigate("http://127.0.0.1:5173")
playwright_browser_fill_form([...])
playwright_browser_click(element="Login", ref="button[type='submit']")

// 2. Navegar a seccion
playwright_browser_click(element="Menu Productos", ref="nav >> text=Productos")

// 3. Crear
playwright_browser_click(element="Nuevo", ref="button:has-text('Nuevo')")
playwright_browser_fill_form([...])
playwright_browser_click(element="Guardar", ref="button:has-text('Guardar')")

// 4. Verificar creacion
playwright_browser_wait_for(text="Producto creado")
playwright_browser_snapshot()

// 5. Eliminar
playwright_browser_click(element="Eliminar", ref="button:has-text('Eliminar')")
playwright_browser_handle_dialog(accept=true)

// 6. Verificar eliminacion
playwright_browser_wait_for(text="Producto eliminado")
```

### Flujo: Buscar y Editar

```javascript
// 1. Buscar
playwright_browser_type(element="Busqueda", ref="#search", text="termino")
playwright_browser_press_key(key="Enter")

// 2. Seleccionar resultado
playwright_browser_click(element="Resultado", ref="tr:has-text('termino')")

// 3. Editar
playwright_browser_click(element="Editar", ref="button:has-text('Editar')")
playwright_browser_fill_form([...])
playwright_browser_click(element="Guardar", ref="button:has-text('Guardar')")

// 4. Verificar
playwright_browser_wait_for(text="Cambios guardados")
```
