package mcp

import (
	"context"
	"encoding/json"
	"fmt"

	mcpgo "github.com/mark3labs/mcp-go/mcp"

	"github.com/agustinalbonico/feature-store/internal/store"
)

type Handlers struct {
	store *store.Store
}

func NewHandlers(storeInstance *store.Store) *Handlers {
	return &Handlers{store: storeInstance}
}

func (h *Handlers) FeatureSave(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	projectSlug, err := request.RequireString("projectSlug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	slug, err := request.RequireString("slug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	title, err := request.RequireString("title")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	featureType, err := request.RequireString("type")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	content, err := request.RequireString("content")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	status := request.GetString("status", "draft")
	changelog := request.GetString("changelog", "")

	feature, err := h.store.SaveFeature(ctx, store.SaveFeatureInput{
		ProjectSlug: projectSlug,
		Slug:        slug,
		Title:       title,
		Type:        featureType,
		Content:     content,
		Status:      status,
		Changelog:   changelog,
	})
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(feature)
}

func (h *Handlers) FeatureGet(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	slug, err := request.RequireString("slug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	projectSlug := request.GetString("projectSlug", "")
	feature, err := h.store.GetFeature(ctx, slug, projectSlug)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	if feature == nil {
		return mcpgo.NewToolResultError("feature no encontrada"), nil
	}

	return jsonResult(feature)
}

func (h *Handlers) FeatureSearch(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	query, err := request.RequireString("query")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	projectSlug := request.GetString("projectSlug", "")
	results, err := h.store.SearchFeatures(ctx, query, projectSlug)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(results)
}

func (h *Handlers) FeatureCatalog(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	projectSlug, err := request.RequireString("projectSlug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	status := request.GetString("status", "")
	featureType := request.GetString("type", "")
	results, err := h.store.CatalogFeatures(ctx, projectSlug, status, featureType)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(results)
}

func (h *Handlers) FeatureVersions(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	slug, err := request.RequireString("slug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	projectSlug, err := request.RequireString("projectSlug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	results, err := h.store.FeatureVersions(ctx, slug, projectSlug)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(results)
}

func (h *Handlers) FeatureGetVersion(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	featureIDRaw, err := request.RequireInt("featureId")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	versionRaw, err := request.RequireInt("version")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	item, err := h.store.GetFeatureVersion(ctx, int64(featureIDRaw), int64(versionRaw))
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	if item == nil {
		return mcpgo.NewToolResultError("version no encontrada"), nil
	}

	return jsonResult(item)
}

func (h *Handlers) ProjectRegister(ctx context.Context, request mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	slug, err := request.RequireString("slug")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	name, err := request.RequireString("name")
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	path := request.GetString("path", "")
	project, err := h.store.RegisterProject(ctx, slug, name, path)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(project)
}

func (h *Handlers) ProjectList(ctx context.Context, _ mcpgo.CallToolRequest) (*mcpgo.CallToolResult, error) {
	projects, err := h.store.ListProjects(ctx)
	if err != nil {
		return mcpgo.NewToolResultError(err.Error()), nil
	}

	return jsonResult(projects)
}

func jsonResult(payload any) (*mcpgo.CallToolResult, error) {
	encoded, err := json.Marshal(payload)
	if err != nil {
		return mcpgo.NewToolResultError(fmt.Sprintf("no se pudo serializar la respuesta: %s", err.Error())), nil
	}

	return mcpgo.NewToolResultText(string(encoded)), nil
}
