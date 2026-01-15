module VendaProdutosHelper
  def quantidade_estoque(venda_produto, filial_id)
    produto_id = venda_produto.produto_id

    filial_produto = FilialProduto.find_by(filial_id: filial_id, produto_id: produto_id)
  
    return unless filial_produto
  
    total_estoque = filial_produto.quantidade
    quantidade_minima = filial_produto.quantidade_minima
    quantidade_alerta = filial_produto.quantidade_alerta
  
    background_color = if quantidade_minima.present? && total_estoque <= quantidade_minima
                         '#f00'
                       elsif quantidade_alerta.present? && total_estoque <= quantidade_alerta
                         '#f90'
                       else
                         return total_estoque
                       end
  
    "<div class='quantidade-estoque' style='background-color: #{background_color};'>#{total_estoque}</div>".html_safe
  end
end
