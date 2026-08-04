class Filial < ApplicationRecord
  has_many :filial_produtos, dependent: :destroy
  has_many :produtos, through: :filial_produtos
  has_many :vendas, dependent: :destroy
  has_many :filial_usuarios, dependent: :destroy

  after_create :adicionar_produtos

  validates :nome_fantasia, uniqueness: true

  def self.com_metricas
    select(
      "filiais.*",
      "(SELECT COALESCE(SUM(vendas.valor), 0) FROM vendas WHERE vendas.filial_id = filiais.id) AS valor_vendido_total",
      "(SELECT COUNT(*) FROM filial_produtos WHERE filial_produtos.filial_id = filiais.id) AS quantidade_produtos",
      "(SELECT COUNT(*) FROM filial_usuarios WHERE filial_usuarios.filial_id = filiais.id) AS quantidade_usuarios"
    )
  end

  private

  def adicionar_produtos
    Produto.find_each do |produto|
      FilialProduto.create(
        filial: self, produto: produto,
        valor: produto.preco,
        quantidade_alerta: produto.quantidade_alerta,
        quantidade_minima: produto.quantidade_minima
      )
    end
  end
end
