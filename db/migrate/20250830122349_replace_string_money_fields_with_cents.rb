class ReplaceStringMoneyFieldsWithCents < ActiveRecord::Migration[6.1]
  def up
    remove_column :estoques, :valor_unitario
    remove_column :estoques, :valor_total
    remove_column :filial_produtos, :valor
    remove_column :financeiros, :valor
    remove_column :produtos, :preco
    remove_column :venda_produtos, :valor_unitario
    remove_column :venda_produtos, :valor_total
    remove_column :vendas, :valor
    
    rename_column :estoques, :valor_unitario_cents, :valor_unitario
    rename_column :estoques, :valor_total_cents, :valor_total
    rename_column :filial_produtos, :valor_cents, :valor
    rename_column :financeiros, :valor_cents, :valor
    rename_column :produtos, :preco_cents, :preco
    rename_column :venda_produtos, :valor_unitario_cents, :valor_unitario
    rename_column :venda_produtos, :valor_total_cents, :valor_total
    rename_column :vendas, :valor_cents, :valor
  end

  def down
    add_column :estoques, :valor_unitario, :string
    add_column :estoques, :valor_total, :string
    add_column :filial_produtos, :valor, :string
    add_column :financeiros, :valor, :string
    add_column :produtos, :preco, :string
    add_column :venda_produtos, :valor_unitario, :string
    add_column :venda_produtos, :valor_total, :string
    add_column :vendas, :valor, :float
    
    rename_column :estoques, :valor_unitario, :valor_unitario_cents
    rename_column :estoques, :valor_total, :valor_total_cents
    rename_column :filial_produtos, :valor, :valor_cents
    rename_column :financeiros, :valor, :valor_cents
    rename_column :produtos, :preco, :preco_cents
    rename_column :venda_produtos, :valor_unitario, :valor_unitario_cents
    rename_column :venda_produtos, :valor_total, :valor_total_cents
    rename_column :vendas, :valor, :valor_cents
  end
end