class CreateGrupoProdutos < ActiveRecord::Migration[6.1]
  def change
    create_table :grupo_produtos do |t|
      t.string :nome
      t.string :status
      t.string :grupo_consumacao
      t.string :fracionado

      t.timestamps
    end
  end
end
