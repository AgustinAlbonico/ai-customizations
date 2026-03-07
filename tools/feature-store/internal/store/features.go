package store

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"fmt"
	"strings"
)

type Store struct {
	database *sql.DB
}

func New(database *sql.DB) *Store {
	return &Store{database: database}
}

type Feature struct {
	ID             int64  `json:"id"`
	ProjectSlug    string `json:"projectSlug"`
	Slug           string `json:"slug"`
	Title          string `json:"title"`
	Type           string `json:"type"`
	Status         string `json:"status"`
	Content        string `json:"content"`
	Version        int64  `json:"version"`
	TopicKey       string `json:"topicKey"`
	NormalizedHash string `json:"normalizedHash"`
	CreatedAt      string `json:"createdAt"`
	UpdatedAt      string `json:"updatedAt"`
}

type FeatureVersion struct {
	ID        int64  `json:"id,omitempty"`
	FeatureID int64  `json:"featureId"`
	Version   int64  `json:"version"`
	Content   string `json:"content"`
	Changelog string `json:"changelog,omitempty"`
	CreatedAt string `json:"createdAt"`
}

type FeatureSearchResult struct {
	ID          int64  `json:"id"`
	ProjectSlug string `json:"projectSlug"`
	Slug        string `json:"slug"`
	Title       string `json:"title"`
	Type        string `json:"type"`
	Status      string `json:"status"`
	Version     int64  `json:"version"`
	UpdatedAt   string `json:"updatedAt"`
}

type SaveFeatureInput struct {
	ProjectSlug string
	Slug        string
	Title       string
	Type        string
	Content     string
	Status      string
	Changelog   string
}

func (s *Store) SaveFeature(ctx context.Context, input SaveFeatureInput) (*Feature, error) {
	status := strings.TrimSpace(input.Status)
	if status == "" {
		status = "draft"
	}

	topicKey := fmt.Sprintf("%s/%s", strings.TrimSpace(input.ProjectSlug), strings.TrimSpace(input.Slug))
	hash := normalizeHash(input.Content)

	tx, err := s.database.BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("no se pudo iniciar transaccion: %w", err)
	}

	committed := false
	defer func() {
		if !committed {
			_ = tx.Rollback()
		}
	}()

	var featureID int64
	var currentVersion int64
	var previousContent string

	lookupErr := tx.QueryRowContext(
		ctx,
		`SELECT id, version, content FROM features WHERE topicKey = ?`,
		topicKey,
	).Scan(&featureID, &currentVersion, &previousContent)

	if lookupErr != nil && lookupErr != sql.ErrNoRows {
		return nil, fmt.Errorf("no se pudo consultar feature existente: %w", lookupErr)
	}

	if lookupErr == sql.ErrNoRows {
		result, execErr := tx.ExecContext(
			ctx,
			`INSERT INTO features (
				projectSlug,
				slug,
				title,
				type,
				status,
				content,
				version,
				topicKey,
				normalizedHash
			) VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?)`,
			input.ProjectSlug,
			input.Slug,
			input.Title,
			input.Type,
			status,
			input.Content,
			topicKey,
			hash,
		)
		if execErr != nil {
			return nil, fmt.Errorf("no se pudo insertar feature: %w", execErr)
		}

		featureID, err = result.LastInsertId()
		if err != nil {
			return nil, fmt.Errorf("no se pudo obtener id de feature: %w", err)
		}
	} else {
		if _, execErr := tx.ExecContext(
			ctx,
			`INSERT INTO featureVersions (featureId, version, content, changelog) VALUES (?, ?, ?, ?)`,
			featureID,
			currentVersion,
			previousContent,
			nullString(input.Changelog),
		); execErr != nil {
			return nil, fmt.Errorf("no se pudo insertar snapshot de version: %w", execErr)
		}

		nextVersion := currentVersion + 1
		if _, execErr := tx.ExecContext(
			ctx,
			`UPDATE features
			 SET projectSlug = ?,
			     slug = ?,
			     title = ?,
			     type = ?,
			     status = ?,
			     content = ?,
			     version = ?,
			     normalizedHash = ?,
			     updatedAt = datetime('now')
			 WHERE id = ?`,
			input.ProjectSlug,
			input.Slug,
			input.Title,
			input.Type,
			status,
			input.Content,
			nextVersion,
			hash,
			featureID,
		); execErr != nil {
			return nil, fmt.Errorf("no se pudo actualizar feature: %w", execErr)
		}
	}

	feature, err := queryFeatureByID(ctx, tx, featureID)
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("no se pudo confirmar transaccion: %w", err)
	}
	committed = true

	return feature, nil
}

