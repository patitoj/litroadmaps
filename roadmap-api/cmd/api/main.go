package main

import (
	"context" // NUEVO: Para manejar tiempos máximos en el apagado
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal" // NUEVO: Para escuchar señales del sistema operativo
	"strconv"
	"syscall" // NUEVO: Para detectar cuando la nube reinicia el servidor
	"time"

	"roadmap-api/internal/handler"
	"roadmap-api/internal/middleware"
	"roadmap-api/internal/repository"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	// 1. Cargar las variables de entorno
	err := godotenv.Load()
	if err != nil {
		log.Println("Advertencia: No se pudo cargar el archivo .env, intentando usar variables del sistema...")
	}

	// 2. Leer las variables
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	apiPort := os.Getenv("API_PORT")
	dbMaxOpen := os.Getenv("DB_MAX_OPEN_CONNS")

	if apiPort == "" {
		apiPort = "8080"
	}

	// 3. Conectar a PostgreSQL
	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName,
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// 4. Configurar Connection Pooling
	maxOpenConns := 25
	if dbMaxOpen != "" {
		if val, err := strconv.Atoi(dbMaxOpen); err == nil {
			maxOpenConns = val
		}
	}
	db.SetMaxOpenConns(maxOpenConns)
	db.SetMaxIdleConns(maxOpenConns)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err = db.Ping(); err != nil {
		log.Fatal("Error conectando a BD: ", err)
	}
	fmt.Printf("Conectado a PostgreSQL con pool de %d conexiones...\n", maxOpenConns)

	// 5. Inicialización de capas
	bookRepo := &repository.BookRepository{DB: db}
	bookHandler := &handler.BookHandler{Repo: bookRepo}

	// 6. Enrutador explícito (Mejor práctica en lugar del global)
	mux := http.NewServeMux()
	mux.HandleFunc("/api/roadmap", middleware.EnableCORS(bookHandler.GetRoadmap))
	mux.HandleFunc("/api/search", middleware.EnableCORS(bookHandler.SearchBooks))
	mux.HandleFunc("/api/search/authors", middleware.EnableCORS(bookHandler.SearchAuthors))
	mux.HandleFunc("/api/suggestions/books", middleware.EnableCORS(bookHandler.GetSuggestedBooks))
	mux.HandleFunc("/api/suggestions/authors", middleware.EnableCORS(bookHandler.GetSuggestedAuthors))
	mux.HandleFunc("/api/author-roadmap", middleware.EnableCORS(bookHandler.GetAuthorRoadmap))

	// 7. Configuración del Servidor HTTP con Timeouts (Seguridad contra ataques)
	srv := &http.Server{
		Addr:         ":" + apiPort,
		Handler:      mux,
		ReadTimeout:  10 * time.Second,  // Tiempo máx para leer la petición del usuario
		WriteTimeout: 10 * time.Second,  // Tiempo máx para enviarle la respuesta
		IdleTimeout:  120 * time.Second, // Tiempo máx de espera entre conexiones activas
	}

	// 8. Iniciar el servidor en una Goroutine (Segundo plano)
	go func() {
		fmt.Printf("Servidor corriendo en http://localhost:%s\n", apiPort)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Error fatal en el servidor: %v\n", err)
		}
	}()

	// 9. Graceful Shutdown (Apagado Elegante)
	// Creamos un canal para escuchar las señales de apagado
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	// El código se pausa acá hasta que reciba una señal de apagado (ej: presionar Ctrl+C en la terminal)
	<-quit
	fmt.Println("\nSeñal de apagado detectada. Iniciando Graceful Shutdown...")

	// Le damos 10 segundos máximo al servidor para terminar de responder peticiones en curso
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("El servidor fue forzado a apagarse: ", err)
	}

	fmt.Println("Servidor apagado correctamente. Base de datos desconectada. ¡Adiós!")
}
