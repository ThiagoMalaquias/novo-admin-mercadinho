class CreateProdutos < ActiveRecord::Migration[6.1]
  def change
    create_table :produtos do |t|
      t.string :descricao_cupom
      t.references :grupo_produto, null: false, foreign_key: true
      t.string :codigo_venda
      t.string :unidade
      t.string :codigo_ncm
      t.string :codigo_cast

      t.timestamps
    end
  end
end
