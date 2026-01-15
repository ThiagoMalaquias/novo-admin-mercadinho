class AddQuantidadeAlertaToFilialProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :filial_produtos, :quantidade_alerta, :integer
  end
end
