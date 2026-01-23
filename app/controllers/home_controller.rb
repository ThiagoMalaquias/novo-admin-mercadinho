class HomeController < ApplicationController
  before_action :set_datas

  def index
    @vendas = Venda.includes(:filial, :produtos).order(created_at: :desc).limit(5)

    todas_vendas = Venda.all
    @receita_total = todas_vendas.sum(:valor) || 0
    @total_vendas = todas_vendas.count

    produtos_ativos_query = FilialProduto.ativos.select(:produto_id).distinct
    produtos_ativos_query = produtos_ativos_query.where(filial_id: params[:filial_id]) if params[:filial_id].present?
    @produtos_ativos = produtos_ativos_query.count

    @total_filiais = Filial.count
  end

  def produtos_mais_vendidos
    @mais_vendidos = VendaProduto
                     .select("venda_produtos.produto_id, produtos.descricao_cupom, SUM(venda_produtos.quantidade) AS total_quantidade, grupo_produtos.nome as grupo_nome")
                     .joins(produto: :grupo_produto)
                     .periodo_data(params[:data_inicio], params[:data_fim])
                     .group("venda_produtos.produto_id, produtos.descricao_cupom, grupo_produtos.nome")
                     .order("total_quantidade DESC")

    @mais_vendidos = @mais_vendidos.joins(:venda).where(venda: { filial_id: params[:filial_id] }) if params[:filial_id].present?
  end

  def formas_recebimento
    @vendas = Venda.periodo_data(params[:data_inicio], params[:data_fim]).order(created_at: :desc)
    @vendas = @vendas.where(filial_id: params[:filial_id]) if params[:filial_id].present?
  end

  def faturamento_filial
    @vendas = Venda
              .select("vendas.filial_id, filiais.nome_fantasia, COUNT(*) AS quantidade_vendas, SUM(valor) AS faturamento_total")
              .joins(:filial)
              .periodo_data(params[:data_inicio], params[:data_fim])
              .group("vendas.filial_id, filiais.nome_fantasia")
              .order("vendas.filial_id asc")

    @vendas = @vendas.where(filial_id: params[:filial_id]) if params[:filial_id].present?
  end

  def consumo_produtos
    @produtos = Produto
                .joins("LEFT JOIN venda_produtos ON venda_produtos.produto_id = produtos.id")
                .joins("LEFT JOIN vendas ON vendas.id = venda_produtos.venda_id")
                .select('produtos.*, COALESCE(SUM(venda_produtos.quantidade), 0) as total_vendido, 
                         COALESCE(SUM(venda_produtos.quantidade) / NULLIF(COUNT(DISTINCT vendas.id), 0), 0) as media_vendido')
                .periodo_venda_data(params[:data_inicio], params[:data_fim])
                .group('produtos.id')
                .order('total_vendido DESC')

    @produtos = @produtos.where(vendas: { filial_id: params[:filial_id] }) if params[:filial_id].present?

    options = { page: params[:page] || 1, per_page: 15 }
    @produtos = @produtos.paginate(options)
  end

  private

  def set_datas
    params[:data_inicio] ||= Time.zone.today.beginning_of_month.strftime("%Y-%m-%d")
    params[:data_fim] ||= Time.zone.today.end_of_month.strftime("%Y-%m-%d")
  end
end
