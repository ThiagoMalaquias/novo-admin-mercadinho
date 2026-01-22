class ProdutosController < ApplicationController
  before_action :set_produto, only: %i[show edit update destroy]

  def index
    @produtos = Produto.order(created_at: :desc)

    options = { page: params[:page] || 1, per_page: 15 }
    @produtos = @produtos.paginate(options)
  end

  def por_codigo_barras
    return render json: { message: "Código de barras invalido" }, status: :unprocessable_entity if params[:codigo_barras].blank?
    
    produto = Produto.find_by(codigo_venda: params[:codigo_barras])
    if produto.present?
      produto = JSON.parse(produto.to_json(:except => [:imagem]))
      return render json: produto, status: :ok 
    end
    
    return render json: { message: "Não encontrado" }, status: :unprocessable_entity
  end

  def show; end

  def new
    @produto = Produto.new
  end

  def edit; end

  def create
    @produto = Produto.new(produto_params)
    @produto.descricao_cupom = produto_params[:descricao_cupom].upcase.strip
    @produto.preco = Conversao.convert_comma_to_float(produto_params[:preco]) * 100.0

    respond_to do |format|
      if @produto.save
        format.html { redirect_to produtos_url, notice: 'Produto criado com sucesso.' }
        format.json { render :show, status: :created, location: @produto }
      else
        format.html { render :new }
        format.json { render json: @produto.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @produto.update(produto_params)
        @produto.preco = Conversao.convert_comma_to_float(produto_params[:preco]) * 100.0
        @produto.save

        format.html { redirect_to produtos_url, notice: 'Produto atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @produto }
      else
        format.html { render :edit }
        format.json { render json: @produto.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @produto.venda_produtos.count.positive?
      flash[:error] = "O produto #{@produto.descricao_cupom} não pode ser excluido porque possui vendas registradas no sistema"
      redirect_to produtos_url
      return
    end

    @produto.destroy
    respond_to do |format|
      format.html { redirect_to produtos_url, notice: 'Produto excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:descricao_cupom, :grupo_produto_id, :codigo_venda, :preco, :quantidade_alerta, :quantidade_minima, :imagem)
  end
end
