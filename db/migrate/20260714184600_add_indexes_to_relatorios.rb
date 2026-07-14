class AddIndexesToRelatorios < ActiveRecord::Migration[6.1]
  def change
    add_index :relatorios, :status unless index_exists?(:relatorios, :status)
    add_index :relatorios, :tipo unless index_exists?(:relatorios, :tipo)
  end
end
