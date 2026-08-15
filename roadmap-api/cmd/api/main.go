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

// Función para habilitar CORS (Solo la declarás si no la usás en middleware,
// pero en tus rutas veo que ya estás usando middleware.EnableCORS.
// Te la dejo por si la necesitás para otra cosa).
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

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
	dbMaxOpen := os.Getenv("DB_MAX_OPEN_CONNS")

	// ---> PARCHE PARA RENDER <---
	// Render SIEMPRE inyecta la variable "PORT"
	apiPort := os.Getenv("PORT")
	if apiPort == "" {
		// Si no hay "PORT", probamos con tu variable local "API_PORT"
		apiPort = os.Getenv("API_PORT")
		if apiPort == "" {
			// Si tampoco existe, usamos el 8080 por defecto
			apiPort = "8080"
		}
	}

	// 3. Conectar a PostgreSQL
	// Supabase usa pgbouncer en el puerto 6543, no uses sslmode=disable si querés seguridad real,
	// pero para arrancar y probar, disable está perfecto.
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

	// 6. Enrutador explícito
	mux := http.NewServeMux()
	mux.HandleFunc("/api/roadmap", middleware.EnableCORS(bookHandler.GetRoadmap))
	mux.HandleFunc("/api/search", middleware.EnableCORS(bookHandler.SearchBooks))
	mux.HandleFunc("/api/search/authors", middleware.EnableCORS(bookHandler.SearchAuthors))
	mux.HandleFunc("/api/suggestions/books", middleware.EnableCORS(bookHandler.GetSuggestedBooks))
	mux.HandleFunc("/api/suggestions/authors", middleware.EnableCORS(bookHandler.GetSuggestedAuthors))
	mux.HandleFunc("/api/author-roadmap", middleware.EnableCORS(bookHandler.GetAuthorRoadmap))

	// 7. Configuración del Servidor HTTP con Timeouts
	srv := &http.Server{
		Addr:         ":" + apiPort,
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// 8. Iniciar el servidor en una Goroutine
	go func() {
		fmt.Printf("Servidor corriendo en el puerto %s\n", apiPort)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Error fatal en el servidor: %v\n", err)
		}
	}()

	// 9. Graceful Shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	<-quit
	fmt.Println("\nSeñal de apagado detectada. Iniciando Graceful Shutdown...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("El servidor fue forzado a apagarse: ", err)
	}

	fmt.Println("Servidor apagado correctamente. Base de datos desconectada. ¡Adiós!")
}
