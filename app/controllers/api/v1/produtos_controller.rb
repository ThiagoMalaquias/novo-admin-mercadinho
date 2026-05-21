class Api::V1::ProdutosController < Api::V1::ApplicationController
  def index
    @produtos = Produto.order(descricao_cupom: :asc)
                       .joins(:filial_produtos)
                       .where(filial_produtos: { status: "ATIVO", filial_id: @filial.id })
                       .includes(:filial_produtos)

    @produtos = @produtos.where(codigo_venda: params[:codigo_barras]) if params[:codigo_barras].present?
    @produtos = @produtos.where(grupo_produto_id: params[:grupo_produto_id]) if params[:grupo_produto_id].present?

    options = { page: params[:page], per_page: params[:per_page] }
    @produtos = @produtos.paginate(options)
  end
end
