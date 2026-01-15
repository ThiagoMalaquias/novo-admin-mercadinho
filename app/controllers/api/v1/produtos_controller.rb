class Api::V1::ProdutosController < Api::V1::ApplicationController
  before_action :set_produto, only: %i[show edit update destroy]

  def index
    @produtos = Produto.ativos_por_filial(@filial.id).order(descricao_cupom: :asc)
    @produtos = @produtos.where("descricao_cupom ILIKE ?", "%#{params[:descricao]}%") if params[:descricao].present?
    @produtos = @produtos.where(grupo_produto_id: params[:grupo_produto_id]) if params[:grupo_produto_id].present?
    
    options = { page: params[:page] || 1, per_page: 15 }
    @produtos = @produtos.paginate(options)
  end

  def show; end

  def new
    @produto = Produto.new
  end

  def edit; end

  def create
    @produto = Produto.new(produto_params)
    @produto.descricao_cupom = produto_params[:descricao_cupom].upcase.strip

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
