class FilialProdutosController < ApplicationController
  before_action :set_filial
  before_action :set_filial_produto, only: %i[edit destroy alterar_status]

  def index
    @filial_produtos = @filial.filial_produtos.order("created_at desc")

    options = { page: params[:page] || 1, per_page: 10 }
    @filial_produtos = @filial_produtos.paginate(options)
  end

  def edit; end

  def create
    @filial_produto = @filial.filial_produtos.new(filial_produto_params)

    respond_to do |format|
      if @filial_produto.save
        format.html { redirect_to filial_filial_produtos_url(@filial), notice: 'Produto criado com sucesso.' }
        format.json { render :show, status: :created, location: @filial_produto }
      else
        format.html { render :index }
        format.json { render json: @filial_produto.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @filial_produto.destroy
    respond_to do |format|
      format.html { redirect_to filial_filial_produtos_url(@filial), notice: 'Produto excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

  def alterar_status
    status = @filial_produto.status == "INATIVO" ? "ATIVO" : "INATIVO"

    @filial_produto.status = status
    @filial_produto.save

    redirect_to filial_filial_produtos_url(@filial)
  end

  private

  def set_filial_produto
    @filial_produto = @filial.filial_produtos.find(params[:id])
  end

  def set_filial
    @filial = Filial.find(params[:filial_id])
  end

  def filial_produto_params
    params.require(:filial_produto).permit(:produto_id, :valor, :quantidade_alerta, :quantidade_minima)
  end
end
