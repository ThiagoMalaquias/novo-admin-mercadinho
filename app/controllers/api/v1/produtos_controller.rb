class Api::V1::ProdutosController < Api::V1::ApplicationController
  def index
    produtos_com_estoque = Estoque.where(filial_id: @filial.id)
                                   .group(:produto_id)
                                   .having("COALESCE(SUM(CASE WHEN acao = 'entrada' THEN quantidade ELSE -quantidade END), 0) > 0")
                                   .select(:produto_id)

    @produtos = Produto.order(descricao_cupom: :asc)
                       .joins(:filial_produtos)
                       .where(filial_produtos: { status: "ATIVO", filial_id: @filial.id })
                       .where(id: produtos_com_estoque)
                       .includes(:filial_produtos)

    @produtos = @produtos.where(codigo_venda: params[:codigo_barras]) if params[:codigo_barras].present?
    @produtos = @produtos.where(grupo_produto_id: params[:grupo_produto_id]) if params[:grupo_produto_id].present?

    options = { page: params[:page], per_page: params[:per_page] }
    @produtos = @produtos.paginate(options)
  end
end