func (s *Store) GetFeature(ctx context.Context, slug string, projectSlug string) (*Feature, error) {
	if strings.TrimSpace(projectSlug) != "" {
		var feature Feature
		err := s.database.QueryRowContext(
			ctx,
			`SELECT id, projectSlug, slug, title, type, status, content, version, COALESCE(topicKey, ''), COALESCE(normalizedHash, ''), createdAt, updatedAt
			 FROM features
			 WHERE slug = ? AND projectSlug = ?`,
			slug,
			projectSlug,
		).Scan(
			&feature.ID,
			&feature.ProjectSlug,
			&feature.Slug,
			&feature.Title,
			&feature.Type,
			&feature.Status,
			&feature.Content,
			&feature.Version,
			&feature.TopicKey,
			&feature.NormalizedHash,
			&feature.CreatedAt,
			&feature.UpdatedAt,
		)
		if err != nil {
			if err == sql.ErrNoRows {
				return nil, nil
			}
			return nil, fmt.Errorf("no se pudo obtener feature: %w", err)
		}
		return &feature, nil
	}

	var feature Feature
	err := s.database.QueryRowContext(
		ctx,
		`SELECT id, projectSlug, slug, title, type, status, content, version, COALESCE(topicKey, ''), COALESCE(normalizedHash, ''), createdAt, updatedAt
		 FROM features
		 WHERE slug = ?
		 ORDER BY updatedAt DESC
		 LIMIT 1`,
		slug,
	).Scan(
		&feature.ID,
		&feature.ProjectSlug,
		&feature.Slug,
		&feature.Title,
		&feature.Type,
		&feature.Status,
		&feature.Content,
		&feature.Version,
		&feature.TopicKey,
		&feature.NormalizedHash,
		&feature.CreatedAt,
		&feature.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("no se pudo obtener feature: %w", err)
	}

	return &feature, nil
}

