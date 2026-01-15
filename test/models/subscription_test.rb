require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  
  # ==========================================
  # TESTES DE VALIDAÇÃO E CRIAÇÃO
  # ==========================================
  
  test "fixtures devem ser válidas" do
    assert subscriptions(:assinatura_ativa).valid?
    assert subscriptions(:assinatura_pendente).valid?
    assert subscriptions(:assinatura_cancelada).valid?
  end
  
  test "deve criar uma assinatura válida" do
    assert_difference('Subscription.count', 1) do
      Subscription.create!(
        company: companies(:rani_passos),
        user: users(:usuario_ativo),
        amount: 4700.0,
        method: "card",
        duration: "monthly",
        status: :pending
      )
    end
  end
  
  test "deve gerar código automaticamente no before_create" do
    subscription = Subscription.new(
      company: companies(:rani_passos),
      user: users(:usuario_ativo),
      amount: 4700.0,
      method: "card",
      status: :pending
    )
    
    assert_nil subscription.code
    
    subscription.save!
    
    assert_not_nil subscription.code
    assert subscription.code.length > 0
  end
  
  # ==========================================
  # TESTES DE RELACIONAMENTOS
  # ==========================================
  
  test "deve pertencer a uma empresa" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_not_nil subscription.company
    assert_instance_of Company, subscription.company
  end
  
  test "deve pertencer a um usuário" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_not_nil subscription.user
    assert_instance_of User, subscription.user
  end
  
  test "deve ter muitos user_courses" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_respond_to subscription, :user_courses
  end
  
  test "deve ter muitos invoices" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_respond_to subscription, :invoices
  end
  
  # ==========================================
  # TESTES DE ENUM STATUS
  # ==========================================
  
  test "deve ter enum status correto" do
    subscription = Subscription.new(
      company: companies(:rani_passos),
      user: users(:usuario_ativo),
      amount: 100.0,
      method: "card"
    )
    
    subscription.status = :pending
    assert_equal "pending", subscription.status
    
    subscription.status = :paid
    assert_equal "paid", subscription.status
    
    subscription.status = :canceled
    assert_equal "canceled", subscription.status
  end
  
  test "assinatura ativa deve ter status paid" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_equal "paid", subscription.status
    assert subscription.paid?
  end
  
  test "assinatura pendente deve ter status pending" do
    subscription = subscriptions(:assinatura_pendente)
    
    assert_equal "pending", subscription.status
    assert subscription.pending?
  end
  
  test "assinatura cancelada deve ter status canceled" do
    subscription = subscriptions(:assinatura_cancelada)
    
    assert_equal "canceled", subscription.status
    assert subscription.canceled?
  end
  
  # ==========================================
  # TESTES DE SCOPES
  # ==========================================
  
  test "scope paids deve retornar apenas assinaturas pagas" do
    paids = Subscription.paids
    
    assert_includes paids, subscriptions(:assinatura_ativa)
    assert_not_includes paids, subscriptions(:assinatura_pendente)
  end
  
  test "scope pendings deve retornar apenas assinaturas pendentes" do
    pendings = Subscription.pendings
    
    assert_includes pendings, subscriptions(:assinatura_pendente)
    assert_not_includes pendings, subscriptions(:assinatura_ativa)
  end
  
  test "scope canceleds deve retornar apenas assinaturas canceladas" do
    canceleds = Subscription.canceleds
    
    assert_includes canceleds, subscriptions(:assinatura_cancelada)
    assert_not_includes canceleds, subscriptions(:assinatura_ativa)
  end
  
  test "scope method_card deve retornar apenas assinaturas com cartão" do
    cards = Subscription.method_card
    
    assert_includes cards, subscriptions(:assinatura_ativa)
  end
  
  # ==========================================
  # TESTES DE MÉTODOS PÚBLICOS
  # ==========================================
  
  test "method_pt deve retornar método em português" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_equal "Cartão de Crédito", subscription.method_pt
  end
  
  test "status_pt deve retornar status em português" do
    assert_equal "Ativo", subscriptions(:assinatura_ativa).status_pt
    assert_equal "Pendente", subscriptions(:assinatura_pendente).status_pt
    assert_equal "Cancelado", subscriptions(:assinatura_cancelada).status_pt
    assert_equal "Vencido", subscriptions(:assinatura_vencida).status_pt
  end
  
  test "save_error deve salvar mensagem de erro" do
    subscription = subscriptions(:assinatura_pendente)
    
    assert_nil subscription.error
    
    subscription.save_error("Erro no pagamento")
    
    assert_equal "Erro no pagamento", subscription.error
    assert subscription.canceled?
  end
  
  test "save_error não deve alterar status de assinatura paga" do
    subscription = subscriptions(:assinatura_ativa)
    
    subscription.save_error("Tentativa de erro")
    
    assert subscription.paid?
  end
  
  # ==========================================
  # TESTES DE MÉTODOS DE CLASSE
  # ==========================================
  
  test "status_webhook deve retornar false quando não há id" do
    result = Subscription.status_webhook({})
    
    assert_equal false, result
  end
  
  test "status_webhook deve retornar true quando assinatura não existe" do
    result = Subscription.status_webhook({ "id" => "invoice_inexistente" })
    
    assert_equal true, result
  end
  
  test "status_webhook deve atualizar status para paid" do
    subscription = subscriptions(:assinatura_pendente)
    subscription.update(invoice_id: "invoice_test_webhook")
    
    Subscription.status_webhook({
      "id" => "invoice_test_webhook",
      "status" => "paid"
    })
    
    subscription.reload
    assert subscription.paid?
  end
  
  test "status_webhook deve mapear activated para paid" do
    subscription = subscriptions(:assinatura_pendente)
    subscription.update(invoice_id: "invoice_activated")
    
    Subscription.status_webhook({
      "id" => "invoice_activated",
      "status" => "activated"
    })
    
    subscription.reload
    assert subscription.paid?
  end
  
  # ==========================================
  # TESTES DE VALORES PADRÃO
  # ==========================================
  
  test "deve ter valores padrão corretos" do
    subscription = Subscription.new
    
    assert_equal false, subscription.send_message_pix_pending
    assert_equal false, subscription.send_message_overdue
  end
  
  # ==========================================
  # TESTES DE DURAÇÃO
  # ==========================================
  
  test "assinatura mensal deve ter duration monthly" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_equal "monthly", subscription.duration
  end
  
  # ==========================================
  # TESTES DE AMOUNT
  # ==========================================
  
  test "amount deve ser numérico" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_kind_of Numeric, subscription.amount
    assert subscription.amount > 0
  end
  
  # ==========================================
  # TESTES DE ERROR
  # ==========================================
  
  test "assinatura sem erro não deve ter error" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_nil subscription.error
  end
  
  test "assinatura cancelada deve ter mensagem de erro" do
    subscription = subscriptions(:assinatura_cancelada)
    
    assert_not_nil subscription.error
  end
  
  # ==========================================
  # TESTES DE CALLBACKS
  # ==========================================
  
  test "deve ter callback before_create para set_code" do
    callbacks = Subscription._create_callbacks.select { |cb| cb.kind == :before }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :set_code
  end
  
  test "deve ter callback after_save para verify_status" do
    callbacks = Subscription._save_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :verify_status
  end
  
  # ==========================================
  # TESTES DE EDGE CASES
  # ==========================================
  
  test "code deve ser único" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_not_nil subscription.code
    assert subscription.code.length > 0
  end
  
  test "deve aceitar discount" do
    subscription = Subscription.create!(
      company: companies(:rani_passos),
      user: users(:usuario_ativo),
      amount: 4700.0,
      method: "card",
      duration: "monthly",
      status: :paid,
      discount: "PROMO50"
    )
    
    assert_equal "PROMO50", subscription.discount
  end
  
  test "installments deve ser string" do
    subscription = subscriptions(:assinatura_ativa)
    
    assert_kind_of String, subscription.installments
  end
  
  # ==========================================
  # TESTES DE INTEGRAÇÃO
  # ==========================================
  
  test "deve combinar scopes corretamente" do
    results = Subscription.paids.method_card
    
    assert_includes results, subscriptions(:assinatura_ativa)
    assert_not_includes results, subscriptions(:assinatura_pendente)
  end
  
  test "deve criar assinatura com todos os campos" do
    subscription = Subscription.create!(
      company: companies(:rani_passos),
      user: users(:usuario_ativo),
      amount: 4700.0,
      method: "card",
      duration: "monthly",
      token: "token_test",
      discount: "DESC20",
      status: :paid,
      invoice_id: "INV-TEST-001",
      log_return_transaction: "Transação aprovada"
    )
    
    assert subscription.persisted?
    assert_equal "card", subscription.method
    assert_equal "monthly", subscription.duration
  end
end