package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

type AuthorData struct {
	Name      string `json:"name"`
	Biography string `json:"biography"`
	Roadmap   []Step `json:"roadmap"`
}

type Step struct {
	StepNumber    int      `json:"step_number"`
	Justification string   `json:"justification"`
	Book          BookData `json:"book"`
}

type BookData struct {
	Title           string       `json:"title"`
	PublicationYear int          `json:"publication_year"`
	PageCount       int          `json:"page_count"`
	Connections     []Connection `json:"connections,omitempty"` // NUEVO: Conexiones a otros libros
}

type Connection struct {
	TargetBookTitle     string `json:"target_book_title"`
	TargetAuthorName    string `json:"target_author_name"`
	Reason              string `json:"reason"`
	ConnectionType      string `json:"connection_type"`
	RecommendationOrder int    `json:"recommendation_order"`
}

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Println("Advertencia: No se encontró el .env")
	}

	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"), os.Getenv("DB_PORT"), os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"), os.Getenv("DB_NAME"),
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error al abrir BD: ", err)
	}
	defer db.Close()

	dataPath := "./data"
	files, err := os.ReadDir(dataPath)
	if err != nil {
		log.Fatal("Error leyendo carpeta data/: ", err)
	}

	// PASO 1: Crear Autores, Libros y Roadmaps de Autores
	fmt.Println("--- INICIANDO FASE 1: AUTORES Y LIBROS ---")
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".json" {
			procesarFase1(db, filepath.Join(dataPath, file.Name()))
		}
	}

	// PASO 2: Crear Conexiones entre Libros (Requiere que los libros ya existan)
	fmt.Println("\n--- INICIANDO FASE 2: CONEXIONES ENTRE LIBROS ---")
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".json" {
			procesarFase2(db, filepath.Join(dataPath, file.Name()))
		}
	}

	fmt.Println("\n¡Siembra completada con éxito!")
}

// Fase 1: Igual que antes, crea autores y libros
func procesarFase1(db *sql.DB, filePath string) {
	bytes, _ := os.ReadFile(filePath)
	var authors []AuthorData
	json.Unmarshal(bytes, &authors)

	for _, data := range authors {
		var authorID int
		db.QueryRow(`SELECT id FROM authors WHERE name = $1`, data.Name).Scan(&authorID)
		if authorID == 0 {
			db.QueryRow(`INSERT INTO authors (name, biography) VALUES ($1, $2) RETURNING id`, data.Name, data.Biography).Scan(&authorID)
		}

		db.Exec(`DELETE FROM author_reading_orders WHERE author_id = $1`, authorID)

		for _, step := range data.Roadmap {
			var bookID int
			db.QueryRow(`SELECT id FROM books WHERE title = $1 AND author_id = $2`, step.Book.Title, authorID).Scan(&bookID)
			if bookID == 0 {
				db.QueryRow(`INSERT INTO books (author_id, title, publication_year, page_count) VALUES ($1, $2, $3, $4) RETURNING id`,
					authorID, step.Book.Title, step.Book.PublicationYear, step.Book.PageCount).Scan(&bookID)
			}
			db.Exec(`INSERT INTO author_reading_orders (author_id, book_id, step_number, justification) VALUES ($1, $2, $3, $4)`,
				authorID, bookID, step.StepNumber, step.Justification)
		}
	}
}

// Fase 2: Lee las conexiones y las inserta
func procesarFase2(db *sql.DB, filePath string) {
	bytes, _ := os.ReadFile(filePath)
	var authors []AuthorData
	json.Unmarshal(bytes, &authors)

	for _, data := range authors {
		for _, step := range data.Roadmap {
			if len(step.Book.Connections) > 0 {
				var sourceBookID int
				db.QueryRow(`SELECT b.id FROM books b JOIN authors a ON b.author_id = a.id WHERE b.title = $1 AND a.name = $2`, step.Book.Title, data.Name).Scan(&sourceBookID)

				// Limpiar conexiones previas de este libro para evitar duplicados
				db.Exec(`DELETE FROM book_connections WHERE source_book_id = $1`, sourceBookID)

				for _, conn := range step.Book.Connections {
					var targetBookID int
					// Buscar el libro destino
					err := db.QueryRow(`SELECT b.id FROM books b JOIN authors a ON b.author_id = a.id WHERE b.title = $1 AND a.name = $2`, conn.TargetBookTitle, conn.TargetAuthorName).Scan(&targetBookID)

					if err == nil && sourceBookID != 0 && targetBookID != 0 {
						db.Exec(`INSERT INTO book_connections (source_book_id, target_book_id, reason, connection_type, recommendation_order) 
								 VALUES ($1, $2, $3, $4, $5)`,
							sourceBookID, targetBookID, conn.Reason, conn.ConnectionType, conn.RecommendationOrder)
						fmt.Printf("Conexión creada: %s -> %s\n", step.Book.Title, conn.TargetBookTitle)
					}
				}
			}
		}
	}
}
