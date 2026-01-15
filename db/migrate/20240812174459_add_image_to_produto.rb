class AddImageToProduto < ActiveRecord::Migration[6.1]
  def change
    add_column :produtos, :imagem, :text
  end
end
