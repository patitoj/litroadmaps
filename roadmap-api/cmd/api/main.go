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
	// 1. Conexión a la Base de Datos
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

	// 2. Inyección de Dependencias
	bookRepo := &repository.BookRepository{DB: db}
	bookHandler := &handler.BookHandler{Repo: bookRepo}

	// 3. Configuración de Rutas con Middleware
	http.HandleFunc("/api/roadmap", middleware.EnableCORS(bookHandler.GetRoadmap))
	http.HandleFunc("/api/search", middleware.EnableCORS(bookHandler.SearchBooks))

	// 4. Iniciar Servidor
	fmt.Println("Servidor corriendo en http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
