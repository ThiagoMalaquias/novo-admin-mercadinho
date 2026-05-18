namespace :jobs do
  desc "Delete all data from the database"
  task delete_all_data: :environment do
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    puts "Deleting all data from the database..."
    
    ActiveStorage::Attachment.delete_all
    ActiveStorage::Blob.delete_all
  
    VendaProduto.delete_all
    Venda.delete_all
    Estoque.delete_all
    FilialProduto.delete_all
    Produto.delete_all
    GrupoProduto.delete_all
  
    puts "Done."
  end

  desc "Import products from xlsx file"
  task import_products: :environment do
    puts "Importing products from xlsx file..."
    Xlsx::Importar::ProdutosService.new(Rails.root.join("public", "lista-produtos.xlsx")).call!
  end
end