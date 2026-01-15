class ChangeValorInVenda < ActiveRecord::Migration[6.1]
  def up
    remove_column :vendas, :valor
    add_column :vendas, :valor, :float
  end
end
