package store

import (
	"errors"
	"sync"
	"time"

	"github.com/joacsta/todo-api/models"
)

var ErrorNotFound = errors.New("tarefa nao encontrada")

type Taskstore struct {
	mu     sync.RWMutex
	tasks  map[int]models.Task
	nextID int
}

func NewTaskStore() *Taskstore { // apontando para o ponteiro
	return &Taskstore{
		tasks:  make(map[int]models.Task), // constructor
		nextID: 1,
	}
}

func (s *Taskstore) List() []models.Task {
	s.mu.RLock()
	defer s.mu.RUnlock()

	result := make([]models.Task, 0, len(s.tasks))
	for _, t := range s.tasks {
		result = append(result, t)
	}
	return result
}

func (s *Taskstore) Get(id int) (models.Task, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	// permite que mts clientes consultem tarefas ao msm
	// tempo sem bloquear uns aos outros
	t, ok := s.tasks[id]
	if !ok {
		return models.Task{}, ErrorNotFound
	}
	return t, nil
}

func (s *Taskstore) Create(title string) models.Task {
	s.mu.Lock()
	// Rlock era apenas pra leitura, nesse caso ha mutacao de estado
	defer s.mu.Unlock()

	t := models.Task{
		ID:        s.nextID,
		Title:     title,
		Done:      false,
		CreatedAt: time.Now(),
	}
	s.tasks[t.ID] = t
	s.nextID++
	return t
}

func (s *Taskstore) Update(id int, title string, done bool) (models.Task, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	t, ok := s.tasks[id]
	if !ok {
		return models.Task{}, ErrorNotFound
	}
	t.Title = title
	t.Done = done
	s.tasks[id] = t
	return t, nil
}

func (s *Taskstore) Delete(id int) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, ok := s.tasks[id]; !ok {
		return ErrorNotFound
	}
	delete(s.tasks, id)
	return nil
}
