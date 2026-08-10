package repository

import (
	"database/sql"
	"fmt"
	"roadmap-api/internal/models"
)

type BookRepository struct {
	DB *sql.DB
}

func (r *BookRepository) GetRoadmap(bookID string) ([]models.Recommendation, error) {
	query := `
		SELECT b.title, a.name, 
		       COALESCE(bc.reason, 'Sin justificación'), 
		       COALESCE(bc.connection_type, 'relacionado'), 
		       COALESCE(bc.recommendation_order, 1),
		       COALESCE(b.publication_year, 0),
		       COALESCE(b.page_count, 0)
		FROM book_connections bc
		JOIN books b ON bc.target_book_id = b.id
		JOIN authors a ON b.author_id = a.id
		WHERE bc.source_book_id = $1
		ORDER BY bc.recommendation_order ASC;
	`
	rows, err := r.DB.Query(query, bookID)
	if err != nil {
		fmt.Println("❌ Error de SQL en GetRoadmap:", err)
		return nil, err
	}
	defer rows.Close()

	var roadmap []models.Recommendation
	for rows.Next() {
		var rec models.Recommendation
		// Agregamos PublicationYear y PageCount al Scan
		if err := rows.Scan(&rec.RecommendedBook, &rec.AuthorName, &rec.ConnectionReason, &rec.ConnectionType, &rec.Order, &rec.PublicationYear, &rec.PageCount); err != nil {
			fmt.Println("❌ Error al escanear la recomendación:", err)
			return nil, err
		}
		roadmap = append(roadmap, rec)
	}

	if roadmap == nil {
		roadmap = []models.Recommendation{}
	}
	return roadmap, nil
}

func (r *BookRepository) SearchBooks(searchTerm string) ([]models.SearchResult, error) {
	query := `
		SELECT b.id, b.title, a.id, a.name, 
		       COALESCE(b.publication_year, 0), -- Si es NULL, devuelve 0
		       COALESCE(b.page_count, 0)        -- Si es NULL, devuelve 0
		FROM books b
		JOIN authors a ON b.author_id = a.id
		WHERE unaccent(b.title) ILIKE unaccent($1) OR unaccent(a.name) ILIKE unaccent($1)
		LIMIT 10;
	`
	rows, err := r.DB.Query(query, "%"+searchTerm+"%")
	if err != nil {
		fmt.Println("❌ Error en SearchBooks:", err)
		return nil, err
	}
	defer rows.Close()

	var results []models.SearchResult
	for rows.Next() {
		var res models.SearchResult
		if err := rows.Scan(&res.ID, &res.Title, &res.AuthorID, &res.AuthorName, &res.PublicationYear, &res.PageCount); err != nil {
			fmt.Println("❌ Error al leer datos del libro:", err)
			return nil, err
		}
		results = append(results, res)
	}

	if results == nil {
		results = []models.SearchResult{}
	}
	return results, nil
}

func (r *BookRepository) GetAuthorRoadmap(authorID string) ([]models.AuthorRoadmapStep, error) {
	query := `
		SELECT aro.step_number, b.title, aro.justification,
		       COALESCE(b.publication_year, 0),
		       COALESCE(b.page_count, 0)
		FROM author_reading_orders aro
		JOIN books b ON aro.book_id = b.id
		WHERE aro.author_id = $1
		ORDER BY aro.step_number ASC;
	`
	rows, err := r.DB.Query(query, authorID)
	if err != nil {
		fmt.Println("❌ Error de SQL en GetAuthorRoadmap:", err)
		return nil, err
	}
	defer rows.Close()

	var steps []models.AuthorRoadmapStep
	for rows.Next() {
		var step models.AuthorRoadmapStep
		// Agregamos PublicationYear y PageCount al Scan
		if err := rows.Scan(&step.StepNumber, &step.BookTitle, &step.Justification, &step.PublicationYear, &step.PageCount); err != nil {
			fmt.Println("❌ Error al escanear paso del autor:", err)
			return nil, err
		}
		steps = append(steps, step)
	}

	if steps == nil {
		steps = []models.AuthorRoadmapStep{}
	}
	return steps, nil
}

func (r *BookRepository) SearchAuthors(searchTerm string) ([]models.AuthorSearchResult, error) {
	query := `
		SELECT id, name
		FROM authors
		WHERE unaccent(name) ILIKE unaccent($1)
		LIMIT 10;
	`
	rows, err := r.DB.Query(query, "%"+searchTerm+"%")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.AuthorSearchResult
	for rows.Next() {
		var res models.AuthorSearchResult
		if err := rows.Scan(&res.ID, &res.Name); err != nil {
			return nil, err
		}
		results = append(results, res)
	}

	if results == nil {
		results = []models.AuthorSearchResult{}
	}
	return results, nil
}

func (r *BookRepository) GetSuggestedBooks() ([]models.SearchResult, error) {
	query := `
        SELECT b.id, b.title, a.id, a.name, 
               COALESCE(b.publication_year, 0), 
               COALESCE(b.page_count, 0)
        FROM books b
        JOIN authors a ON b.author_id = a.id
        ORDER BY RANDOM()
        LIMIT 4;
    `
	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.SearchResult
	for rows.Next() {
		var res models.SearchResult
		if err := rows.Scan(&res.ID, &res.Title, &res.AuthorID, &res.AuthorName, &res.PublicationYear, &res.PageCount); err != nil {
			return nil, err
		}
		results = append(results, res)
	}
	return results, nil
}

// Trae 4 autores aleatorios para sugerencias
func (r *BookRepository) GetSuggestedAuthors() ([]models.AuthorSearchResult, error) {
	query := `
        SELECT id, name
        FROM authors
        ORDER BY RANDOM()
        LIMIT 4;
    `
	rows, err := r.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.AuthorSearchResult
	for rows.Next() {
		var res models.AuthorSearchResult
		if err := rows.Scan(&res.ID, &res.Name); err != nil {
			return nil, err
		}
		results = append(results, res)
	}
	return results, nil
}
