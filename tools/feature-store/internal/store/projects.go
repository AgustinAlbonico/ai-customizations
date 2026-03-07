package store

import (
	"context"
	"database/sql"
	"fmt"
)

type Project struct {
	ID        int64  `json:"id"`
	Slug      string `json:"slug"`
	Name      string `json:"name"`
	Path      string `json:"path,omitempty"`
	CreatedAt string `json:"createdAt"`
}

type ProjectWithCount struct {
	Project
	FeatureCount int64 `json:"featureCount"`
}

func (s *Store) RegisterProject(ctx context.Context, slug string, name string, path string) (*Project, error) {
	if _, err := s.database.ExecContext(
		ctx,
		`INSERT INTO projects (slug, name, path)
		 VALUES (?, ?, ?)
		 ON CONFLICT(slug) DO UPDATE SET
		   name = excluded.name,
		   path = excluded.path`,
		slug,
		name,
		nullString(path),
	); err != nil {
		return nil, fmt.Errorf("no se pudo registrar el proyecto: %w", err)
	}

	var project Project
	var dbPath sql.NullString
	err := s.database.QueryRowContext(
		ctx,
		`SELECT id, slug, name, path, createdAt FROM projects WHERE slug = ?`,
		slug,
	).Scan(&project.ID, &project.Slug, &project.Name, &dbPath, &project.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("no se pudo leer el proyecto registrado: %w", err)
	}

	if dbPath.Valid {
		project.Path = dbPath.String
	}

	return &project, nil
}

func (s *Store) ListProjects(ctx context.Context) ([]ProjectWithCount, error) {
	rows, err := s.database.QueryContext(
		ctx,
		`SELECT p.id, p.slug, p.name, p.path, p.createdAt, COUNT(f.id) AS featureCount
		 FROM projects p
		 LEFT JOIN features f ON f.projectSlug = p.slug
		 GROUP BY p.id, p.slug, p.name, p.path, p.createdAt
		 ORDER BY p.createdAt DESC`,
	)
	if err != nil {
		return nil, fmt.Errorf("no se pudo listar proyectos: %w", err)
	}
	defer rows.Close()

	projects := make([]ProjectWithCount, 0)
	for rows.Next() {
		var item ProjectWithCount
		var dbPath sql.NullString
		if err := rows.Scan(
			&item.ID,
			&item.Slug,
			&item.Name,
			&dbPath,
			&item.CreatedAt,
			&item.FeatureCount,
		); err != nil {
			return nil, fmt.Errorf("no se pudo leer proyecto: %w", err)
		}

		if dbPath.Valid {
			item.Path = dbPath.String
		}

		projects = append(projects, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterando proyectos: %w", err)
	}

	return projects, nil
}
