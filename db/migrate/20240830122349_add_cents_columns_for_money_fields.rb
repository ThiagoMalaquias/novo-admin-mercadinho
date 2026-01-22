class AddCentsColumnsForMoneyFields < ActiveRecord::Migration[6.1]
  def up
    add_column :estoques, :valor_unitario_cents, :integer, default: 0, null: false
    add_column :estoques, :valor_total_cents, :integer, default: 0, null: false
    add_column :filial_produtos, :valor_cents, :integer, default: 0, null: false
    add_column :financeiros, :valor_cents, :integer, default: 0, null: false
    add_column :produtos, :preco_cents, :integer, default: 0, null: false
    add_column :venda_produtos, :valor_unitario_cents, :integer, default: 0, null: false
    add_column :venda_produtos, :valor_total_cents, :integer, default: 0, null: false
    add_column :vendas, :valor_cents, :integer, default: 0, null: false
    
    migrate_data_to_cents
  end

  def down
    remove_column :estoques, :valor_unitario_cents
    remove_column :estoques, :valor_total_cents
    remove_column :filial_produtos, :valor_cents
    remove_column :financeiros, :valor_cents
    remove_column :produtos, :preco_cents
    remove_column :venda_produtos, :valor_unitario_cents
    remove_column :venda_produtos, :valor_total_cents
    remove_column :vendas, :valor_cents
  end

  private

  def migrate_data_to_cents
    execute <<-SQL
      UPDATE estoques 
      SET valor_unitario_cents = CASE 
        WHEN valor_unitario IS NULL OR valor_unitario = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor_unitario, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END,
      valor_total_cents = CASE 
        WHEN valor_total IS NULL OR valor_total = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor_total, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END
    SQL
    
    execute <<-SQL
      UPDATE filial_produtos 
      SET valor_cents = CASE 
        WHEN valor IS NULL OR valor = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END
    SQL
    
    execute <<-SQL
      UPDATE financeiros 
      SET valor_cents = CASE 
        WHEN valor IS NULL OR valor = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END
    SQL
    
    execute <<-SQL
      UPDATE produtos 
      SET preco_cents = CASE 
        WHEN preco IS NULL OR preco = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(preco, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END
    SQL
    
    execute <<-SQL
      UPDATE venda_produtos 
      SET valor_unitario_cents = CASE 
        WHEN valor_unitario IS NULL OR valor_unitario = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor_unitario, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END,
      valor_total_cents = CASE 
        WHEN valor_total IS NULL OR valor_total = '' THEN 0
        ELSE CAST(REPLACE(REPLACE(REPLACE(valor_total, '.', ''), ',', '.'), ' ', '') AS DECIMAL) * 100
      END
    SQL
    
    execute <<-SQL
      UPDATE vendas 
      SET valor_cents = COALESCE(valor, 0) * 100
    SQL
  end
end