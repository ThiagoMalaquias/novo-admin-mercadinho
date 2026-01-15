class AddQuantidadeMinimaToFilialProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :filial_produtos, :quantidade_minima, :integer
  end
end
