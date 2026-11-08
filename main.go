package main

import (
	"log"
	"net/http"
	"time"

	"github.com/joacsta/todo-api/handlers"
	"github.com/joacsta/todo-api/store"
)

func main() {
	taskStore := store.NewTaskStore()
	taskHandler := handlers.NewTaskHandler(taskStore)

	mux := http.NewServeMux()
	taskHandler.Register(mux)

	handler := loggingMiddleware(mux)
	srv := &http.Server{
		Addr:         ":8080",
		Handler:      handler,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}
	log.Println("servidor rodando em localhost:8080")
	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}
