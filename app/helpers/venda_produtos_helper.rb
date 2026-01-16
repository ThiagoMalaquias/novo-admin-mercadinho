module VendaProdutosHelper
  def quantidade_estoque(venda_produto, filial_id)
    produto_id = venda_produto.produto_id

    filial_produto = FilialProduto.find_by(filial_id: filial_id, produto_id: produto_id)
  
    return unless filial_produto
  
    total_estoque = filial_produto.quantidade
    quantidade_minima = filial_produto.quantidade_minima
    quantidade_alerta = filial_produto.quantidade_alerta
  
    badge_classes = if quantidade_minima.present? && total_estoque <= quantidade_minima
                       'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
                     elsif quantidade_alerta.present? && total_estoque <= quantidade_alerta
                       'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200'
                     else
                       'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                     end
  
    "<span class='#{badge_classes}'>#{total_estoque}</span>".html_safe
  end
end
