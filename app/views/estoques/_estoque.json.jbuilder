json.extract! estoque, :id, :filial_id, :produto_id, :acao, :lancamento, :quantidade, :valor_unitario, :valor_total, :created_at, :updated_at
json.url estoque_url(estoque, format: :json)
