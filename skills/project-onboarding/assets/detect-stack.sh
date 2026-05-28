#!/usr/bin/env bash
# detect-stack.sh - Detecta stack tecnológico y componentes de un proyecto
# Uso: ./detect-stack.sh [ruta_proyecto]
# Si no se especifica ruta, usa el directorio actual

set -e

PROJECT_PATH="${1:-.}"

# Función para detectar tecnologías en un package.json
get_node_stack() {
    local package_json="$1"
    local stack=("Node.js")
    
    if [ ! -f "$package_json" ]; then
        echo "${stack[@]}"
        return
    fi
    
    # Frameworks frontend
    grep -q '"react"' "$package_json" && stack+=("React")
    grep -q '"next"' "$package_json" && stack+=("Next.js")
    grep -q '"vue"' "$package_json" && stack+=("Vue")
    grep -q '"nuxt"' "$package_json" && stack+=("Nuxt")
    grep -q '"@angular/core"' "$package_json" && stack+=("Angular")
    grep -q '"svelte"' "$package_json" && stack+=("Svelte")
    
    # Frameworks backend
    grep -q '"@nestjs/core"' "$package_json" && stack+=("NestJS")
    grep -q '"express"' "$package_json" && stack+=("Express")
    grep -q '"fastify"' "$package_json" && stack+=("Fastify")
    grep -q '"koa"' "$package_json" && stack+=("Koa")
    
    # Build tools
    grep -q '"vite"' "$package_json" && stack+=("Vite")
    grep -q '"webpack"' "$package_json" && stack+=("Webpack")
    grep -q '"esbuild"' "$package_json" && stack+=("esbuild")
    
    # CSS
    grep -q '"tailwindcss"' "$package_json" && stack+=("Tailwind CSS")
    grep -q '"styled-components"' "$package_json" && stack+=("styled-components")
    
    # UI Libraries
    grep -q '"@radix-ui' "$package_json" && stack+=("Radix UI")
    grep -q '"@mui/material"' "$package_json" && stack+=("Material-UI")
    grep -q '"antd"' "$package_json" && stack+=("Ant Design")
    
    # ORM / Database
    grep -q '"typeorm"' "$package_json" && stack+=("TypeORM")
    grep -q '"prisma"' "$package_json" && stack+=("Prisma")
    grep -q '"drizzle-orm"' "$package_json" && stack+=("Drizzle")
    grep -q '"mongoose"' "$package_json" && stack+=("Mongoose")
    grep -q '"sequelize"' "$package_json" && stack+=("Sequelize")
    
    # Testing
    grep -q '"vitest"' "$package_json" && stack+=("Vitest")
    grep -q '"jest"' "$package_json" && stack+=("Jest")
    grep -q '"@playwright/test"' "$package_json" && stack+=("Playwright")
    grep -q '"cypress"' "$package_json" && stack+=("Cypress")
    
    # Auth
    grep -q '"next-auth"\|"@auth/core"' "$package_json" && stack+=("Auth.js")
    grep -q '"@clerk' "$package_json" && stack+=("Clerk")
    
    # State management
    grep -q '"zustand"' "$package_json" && stack+=("Zustand")
    grep -q '"redux"\|"@reduxjs/toolkit"' "$package_json" && stack+=("Redux")
    grep -q '"@tanstack/react-query"' "$package_json" && stack+=("TanStack Query")
    
    # Validation
    grep -q '"zod"' "$package_json" && stack+=("Zod")
    grep -q '"yup"' "$package_json" && stack+=("Yup")
    
    echo "${stack[@]}"
}

# Función para detectar tecnologías en pyproject.toml
get_python_stack() {
    local pyproject="$1"
    local stack=("Python")
    
    if [ ! -f "$pyproject" ]; then
        echo "${stack[@]}"
        return
    fi
    
    grep -q "django" "$pyproject" && stack+=("Django")
    grep -q "fastapi" "$pyproject" && stack+=("FastAPI")
    grep -q "flask" "$pyproject" && stack+=("Flask")
    grep -q "sqlalchemy" "$pyproject" && stack+=("SQLAlchemy")
    grep -q "pytest" "$pyproject" && stack+=("pytest")
    
    echo "${stack[@]}"
}

# Función para detectar tecnologías en go.mod
get_go_stack() {
    local go_mod="$1"
    local stack=("Go")
    
    if [ ! -f "$go_mod" ]; then
        echo "${stack[@]}"
        return
    fi
    
    grep -q "gin-gonic" "$go_mod" && stack+=("Gin")
    grep -q "gorilla/mux" "$go_mod" && stack+=("Gorilla Mux")
    grep -q "gorm" "$go_mod" && stack+=("GORM")
    
    echo "${stack[@]}"
}

