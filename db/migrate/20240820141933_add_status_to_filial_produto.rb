class AddStatusToFilialProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :filial_produtos, :status, :string, default: "ATIVO"
  end
end
