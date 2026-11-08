# ============================================
# Testes da Todo API
# Execute com: hurl --test --variable host=http://localhost:8080 tests/api.hurl
# ============================================

# 1. Health check — apenas valida se o endpoint responde uma lista
GET {{host}}/tasks
HTTP 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$" isCollection

# 2. Criar primeira tarefa
POST {{host}}/tasks
Content-Type: application/json
{
  "title": "Estudar Go"
}
HTTP 201
[Captures]
task1_id: jsonpath "$.id"
[Asserts]
jsonpath "$.title" == "Estudar Go"
jsonpath "$.done" == false
jsonpath "$.id" isInteger
jsonpath "$.created_at" exists

# 3. Criar segunda tarefa
POST {{host}}/tasks
Content-Type: application/json
{
  "title": "Escrever testes"
}
HTTP 201
[Captures]
task2_id: jsonpath "$.id"
[Asserts]
jsonpath "$.title" == "Escrever testes"
jsonpath "$.id" isInteger

# 4. Criar terceira tarefa (para testar delete)
POST {{host}}/tasks
Content-Type: application/json
{
  "title": "Tarefa temporária"
}
HTTP 201
[Captures]
task3_id: jsonpath "$.id"

# 5. Listar todas — deve conter ao menos as 3 criadas
GET {{host}}/tasks
HTTP 200
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$" count >= 3

# 6. Buscar tarefa por id
GET {{host}}/tasks/{{task1_id}}
HTTP 200
[Asserts]
jsonpath "$.id" == {{task1_id}}
jsonpath "$.title" == "Estudar Go"

# 7. Buscar tarefa inexistente — 404
GET {{host}}/tasks/999
HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"

# 8. Atualizar tarefa (marcar como done)
PUT {{host}}/tasks/{{task1_id}}
Content-Type: application/json
{
  "title": "Estudar Go",
  "done": true
}
HTTP 200
[Asserts]
jsonpath "$.id" == {{task1_id}}
jsonpath "$.title" == "Estudar Go"
jsonpath "$.done" == true

# 9. Confirmar persistência da atualização
GET {{host}}/tasks/{{task1_id}}
HTTP 200
[Asserts]
jsonpath "$.done" == true

# 10. Atualizar tarefa inexistente — 404
PUT {{host}}/tasks/999
Content-Type: application/json
{
  "title": "Nada",
  "done": false
}
HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"

# 11. Deletar tarefa
DELETE {{host}}/tasks/{{task3_id}}
HTTP 204

# 12. Confirmar que foi deletada — 404
GET {{host}}/tasks/{{task3_id}}
HTTP 404

# 13. Deletar tarefa inexistente — 404
DELETE {{host}}/tasks/{{task3_id}}
HTTP 404
[Asserts]
jsonpath "$.error" == "tarefa nao encontrada"

# 14. Listar — agora deve conter pelo menos 2 tarefas
GET {{host}}/tasks
HTTP 200
[Asserts]
jsonpath "$" count >= 2

# ============================================
# Casos de erro de validação
# ============================================

# 15. POST sem body — 400
POST {{host}}/tasks
Content-Type: application/json
HTTP 400
[Asserts]
jsonpath "$.error" == "json invalido, tente novamente"

# ============================================
# Limpeza final das tarefas criadas no teste
# ============================================

# 16. Limpar primeira tarefa
DELETE {{host}}/tasks/{{task1_id}}
HTTP 204

# 17. Limpar segunda tarefa
DELETE {{host}}/tasks/{{task2_id}}
HTTP 204
