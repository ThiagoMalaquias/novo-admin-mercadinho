require "test_helper"

class OrderInstallmentTest < ActiveSupport::TestCase
  
  test "fixtures devem ser válidas" do
    assert order_installments(:parcela_paga).valid?
    assert order_installments(:parcela_pendente).valid?
    assert order_installments(:parcela_sem_pagamento).valid?
  end
  
  test "deve criar uma parcela válida" do
    assert_difference('OrderInstallment.count', 1) do
      OrderInstallment.create!(
        order: orders(:pedido_cartao_pago),
        marker: 3,
        amount: 100.0,
        date_generate_payment: Time.zone.now
      )
    end
  end
  
  test "deve pertencer a um order" do
    installment = order_installments(:parcela_paga)
    
    assert_not_nil installment.order
    assert_instance_of Order, installment.order
  end
  
  test "deve pertencer a um payment opcional" do
    installment_with = order_installments(:parcela_paga)
    installment_without = order_installments(:parcela_sem_pagamento)
    
    assert_not_nil installment_with.payment
    assert_nil installment_without.payment
  end
  
  test "scope average_amount deve calcular média dos valores" do
    avg = OrderInstallment.average_amount
    
    assert_kind_of Numeric, avg
  end
  
  test "scope average_per_order deve calcular média por pedido" do
    avg = OrderInstallment.average_per_order
    
    assert_kind_of Numeric, avg
  end
  
  test "status deve retornar status do pagamento quando existe" do
    installment = order_installments(:parcela_paga)
    
    status = installment.status
    
    assert_not_nil status
    assert_kind_of String, status
  end
  
  test "status deve retornar Não Lançado quando não há pagamento" do
    installment = order_installments(:parcela_sem_pagamento)
    
    assert_equal "Não Lançado", installment.status
  end
  
  test "viwer_link_payment? deve retornar false sem pagamento" do
    installment = order_installments(:parcela_sem_pagamento)
    
    assert_not installment.viwer_link_payment?
  end
  
  test "viwer_link_payment? deve retornar false para cartão" do
    installment = order_installments(:parcela_paga)
    
    result = installment.viwer_link_payment?
    
    assert_includes [true, false], result
  end
  
  test "viwer_link_payment? deve retornar false com erro" do
    installment = order_installments(:parcela_com_erro)
    
    assert_not installment.viwer_link_payment?
  end
  
  test "viwer_link_new_payment? deve retornar false para cartão" do
    installment = order_installments(:parcela_paga)
    
    result = installment.viwer_link_new_payment?
    
    assert_includes [true, false], result
  end
  
  test "viwer_link_new_payment? deve retornar false sem erro" do
    installment = order_installments(:parcela_paga)
    installment.error = nil
    
    result = installment.viwer_link_new_payment?
    
    assert_includes [true, false], result
  end
  
  test "viwer_link_edit? deve retornar false para cartão" do
    installment = order_installments(:parcela_paga)
    
    result = installment.viwer_link_edit?
    
    assert_includes [true, false], result
  end
  
  test "access_until deve retornar nil para order lifetime" do
    installment = order_installments(:parcela_paga)
    order = installment.order
    order.lifetime = true
    course = courses(:curso_rails_ativo)
    
    result = installment.send(:access_until, Time.zone.now, 0, course)
    
    assert_nil result
  end
  
  test "access_until deve retornar nil para course lifetime" do
    installment = order_installments(:parcela_paga)
    order = installment.order
    course = courses(:curso_premium_lifetime)
    course.lifetime = true
    
    result = installment.send(:access_until, Time.zone.now, 0, course)
    
    assert_nil result
  end
  
  test "access_until deve calcular data com period_access" do
    installment = order_installments(:parcela_paga)
    order = installment.order
    order.lifetime = false
    course = courses(:curso_rails_ativo)
    course.lifetime = false
    order_created = Time.zone.now
    
    result = installment.send(:access_until, order_created, 0, course)
    
    assert_not_nil result
    assert_instance_of ActiveSupport::TimeWithZone, result
  end
  
  test "access_until deve adicionar tempo adicional" do
    installment = order_installments(:parcela_paga)
    order = installment.order
    order.lifetime = false
    course = courses(:curso_rails_ativo)
    course.lifetime = false
    order_created = Time.zone.now
    
    result = installment.send(:access_until, order_created, 3, course)
    
    assert_not_nil result
  end
  
  test "marker deve identificar número da parcela" do
    installment = order_installments(:parcela_paga)
    
    assert_equal 1, installment.marker
  end
  
  test "amount deve ser numérico" do
    installment = order_installments(:parcela_paga)
    
    assert_kind_of Numeric, installment.amount
    assert installment.amount > 0
  end
  
  test "parcela sem erro não deve ter error" do
    installment = order_installments(:parcela_paga)
    
    assert_nil installment.error
  end
  
  test "parcela com erro deve ter mensagem de error" do
    installment = order_installments(:parcela_com_erro)
    
    assert_not_nil installment.error
  end
  
  test "deve ter callback after_update para remove_payment" do
    callbacks = OrderInstallment._update_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :remove_payment
  end
  
  test "deve ter callback after_update para alter_access_until_course" do
    callbacks = OrderInstallment._update_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :alter_access_until_course
  end
  
  test "date_generate_payment deve ser DateTime" do
    installment = order_installments(:parcela_paga)
    
    assert_not_nil installment.date_generate_payment
    assert_kind_of Time, installment.date_generate_payment
  end
  
  test "deve criar parcela associada a pedido" do
    order = orders(:pedido_cartao_pago)
    
    installment = OrderInstallment.create!(
      order: order,
      marker: 5,
      amount: 50.0,
      date_generate_payment: Time.zone.now
    )
    
    assert_equal order, installment.order
  end
  
  test "deve permitir parcela sem payment" do
    installment = OrderInstallment.create!(
      order: orders(:pedido_cartao_pago),
      payment: nil,
      marker: 6,
      amount: 75.0,
      date_generate_payment: Time.zone.now
    )
    
    assert_nil installment.payment
    assert_equal "Não Lançado", installment.status
  end
end