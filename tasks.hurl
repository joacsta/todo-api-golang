# 1.1 Tentar criar com JSON malformado (espera 400)
POST http://localhost:8080/tasks
Content-Type: application/json
{
  "title": "Incompleto"
# falta fechar a chave propositalmente

HTTP 400
[Asserts]
jsonpath "$.error" == "json invalido, tente novamente"


# 1.2 Tentar criar com título vazio (espera 400)
POST http://localhost:8080/tasks
Content-Type: application/json
{
  "title": ""
}

HTTP 400
[Asserts]
jsonpath "$.error" == "titulo necessario para continuar"


# 2.1 Criar a primeira tarefa
POST http://localhost:8080/tasks
Content-Type: application/json
{
  "title": "Aprender Go"
}

HTTP 201
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.id" exists
jsonpath "$.title" == "Aprender Go"
jsonpath "$.done" == false
[Captures]
task_1_id: jsonpath "$.id"


# 2.2 Criar uma segunda tarefa
POST http://localhost:8080/tasks
Content-Type: application/json
{
  "title": "Praticar Hurl"
}

HTTP 201
[Asserts]
jsonpath "$.id" exists
jsonpath "$.title" == "Praticar Hurl"
[Captures]
task_2_id: jsonpath "$.id"


# 3.1 Listar todas as tarefas (deve conter ao menos as 2 criadas)
GET http://localhost:8080/tasks

HTTP 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$" count >= 2


# 4.1 Buscar com ID não numérico / inválido (espera 400)
GET http://localhost:8080/tasks/abc

HTTP 400
[Asserts]
jsonpath "$.error" == "id invalido"


# 4.2 Buscar ID que não existe (espera 404)
GET http://localhost:8080/tasks/99999

HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"


# 4.3 Buscar a primeira tarefa existente (espera 200)
GET http://localhost:8080/tasks/{{task_1_id}}

HTTP 200
[Asserts]
jsonpath "$.id" == {{task_1_id}}
jsonpath "$.title" == "Aprender Go"
jsonpath "$.done" == false


# 5.1 Atualizar com ID inválido (espera 400)
PUT http://localhost:8080/tasks/xyz
Content-Type: application/json
{
  "title": "Novo Titulo",
  "done": true
}

HTTP 400
[Asserts]
jsonpath "$.error" == "id invalido"


# 5.2 Atualizar com JSON malformado (espera 400)
PUT http://localhost:8080/tasks/{{task_1_id}}
Content-Type: application/json
{
  "title": "Quebrado"

HTTP 400
[Asserts]
jsonpath "$.error" == "json invalido, tente novamente"


# 5.3 Atualizar tarefa inexistente (espera 404)
PUT http://localhost:8080/tasks/99999
Content-Type: application/json
{
  "title": "Fantasma",
  "done": true
}

HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"


# 5.4 Atualizar com sucesso a primeira tarefa (espera 200)
PUT http://localhost:8080/tasks/{{task_1_id}}
Content-Type: application/json
{
  "title": "Aprender Go e Concorrência",
  "done": true
}

HTTP 200
[Asserts]
jsonpath "$.id" == {{task_1_id}}
jsonpath "$.title" == "Aprender Go e Concorrência"
jsonpath "$.done" == true


# 6.1 Deletar com ID inválido (espera 400)
DELETE http://localhost:8080/tasks/invalido

HTTP 400
[Asserts]
jsonpath "$.error" == "id invalido"


# 6.2 Deletar ID inexistente (espera 404)
DELETE http://localhost:8080/tasks/99999

HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"


# 6.3 Deletar com sucesso a primeira tarefa (espera 204)
DELETE http://localhost:8080/tasks/{{task_1_id}}

HTTP 204


# 6.4 Tentar deletar a mesma tarefa novamente (deve dar 404 agora)
DELETE http://localhost:8080/tasks/{{task_1_id}}

HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"


# 6.5 Confirmar via GET que a primeira tarefa sumiu (espera 404)
GET http://localhost:8080/tasks/{{task_1_id}}

HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"


# 6.6 Confirmar que a segunda tarefa ainda continua existindo
GET http://localhost:8080/tasks/{{task_2_id}}

HTTP 200
[Asserts]
jsonpath "$.id" == {{task_2_id}}
jsonpath "$.title" == "Praticar Hurl"
