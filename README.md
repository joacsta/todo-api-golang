# To-do API

API REST para gerenciamento de tarefas desenvolvida em Go, utilizando exclusivamente a biblioteca padrao (net/http) com roteamento nativo e armazenamento em memoria thread-safe com sync.RWMutex.
Com o tempo pretendo adicionar mais funcionalidades ao projeto, como banco de dados (Postgres), validacoes com `go-playground/validator`, interface, testes, configuracoes e container
---

## Pre-requisitos

Para executar a aplicacao e rodar a suite completa de testes de integracao, sao necessarias apenas duas ferramentas instaladas no sistema:

- Go (versao 1.22 ou superior)
- Hurl (utilitario CLI para execucao e assercao de requisicoes HTTP)

---

## Como Executar a Aplicacao

1. Clone o repositorio e acesse a pasta raiz:

   ```bash
   git clone https://github.com/joacsta/todo-api.git
   cd todo-api
   ```

2. Inicie o servidor:

   ```bash
   go run .
   ```

A API iniciara a escuta no endereco `http://localhost:8080`.

---

## Como Executar os Testes

Com o servidor em execucao no primeiro terminal, abra uma nova janela ou aba no mesmo diretorio e execute:

```bash
hurl --test tasks.hurl
```

Para inspecionar detalhadamente todas as requisicoes, cabecalhos e corpos de resposta:

```bash
hurl --verbose tasks.hurl
```

---

## Endpoints

| Metodo | Rota        | Descricao                             | Status de Sucesso |
| :----- | :---------- | :------------------------------------ | :---------------- |
| GET    | /tasks      | Lista todas as tarefas                | 200 OK            |
| GET    | /tasks/{id} | Obtem uma tarefa por ID               | 200 OK            |
| POST   | /tasks      | Cria uma nova tarefa                  | 201 Created       |
| PUT    | /tasks/{id} | Atualiza titulo e status de conclusao | 200 OK            |
| DELETE | /tasks/{id} | Remove uma tarefa por ID              | 204 No Content    |

---

## Exemplos de Requisicao e Resposta

### Criar Tarefa

Requisicao:

```http
POST /tasks HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
  "title": "Estudar Go"
}
```

Resposta:

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": 1,
  "title": "Estudar Go",
  "done": false,
  "created_at": "2026-11-08T15:30:00Z"
}
```

### Buscar Tarefa por ID

Requisicao:

```http
GET /tasks/1 HTTP/1.1
Host: localhost:8080
```

Resposta:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "Estudar Go",
  "done": false,
  "created_at": "2026-11-08T15:30:00Z"
}
```

### Atualizar Tarefa

Requisicao:

```http
PUT /tasks/1 HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
  "title": "Estudar Go e Concorrencia",
  "done": true
}
```

Resposta:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "Estudar Go e Concorrencia",
  "done": true,
  "created_at": "2026-11-08T15:30:00Z"
}
```

### Deletar Tarefa

Requisicao:

```http
DELETE /tasks/1 HTTP/1.1
Host: localhost:8080
```

Resposta:

```http
HTTP/1.1 204 No Content
```

### Resposta de Erro Padrao

Quando ocorre um erro de validacao (ex.: titulo em branco, JSON malformado) ou recurso inexistente:

```json
{
  "error": "tarefa nao encontrada"
}
```

---

## Estrutura do Diretorio

```text
.
├── handlers/
│   └── task.go
├── models/
│   └── task.go
├── store/
│   └── task.go
├── go.mod
├── main.go
├── tasks.hurl
└── README.md
```

- `handlers/`: Implementacao dos adaptadores HTTP, parsing de rotas, validacoes e codificacao JSON.
- `models/`: Definicoes dos esquemas de dados e structs de dominio.
- `store/`: Persistencia em memoria com controle de concorrencia atraves de `sync.RWMutex`.
- `main.go`: Ponto de entrada responsavel por inicializar os modulos, injetar dependencias e subir o servidor HTTP.
- `tasks.hurl`: Suite automatizada de testes declarativos com Hurl.