# Función para detectar tecnologías en Cargo.toml
get_rust_stack() {
    local cargo="$1"
    local stack=("Rust")
    
    if [ ! -f "$cargo" ]; then
        echo "${stack[@]}"
        return
    fi
    
    grep -q "actix-web" "$cargo" && stack+=("Actix Web")
    grep -q "axum" "$cargo" && stack+=("Axum")
    grep -q "diesel" "$cargo" && stack+=("Diesel")
    
    echo "${stack[@]}"
}

# Detectar componentes (carpetas)
get_components() {
    local root="$1"
    local components=()
    
    # Backend
    for pattern in "backend" "api" "server" "apps/backend" "apps/api" "apps/server"; do
        if [ -d "$root/$pattern" ]; then
            components+=("backend:$pattern")
            break
        fi
    done
    
    # Frontend
    for pattern in "frontend" "web" "client" "apps/frontend" "apps/web" "apps/client"; do
        if [ -d "$root/$pattern" ]; then
            components+=("frontend:$pattern")
            break
        fi
    done
    
    # Shared
    for pattern in "packages/shared" "shared" "common" "packages/common"; do
        if [ -d "$root/$pattern" ]; then
            components+=("shared:$pattern")
            break
        fi
    done
    
    # MCP
    for pattern in "mcp_server" "mcp" "mcp-server"; do
        if [ -d "$root/$pattern" ]; then
            components+=("mcp:$pattern")
            break
        fi
    done
    
    # SDK
    for pattern in "sdk" "lib" "packages/sdk" "packages/lib"; do
        if [ -d "$root/$pattern" ]; then
            components+=("sdk:$pattern")
            break
        fi
    done
    
    echo "${components[@]}"
}

# Función principal
get_project_stack() {
    local root="$1"
    
    echo "{"
    echo '  "components": {'
    
    # Detectar componentes
    local components=($(get_components "$root"))
    
    # Si no hay componentes, tratar todo como root
    if [ ${#components[@]} -eq 0 ]; then
        components=("root:.")
    fi
    
    local first_component=true
    for component in "${components[@]}"; do
        local name="${component%%:*}"
        local path="${component#*:}"
        local component_path="$root/$path"
        
        if [ "$first_component" = false ]; then
            echo ","
        fi
        first_component=false
        
        echo "    \"$name\": {"
        echo "      \"path\": \"$path\","
        echo -n '      "stack": ['
        
        local stack=()
        
        # Detectar stack según archivos
        if [ -f "$component_path/package.json" ]; then
            stack+=($(get_node_stack "$component_path/package.json"))
        fi
        
        if [ -f "$component_path/pyproject.toml" ]; then
            stack+=($(get_python_stack "$component_path/pyproject.toml"))
        fi
        
        if [ -f "$component_path/go.mod" ]; then
            stack+=($(get_go_stack "$component_path/go.mod"))
        fi
        
        if [ -f "$component_path/Cargo.toml" ]; then
            stack+=($(get_rust_stack "$component_path/Cargo.toml"))
        fi
        
        # TypeScript
        if [ -f "$component_path/tsconfig.json" ]; then
            if [[ ! " ${stack[@]} " =~ " TypeScript " ]]; then
                stack+=("TypeScript")
            fi
        fi
        
        # Tailwind
        for pattern in "tailwind.config.js" "tailwind.config.ts" "tailwind.config.cjs"; do
            if [ -f "$component_path/$pattern" ]; then
                if [[ ! " ${stack[@]} " =~ " Tailwind\ CSS " ]]; then
                    stack+=("Tailwind CSS")
                fi
                break
            fi
        done
        
        # Eliminar duplicados y formatear
        local unique_stack=($(echo "${stack[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        local first_stack=true
        for tech in "${unique_stack[@]}"; do
            if [ "$first_stack" = false ]; then
                echo -n ", "
            fi
            first_stack=false
            echo -n "\"$tech\""
        done
        
        echo "]"
        echo -n "    }"
    done
    
    echo ""
    echo "  },"
    
    # Herramientas globales
    echo -n '  "tools": ['
    local tools=()
    
    if [ -f "$root/docker-compose.yml" ] || [ -f "$root/docker-compose.yaml" ] || [ -f "$root/Dockerfile" ]; then
        tools+=("Docker")
    fi
    
    local first_tool=true
    for tool in "${tools[@]}"; do
        if [ "$first_tool" = false ]; then
            echo -n ", "
        fi
        first_tool=false
        echo -n "\"$tool\""
    done
    
    echo "],"
    
    # Scopes
    echo -n '  "scopes": ['
    local first_scope=true
    for component in "${components[@]}"; do
        local name="${component%%:*}"
        if [ "$first_scope" = false ]; then
            echo -n ", "
        fi
        first_scope=false
        echo -n "\"$name\""
    done
    
    echo "]"
    echo "}"
}

# Ejecutar detección
get_project_stack "$PROJECT_PATH"
