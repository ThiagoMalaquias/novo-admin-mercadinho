class AddValidadeToEstoque < ActiveRecord::Migration[6.1]
  def change
    add_column :estoques, :validade, :date
  end
end
