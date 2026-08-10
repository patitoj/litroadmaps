package models

// 1. Roadmap por Libro
type Recommendation struct {
	RecommendedBook  string `json:"recommended_book"`
	AuthorName       string `json:"author_name"`
	ConnectionReason string `json:"connection_reason"`
	ConnectionType   string `json:"connection_type"`
	Order            int    `json:"recommendation_order"`
}

type SearchResult struct {
	ID              int    `json:"id"`
	Title           string `json:"title"`
	AuthorID        int    `json:"author_id"`
	AuthorName      string `json:"author_name"`
	PublicationYear int    `json:"publication_year"` // NUEVO
	PageCount       int    `json:"page_count"`       // NUEVO
}

// 3. NUEVO: Roadmap por Autor
type AuthorRoadmapStep struct {
	StepNumber    int    `json:"step_number"`
	BookTitle     string `json:"book_title"`
	Justification string `json:"justification"`
}

type AuthorSearchResult struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}
