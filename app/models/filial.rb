class Filial < ApplicationRecord
  has_many :filial_produtos, dependent: :destroy
  has_many :produtos, through: :filial_produtos

  after_create :adicionar_produtos

  validates :nome_fantasia, uniqueness: true

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
