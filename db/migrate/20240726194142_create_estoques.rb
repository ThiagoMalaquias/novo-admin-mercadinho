class CreateEstoques < ActiveRecord::Migration[6.1]
  def change
    create_table :estoques do |t|
      t.references :filial, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.string :acao
      t.date :lancamento
      t.integer :quantidade
      t.string :valor_unitario
      t.string :valor_total

      t.timestamps
    end
  end
end
