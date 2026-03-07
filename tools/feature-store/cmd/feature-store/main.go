package main

import (
	"fmt"
	"os"

	"github.com/agustinalbonico/feature-store/internal/db"
	mcpserver "github.com/agustinalbonico/feature-store/internal/mcp"
	"github.com/agustinalbonico/feature-store/internal/store"
)

func main() {
	if err := run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %s\n", err.Error())
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) < 2 {
		return fmt.Errorf("uso: feature-store <mcp|migrate|tui>")
	}

	switch args[1] {
	case "migrate":
		path, err := db.MigrateDefault()
		if err != nil {
			return err
		}

		fmt.Printf("Migracion aplicada en: %s\n", path)
		return nil

	case "mcp":
		database, path, err := db.OpenAndMigrateDefault()
		if err != nil {
			return err
		}
		defer database.Close()

		fmt.Fprintf(os.Stderr, "MCP feature-store inicializado con DB en: %s\n", path)

		storeInstance := store.New(database)
		return mcpserver.RunStdio(storeInstance)

	case "tui":
		fmt.Println("TUI not implemented yet")
		return nil

	default:
		return fmt.Errorf("subcomando no soportado: %s", args[1])
	}
}
