class CreateFilialUsuarios < ActiveRecord::Migration[6.1]
  def change
    create_table :filial_usuarios do |t|
      t.references :filial, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :email, null: false
      t.string :telefone
      t.references :token, null: false, foreign_key: { to_table: :tls_tokens }

      t.timestamps
    end

    add_index :filial_usuarios, :email
  end
end
