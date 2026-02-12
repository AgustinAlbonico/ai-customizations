# /tauri-migrate-verify

Ejecutar verificacion funcional y de estabilidad para migracion Tauri.

## Checklist

- Setup inicial completo
- Login correcto
- CRUD principal operativo
- Sin errores bloqueantes en logs

## Logs prioritarios

- `%APPDATA%/sistema-caja/debug_startup.log`
- `%APPDATA%/sistema-caja/logs/error-YYYY-MM-DD.log`
- `%APPDATA%/sistema-caja/logs/application-YYYY-MM-DD.log`

## Criterio

- Go: todo el checklist en verde
- No-Go: sidecar inestable, auth rota o DB inaccesible
