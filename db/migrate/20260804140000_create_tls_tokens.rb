class CreateTlsTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :tls_tokens do |t|
      t.string :codigo, null: false
      t.integer :quantidade_acessos, null: false, default: 0

      t.timestamps
    end

    add_index :tls_tokens, :codigo, unique: true
  end
end
