class EstoquesController < ApplicationController
  before_action :set_estoque, only: %i[show edit update destroy]
  skip_before_action :verify_authenticity_token, only: %i[importar]

  def index
    @estoques = Estoque.order("created_at desc")
    @estoques = @estoques.where(filial_id: params[:filial_id]) if params[:filial_id].present?
    @estoques = @estoques.where(produto_id: params[:produto_id]) if params[:produto_id].present?

    @valor_total = Estoque.calculo_valor_total(@estoques)

    options = { page: params[:page] || 1, per_page: total_per_page }
    @estoques = @estoques.paginate(options)
  end

  def show; end

  def new
    @estoque = Estoque.new
    @estoque.lancamento = Time.zone.now.strftime("%Y-%m-%d")
  end

  def edit; end

  def create
    produtos = params[:estoque][:produto]
    produtos.each do |produto|
      Estoque.create(
        filial_id: params[:estoque][:filial_id],
        produto_id: produto["id"],
        acao: params[:estoque][:acao],
        lancamento: params[:estoque][:lancamento],
        validade: produto["validade"],
        quantidade: produto["quantidade"],
        valor_unitario: produto["valor_unitario"],
        valor_total: produto["valor_total"]
      )
    end

    flash[:sucesso] = "Movimentação criada com sucesso."
    redirect_to estoques_url
  rescue => e
    flash[:error] = e.message
    redirect_to estoques_url
  end

  def update
    respond_to do |format|
      if @estoque.update(estoque_params)
        format.html { redirect_to estoques_url, notice: 'Movimentação atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @estoque }
      else
        format.html { render :edit }
        format.json { render json: @estoque.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @estoque.destroy
    respond_to do |format|
      format.html { redirect_to estoques_url, notice: 'Movimentação excluída com sucesso.' }
      format.json { head :no_content }
    end
  end

  def importar
    if params[:arquivo].blank?
      flash[:error] = "Selecione um arquivo"
      redirect_to estoques_url
    end

    Xlsx::Importar::EstoqueService.new(params[:arquivo]).call!

    flash[:sucesso] = "Dados importados com sucesso"
    redirect_to estoques_url
  rescue => e
    flash[:error] = e
    redirect_to estoques_url
  end

  private

  def set_estoque
    @estoque = Estoque.find(params[:id])
  end

  def total_per_page
    params[:local] == "filial" ? @estoques.count : 10
  end

  def estoque_params
    params.require(:estoque).permit(:produto_id, :validade, :quantidade, :valor_unitario, :valor_total)
  end
end
