class AddNomeToRelatorios < ActiveRecord::Migration[6.1]
  def change
    add_column :relatorios, :nome, :string
  end
end
