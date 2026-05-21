class Api::V1::GrupoProdutosController < Api::V1::ApplicationController
  def index
    @grupo_produtos = GrupoProduto.order(nome: :asc)
  end
end
