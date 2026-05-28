#!/usr/bin/env pwsh
# detect-stack.ps1 - Detecta stack tecnológico y componentes de un proyecto
# Uso: ./detect-stack.ps1 [ruta_proyecto]
# Si no se especifica ruta, usa el directorio actual

param(
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath)) {
    throw "Project path does not exist: $ProjectPath"
}

$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

# Función para detectar tecnologías en un package.json
function Get-NodeStack {
    param([string]$packageJsonPath)
    
    $stack = @("Node.js")
    
    if (-not (Test-Path $packageJsonPath)) {
        return $stack
    }
    
    $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
    
    $allDeps = @{}
    if ($packageJson.dependencies) {
        $packageJson.dependencies.PSObject.Properties | ForEach-Object {
            $allDeps[$_.Name] = $_.Value
        }
    }
    if ($packageJson.devDependencies) {
        $packageJson.devDependencies.PSObject.Properties | ForEach-Object {
            $allDeps[$_.Name] = $_.Value
        }
    }
    
    # Frameworks frontend
    if ($allDeps.ContainsKey("react")) { $stack += "React" }
    if ($allDeps.ContainsKey("next")) { $stack += "Next.js" }
    if ($allDeps.ContainsKey("vue")) { $stack += "Vue" }
    if ($allDeps.ContainsKey("nuxt")) { $stack += "Nuxt" }
    if ($allDeps.ContainsKey("@angular/core")) { $stack += "Angular" }
    if ($allDeps.ContainsKey("svelte")) { $stack += "Svelte" }
    
    # Frameworks backend
    if ($allDeps.ContainsKey("@nestjs/core")) { $stack += "NestJS" }
    if ($allDeps.ContainsKey("express")) { $stack += "Express" }
    if ($allDeps.ContainsKey("fastify")) { $stack += "Fastify" }
    if ($allDeps.ContainsKey("koa")) { $stack += "Koa" }
    
    # Build tools
    if ($allDeps.ContainsKey("vite")) { $stack += "Vite" }
    if ($allDeps.ContainsKey("webpack")) { $stack += "Webpack" }
    if ($allDeps.ContainsKey("esbuild")) { $stack += "esbuild" }
    
    # CSS
    if ($allDeps.ContainsKey("tailwindcss")) { $stack += "Tailwind CSS" }
    if ($allDeps.ContainsKey("styled-components")) { $stack += "styled-components" }
    
    # UI Libraries
    if ($allDeps.ContainsKey("@radix-ui/react-dialog") -or 
        $allDeps.ContainsKey("@radix-ui/themes")) { $stack += "Radix UI" }
    if ($allDeps.ContainsKey("@mui/material")) { $stack += "Material-UI" }
    if ($allDeps.ContainsKey("antd")) { $stack += "Ant Design" }
    
    # ORM / Database
    if ($allDeps.ContainsKey("typeorm")) { $stack += "TypeORM" }
    if ($allDeps.ContainsKey("prisma")) { $stack += "Prisma" }
    if ($allDeps.ContainsKey("drizzle-orm")) { $stack += "Drizzle" }
    if ($allDeps.ContainsKey("mongoose")) { $stack += "Mongoose" }
    if ($allDeps.ContainsKey("sequelize")) { $stack += "Sequelize" }
    if ($allDeps.ContainsKey("pg")) { $stack += "PostgreSQL" }
    if ($allDeps.ContainsKey("mysql2")) { $stack += "MySQL" }
    
    # Testing
    if ($allDeps.ContainsKey("vitest")) { $stack += "Vitest" }
    if ($allDeps.ContainsKey("jest")) { $stack += "Jest" }
    if ($allDeps.ContainsKey("@playwright/test")) { $stack += "Playwright" }
    if ($allDeps.ContainsKey("cypress")) { $stack += "Cypress" }
    
    # Auth
    if ($allDeps.ContainsKey("next-auth") -or $allDeps.ContainsKey("@auth/core")) { $stack += "Auth.js" }
    if ($allDeps.ContainsKey("@clerk/nextjs") -or $allDeps.ContainsKey("@clerk/express")) { $stack += "Clerk" }
    
    # State management
    if ($allDeps.ContainsKey("zustand")) { $stack += "Zustand" }
    if ($allDeps.ContainsKey("redux") -or $allDeps.ContainsKey("@reduxjs/toolkit")) { $stack += "Redux" }
    if ($allDeps.ContainsKey("@tanstack/react-query")) { $stack += "TanStack Query" }
    
    # Validation
    if ($allDeps.ContainsKey("zod")) { $stack += "Zod" }
    if ($allDeps.ContainsKey("yup")) { $stack += "Yup" }
    
    return $stack
}

# Función para detectar tecnologías en pyproject.toml
function Get-PythonStack {
    param([string]$pyprojectPath)
    
    $stack = @("Python")
    
    if (-not (Test-Path $pyprojectPath)) {
        return $stack
    }
    
    $content = Get-Content $pyprojectPath -Raw
    
    if ($content -match "django") { $stack += "Django" }
    if ($content -match "fastapi") { $stack += "FastAPI" }
    if ($content -match "flask") { $stack += "Flask" }
    if ($content -match "sqlalchemy") { $stack += "SQLAlchemy" }
    if ($content -match "pytest") { $stack += "pytest" }
    
    return $stack
}

# Función para detectar tecnologías en go.mod
function Get-GoStack {
    param([string]$goModPath)
    
    $stack = @("Go")
    
    if (-not (Test-Path $goModPath)) {
        return $stack
    }
    
    $content = Get-Content $goModPath -Raw
    
    if ($content -match "gin-gonic") { $stack += "Gin" }
    if ($content -match "gorilla/mux") { $stack += "Gorilla Mux" }
    if ($content -match "gorm") { $stack += "GORM" }
    
    return $stack
}

