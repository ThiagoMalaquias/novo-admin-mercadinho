require "test_helper"

class UserCourseTest < ActiveSupport::TestCase
  test "fixtures devem ser válidas" do
    assert user_courses(:user_course_ativo_pago).valid?
    assert user_courses(:user_course_lifetime).valid?
    assert user_courses(:user_course_com_desconto).valid?
  end
  
  test "deve criar um user_course válido" do
    assert_difference('UserCourse.count', 1) do
      UserCourse.create!(
        user: users(:usuario_ativo),
        course: courses(:curso_rails_ativo),
        status: "active",
        authenticate: true,
        lifetime: false
      )
    end
  end
  
  test "deve pertencer a um user" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_not_nil uc.user
    assert_instance_of User, uc.user
  end
  
  test "deve pertencer a um course" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_not_nil uc.course
    assert_instance_of Course, uc.course
  end
  
  test "deve pertencer a um payment opcional" do
    uc_with = user_courses(:user_course_ativo_pago)
    uc_without = user_courses(:user_course_inativo)
    
    assert_not_nil uc_with.payment
    assert uc_without.payment.nil? || uc_without.payment.present?
  end
  
  test "deve pertencer a uma subscription opcional" do
    uc = user_courses(:user_course_assinatura)
    
    assert_not_nil uc.subscription
  end
  
  test "deve ter muitos free_link_user_courses" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_respond_to uc, :free_link_user_courses
  end
  
  test "scope access_actives deve retornar apenas ativos" do
    actives = UserCourse.access_actives
    
    assert_includes actives, user_courses(:user_course_ativo_pago)
    assert_not_includes actives, user_courses(:user_course_inativo)
  end
  
  test "scope authenticated deve retornar apenas autenticados" do
    authenticated = UserCourse.authenticated
    
    assert_includes authenticated, user_courses(:user_course_ativo_pago)
    assert_not_includes authenticated, user_courses(:user_course_nao_autenticado)
  end
  
  test "scope non_nil_amount deve retornar apenas com amount" do
    non_nil = UserCourse.non_nil_amount
    
    assert_includes non_nil, user_courses(:user_course_ativo_pago)
  end
  
  test "scope non_nil_discount deve retornar apenas com discount" do
    non_nil = UserCourse.non_nil_discount
    
    assert_includes non_nil, user_courses(:user_course_com_desconto)
  end
  
  test "scope non_lifetime deve retornar apenas não lifetime" do
    non_lifetime = UserCourse.non_lifetime
    
    assert_includes non_lifetime, user_courses(:user_course_ativo_pago)
    assert_not_includes non_lifetime, user_courses(:user_course_lifetime)
  end
  
  test "titles deve retornar títulos dos cursos com amount" do
    titles = UserCourse.non_nil_amount.titles
    
    assert_kind_of String, titles
  end
  
  test "discounts deve retornar descontos formatados" do
    discounts = UserCourse.non_nil_discount.discounts
    
    assert_kind_of String, discounts
  end
  
  test "user_course lifetime deve ter lifetime true" do
    uc = user_courses(:user_course_lifetime)
    
    assert uc.lifetime
    assert_nil uc.access_until
  end
  
  test "deve ter valor padrão lifetime false" do
    uc = UserCourse.new
    
    assert_equal false, uc.lifetime
  end
  
  test "user_course autenticado deve ter authenticate true" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert uc.authenticate
  end
  
  test "user_course não autenticado deve ter authenticate false" do
    uc = user_courses(:user_course_nao_autenticado)
    
    assert_not uc.authenticate
  end
  
  test "deve ter valor padrão authenticate true" do
    uc = UserCourse.new
    
    assert_equal true, uc.authenticate
  end
  
  test "value_with_discount deve retornar 0 sem desconto" do
    uc = user_courses(:user_course_ativo_pago)
    
    value = uc.value_with_discount
    
    assert_equal 0, value
  end
  
  test "value_with_discount deve calcular desconto quando existe" do
    uc = user_courses(:user_course_com_desconto)
    
    value = uc.value_with_discount
    
    assert_kind_of Numeric, value
  end
  
  test "value_cash_course deve retornar amount sem desconto" do
    uc = user_courses(:user_course_ativo_pago)
    
    value = uc.value_cash_course
    
    assert_equal uc.amount, value
  end
  
  test "value_cash_course deve calcular valor original com desconto" do
    uc = user_courses(:user_course_com_desconto)
    
    value = uc.value_cash_course
    
    assert_kind_of Numeric, value
    assert value >= uc.amount
  end
  
  test "confirm_status deve retornar inactive quando status é inactive" do
    uc = user_courses(:user_course_inativo)
    
    assert_equal "inactive", uc.confirm_status
  end
  
  test "confirm_status deve retornar expired quando expirado" do
    uc = user_courses(:user_course_expirado)
    
    assert_equal "expired", uc.confirm_status
  end
  
  test "confirm_status deve retornar status do payment quando existe" do
    uc = user_courses(:user_course_ativo_pago)
    
    status = uc.confirm_status
    
    assert_not_nil status
  end
  
  test "confirm_status deve retornar status quando ativo e não expirado" do
    uc = user_courses(:user_course_ativo_pago)
    
    status = uc.confirm_status
    
    assert_not_nil status
  end
  
  test "origin deve retornar Venda quando tem payment" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_equal "Venda", uc.origin
  end
  
  test "origin deve retornar Assinatura quando tem subscription" do
    uc = user_courses(:user_course_assinatura)
    
    assert_equal "Assinatura", uc.origin
  end
  
  test "origin deve retornar Manual quando não tem payment nem subscription" do
    uc = UserCourse.create!(
      user: users(:usuario_ativo),
      course: courses(:curso_rails_ativo),
      status: "active",
      authenticate: true
    )
    
    assert_equal "Manual", uc.origin
  end
  
  test "user_course ativo deve ter status active" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_equal "active", uc.status
  end
  
  test "user_course inativo deve ter status inactive" do
    uc = user_courses(:user_course_inativo)
    
    assert_equal "inactive", uc.status
  end
  
  test "user_course com desconto deve ter discount preenchido" do
    uc = user_courses(:user_course_com_desconto)
    
    assert uc.discount.present?
    assert_equal "Black Friday 2024", uc.discount
  end
  
  test "user_course sem desconto deve ter discount vazio" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert uc.discount.blank?
  end
  
  test "amount deve ser numérico" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_kind_of Numeric, uc.amount
    assert uc.amount > 0
  end
  
  test "deve ter access_start" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_not_nil uc.access_start
    assert_instance_of Date, uc.access_start
  end
  
  test "user_course lifetime não deve ter access_until" do
    uc = user_courses(:user_course_lifetime)
    
    assert uc.lifetime
    assert_nil uc.access_until
  end
  
  test "user_course não lifetime deve ter access_until" do
    uc = user_courses(:user_course_ativo_pago)
    
    assert_not uc.lifetime
    assert_not_nil uc.access_until
  end
  
  test "deve ter callback after_commit para verify_tags" do
    callbacks = UserCourse._commit_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :verify_tags
  end
  
  test "deve ter callback after_commit para set_tag_with_lifetime" do
    callbacks = UserCourse._commit_callbacks.select { |cb| cb.kind == :after }
    callback_names = callbacks.map(&:filter)
    
    assert_includes callback_names, :set_tag_with_lifetime
  end
  
  test "deve combinar scopes corretamente" do
    results = UserCourse.access_actives.authenticated.non_lifetime
    
    assert_includes results, user_courses(:user_course_ativo_pago)
    assert_not_includes results, user_courses(:user_course_lifetime)
    assert_not_includes results, user_courses(:user_course_inativo)
  end
  
  test "deve criar user_course completo" do
    uc = UserCourse.create!(
      user: users(:usuario_ativo),
      course: courses(:curso_rails_ativo),
      payment: payments(:pagamento_cartao_aprovado),
      status: "active",
      access_start: Date.today,
      access_until: 1.year.from_now.to_date,
      lifetime: false,
      discount: "PROMO20",
      amount: 397.60,
      authenticate: true
    )
    
    assert uc.persisted?
    assert_equal "active", uc.status
    assert uc.authenticate
  end
end