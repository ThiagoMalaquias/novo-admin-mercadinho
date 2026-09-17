class FilialUsuario < ApplicationRecord
  belongs_to :filial
  belongs_to :token, class_name: "TlsToken", foreign_key: :token_id

  validates :nome, presence: true
  validates :email, presence: true
  validates :token_id, presence: true
  validate :token_com_vaga_disponivel

  private

  def token_com_vaga_disponivel
    return if token.blank?
    return if token_id_was == token_id
    return if token.disponivel?

    errors.add(:token_id, "já atingiu o limite de acessos")
  end
end
