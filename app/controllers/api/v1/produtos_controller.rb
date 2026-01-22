class Api::V1::ProdutosController < Api::V1::ApplicationController
  def index
    # Subquery para produtos com estoque disponível > 0
    produtos_com_estoque = Estoque.where(filial_id: @filial.id)
                                   .group(:produto_id)
                                   .having("COALESCE(SUM(CASE WHEN acao = 'entrada' THEN quantidade ELSE -quantidade END), 0) > 0")
                                   .select(:produto_id)
    
    @produtos = Produto.order(descricao_cupom: :asc)
                       .joins(:filial_produtos)
                       .where(filial_produtos: { status: "ATIVO", filial_id: @filial.id })
                       .where(id: produtos_com_estoque)
                       .includes(:filial_produtos)
  end
end
