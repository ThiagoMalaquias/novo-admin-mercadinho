class TlsToken < ApplicationRecord
  self.table_name = "tls_tokens"

  has_many :filial_usuarios, foreign_key: :token_id, dependent: :restrict_with_error

  validates :codigo, presence: true, uniqueness: true
  validates :quantidade_acessos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :com_vagas, -> {
    left_joins(:filial_usuarios)
      .group("tls_tokens.id")
      .having("COUNT(filial_usuarios.id) < tls_tokens.quantidade_acessos")
  }

  def self.disponiveis(incluindo_id: nil)
    ids = com_vagas.pluck(:id)
    ids << incluindo_id.to_i if incluindo_id.present?
    where(id: ids.uniq).order(:codigo)
  end

  def registros
    filial_usuarios.count
  end

  def disponivel?
    registros < quantidade_acessos
  end
end
