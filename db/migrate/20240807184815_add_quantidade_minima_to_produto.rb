class AddQuantidadeMinimaToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :quantidade_minima, :integer
  end
end
