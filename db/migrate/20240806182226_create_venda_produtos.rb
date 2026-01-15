class CreateVendaProdutos < ActiveRecord::Migration[6.1]
  def change
    create_table :venda_produtos do |t|
      t.references :venda, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.integer :quantidade
      t.string :valor_unitario
      t.string :valor_total

      t.timestamps
    end
  end
end
