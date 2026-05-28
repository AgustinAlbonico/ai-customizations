#!/usr/bin/env bash
# detect-stack.sh - Detect project stack and components.
# Usage: ./detect-stack.sh [project_path]

set -e

PROJECT_PATH="${1:-.}"

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_array() {
    local first=true
    printf '['
    for item in "$@"; do
        if [ "$first" = false ]; then printf ', '; fi
        first=false
        printf '"%s"' "$(json_escape "$item")"
    done
    printf ']'
}

unique_array() {
    local result=()
    local item existing found
    for item in "$@"; do
        found=false
        for existing in "${result[@]}"; do
            if [ "$existing" = "$item" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then result+=("$item"); fi
    done
    printf '%s\n' "${result[@]}"
}

get_node_stack() {
    local package_json="$1"
    printf '%s\n' "Node.js"
    [ -f "$package_json" ] || return

    grep -q '"react"' "$package_json" && printf '%s\n' "React"
    grep -q '"next"' "$package_json" && printf '%s\n' "Next.js"
    grep -q '"vue"' "$package_json" && printf '%s\n' "Vue"
    grep -q '"nuxt"' "$package_json" && printf '%s\n' "Nuxt"
    grep -q '"@angular/core"' "$package_json" && printf '%s\n' "Angular"
    grep -q '"svelte"' "$package_json" && printf '%s\n' "Svelte"

    grep -q '"@nestjs/core"' "$package_json" && printf '%s\n' "NestJS"
    grep -q '"express"' "$package_json" && printf '%s\n' "Express"
    grep -q '"fastify"' "$package_json" && printf '%s\n' "Fastify"
    grep -q '"koa"' "$package_json" && printf '%s\n' "Koa"

    grep -q '"vite"' "$package_json" && printf '%s\n' "Vite"
    grep -q '"webpack"' "$package_json" && printf '%s\n' "Webpack"
    grep -q '"esbuild"' "$package_json" && printf '%s\n' "esbuild"

    grep -q '"tailwindcss"' "$package_json" && printf '%s\n' "Tailwind CSS"
    grep -q '"styled-components"' "$package_json" && printf '%s\n' "styled-components"

    grep -q '"@radix-ui' "$package_json" && printf '%s\n' "Radix UI"
    grep -q '"@mui/material"' "$package_json" && printf '%s\n' "Material-UI"
    grep -q '"antd"' "$package_json" && printf '%s\n' "Ant Design"

    grep -q '"typeorm"' "$package_json" && printf '%s\n' "TypeORM"
    grep -q '"prisma"' "$package_json" && printf '%s\n' "Prisma"
    grep -q '"drizzle-orm"' "$package_json" && printf '%s\n' "Drizzle"
    grep -q '"mongoose"' "$package_json" && printf '%s\n' "Mongoose"
    grep -q '"sequelize"' "$package_json" && printf '%s\n' "Sequelize"
    grep -q '"pg"' "$package_json" && printf '%s\n' "PostgreSQL"
    grep -q '"mysql2"' "$package_json" && printf '%s\n' "MySQL"

    grep -q '"vitest"' "$package_json" && printf '%s\n' "Vitest"
    grep -q '"jest"' "$package_json" && printf '%s\n' "Jest"
    grep -q '"@playwright/test"' "$package_json" && printf '%s\n' "Playwright"
    grep -q '"cypress"' "$package_json" && printf '%s\n' "Cypress"

    grep -q '"next-auth"\|"@auth/core"' "$package_json" && printf '%s\n' "Auth.js"
    grep -q '"@clerk' "$package_json" && printf '%s\n' "Clerk"

    grep -q '"zustand"' "$package_json" && printf '%s\n' "Zustand"
    grep -q '"redux"\|"@reduxjs/toolkit"' "$package_json" && printf '%s\n' "Redux"
    grep -q '"@tanstack/react-query"' "$package_json" && printf '%s\n' "TanStack Query"

    grep -q '"zod"' "$package_json" && printf '%s\n' "Zod"
    grep -q '"yup"' "$package_json" && printf '%s\n' "Yup"
}

get_python_stack() {
    local pyproject="$1"
    printf '%s\n' "Python"
    [ -f "$pyproject" ] || return
    grep -qi "django" "$pyproject" && printf '%s\n' "Django"
    grep -qi "fastapi" "$pyproject" && printf '%s\n' "FastAPI"
    grep -qi "flask" "$pyproject" && printf '%s\n' "Flask"
    grep -qi "sqlalchemy" "$pyproject" && printf '%s\n' "SQLAlchemy"
    grep -qi "pytest" "$pyproject" && printf '%s\n' "pytest"
}

get_go_stack() {
    local go_mod="$1"
    printf '%s\n' "Go"
    [ -f "$go_mod" ] || return
    grep -q "gin-gonic" "$go_mod" && printf '%s\n' "Gin"
    grep -q "gorilla/mux" "$go_mod" && printf '%s\n' "Gorilla Mux"
    grep -q "gorm" "$go_mod" && printf '%s\n' "GORM"
}

get_rust_stack() {
    local cargo="$1"
    printf '%s\n' "Rust"
    [ -f "$cargo" ] || return
    grep -q "actix-web" "$cargo" && printf '%s\n' "Actix Web"
    grep -q "axum" "$cargo" && printf '%s\n' "Axum"
    grep -q "diesel" "$cargo" && printf '%s\n' "Diesel"
}

get_components() {
    local root="$1"
    local found=false
    local pattern

    for pattern in "backend" "api" "server" "apps/backend" "apps/api" "apps/server"; do
        if [ -d "$root/$pattern" ]; then printf '%s\n' "backend:$pattern"; found=true; break; fi
    done
    for pattern in "frontend" "web" "client" "apps/frontend" "apps/web" "apps/client"; do
        if [ -d "$root/$pattern" ]; then printf '%s\n' "frontend:$pattern"; found=true; break; fi
    done
    for pattern in "packages/shared" "shared" "common" "packages/common"; do
        if [ -d "$root/$pattern" ]; then printf '%s\n' "shared:$pattern"; found=true; break; fi
    done
    for pattern in "mcp_server" "mcp" "mcp-server"; do
        if [ -d "$root/$pattern" ]; then printf '%s\n' "mcp:$pattern"; found=true; break; fi
    done
    for pattern in "sdk" "lib" "packages/sdk" "packages/lib"; do
        if [ -d "$root/$pattern" ]; then printf '%s\n' "sdk:$pattern"; found=true; break; fi
    done

    if [ "$found" = false ]; then printf '%s\n' "root:."; fi
}

component_stack() {
    local component_path="$1"
    local stack=()
    local tech

    if [ -f "$component_path/package.json" ]; then
        while IFS= read -r tech; do stack+=("$tech"); done < <(get_node_stack "$component_path/package.json")
    fi
    if [ -f "$component_path/pyproject.toml" ]; then
        while IFS= read -r tech; do stack+=("$tech"); done < <(get_python_stack "$component_path/pyproject.toml")
    fi
    if [ -f "$component_path/go.mod" ]; then
        while IFS= read -r tech; do stack+=("$tech"); done < <(get_go_stack "$component_path/go.mod")
    fi
    if [ -f "$component_path/Cargo.toml" ]; then
        while IFS= read -r tech; do stack+=("$tech"); done < <(get_rust_stack "$component_path/Cargo.toml")
    fi
    if [ -f "$component_path/tsconfig.json" ]; then stack+=("TypeScript"); fi
    for pattern in "tailwind.config.js" "tailwind.config.ts" "tailwind.config.cjs"; do
        if [ -f "$component_path/$pattern" ]; then stack+=("Tailwind CSS"); break; fi
    done

    local unique=()
    while IFS= read -r tech; do unique+=("$tech"); done < <(unique_array "${stack[@]}")
    json_array "${unique[@]}"
}

get_project_stack() {
    local root="$1"
    local components=()
    local component name path component_path
    while IFS= read -r component; do components+=("$component"); done < <(get_components "$root")

    printf '{\n'
    printf '  "components": {\n'

    local first_component=true
    for component in "${components[@]}"; do
        name="${component%%:*}"
        path="${component#*:}"
        component_path="$root/$path"
        if [ "$first_component" = false ]; then printf ',\n'; fi
        first_component=false
        printf '    "%s": {\n' "$(json_escape "$name")"
        printf '      "path": "%s",\n' "$(json_escape "$path")"
        printf '      "stack": '
        component_stack "$component_path"
        printf '\n    }'
    done

    printf '\n  },\n'

    local tools=()
    if [ -f "$root/docker-compose.yml" ] || [ -f "$root/docker-compose.yaml" ] || [ -f "$root/Dockerfile" ]; then
        tools+=("Docker")
    fi
    printf '  "tools": '
    json_array "${tools[@]}"
    printf ',\n'

    local scopes=()
    for component in "${components[@]}"; do scopes+=("${component%%:*}"); done
    printf '  "scopes": '
    json_array "${scopes[@]}"
    printf '\n}\n'
}

get_project_stack "$PROJECT_PATH"
