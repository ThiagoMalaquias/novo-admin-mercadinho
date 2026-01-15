class AddStatusToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :status, :string
  end
end
