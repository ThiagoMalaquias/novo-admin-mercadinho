json.extract! produto, :id, :grupo_produto_id, :codigo_venda, :descricao_cupom
filial_produto = produto.filial_produtos.find_by(filial_id: @filial.id)
json.preco filial_produto&.valor
json.imagem rails_blob_url(produto.imagem) if produto.imagem.attached?
