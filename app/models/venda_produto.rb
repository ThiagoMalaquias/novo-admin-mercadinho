class VendaProduto < ApplicationRecord
  belongs_to :venda
  belongs_to :produto

  scope :periodo_data, ->(data_inicio, data_fim) { where("TO_CHAR(venda_produtos.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(venda_produtos.created_at - interval '3 hour','YYYY-MM-DD') <= ?", data_inicio, data_fim) }

  after_create :baixa_estoque

  private

  def baixa_estoque
    Estoque.create(
      filial: venda.filial,
      produto: produto,
      acao: "saida",
      lancamento: Time.zone.now,
      quantidade: quantidade,
      valor_unitario: valor_unitario,
      valor_total: valor_total
    )
  end
end
