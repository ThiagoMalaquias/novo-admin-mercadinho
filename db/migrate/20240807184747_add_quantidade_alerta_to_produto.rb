class AddQuantidadeAlertaToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :quantidade_alerta, :integer
  end
end
