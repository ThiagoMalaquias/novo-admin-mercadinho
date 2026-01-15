class RemoveUnidadeToProduto < ActiveRecord::Migration[6.1]
  def change
    remove_column :produtos, :unidade, :string
  end
end