# Función para detectar tecnologías en Cargo.toml
function Get-RustStack {
    param([string]$cargoPath)
    
    $stack = @("Rust")
    
    if (-not (Test-Path $cargoPath)) {
        return $stack
    }
    
    $content = Get-Content $cargoPath -Raw
    
    if ($content -match "actix-web") { $stack += "Actix Web" }
    if ($content -match "axum") { $stack += "Axum" }
    if ($content -match "diesel") { $stack += "Diesel" }
    
    return $stack
}

# Detectar componentes (carpetas)
function Get-Components {
    param([string]$rootPath)
    
    $components = @{}
    
    # Patrones de carpetas para backend
    $backendPatterns = @("backend", "api", "server", "apps/backend", "apps/api", "apps/server")
    foreach ($pattern in $backendPatterns) {
        $path = Join-Path $rootPath $pattern
        if (Test-Path $path) {
            $components["backend"] = @{
                path = $pattern
                stack = @()
            }
            break
        }
    }
    
    # Patrones de carpetas para frontend
    $frontendPatterns = @("frontend", "web", "client", "apps/frontend", "apps/web", "apps/client")
    foreach ($pattern in $frontendPatterns) {
        $path = Join-Path $rootPath $pattern
        if (Test-Path $path) {
            $components["frontend"] = @{
                path = $pattern
                stack = @()
            }
            break
        }
    }
    
    # Patrones para shared/common
    $sharedPatterns = @("packages/shared", "shared", "common", "packages/common")
    foreach ($pattern in $sharedPatterns) {
        $path = Join-Path $rootPath $pattern
        if (Test-Path $path) {
            $components["shared"] = @{
                path = $pattern
                stack = @()
            }
            break
        }
    }
    
    # Patrones para MCP
    $mcpPatterns = @("mcp_server", "mcp", "mcp-server")
    foreach ($pattern in $mcpPatterns) {
        $path = Join-Path $rootPath $pattern
        if (Test-Path $path) {
            $components["mcp"] = @{
                path = $pattern
                stack = @()
            }
            break
        }
    }
    
    # Patrones para SDK/Library
    $sdkPatterns = @("sdk", "lib", "packages/sdk", "packages/lib")
    foreach ($pattern in $sdkPatterns) {
        $path = Join-Path $rootPath $pattern
        if (Test-Path $path) {
            $components["sdk"] = @{
                path = $pattern
                stack = @()
            }
            break
        }
    }
    
    return $components
}

# Función principal
function Get-ProjectStack {
    param([string]$rootPath)
    
    $result = @{
        components = @{}
        tools = @()
        scopes = @()
    }
    
    # Detectar componentes
    $components = Get-Components $rootPath
    
    # Si no hay componentes, tratar todo como root
    if ($components.Count -eq 0) {
        $components["root"] = @{
            path = "."
            stack = @()
        }
    }
    
    # Analizar cada componente
    foreach ($componentName in $components.Keys) {
        $component = $components[$componentName]
        $componentPath = Join-Path $rootPath $component.path
        
        # Detectar stack según archivos presentes
        $packageJsonPath = Join-Path $componentPath "package.json"
        if (Test-Path $packageJsonPath) {
            $component.stack += Get-NodeStack $packageJsonPath
        }
        
        $pyprojectPath = Join-Path $componentPath "pyproject.toml"
        if (Test-Path $pyprojectPath) {
            $component.stack += Get-PythonStack $pyprojectPath
        }
        
        $goModPath = Join-Path $componentPath "go.mod"
        if (Test-Path $goModPath) {
            $component.stack += Get-GoStack $goModPath
        }
        
        $cargoPath = Join-Path $componentPath "Cargo.toml"
        if (Test-Path $cargoPath) {
            $component.stack += Get-RustStack $cargoPath
        }
        
        # Detectar TypeScript
        $tsconfigPath = Join-Path $componentPath "tsconfig.json"
        if (Test-Path $tsconfigPath) {
            if ($component.stack -notcontains "TypeScript") {
                $component.stack += "TypeScript"
            }
        }
        
        # Detectar Tailwind
        $tailwindPatterns = @("tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs")
        foreach ($pattern in $tailwindPatterns) {
            $tailwindPath = Join-Path $componentPath $pattern
            if (Test-Path $tailwindPath) {
                if ($component.stack -notcontains "Tailwind CSS") {
                    $component.stack += "Tailwind CSS"
                }
                break
            }
        }
        
        # Eliminar duplicados
        $component.stack = $component.stack | Select-Object -Unique
        
        $result.components[$componentName] = $component
        $result.scopes += $componentName
    }
    
    # Detectar herramientas globales
    $dockerComposePath = Join-Path $rootPath "docker-compose.yml"
    $dockerComposeYamlPath = Join-Path $rootPath "docker-compose.yaml"
    if ((Test-Path $dockerComposePath) -or (Test-Path $dockerComposeYamlPath)) {
        $result.tools += "Docker"
    }
    
    $dockerfilePath = Join-Path $rootPath "Dockerfile"
    if (Test-Path $dockerfilePath) {
        if ($result.tools -notcontains "Docker") {
            $result.tools += "Docker"
        }
    }
    
    return $result
}

# Ejecutar detección
$stack = Get-ProjectStack $ProjectPath

# Convertir a JSON
$json = $stack | ConvertTo-Json -Depth 4

# Output
Write-Output $json
