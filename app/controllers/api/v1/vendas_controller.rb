class Api::V1::VendasController < Api::V1::ApplicationController
  def create
    @venda = Venda.new
    @venda.filial_id = venda_params[:filial_id]
    @venda.metodo = venda_params[:metodo]
    @venda.valor = Conversao.convert_comma_to_float(venda_params[:valor])
     
    respond_to do |format|
      if @venda.save
        adicionar_produtos(@venda)
        format.html { redirect_to @venda, notice: 'Venda criada com sucesso.' }
        format.json { render :show, status: :created, location: @venda }
      else
        format.html { render :new }
        format.json { render json: @venda.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def adicionar_produtos(venda)
    produtos = params[:venda][:produto]
    produtos.each do |produto|
      VendaProduto.create(
        venda: venda,
        produto_id: produto["id"],
        quantidade: produto["quantidade"],
        valor_unitario: produto["valor_unitario"],
        valor_total: produto["valor_total"],
        total_estoque: total_estoque(venda, produto)
      )
    end
  end

  def total_estoque(venda, produto)
    filial_produto = FilialProduto.find_or_create_by!(filial_id: venda.filial_id, produto_id: produto["id"])
    quantidade_em_estoque = filial_produto.quantidade || 0
    quantidade_em_estoque - produto["quantidade"].to_i
  end

  def set_venda
    @venda = Venda.find(params[:id])
  end

  def venda_params
    params.require(:venda).permit(:filial_id, :metodo, :valor, { produto: %i[id quantidade valor_unitario valor_total] })
  end
end
