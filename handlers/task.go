package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/joacsta/todo-api/store"
)

type TaskHandler struct {
	store *store.Taskstore
}

func NewTaskHandler(s *store.Taskstore) *TaskHandler {
	return &TaskHandler{store: s}
}

func (h *TaskHandler) Register(mux *http.ServeMux) {
	mux.HandleFunc("GET /tasks", h.list)
	mux.HandleFunc("GET /tasks/{id}", h.get)
	mux.HandleFunc("POST /tasks", h.create)
	mux.HandleFunc("PUT /tasks/{id}", h.update)
	mux.HandleFunc("DELETE /tasks/{id}", h.delete)
}

func (h *TaskHandler) list(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, h.store.List())
}

func (h *TaskHandler) get(w http.ResponseWriter, r *http.Request) {
	id, err := parseID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "id invalido")
		return
	}
	t, err := h.store.Get(id)
	if err != nil {
		writeError(w, http.StatusNotFound, "tarefa nao encontrada")
		return
	}
	writeJSON(w, http.StatusOK, t)
}

type createTaskRequest struct {
	Title string `json:"title"`
}

func (h *TaskHandler) create(w http.ResponseWriter, r *http.Request) {
	var req createTaskRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "json invalido, tente novamente")
		return
	}
	if req.Title == "" {
		writeError(w, http.StatusBadRequest, "titulo necessario para continuar")
		return
	}
	t := h.store.Create(req.Title)
	writeJSON(w, http.StatusCreated, t)
}

type updateTaskRequest struct {
	Title string `json:"title"`
	Done  bool   `json:"done"`
}

func (h *TaskHandler) update(w http.ResponseWriter, r *http.Request) {
	id, err := parseID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "id invalido")
		return
	}
	var req updateTaskRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "json invalido, tente novamente")
		return
	}
	t, err := h.store.Update(id, req.Title, req.Done)
	if errors.Is(err, store.ErrorNotFound) {
		writeError(w, http.StatusNotFound, "tarefa nao encontrada")
		return
	}
	writeJSON(w, http.StatusOK, t)
}

func (h *TaskHandler) delete(w http.ResponseWriter, r *http.Request) {
	id, err := parseID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "id invalido")
		return
	}
	if err := h.store.Delete(id); errors.Is(err, store.ErrorNotFound) {
		writeError(w, http.StatusNotFound, "tarefa nao encontrada")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func parseID(r *http.Request) (int, error) {
	return strconv.Atoi(r.PathValue("id"))
}

func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
