class CreateFinanceiros < ActiveRecord::Migration[6.1]
  def change
    create_table :financeiros do |t|
      t.string :local
      t.date :data
      t.string :valor

      t.timestamps
    end
  end
end
