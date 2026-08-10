package models

// 1. Roadmap por Libro
type Recommendation struct {
	RecommendedBook  string `json:"recommended_book"`
	AuthorName       string `json:"author_name"`
	ConnectionReason string `json:"connection_reason"`
	ConnectionType   string `json:"connection_type"`
	Order            int    `json:"recommendation_order"`
}

// 2. Resultados del Buscador
type SearchResult struct {
	ID         int    `json:"id"`
	Title      string `json:"title"`
	AuthorID   int    `json:"author_id"` // Nuevo: necesario para el roadmap de autor
	AuthorName string `json:"author_name"`
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
