class AddPrecoToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :preco, :string
  end
end
