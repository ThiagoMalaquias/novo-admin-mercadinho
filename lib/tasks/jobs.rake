namespace :jobs do
  desc "Delete all data from the database"
  task delete_all_data: :environment do
    puts "Deleting all data from the database..."
    VendaProduto.destroy_all
    Venda.destroy_all
    Estoque.destroy_all
    FilialProduto.destroy_all
    Produto.destroy_all
    GrupoProduto.destroy_all
  end

  desc "Import products from xlsx file"
  task import_products: :environment do
    puts "Importing products from xlsx file..."
    Xlsx::Importar::ProdutosService.new(Rails.root.join("public", "lista-produtos.xlsx")).call!
  end
end