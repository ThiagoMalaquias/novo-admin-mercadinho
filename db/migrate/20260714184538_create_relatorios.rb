class CreateRelatorios < ActiveRecord::Migration[6.1]
  def change
    create_table :relatorios do |t|
      t.string :tipo, null: false
      t.string :status, null: false, default: "pendente"
      t.jsonb :filtros, null: false, default: {}
      t.string :arquivo_url
      t.string :arquivo_nome
      t.text :erro_mensagem
      t.datetime :processado_em
      t.references :administrador, foreign_key: true

      t.timestamps
    end
  end
end
