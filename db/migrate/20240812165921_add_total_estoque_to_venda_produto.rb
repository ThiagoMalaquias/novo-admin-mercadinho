class AddTotalEstoqueToVendaProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :venda_produtos, :total_estoque, :integer
  end
end
