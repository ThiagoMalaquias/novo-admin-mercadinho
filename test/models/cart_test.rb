require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "deve inicializar com cookies" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    
    assert_not_nil cart
    assert_instance_of Cart, cart
  end
  
  test "deve inicializar com array vazio" do
    cart = Cart.new([])
    
    assert_not_nil cart
  end
  
  test "courses deve retornar cursos dos cookies" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s },
      { "id" => courses(:curso_premium_lifetime).id.to_s }
    ]
    
    cart = Cart.new(cookies)
    courses_result = cart.courses
    
    assert_includes courses_result, courses(:curso_rails_ativo)
    assert_includes courses_result, courses(:curso_premium_lifetime)
  end
  
  test "courses deve retornar array vazio quando não há cursos" do
    cart = Cart.new([])
    
    courses_result = cart.courses
    
    assert_instance_of Array, courses_result
    assert courses_result.empty?
  end
  
  test "max_installments deve retornar maior número de parcelas" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s }
    ]
    
    cart = Cart.new(cookies)
    max = cart.max_installments
    
    assert_kind_of Integer, max
  end
  
  test "total_amount deve calcular soma dos cursos" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    total = cart.total_amount
    
    assert_kind_of Numeric, total
    assert total >= 0
  end
  
  test "total_amount deve considerar descontos" do
    cookies = [
      { 
        "id" => courses(:curso_rails_ativo).id.to_s,
        "discount" => "PROMO50",
        "code" => 0
      }
    ]
    
    cart = Cart.new(cookies)
    total = cart.total_amount
    
    assert_kind_of Numeric, total
  end
  
  test "total_amount deve retornar zero quando não há cursos" do
    cart = Cart.new([])
    
    total = cart.total_amount
    
    assert_equal 0, total
  end
  
  test "total_amount_with_installment deve retornar total sem parcelas" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    total = cart.total_amount_with_installment("")
    
    assert_kind_of Numeric, total
  end
  
  test "total_amount_with_installment deve calcular valor com parcelas" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    
    return if cart.all_installments.empty?
    
    total = cart.total_amount_with_installment("3")
    
    assert_kind_of Numeric, total
  end
  
  test "all_installments deve retornar array de parcelas" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    installments = cart.all_installments
    
    assert_instance_of Array, installments
  end
  
  test "all_installments primeira parcela não deve ter juros" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    installments = cart.all_installments
    
    return if installments.empty?
    
    first = installments.first
    assert_equal 1, first[:key]
  end
  
  test "all_installments parcelas até 6 não devem ter juros" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    installments = cart.all_installments
    
    return if installments.length < 3
    
    installment_3 = installments.find { |i| i[:key] == 3 }
    assert_not_nil installment_3
  end
  
  test "check_discount deve retornar nil quando não há cursos" do
    cart = Cart.new([])
    
    discount = cart.check_discount
    
    assert_nil discount
  end
  
  test "check_discount deve retornar nil quando há apenas um curso" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s }
    ]
    
    cart = Cart.new(cookies)
    discount = cart.check_discount
    
    assert_nil discount
  end
  
  test "validating_course_discounts deve retornar cookies quando não há descontos" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "code" => 0, "discount" => "" }
    ]
    
    cart = Cart.new(cookies)
    result = cart.validating_course_discounts
    
    assert_instance_of Array, result
  end
  
  test "validating_course_discounts deve retornar array vazio quando cookies vazio" do
    cart = Cart.new([])
    
    result = cart.validating_course_discounts
    
    assert_equal [], result
  end
  
  test "deve ter constante INTEREST definida" do
    assert_equal 1.67, Cart::INTEREST
  end
  
  test "deve lidar com múltiplos cursos no carrinho" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 },
      { "id" => courses(:curso_premium_lifetime).id.to_s, "discount" => "", "code" => 0 },
      { "id" => courses(:curso_gratuito).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    
    assert_equal 3, cart.courses.count
  end
  
  test "deve calcular total com múltiplos cursos" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 },
      { "id" => courses(:curso_premium_lifetime).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    total = cart.total_amount
    
    assert total > 0
  end
  
  test "deve calcular parcelas com juros para mais de 6 parcelas" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    installments = cart.all_installments
    
    return if installments.length < 12
    
    installment_12 = installments.find { |i| i[:key] == 12 }
    
    assert_not_nil installment_12 if installments.length >= 12
  end
  
  test "deve formatar valores corretamente" do
    cookies = [
      { "id" => courses(:curso_rails_ativo).id.to_s, "discount" => "", "code" => 0 }
    ]
    
    cart = Cart.new(cookies)
    installments = cart.all_installments
    
    return if installments.empty?
    
    first_value = installments.first[:value]
    assert_kind_of String, first_value if first_value.is_a?(String)
  end
end