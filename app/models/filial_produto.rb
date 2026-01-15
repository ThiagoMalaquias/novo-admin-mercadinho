class FilialProduto < ApplicationRecord
  belongs_to :filial
  belongs_to :produto

  scope :ativos, -> { where(status: "ATIVO") }

  def quantidade
    estoque = Estoque.where(filial: filial, produto: produto)
    return 0 if estoque.count.zero?

    total_entrada = estoque.entradas.sum(:quantidade)
    total_saida = estoque.saidas.sum(:quantidade)
    total_entrada - total_saida
  end

  def proxima_validade
    estoque = Estoque.where(filial: filial, produto: produto)
                     .where("validade >= ?", Date.today)
                     .order(:validade)

    return "" if estoque.empty?

    estoque.first.validade
  end

  def produto_foi_vendido?
    FilialProduto.joins("INNER JOIN vendas ON vendas.filial_id = filial_produtos.filial_id")
                 .joins("INNER JOIN venda_produtos ON venda_produtos.venda_id = vendas.id")
                 .where(filial_produtos: { filial_id: filial_id, produto_id: produto_id })
                 .where(venda_produtos: { produto_id: produto_id })
                 .exists?
  end
end
