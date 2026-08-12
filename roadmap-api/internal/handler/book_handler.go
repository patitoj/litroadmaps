package handler

import (
	"encoding/json"
	"net/http"
	"regexp" // NUEVO: Importación para el filtro Regex
	"roadmap-api/internal/repository"
)

type BookHandler struct {
	Repo *repository.BookRepository
}

// NUEVO: Función para validar la entrada (máx 50 caracteres y sin símbolos raros)
func validarEntrada(input string) bool {
	if len(input) > 50 {
		return false
	}
	re := regexp.MustCompile(`^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]+$`)
	return re.MatchString(input)
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

	// NUEVO: Filtro de seguridad
	if !validarEntrada(searchTerm) {
		http.Error(w, "El término de búsqueda contiene caracteres inválidos o es muy largo", http.StatusBadRequest)
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

// NUEVO: Handler para el Roadmap de Autor
func (h *BookHandler) GetAuthorRoadmap(w http.ResponseWriter, r *http.Request) {
	authorID := r.URL.Query().Get("author_id")
	if authorID == "" {
		http.Error(w, "Falta el author_id", http.StatusBadRequest)
		return
	}

	steps, err := h.Repo.GetAuthorRoadmap(authorID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(steps)
}

func (h *BookHandler) SearchAuthors(w http.ResponseWriter, r *http.Request) {
	searchTerm := r.URL.Query().Get("q")
	if searchTerm == "" {
		http.Error(w, "Falta el término de búsqueda", http.StatusBadRequest)
		return
	}

	// NUEVO: Filtro de seguridad
	if !validarEntrada(searchTerm) {
		http.Error(w, "El término de búsqueda contiene caracteres inválidos o es muy largo", http.StatusBadRequest)
		return
	}

	results, err := h.Repo.SearchAuthors(searchTerm)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

func (h *BookHandler) GetSuggestedBooks(w http.ResponseWriter, r *http.Request) {
	results, err := h.Repo.GetSuggestedBooks()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

func (h *BookHandler) GetSuggestedAuthors(w http.ResponseWriter, r *http.Request) {
	results, err := h.Repo.GetSuggestedAuthors()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}
