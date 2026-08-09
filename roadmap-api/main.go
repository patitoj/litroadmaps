package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	_ "github.com/lib/pq"
)

// 1. Estructura para el Roadmap
type Recommendation struct {
	RecommendedBook  string `json:"recommended_book"`
	AuthorName       string `json:"author_name"`
	ConnectionReason string `json:"connection_reason"`
}

// 2. Estructura para el Buscador
type SearchResult struct {
	ID         int    `json:"id"`
	Title      string `json:"title"`
	AuthorName string `json:"author_name"`
}

// 3. Middleware para habilitar peticiones Web (CORS)
func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*") // Permite que cualquier web se conecte
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		// Si el navegador web manda una petición de pre-vuelo, le decimos que todo está bien
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next(w, r)
	}
}

func main() {
	// IMPORTANTE: Poné tu contraseña de postgres
	connStr := "user=postgres password=patito dbname=roadmap_db sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// ENDPOINT 1: El Roadmap (Actualizado con CORS)
	http.HandleFunc("/api/roadmap", enableCORS(func(w http.ResponseWriter, r *http.Request) {
		bookID := r.URL.Query().Get("book_id")
		if bookID == "" {
			http.Error(w, "Falta el book_id", http.StatusBadRequest)
			return
		}

		query := `
			SELECT b.title, a.name, bc.reason
			FROM book_connections bc
			JOIN books b ON bc.target_book_id = b.id
			JOIN authors a ON b.author_id = a.id
			WHERE bc.source_book_id = $1;
		`
		rows, err := db.Query(query, bookID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var roadmap []Recommendation
		for rows.Next() {
			var rec Recommendation
			if err := rows.Scan(&rec.RecommendedBook, &rec.AuthorName, &rec.ConnectionReason); err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			roadmap = append(roadmap, rec)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(roadmap)
	}))

	// ENDPOINT 2: El Buscador de Texto (NUEVO)
	http.HandleFunc("/api/search", enableCORS(func(w http.ResponseWriter, r *http.Request) {
		// Obtenemos lo que el usuario escribió (ej: ?q=dorian)
		searchTerm := r.URL.Query().Get("q")
		if searchTerm == "" {
			http.Error(w, "Falta el término de búsqueda", http.StatusBadRequest)
			return
		}

		// Usamos ILIKE para buscar sin importar mayúsculas o minúsculas
		// Los % permiten buscar palabras incompletas (ej: "cien" encuentra "Cien años de soledad")
		query := `
			SELECT b.id, b.title, a.name
			FROM books b
			JOIN authors a ON b.author_id = a.id
			WHERE b.title ILIKE $1 OR a.name ILIKE $1
			LIMIT 10;
		`

		rows, err := db.Query(query, "%"+searchTerm+"%")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var results []SearchResult
		for rows.Next() {
			var res SearchResult
			if err := rows.Scan(&res.ID, &res.Title, &res.AuthorName); err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			results = append(results, res)
		}

		// Si no hay resultados, devolvemos un arreglo vacío en lugar de null
		if results == nil {
			results = []SearchResult{}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(results)
	}))

	fmt.Println("Servidor corriendo en http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