func (s *Store) SearchFeatures(ctx context.Context, query string, projectSlug string) ([]FeatureSearchResult, error) {
	base := `SELECT f.id, f.projectSlug, f.slug, f.title, f.type, f.status, f.version, f.updatedAt
		FROM featuresFts
		JOIN features f ON f.id = featuresFts.rowid
		WHERE featuresFts MATCH ?`
	args := []any{query}

	if strings.TrimSpace(projectSlug) != "" {
		base += ` AND f.projectSlug = ?`
		args = append(args, projectSlug)
	}

	base += ` ORDER BY bm25(featuresFts), f.updatedAt DESC LIMIT 100`

	rows, err := s.database.QueryContext(ctx, base, args...)
	if err != nil {
		return nil, fmt.Errorf("no se pudo ejecutar busqueda FTS: %w", err)
	}
	defer rows.Close()

	results := make([]FeatureSearchResult, 0)
	for rows.Next() {
		var item FeatureSearchResult
		if err := rows.Scan(
			&item.ID,
			&item.ProjectSlug,
			&item.Slug,
			&item.Title,
			&item.Type,
			&item.Status,
			&item.Version,
			&item.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("no se pudo leer resultado FTS: %w", err)
		}
		results = append(results, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterando resultados FTS: %w", err)
	}

	return results, nil
}

func (s *Store) CatalogFeatures(ctx context.Context, projectSlug string, status string, featureType string) ([]FeatureSearchResult, error) {
	query := `SELECT id, projectSlug, slug, title, type, status, version, updatedAt
		FROM features
		WHERE projectSlug = ?`
	args := []any{projectSlug}

	if strings.TrimSpace(status) != "" {
		query += ` AND status = ?`
		args = append(args, status)
	}

	if strings.TrimSpace(featureType) != "" {
		query += ` AND type = ?`
		args = append(args, featureType)
	}

	query += ` ORDER BY updatedAt DESC`

	rows, err := s.database.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("no se pudo consultar catalogo de features: %w", err)
	}
	defer rows.Close()

	results := make([]FeatureSearchResult, 0)
	for rows.Next() {
		var item FeatureSearchResult
		if err := rows.Scan(
			&item.ID,
			&item.ProjectSlug,
			&item.Slug,
			&item.Title,
			&item.Type,
			&item.Status,
			&item.Version,
			&item.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("no se pudo leer feature del catalogo: %w", err)
		}
		results = append(results, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterando catalogo de features: %w", err)
	}

	return results, nil
}

func (s *Store) FeatureVersions(ctx context.Context, slug string, projectSlug string) ([]FeatureVersion, error) {
	feature, err := s.GetFeature(ctx, slug, projectSlug)
	if err != nil {
		return nil, err
	}
	if feature == nil {
		return []FeatureVersion{}, nil
	}

	rows, err := s.database.QueryContext(
		ctx,
		`SELECT id, featureId, version, content, COALESCE(changelog, ''), createdAt
		 FROM featureVersions
		 WHERE featureId = ?
		 ORDER BY version DESC`,
		feature.ID,
	)
	if err != nil {
		return nil, fmt.Errorf("no se pudieron consultar versiones historicas: %w", err)
	}
	defer rows.Close()

	versions := make([]FeatureVersion, 0)

	current := FeatureVersion{
		FeatureID: feature.ID,
		Version:   feature.Version,
		Content:   feature.Content,
		CreatedAt: feature.UpdatedAt,
	}
	versions = append(versions, current)

	for rows.Next() {
		var item FeatureVersion
		if err := rows.Scan(
			&item.ID,
			&item.FeatureID,
			&item.Version,
			&item.Content,
			&item.Changelog,
			&item.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("no se pudo leer version historica: %w", err)
		}
		versions = append(versions, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterando versiones historicas: %w", err)
	}

	return versions, nil
}

func (s *Store) GetFeatureVersion(ctx context.Context, featureID int64, version int64) (*FeatureVersion, error) {
	var currentVersion int64
	var currentContent string
	var currentUpdatedAt string

	err := s.database.QueryRowContext(
		ctx,
		`SELECT version, content, updatedAt FROM features WHERE id = ?`,
		featureID,
	).Scan(&currentVersion, &currentContent, &currentUpdatedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("no se pudo obtener feature actual: %w", err)
	}

	if version == currentVersion {
		return &FeatureVersion{
			FeatureID: featureID,
			Version:   currentVersion,
			Content:   currentContent,
			CreatedAt: currentUpdatedAt,
		}, nil
	}

	var item FeatureVersion
	err = s.database.QueryRowContext(
		ctx,
		`SELECT id, featureId, version, content, COALESCE(changelog, ''), createdAt
		 FROM featureVersions
		 WHERE featureId = ? AND version = ?`,
		featureID,
		version,
	).Scan(
		&item.ID,
		&item.FeatureID,
		&item.Version,
		&item.Content,
		&item.Changelog,
		&item.CreatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("no se pudo obtener version historica: %w", err)
	}

	return &item, nil
}

func queryFeatureByID(ctx context.Context, tx *sql.Tx, featureID int64) (*Feature, error) {
	var feature Feature
	err := tx.QueryRowContext(
		ctx,
		`SELECT id, projectSlug, slug, title, type, status, content, version, COALESCE(topicKey, ''), COALESCE(normalizedHash, ''), createdAt, updatedAt
		 FROM features
		 WHERE id = ?`,
		featureID,
	).Scan(
		&feature.ID,
		&feature.ProjectSlug,
		&feature.Slug,
		&feature.Title,
		&feature.Type,
		&feature.Status,
		&feature.Content,
		&feature.Version,
		&feature.TopicKey,
		&feature.NormalizedHash,
		&feature.CreatedAt,
		&feature.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("no se pudo leer feature guardada: %w", err)
	}

	return &feature, nil
}

func normalizeHash(content string) string {
	hash := sha256.Sum256([]byte(strings.TrimSpace(content)))
	return hex.EncodeToString(hash[:])
}

func nullString(value string) any {
	trimmed := strings.TrimSpace(value)
	if trimmed == "" {
		return nil
	}

	return trimmed
}
