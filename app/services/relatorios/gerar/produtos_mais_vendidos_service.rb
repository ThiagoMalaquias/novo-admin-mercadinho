class Relatorios::Gerar::ProdutosMaisVendidosService < Relatorios::Gerar::BaseService
  def call!
    registros = buscar_registros
    filial_id = filtros["filial_id"].presence

    with_tempfile("produtos_mais_vendidos") do |tempfile|
      package = Axlsx::Package.new
      package.workbook.add_worksheet(name: "Mais Vendidos") do |sheet|
        headers = ["Código", "Produto", "Grupo", "Quantidade Vendida"]
        headers << "Estoque Atual" if filial_id
        sheet.add_row headers

        registros.each do |registro|
          row = [
            registro.produto_id,
            registro.descricao_cupom,
            registro.grupo_nome,
            registro.total_quantidade.to_f
          ]
          row << estoque_atual(registro.produto_id, filial_id) if filial_id
          sheet.add_row row
        end
      end

      package.serialize(tempfile.path)
      anexar_e_finalizar!(tempfile, nome_arquivo)
    end

    relatorio
  end

  private

  def buscar_registros
    scope = VendaProduto
            .select("venda_produtos.produto_id, produtos.descricao_cupom, SUM(venda_produtos.quantidade) AS total_quantidade, grupo_produtos.nome as grupo_nome")
            .joins(produto: :grupo_produto)
            .periodo_data(filtros["data_inicio"], filtros["data_fim"])
            .group("venda_produtos.produto_id, produtos.descricao_cupom, grupo_produtos.nome")
            .order("total_quantidade DESC")

    if filtros["filial_id"].present?
      scope = scope.joins(:venda).where(venda: { filial_id: filtros["filial_id"] })
    end

    scope
  end

  def estoque_atual(produto_id, filial_id)
    filial_produto = FilialProduto.find_by(filial_id: filial_id, produto_id: produto_id)
    return nil unless filial_produto

    filial_produto.quantidade
  end

  def nome_arquivo
    periodo = [filtros["data_inicio"], filtros["data_fim"]].compact.join("_a_")
    "produtos_mais_vendidos_#{periodo}_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
  end
end
