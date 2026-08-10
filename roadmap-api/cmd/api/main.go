package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"

	"roadmap-api/internal/handler"
	"roadmap-api/internal/middleware"
	"roadmap-api/internal/repository"

	_ "github.com/lib/pq"
)

func main() {
	// IMPORTANTE: Poné tu contraseña real de PostgreSQL
	connStr := "user=postgres password=patito dbname=roadmap_db sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	if err = db.Ping(); err != nil {
		log.Fatal("Error conectando a BD: ", err)
	}
	fmt.Println("Conectado a PostgreSQL...")

	bookRepo := &repository.BookRepository{DB: db}
	bookHandler := &handler.BookHandler{Repo: bookRepo}

	// Rutas
	http.HandleFunc("/api/roadmap", middleware.EnableCORS(bookHandler.GetRoadmap))
	http.HandleFunc("/api/search", middleware.EnableCORS(bookHandler.SearchBooks))
	http.HandleFunc("/api/search/authors", middleware.EnableCORS(bookHandler.SearchAuthors))
	http.HandleFunc("/api/suggestions/books", middleware.EnableCORS(bookHandler.GetSuggestedBooks))
	http.HandleFunc("/api/suggestions/authors", middleware.EnableCORS(bookHandler.GetSuggestedAuthors))

	// NUEVA RUTA: Roadmap por Autor
	http.HandleFunc("/api/author-roadmap", middleware.EnableCORS(bookHandler.GetAuthorRoadmap))

	fmt.Println("Servidor corriendo en http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
