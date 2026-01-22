class Api::V1::VendasController < Api::V1::ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]

  def show
    @venda = Venda.find(params[:id])
  end

  def create
    @venda = Venda.new
    @venda.filial_id = @filial.id
    @venda.metodo = params[:metodo]
    @venda.valor = params[:valor]

    respond_to do |format|
      if @venda.save
        adicionar_produtos
        format.html { redirect_to @venda, notice: 'Venda criada com sucesso.' }
        format.json { render :show, status: :created, location: @venda }
      else
        format.html { render :new }
        format.json { render json: @venda.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def adicionar_produtos
    produtos = params[:produtos] || []
    produtos.each do |produto|
      VendaProduto.create(
        venda: @venda,
        produto_id: produto["id"],
        quantidade: produto["quantidade"],
        valor_unitario: produto["valor_unitario"],
        valor_total: produto["valor_total"],
        total_estoque: total_estoque(produto)
      )
    end
  end

  def total_estoque(produto)
    filial_produto = @filial.filial_produtos.find_by(produto_id: produto["id"])
    quantidade_em_estoque = filial_produto.quantidade || 0
    quantidade_em_estoque - produto["quantidade"].to_i
  end
end
