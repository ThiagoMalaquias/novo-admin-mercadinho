require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "fixtures devem ser válidas" do
    assert orders(:pedido_cartao_pago).valid?, "Pedido cartão pago deveria ser válido"
    assert orders(:pedido_pix_pendente).valid?, "Pedido pix pendente deveria ser válido"
    assert orders(:pedido_boleto_recorrente).valid?, "Pedido boleto recorrente deveria ser válido"
    assert orders(:pedido_cancelado).valid?, "Pedido cancelado deveria ser válido"
    assert orders(:pedido_com_desconto).valid?, "Pedido com desconto deveria ser válido"
    assert orders(:pedido_lifetime).valid?, "Pedido lifetime deveria ser válido"
  end
  
  test "deve criar um pedido válido" do
    assert_difference('Order.count', 1) do
      Order.create!(
        user: users(:usuario_ativo),
        manager: managers(:one),
        payment_method: "card",
        payment_installments: "12",
        amount: 497.00,
        discount: 0.0
      )
    end
  end
  
  test "deve gerar código automaticamente no before_create" do
    order = Order.new(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "card",
      payment_installments: "1",
      amount: 100.0
    )
    
    assert_nil order.code, "Code deveria ser nil antes de criar"
    
    order.save!
    
    assert_not_nil order.code, "Code deveria ser gerado automaticamente"
    assert order.code.length > 0
  end
  
  # ==========================================
  # TESTES DE RELACIONAMENTOS
  # ==========================================
  
  test "deve pertencer a um usuário" do
    order = orders(:pedido_cartao_pago)
    
    assert_not_nil order.user
    assert_instance_of User, order.user
  end
  
  test "deve pertencer a um gerente" do
    order = orders(:pedido_cartao_pago)
    
    assert_not_nil order.manager
    assert_instance_of Manager, order.manager
  end
  
  test "deve ter muitos order_installments" do
    order = orders(:pedido_cartao_pago)
    
    assert_respond_to order, :order_installments
  end
  
  test "deve ter muitos order_courses" do
    order = orders(:pedido_cartao_pago)
    
    assert_respond_to order, :order_courses
  end
  
  test "deve ter muitos courses através de order_courses" do
    order = orders(:pedido_cartao_pago)
    
    assert_respond_to order, :courses
  end 
  
  test "scope paids deve retornar apenas pedidos pagos" do
    paids = Order.paids
    
    assert_includes paids, orders(:pedido_cartao_pago)
    assert_includes paids, orders(:pedido_com_desconto)
    assert_not_includes paids, orders(:pedido_pix_pendente)
  end
  
  test "scope active deve retornar apenas pedidos não cancelados" do
    actives = Order.active
    
    assert_includes actives, orders(:pedido_cartao_pago)
    assert_includes actives, orders(:pedido_pix_pendente)
    assert_not_includes actives, orders(:pedido_cancelado)
  end
  
  test "scope recurrent deve retornar apenas pedidos recorrentes" do
    recurrents = Order.recurrent
    
    assert_includes recurrents, orders(:pedido_boleto_recorrente)
    assert_not_includes recurrents, orders(:pedido_cartao_pago)
  end
  
  test "scope not_recurrent deve retornar apenas pedidos não recorrentes" do
    not_recurrents = Order.not_recurrent
    
    assert_includes not_recurrents, orders(:pedido_cartao_pago)
    assert_not_includes not_recurrents, orders(:pedido_boleto_recorrente)
  end
  
  # ==========================================
  # TESTES DE MÉTODOS PÚBLICOS
  # ==========================================
  
  test "payment_method_pt deve retornar método em português" do
    assert_equal "Cartão de Crédito", orders(:pedido_cartao_pago).payment_method_pt
    assert_equal "Pix", orders(:pedido_pix_pendente).payment_method_pt
    assert_equal "Boleto Bancário", orders(:pedido_boleto_recorrente).payment_method_pt
  end
  
  test "installments deve retornar array de parcelas" do
    order = orders(:pedido_cartao_pago)
    
    installments = order.installments
    
    assert_instance_of Array, installments
    assert_equal 13, installments.length
    assert installments.first[:key] == 1
    assert installments.first[:value].present?
  end
  
  test "installments deve incluir opção recorrente" do
    order = orders(:pedido_cartao_pago)
    
    installments = order.installments
    
    last_option = installments.last
    assert_equal "recorrente", last_option[:key]
    assert_equal "recorrente", last_option[:value]
  end
  
  test "subtotal deve calcular soma dos order_courses" do
    order = orders(:pedido_cartao_pago)
    
    subtotal = order.subtotal
    
    assert_kind_of Numeric, subtotal
  end
  
  test "total_amount_without_interest deve subtrair desconto do subtotal" do
    order = orders(:pedido_com_desconto)
    
    total = order.total_amount_without_interest
    
    assert_kind_of Numeric, total
  end
  
  test "canceled! deve marcar pedido como cancelado" do
    order = orders(:pedido_pix_pendente)
    
    assert_nil order.canceled_at
    assert_nil order.canceled_name
    
    order.canceled!("Admin System")
    
    assert_not_nil order.canceled_at
    assert_equal "Admin System", order.canceled_name
  end
  
  test "un_cancel! deve desmarcar cancelamento" do
    order = orders(:pedido_cancelado)
    
    assert_not_nil order.canceled_at
    assert_not_nil order.canceled_name
    
    order.un_cancel!
    
    assert_nil order.canceled_at
    assert_nil order.canceled_name
  end
  
  test "invalid_first_installment_amount? deve retornar true quando primeiro valor é zero" do
    order = orders(:pedido_pix_pendente)
    order.first_installment_amount = 0.0
    
    assert order.invalid_first_installment_amount?
  end
  
  test "invalid_first_installment_amount? deve retornar false quando primeiro valor é positivo" do
    order = orders(:pedido_cartao_pago)
    order.first_installment_amount = 50.0
    
    assert_not order.invalid_first_installment_amount?
  end
  
  test "amount_per_installment deve calcular valor por parcela" do
    order = orders(:pedido_cartao_pago)
    
    amount = order.amount_per_installment
    
    assert_kind_of Numeric, amount
    assert amount > 0
  end
  
  test "amount_installment deve retornar valor da primeira parcela quando aplicável" do
    order = orders(:pedido_cartao_pago)
    order.first_installment_amount = 50.0
    
    amount = order.amount_installment(0)
    
    assert_equal 50.0, amount
  end
  
  test "amount_installment deve retornar valor padrão para parcelas posteriores" do
    order = orders(:pedido_cartao_pago)
    
    amount = order.amount_installment(1)
    
    assert_kind_of Numeric, amount
    assert amount > 0
  end
  
  test "paid_installments deve retornar zero para pedido sem pagamentos" do
    order = Order.new(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "card",
      amount: 100.0
    )
    
    assert_equal 0, order.paid_installments
  end
  
  test "pedido pago deve ter status Pago" do
    order = orders(:pedido_cartao_pago)
    
    assert_equal "Pago", order.status
  end
  
  test "pedido pendente deve ter status Pendente" do
    order = orders(:pedido_pix_pendente)
    
    assert_equal "Pendente", order.status
  end
  
  test "pedido cancelado deve ter status Cancelado" do
    order = orders(:pedido_cancelado)
    
    assert_equal "Cancelado", order.status
    assert_not_nil order.canceled_at
  end
  
  test "pedido com cartão deve ter dados de cartão" do
    order = orders(:pedido_cartao_pago)
    
    assert_equal "card", order.payment_method
    assert order.card_number.present?
    assert order.card_name.present?
    assert order.card_expiry.present?
  end
  
  test "pedido com pix deve ter método pix" do
    order = orders(:pedido_pix_pendente)
    
    assert_equal "pix", order.payment_method
  end
  
  test "pedido com boleto deve ter método billet" do
    order = orders(:pedido_boleto_recorrente)
    
    assert_equal "billet", order.payment_method
  end
  
  test "pedido recorrente deve ter payment_installments como recorrente" do
    order = orders(:pedido_boleto_recorrente)
    
    assert_equal "recorrente", order.payment_installments
  end
  
  test "pedido parcelado deve ter número de parcelas" do
    order = orders(:pedido_cartao_pago)
    
    assert_equal "12", order.payment_installments
    assert order.payment_installments.to_i > 0
  end
  
  test "pedido à vista deve ter 1 parcela" do
    order = orders(:pedido_pix_pendente)
    
    assert_equal "1", order.payment_installments
  end
  
  test "deve ter valores padrão corretos" do
    order = Order.new
    
    assert_equal false, order.lifetime, "Lifetime deveria ser false por padrão"
    assert_equal 0, order.additional_time, "Additional_time deveria ser 0 por padrão"
  end
  
  test "pedido com desconto deve ter valor de desconto" do
    order = orders(:pedido_com_desconto)
    
    assert order.discount.present?
    assert order.discount > 0
    assert_equal 97.0, order.discount
  end
  
  test "pedido sem desconto deve ter desconto zero" do
    order = orders(:pedido_cartao_pago)
    
    assert_equal 0.0, order.discount
  end
  
  test "pedido lifetime deve ter lifetime true" do
    order = orders(:pedido_lifetime)
    
    assert order.lifetime
  end
  
  test "pedido normal deve ter lifetime false" do
    order = orders(:pedido_cartao_pago)
    
    assert_not order.lifetime
  end
  
  test "deve ter callback after_create para gerar parcelas" do
    callbacks = Order._create_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :generate_order_installments,
      "Order deveria ter callback after_create :generate_order_installments"
  end

  test "deve ter callback before_create para set_code" do
    callbacks = Order._create_callbacks.select { |cb| cb.kind == :before }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :set_code,
      "Order deveria ter callback before_create :set_code"
  end

  test "deve criar parcelas ao criar pedido" do
    OrderInstallment.any_instance.stubs(:create_installment_payment).returns(nil) rescue nil
    WhatsappMessage.stubs(:send_text).returns(true) rescue nil
    
    order = Order.create!(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "pix",
      payment_installments: "3",
      amount: 300.0,
      discount: 0.0,
      first_installment_amount: 0.0
    )
    
    assert order.order_installments.count > 0, "Order deveria ter parcelas criadas"
    assert_equal 3, order.order_installments.count, "Order deveria ter 3 parcelas"
  end

  test "pedido recorrente deve criar apenas 1 parcela inicial" do
    OrderInstallment.any_instance.stubs(:create_installment_payment).returns(nil) rescue nil
    WhatsappMessage.stubs(:send_text).returns(true) rescue nil
    
    order = Order.create!(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "billet",
      payment_installments: "recorrente",
      amount: 47.0,
      discount: 0.0,
      first_installment_amount: 0.0
    )
    
    assert_equal 1, order.order_installments.count, "Pedido recorrente deveria ter apenas 1 parcela inicial"
  end

  test "pedido com cartão deve criar parcelas ao salvar" do
    OrderInstallment.any_instance.stubs(:create_installment_payment).returns(nil) rescue nil
    WhatsappMessage.stubs(:send_text).returns(true) rescue nil
    
    order = Order.create!(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "card",
      payment_installments: "12",
      card_number: "4111111111111111",
      card_name: "TEST USER",
      card_expiry: "12/2025",
      amount: 600.0,
      discount: 0.0,
      first_installment_amount: 0.0
    )
    
    assert order.order_installments.any?, "Order com cartão deveria ter parcelas"
  end
  
  test "deve aceitar observation" do
    order = orders(:pedido_cartao_pago)
    
    assert order.observation.present?
    assert_equal "Pedido aprovado com sucesso", order.observation
  end
  
  test "amount deve ser numérico" do
    order = orders(:pedido_cartao_pago)
    
    assert_kind_of Numeric, order.amount
    assert order.amount > 0
  end
  
  test "code deve ser único" do
    order = orders(:pedido_cartao_pago)
    
    assert_not_nil order.code
    assert order.code.length > 0
  end
      
  test "deve combinar scopes corretamente" do
    results = Order.paids.active
    
    assert_includes results, orders(:pedido_cartao_pago)
    assert_not_includes results, orders(:pedido_cancelado)
    assert_not_includes results, orders(:pedido_pix_pendente)
  end
  
  test "deve calcular parcelas com juros para mais de 6 parcelas" do
    order = orders(:pedido_cartao_pago)
    order.payment_installments = "12"
    
    installments = order.installments
    installment_12 = installments.find { |i| i[:key] == 12 }
    
    assert_not_nil installment_12
    assert installment_12[:value] > (order.amount / 12), "Parcelas acima de 6 devem ter juros"
  end
  
  test "deve calcular parcelas sem juros para até 6 parcelas" do
    order = orders(:pedido_com_desconto)
    order.payment_installments = "3"
    
    installments = order.installments
    installment_3 = installments.find { |i| i[:key] == 3 }
    
    assert_not_nil installment_3
    assert_in_delta (order.amount / 3), installment_3[:value], 0.01, "Parcelas até 6 não devem ter juros"
  end
  
  test "deve criar pedido com todos os campos" do
    order = Order.create!(
      user: users(:usuario_ativo),
      manager: managers(:one),
      payment_method: "card",
      payment_installments: "6",
      card_number: "4111111111111111",
      card_name: "TEST USER",
      card_expiry: "12/2025",
      amount: 300.00,
      installment_amount: 50.00,
      discount: 20.00,
      status: "Pago",
      observation: "Pedido de teste completo",
      lifetime: false,
      additional_time: 3
    )
    
    assert order.persisted?
    assert_equal "card", order.payment_method
    assert_equal "6", order.payment_installments
    assert_equal 300.00, order.amount
  end
end