package db

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

	_ "modernc.org/sqlite"
)

const (
	dataDirName = ".feature-store"
	dbFileName  = "features.db"
)

func DefaultDatabasePath() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("no se pudo resolver el home del usuario: %w", err)
	}

	return filepath.Join(homeDir, dataDirName, dbFileName), nil
}

func ensureDataDir() error {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("no se pudo resolver el home del usuario: %w", err)
	}

	dataDir := filepath.Join(homeDir, dataDirName)
	if err := os.MkdirAll(dataDir, 0o755); err != nil {
		return fmt.Errorf("no se pudo crear el directorio de datos: %w", err)
	}

	return nil
}

func Open(path string) (*sql.DB, error) {
	database, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, fmt.Errorf("no se pudo abrir la base de datos: %w", err)
	}

	if _, err := database.Exec(queryEnableForeignKeys); err != nil {
		_ = database.Close()
		return nil, fmt.Errorf("no se pudo habilitar foreign_keys: %w", err)
	}

	return database, nil
}

func ApplyMigrations(database *sql.DB) error {
	if _, err := database.Exec(schemaSQL); err != nil {
		return fmt.Errorf("fallo al aplicar schema: %w", err)
	}

	return nil
}

func MigrateDefault() (string, error) {
	if err := ensureDataDir(); err != nil {
		return "", err
	}

	path, err := DefaultDatabasePath()
	if err != nil {
		return "", err
	}

	database, err := Open(path)
	if err != nil {
		return "", err
	}
	defer database.Close()

	if err := ApplyMigrations(database); err != nil {
		return "", err
	}

	return path, nil
}

func OpenAndMigrateDefault() (*sql.DB, string, error) {
	if err := ensureDataDir(); err != nil {
		return nil, "", err
	}

	path, err := DefaultDatabasePath()
	if err != nil {
		return nil, "", err
	}

	database, err := Open(path)
	if err != nil {
		return nil, "", err
	}

	if err := ApplyMigrations(database); err != nil {
		_ = database.Close()
		return nil, "", err
	}

	return database, path, nil
}
