package repository

import (
	"database/sql"
	"roadmap-api/internal/models"
)

// BookRepository encapsula la conexión a la base de datos
type BookRepository struct {
	DB *sql.DB
}

// GetRoadmap ejecuta el SQL del roadmap
func (r *BookRepository) GetRoadmap(bookID string) ([]models.Recommendation, error) {
	query := `
		SELECT b.title, a.name, bc.reason
		FROM book_connections bc
		JOIN books b ON bc.target_book_id = b.id
		JOIN authors a ON b.author_id = a.id
		WHERE bc.source_book_id = $1;
	`
	rows, err := r.DB.Query(query, bookID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var roadmap []models.Recommendation
	for rows.Next() {
		var rec models.Recommendation
		if err := rows.Scan(&rec.RecommendedBook, &rec.AuthorName, &rec.ConnectionReason); err != nil {
			return nil, err
		}
		roadmap = append(roadmap, rec)
	}
	// Si la consulta no trajo resultados, inicializamos una lista vacía
	// para que no devuelva "null" y rompa el frontend.
	if roadmap == nil {
		roadmap = []models.Recommendation{}
	}

	return roadmap, nil
}

// SearchBooks ejecuta el SQL de búsqueda
func (r *BookRepository) SearchBooks(searchTerm string) ([]models.SearchResult, error) {
	query := `
		SELECT b.id, b.title, a.name
		FROM books b
		JOIN authors a ON b.author_id = a.id
		WHERE b.title ILIKE $1 OR a.name ILIKE $1
		LIMIT 10;
	`
	rows, err := r.DB.Query(query, "%"+searchTerm+"%")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.SearchResult
	for rows.Next() {
		var res models.SearchResult
		if err := rows.Scan(&res.ID, &res.Title, &res.AuthorName); err != nil {
			return nil, err
		}
		results = append(results, res)
	}

	if results == nil {
		results = []models.SearchResult{}
	}
	return results, nil
}
