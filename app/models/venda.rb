class Venda < ApplicationRecord
  belongs_to :filial
  has_many :produtos, class_name: :VendaProduto, dependent: :destroy

  scope :periodo_data, ->(data_inicio, data_fim) { where("TO_CHAR(vendas.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(vendas.created_at - interval '3 hour','YYYY-MM-DD') <= ?", data_inicio, data_fim) }
  scope :credito, -> { where(metodo: "CREDITO") }
  scope :debito, -> { where(metodo: "DEBITO") }
  scope :pix, -> { where(metodo: "PIX") }
  scope :sodexo, -> { where(metodo: "VA SODEXO") }
end
