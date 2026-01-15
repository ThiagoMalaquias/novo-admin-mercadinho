class CreateAjusteProgramados < ActiveRecord::Migration[6.1]
  def change
    create_table :ajuste_programados do |t|
      t.string :nome
      t.references :filial, null: false, foreign_key: true
      t.string :percentual_reajuste
      t.string :arredondamento
      t.string :status
      t.references :administrador, null: false, foreign_key: true

      t.timestamps
    end
  end
end
