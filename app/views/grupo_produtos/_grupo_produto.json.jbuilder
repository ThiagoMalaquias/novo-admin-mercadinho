json.extract! grupo_produto, :id, :nome, :status, :grupo_consumacao, :fracionado, :created_at, :updated_at
json.url grupo_produto_url(grupo_produto, format: :json)
