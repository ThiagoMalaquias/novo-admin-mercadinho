class FilialUsuario < ApplicationRecord
  belongs_to :filial
  belongs_to :token, class_name: "TlsToken", foreign_key: :token_id

  validates :nome, presence: true
  validates :email, presence: true
  validates :token_id, presence: true
end
