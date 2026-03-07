package mcp

import (
	"fmt"

	mcpgo "github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"

	"github.com/agustinalbonico/feature-store/internal/store"
)

func RunStdio(storeInstance *store.Store) error {
	handlers := NewHandlers(storeInstance)

	serverInstance := server.NewMCPServer(
		"feature-store",
		"1.0.0",
		server.WithToolCapabilities(false),
	)

	registerTools(serverInstance, handlers)

	if err := server.ServeStdio(serverInstance); err != nil {
		return fmt.Errorf("fallo al iniciar servidor MCP por stdio: %w", err)
	}

	return nil
}

func registerTools(serverInstance *server.MCPServer, handlers *Handlers) {
	serverInstance.AddTool(
		mcpgo.NewTool("feature_save",
			mcpgo.WithDescription("Guarda o actualiza una feature con versionado"),
			mcpgo.WithString("projectSlug", mcpgo.Required(), mcpgo.Description("Slug del proyecto")),
			mcpgo.WithString("slug", mcpgo.Required(), mcpgo.Description("Slug de la feature")),
			mcpgo.WithString("title", mcpgo.Required(), mcpgo.Description("Titulo de la feature")),
			mcpgo.WithString("type", mcpgo.Required(), mcpgo.Description("Tipo de feature")),
			mcpgo.WithString("content", mcpgo.Required(), mcpgo.Description("Contenido de la feature")),
			mcpgo.WithString("status", mcpgo.Description("Estado de la feature")),
			mcpgo.WithString("changelog", mcpgo.Description("Changelog para snapshot de version")),
		),
		handlers.FeatureSave,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("feature_get",
			mcpgo.WithDescription("Obtiene una feature por slug"),
			mcpgo.WithString("slug", mcpgo.Required(), mcpgo.Description("Slug de la feature")),
			mcpgo.WithString("projectSlug", mcpgo.Description("Slug del proyecto")),
		),
		handlers.FeatureGet,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("feature_search",
			mcpgo.WithDescription("Busca features usando FTS5"),
			mcpgo.WithString("query", mcpgo.Required(), mcpgo.Description("Consulta de busqueda")),
			mcpgo.WithString("projectSlug", mcpgo.Description("Filtro por proyecto")),
		),
		handlers.FeatureSearch,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("feature_catalog",
			mcpgo.WithDescription("Lista features de un proyecto con filtros opcionales"),
			mcpgo.WithString("projectSlug", mcpgo.Required(), mcpgo.Description("Slug del proyecto")),
			mcpgo.WithString("status", mcpgo.Description("Filtro por estado")),
			mcpgo.WithString("type", mcpgo.Description("Filtro por tipo")),
		),
		handlers.FeatureCatalog,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("feature_versions",
			mcpgo.WithDescription("Lista las versiones de una feature"),
			mcpgo.WithString("slug", mcpgo.Required(), mcpgo.Description("Slug de la feature")),
			mcpgo.WithString("projectSlug", mcpgo.Required(), mcpgo.Description("Slug del proyecto")),
		),
		handlers.FeatureVersions,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("feature_get_version",
			mcpgo.WithDescription("Obtiene una version especifica de una feature"),
			mcpgo.WithNumber("featureId", mcpgo.Required(), mcpgo.Description("ID numerico de la feature")),
			mcpgo.WithNumber("version", mcpgo.Required(), mcpgo.Description("Numero de version")),
		),
		handlers.FeatureGetVersion,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("project_register",
			mcpgo.WithDescription("Registra o actualiza un proyecto"),
			mcpgo.WithString("slug", mcpgo.Required(), mcpgo.Description("Slug del proyecto")),
			mcpgo.WithString("name", mcpgo.Required(), mcpgo.Description("Nombre del proyecto")),
			mcpgo.WithString("path", mcpgo.Description("Ruta local del proyecto")),
		),
		handlers.ProjectRegister,
	)

	serverInstance.AddTool(
		mcpgo.NewTool("project_list",
			mcpgo.WithDescription("Lista proyectos con conteo de features"),
		),
		handlers.ProjectList,
	)
}
