package handler

import (
	"encoding/json"
	"net/http"
	"roadmap-api/internal/repository"
)

// BookHandler agrupa las funciones HTTP y tiene acceso al repositorio
type BookHandler struct {
	Repo *repository.BookRepository
}

func (h *BookHandler) GetRoadmap(w http.ResponseWriter, r *http.Request) {
	bookID := r.URL.Query().Get("book_id")
	if bookID == "" {
		http.Error(w, "Falta el book_id", http.StatusBadRequest)
		return
	}

	roadmap, err := h.Repo.GetRoadmap(bookID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(roadmap)
}

func (h *BookHandler) SearchBooks(w http.ResponseWriter, r *http.Request) {
	searchTerm := r.URL.Query().Get("q")
	if searchTerm == "" {
		http.Error(w, "Falta el término de búsqueda", http.StatusBadRequest)
		return
	}

	results, err := h.Repo.SearchBooks(searchTerm)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}
