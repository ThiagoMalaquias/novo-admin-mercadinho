class Produto < ApplicationRecord
  belongs_to :grupo_produto
  
  has_one_attached :imagem
  has_many :venda_produtos
  has_many :estoques, dependent: :destroy
  has_many :filial_produtos, dependent: :destroy
  
  validates :descricao_cupom, uniqueness: true

  after_create :adicionar_filial

  scope :ativos_por_filial, ->(filial_id) {
    joins(:filial_produtos)
      .where(filial_produtos: { status: "ATIVO", filial_id: filial_id })
  }

  scope :periodo_venda_data, ->(data_inicio, data_fim) { where("TO_CHAR(vendas.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(vendas.created_at - interval '3 hour','YYYY-MM-DD') <= ?", data_inicio, data_fim) }

  def vendas
    VendaProduto.where(produto: self).sum(:quantidade)
  end

  private
  
  def adicionar_filial
    Filial.find_each do |filial|
      FilialProduto.create(
        filial: filial, 
        produto: self, 
        valor: preco,
        quantidade_alerta: quantidade_alerta, 
        quantidade_minima: quantidade_minima
      )
    end
  end
end
