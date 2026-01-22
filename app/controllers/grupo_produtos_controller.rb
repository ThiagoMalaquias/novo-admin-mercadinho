class GrupoProdutosController < ApplicationController
  before_action :set_grupo_produto, only: %i[show edit update destroy]

  def index
    @grupo_produtos = GrupoProduto.all.order(created_at: :asc)
  end

  def show; end

  def new
    @grupo_produto = GrupoProduto.new
  end

  def edit; end

  def create
    @grupo_produto = GrupoProduto.new(grupo_produto_params)

    respond_to do |format|
      if @grupo_produto.save
        format.html { redirect_to grupo_produtos_url, notice: 'Grupo criado com sucesso' }
        format.json { render :show, status: :created, location: @grupo_produto }
      else
        format.html { render :new }
        format.json { render json: @grupo_produto.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @grupo_produto.update(grupo_produto_params)
        format.html { redirect_to grupo_produtos_url, notice: 'Grupo atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @grupo_produto }
      else
        format.html { render :edit }
        format.json { render json: @grupo_produto.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @grupo_produto.destroy
    respond_to do |format|
      format.html { redirect_to grupo_produtos_url, notice: 'Grupo excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def set_grupo_produto
    @grupo_produto = GrupoProduto.find(params[:id])
  end

  def grupo_produto_params
    params.require(:grupo_produto).permit(:nome, :status, :grupo_consumacao, :fracionado)
  end
end
