class CreateFilialProdutos < ActiveRecord::Migration[6.1]
  def change
    create_table :filial_produtos do |t|
      t.references :filial, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.string :valor

      t.timestamps
    end
  end
end
