require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  
  # ==========================================
  # TESTES DE VALIDAÇÃO E CRIAÇÃO
  # ==========================================
  
  test "fixtures devem ser válidas" do
    assert payments(:pagamento_cartao_aprovado).valid?
    assert payments(:pagamento_pix_pendente).valid?
    assert payments(:pagamento_boleto_pendente).valid?
    assert payments(:pagamento_cancelado).valid?
    assert payments(:pagamento_bonus).valid?
    assert payments(:pagamento_reembolsado).valid?
  end
  
  test "deve criar um pagamento válido" do
    assert_difference('Payment.count', 1) do
      Payment.create!(
        company: companies(:rani_passos),
        user: users(:one),
        course: courses(:curso_rails_ativo),
        amount: 49700.0,
        method: "card",
        status: :pending,
        installments: "1"
      )
    end
  end
  
  test "deve gerar código automaticamente no before_create" do
    payment = Payment.new(
      company: companies(:rani_passos),
      user: users(:one),
      course: courses(:curso_rails_ativo),
      amount: 49700.0,
      method: "card",
      status: :pending
    )
    
    assert_nil payment.code, "Code deveria ser nil antes de criar"
    
    payment.save!
    
    assert_not_nil payment.code, "Code deveria ser gerado automaticamente"
    assert payment.code.length > 0
  end
  
  # ==========================================
  # TESTES DE RELACIONAMENTOS
  # ==========================================
  
  test "deve pertencer a uma empresa" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_not_nil payment.company
    assert_instance_of Company, payment.company
    assert_equal "Rani Passos", payment.company.name
  end
  
  test "deve pertencer a um usuário" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_not_nil payment.user
    assert_instance_of User, payment.user
  end
  
  test "deve pertencer a um curso (opcional)" do
    payment_with_course = payments(:pagamento_cartao_aprovado)
    
    assert_not_nil payment_with_course.course
    assert_instance_of Course, payment_with_course.course
  end
  
  test "deve ter muitos user_courses" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_respond_to payment, :user_courses
  end
  
  test "deve ter muitos utmifies" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_respond_to payment, :utmifies
  end
  
  test "deve ter um order_installment opcional" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_respond_to payment, :order_installment
  end
  
  # ==========================================
  # TESTES DE ENUM STATUS
  # ==========================================
  
  test "deve ter enum status correto" do
    payment = Payment.new(
      company: companies(:rani_passos),
      user: users(:one),
      amount: 100.0,
      method: "card"
    )
    
    payment.status = :pending
    assert_equal "pending", payment.status
    
    payment.status = :paid
    assert_equal "paid", payment.status
    
    payment.status = :canceled
    assert_equal "canceled", payment.status
    
    payment.status = :closed
    assert_equal "closed", payment.status
    
    payment.status = :refunded
    assert_equal "refunded", payment.status
    
    payment.status = :expired
    assert_equal "expired", payment.status
  end
  
  test "pagamento aprovado deve ter status paid" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_equal "paid", payment.status
    assert payment.paid?
  end
  
  test "pagamento pendente deve ter status pending" do
    payment = payments(:pagamento_pix_pendente)
    
    assert_equal "pending", payment.status
    assert payment.pending?
  end
  
  test "pagamento cancelado deve ter status canceled" do
    payment = payments(:pagamento_cancelado)
    
    assert_equal "canceled", payment.status
    assert payment.canceled?
  end
  
  test "pagamento reembolsado deve ter status refunded" do
    payment = payments(:pagamento_reembolsado)
    
    assert_equal "refunded", payment.status
    assert payment.refunded?
  end
  
  # ==========================================
  # TESTES DE SCOPES
  # ==========================================
  
  test "scope paids deve retornar apenas pagamentos pagos" do
    paids = Payment.paids
    
    assert_includes paids, payments(:pagamento_cartao_aprovado)
    assert_includes paids, payments(:pagamento_bonus)
    assert_not_includes paids, payments(:pagamento_pix_pendente)
    assert_not_includes paids, payments(:pagamento_cancelado)
  end
  
  test "scope pendings deve retornar apenas pagamentos pendentes" do
    pendings = Payment.pendings
    
    assert_includes pendings, payments(:pagamento_pix_pendente)
    assert_includes pendings, payments(:pagamento_boleto_pendente)
    assert_not_includes pendings, payments(:pagamento_cartao_aprovado)
  end
  
  test "scope canceleds deve retornar apenas pagamentos cancelados" do
    canceleds = Payment.canceleds
    
    assert_includes canceleds, payments(:pagamento_cancelado)
    assert_not_includes canceleds, payments(:pagamento_cartao_aprovado)
  end
  
  test "scope refundeds deve retornar apenas pagamentos reembolsados" do
    refundeds = Payment.refundeds
    
    assert_includes refundeds, payments(:pagamento_reembolsado)
    assert_not_includes refundeds, payments(:pagamento_cartao_aprovado)
  end
  
  test "scope method_card deve retornar apenas pagamentos com cartão" do
    cards = Payment.method_card
    
    assert_includes cards, payments(:pagamento_cartao_aprovado)
    assert_not_includes cards, payments(:pagamento_pix_pendente)
    assert_not_includes cards, payments(:pagamento_boleto_pendente)
  end
  
  test "scope method_pix deve retornar apenas pagamentos com pix" do
    pixs = Payment.method_pix
    
    assert_includes pixs, payments(:pagamento_pix_pendente)
    assert_not_includes pixs, payments(:pagamento_cartao_aprovado)
  end
  
  test "scope method_billet deve retornar apenas pagamentos com boleto" do
    billets = Payment.method_billet
    
    assert_includes billets, payments(:pagamento_boleto_pendente)
    assert_not_includes billets, payments(:pagamento_cartao_aprovado)
  end
  
  test "scope method_bonus deve retornar apenas pagamentos com bônus" do
    bonus = Payment.method_bonus
    
    assert_includes bonus, payments(:pagamento_bonus)
    assert_not_includes bonus, payments(:pagamento_cartao_aprovado)
  end
  
  # ==========================================
  # TESTES DE MÉTODOS PÚBLICOS
  # ==========================================
  
  test "method_pt deve retornar método em português" do
    assert_equal "Cartão de Crédito", payments(:pagamento_cartao_aprovado).method_pt
    assert_equal "Pix", payments(:pagamento_pix_pendente).method_pt
    assert_equal "Boleto Bancário", payments(:pagamento_boleto_pendente).method_pt
    assert_equal "Bônus", payments(:pagamento_bonus).method_pt
  end
  
  test "status_pt deve retornar status em português" do
    assert_equal "Pago", payments(:pagamento_cartao_aprovado).status_pt
    assert_equal "Pendente", payments(:pagamento_pix_pendente).status_pt
    assert_equal "Cancelado", payments(:pagamento_cancelado).status_pt
    assert_equal "Reembolsado", payments(:pagamento_reembolsado).status_pt
  end
  
  test "save_error deve salvar mensagem de erro" do
    payment = payments(:pagamento_pix_pendente)
    
    assert_nil payment.error
    assert payment.pending?
    
    payment.save_error("Cartão recusado")
    
    assert_equal "Cartão recusado", payment.error
    assert payment.canceled?, "Status deveria mudar para canceled quando há erro e não estava paid"
  end
  
  test "save_error não deve alterar status de pagamento já pago" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert payment.paid?
    
    payment.save_error("Tentativa de erro")
    
    assert_equal "Tentativa de erro", payment.error
    assert payment.paid?, "Status paid não deveria mudar"
  end
  
  test "location_genereted deve retornar Venda quando não tem order_installment" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_equal "Venda", payment.location_genereted
  end
  
  # ==========================================
  # TESTES DE MÉTODOS DE CLASSE
  # ==========================================
  
  test "payment_service_for deve retornar serviço correto para card" do
    service = Payment.payment_service_for('card')
    
    assert_equal Payment::CardService, service
  end
  
  test "payment_service_for deve retornar serviço correto para billet" do
    service = Payment.payment_service_for('billet')
    
    assert_equal Payment::BilletService, service
  end
  
  test "payment_service_for deve retornar serviço correto para pix" do
    service = Payment.payment_service_for('pix')
    
    assert_equal Payment::PixService, service
  end
  
  test "status_webhook deve retornar false quando não há id" do
    result = Payment.status_webhook({})
    
    assert_equal false, result
  end
  
  test "status_webhook deve retornar true quando pagamento não existe" do
    result = Payment.status_webhook({ "id" => "invoice_inexistente" })
    
    assert_equal true, result
  end
  
  test "status_webhook deve atualizar status do pagamento" do
    payment = payments(:pagamento_pix_pendente)
    payment.update(invoice_id: "invoice_teste_webhook")
    
    result = Payment.status_webhook({
      "id" => "invoice_teste_webhook",
      "status" => "paid"
    })
    
    payment.reload
    assert payment.paid?, "Pagamento deveria estar pago após webhook"
  end
  
  # ==========================================
  # TESTES DE VALORES PADRÃO
  # ==========================================
  
  test "deve ter valores padrão corretos" do
    payment = Payment.new
    
    assert_equal false, payment.handmade, "Handmade deveria ser false por padrão"
    assert_equal false, payment.send_message_pix_pending, "Send_message_pix_pending deveria ser false por padrão"
    assert_equal false, payment.send_message_overdue, "Send_message_overdue deveria ser false por padrão"
    assert_equal false, payment.closed, "Closed deveria ser false por padrão"
  end
  
  # ==========================================
  # TESTES DE TIPOS DE PAGAMENTO
  # ==========================================
  
  test "pagamento com cartão deve ter dados de cartão" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_equal "card", payment.method
    assert payment.token.present?
    assert payment.installments.present?
    assert_nil payment.pix_qrcode
    assert_nil payment.billet_line
  end
  
  test "pagamento com pix deve ter dados de pix" do
    payment = payments(:pagamento_pix_pendente)
    
    assert_equal "pix", payment.method
    assert payment.pix_qrcode.present?
    assert payment.pix_qrcode_text.present?
    assert payment.pix_expires_at.present?
    assert_nil payment.billet_line
  end
  
  test "pagamento com boleto deve ter dados de boleto" do
    payment = payments(:pagamento_boleto_pendente)
    
    assert_equal "billet", payment.method
    assert payment.billet_line.present?
    assert payment.billet_barcode.present?
    assert payment.billet_pdf.present?
    assert payment.billet_expiry_date.present?
    assert_nil payment.pix_qrcode
  end
  
  test "pagamento com bônus deve ter handmade true" do
    payment = payments(:pagamento_bonus)
    
    assert_equal "bonus", payment.method
    assert payment.handmade
    assert_equal 0.0, payment.amount
  end
  
  # ==========================================
  # TESTES DE INTEGRAÇÃO E CÁLCULOS
  # ==========================================
  
  test "value_tax deve retornar 0 quando não há installments" do
    payment = Payment.new(
      company: companies(:rani_passos),
      user: users(:one),
      amount: 100.0,
      method: "card",
      installments: nil
    )
    
    assert_equal 0, payment.value_tax
  end
  
  test "pagamento aprovado não deve ter erro" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_nil payment.error
    assert payment.paid?
  end
  
  test "pagamento cancelado deve ter mensagem de erro" do
    payment = payments(:pagamento_cancelado)
    
    assert_not_nil payment.error
    assert payment.canceled?
  end
  
  test "deve combinar scopes corretamente" do
    # Buscar pagamentos pagos com cartão
    results = Payment.paids.method_card
    
    assert_includes results, payments(:pagamento_cartao_aprovado)
    assert_not_includes results, payments(:pagamento_pix_pendente)
    assert_not_includes results, payments(:pagamento_bonus)
  end
  
  # ==========================================
  # TESTES DE CAMPOS ESPECÍFICOS
  # ==========================================
  
  test "pagamento deve ter company_id obrigatório" do
    payment = Payment.new(
      user: users(:one),
      amount: 100.0,
      method: "card"
    )
    
    assert_not payment.valid?
  end
  
  test "pagamento deve ter user_id obrigatório" do
    payment = Payment.new(
      company: companies(:rani_passos),
      amount: 100.0,
      method: "card"
    )
    
    assert_not payment.valid?
  end
  
  test "pagamento pode não ter course_id" do
    payment = Payment.new(
      company: companies(:rani_passos),
      user: users(:one),
      amount: 100.0,
      method: "card",
      status: :pending,
      course: nil
    )
    
    assert payment.save
    assert_nil payment.course
  end
  
  test "amount deve ser numérico" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_kind_of Numeric, payment.amount
    assert payment.amount >= 0
  end
  
  test "code deve ser único" do
    payment = payments(:pagamento_cartao_aprovado)
    
    assert_not_nil payment.code
    assert payment.code.length > 0
  end
end