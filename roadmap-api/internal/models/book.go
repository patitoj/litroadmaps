package models

type Recommendation struct {
	RecommendedBook  string `json:"recommended_book"`
	AuthorName       string `json:"author_name"`
	ConnectionReason string `json:"connection_reason"`
}

type SearchResult struct {
	ID         int    `json:"id"`
	Title      string `json:"title"`
	AuthorName string `json:"author_name"`
}
