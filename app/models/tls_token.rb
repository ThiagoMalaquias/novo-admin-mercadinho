class TlsToken < ApplicationRecord
  self.table_name = "tls_tokens"

  has_many :filial_usuarios, foreign_key: :token_id, dependent: :restrict_with_error

  validates :codigo, presence: true, uniqueness: true
  validates :quantidade_acessos, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def registros
    filial_usuarios.count
  end
end
