class CreateVendas < ActiveRecord::Migration[6.1]
  def change
    create_table :vendas do |t|
      t.references :filial, null: false, foreign_key: true
      t.string :nome
      t.string :metodo
      t.string :valor

      t.timestamps
    end
  end
end
