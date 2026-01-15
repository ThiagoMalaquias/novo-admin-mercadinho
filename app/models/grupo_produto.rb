class GrupoProduto < ApplicationRecord
  has_many :produtos, dependent: :destroy
end
