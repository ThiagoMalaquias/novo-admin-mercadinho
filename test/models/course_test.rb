require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "fixtures devem ser válidas" do
    assert courses(:curso_rails_ativo).valid?, "Curso Rails ativo deveria ser válido"
    assert courses(:curso_premium_lifetime).valid?, "Curso premium lifetime deveria ser válido"
    assert courses(:curso_gratuito).valid?, "Curso gratuito deveria ser válido"
    assert courses(:curso_simulado).valid?, "Curso simulado deveria ser válido"
    assert courses(:curso_recorrente).valid?, "Curso recorrente deveria ser válido"
  end
  
  test "deve criar um curso válido" do
    assert_difference('Course.count', 1) do
      Course.create!(
        company: companies(:rani_passos),
        title: "Novo Curso de Teste",
        slug: "novo-curso-teste",
        nature: "paid",
        status_disclosure: "active",
        status_access: "active",
        duration: "6 meses",
        period_access: 6,
        lifetime: false,
        value_cash: "497,00"
      )
    end
  end
  
  test "deve gerar slug automaticamente se não fornecido" do
    course = courses(:curso_sem_slug)
    course.save
    course.reload
    
    assert_not_nil course.slug, "Slug deveria ser gerado automaticamente"
    assert course.slug.include?("curso-para-testar-slug-automatico"), "Slug deveria conter o título parametrizado"
  end
  
  test "deve pertencer a uma empresa" do
    course = courses(:curso_rails_ativo)
    
    assert_not_nil course.company, "Curso deveria ter uma empresa"
    assert_instance_of Company, course.company, "Company deveria ser uma instância de Company"
    assert_equal "Rani Passos", course.company.name
  end
  
  test "deve ter uma tag opcional" do
    course_with_tag = courses(:curso_rails_ativo)
    course_without_tag = courses(:curso_inativo)
    
    assert_not_nil course_with_tag.tag, "Curso com tag deveria ter tag"
    assert_nil course_without_tag.tag, "Curso sem tag deveria aceitar tag nil"
  end
  
  test "deve ter muitas categorias através de course_categories" do
    course = courses(:curso_rails_ativo)
    
    assert_respond_to course, :categories, "Course deveria responder a :categories"
    assert_respond_to course, :course_categories, "Course deveria responder a :course_categories"
  end
  
  test "deve ter muitos descontos através de course_discounts" do
    course = courses(:curso_rails_ativo)
    
    assert_respond_to course, :discounts, "Course deveria responder a :discounts"
    assert_respond_to course, :course_discounts, "Course deveria responder a :course_discounts"
  end
  
  test "deve ter muitos usuários através de user_courses" do
    course = courses(:curso_rails_ativo)
    
    assert_respond_to course, :users, "Course deveria responder a :users"
    assert_respond_to course, :user_courses, "Course deveria responder a :user_courses"
  end
  
  test "deve ter relacionamentos dependentes" do
    course = courses(:curso_rails_ativo)
    
    # Testa se os relacionamentos existem
    assert_respond_to course, :capsules
    assert_respond_to course, :matters
    assert_respond_to course, :warranties
    assert_respond_to course, :links
    assert_respond_to course, :free_links
    assert_respond_to course, :essays
    assert_respond_to course, :announcements
    assert_respond_to course, :collections
    assert_respond_to course, :relateds
    assert_respond_to course, :related_student_areas
  end
  
  test "scope featureds deve retornar apenas cursos em destaque" do
    featured = Course.featureds
    
    assert_includes featured, courses(:curso_rails_ativo), "Deveria incluir curso em destaque"
    assert_includes featured, courses(:curso_premium_lifetime), "Deveria incluir curso premium"
    assert_not_includes featured, courses(:curso_gratuito), "Não deveria incluir curso sem destaque"
  end
  
  test "scope disclosure_actives deve retornar apenas cursos com divulgação ativa" do
    actives = Course.disclosure_actives
    
    assert_includes actives, courses(:curso_rails_ativo)
    assert_includes actives, courses(:curso_gratuito)
    assert_not_includes actives, courses(:curso_inativo)
  end
  
  test "scope disclosure_inactives deve retornar apenas cursos com divulgação inativa" do
    inactives = Course.disclosure_inactives
    
    assert_includes inactives, courses(:curso_inativo)
    assert_not_includes inactives, courses(:curso_rails_ativo)
  end
  
  test "scope access_actives deve retornar apenas cursos com acesso ativo" do
    actives = Course.access_actives
    
    assert_includes actives, courses(:curso_rails_ativo)
    assert_not_includes actives, courses(:curso_inativo)
  end
  
  test "scope not_signature deve retornar apenas cursos sem assinatura" do
    not_signature = Course.not_signature
    
    assert_includes not_signature, courses(:curso_rails_ativo)
    assert_not_includes not_signature, courses(:curso_premium_lifetime)
  end
  
  test "scope recurrents deve retornar apenas cursos recorrentes" do
    recurrents = Course.recurrents
    
    assert_includes recurrents, courses(:curso_recorrente)
    assert_not_includes recurrents, courses(:curso_rails_ativo)
  end
  
  test "scope not_recurrents deve retornar apenas cursos não recorrentes" do
    not_recurrents = Course.not_recurrents
    
    assert_includes not_recurrents, courses(:curso_rails_ativo)
    assert_not_includes not_recurrents, courses(:curso_recorrente)
  end
  
  test "scope free deve retornar apenas cursos gratuitos" do
    free = Course.free
    
    assert_includes free, courses(:curso_gratuito)
    assert_not_includes free, courses(:curso_rails_ativo)
  end
  
  test "scope paids deve retornar apenas cursos pagos" do
    paids = Course.paids
    
    assert_includes paids, courses(:curso_rails_ativo)
    assert_includes paids, courses(:curso_premium_lifetime)
    assert_not_includes paids, courses(:curso_gratuito)
  end
  
  test "scope usuals deve retornar apenas cursos normais" do
    usuals = Course.usuals
    
    assert_includes usuals, courses(:curso_rails_ativo)
    assert_not_includes usuals, courses(:curso_simulado)
  end
  
  test "scope simulateds deve retornar apenas simulados" do
    simulateds = Course.simulateds
    
    assert_includes simulateds, courses(:curso_simulado)
    assert_not_includes simulateds, courses(:curso_rails_ativo)
  end
  
  test "curso lifetime deve ter lifetime true" do
    course = courses(:curso_premium_lifetime)
    
    assert course.lifetime, "Curso premium deveria ter lifetime true"
  end
  
  test "curso não lifetime deve ter lifetime false" do
    course = courses(:curso_rails_ativo)
    
    assert_not course.lifetime, "Curso normal deveria ter lifetime false"
  end
  
  test "curso lifetime deve ter valor padrão false" do
    course = Course.new(
      company: companies(:rani_passos),
      title: "Teste",
      nature: "paid"
    )
    
    assert_equal false, course.lifetime, "Lifetime deveria ter valor padrão false"
  end
  
  test "curso lifetime não precisa de period_access definido" do
    course = courses(:curso_premium_lifetime)
    
    assert course.lifetime
    # Period_access pode ser 0 ou qualquer valor quando lifetime é true
  end
  
  test "curso não lifetime deve ter period_access maior que zero" do
    course = courses(:curso_rails_ativo)
    
    assert_not course.lifetime
    assert course.period_access.present?, "Period_access deveria estar presente"
    assert course.period_access > 0, "Period_access deveria ser maior que zero"
  end
  
  test "discount_percentage deve calcular o desconto corretamente" do
    course = courses(:curso_rails_ativo)
    # value_of: 997,00 e value_cash: 497,00
    # Desconto: (100 - (497 * 100 / 997)) = aproximadamente 50%
    
    discount = course.discount_percentage
    
    assert_equal 50, discount, "Desconto deveria ser 50%"
  end
  
  test "discount_percentage deve retornar 0 em caso de erro" do
    course = Course.new(value_of: "", value_cash: "")
    
    discount = course.discount_percentage
    
    assert_equal 0, discount, "Desconto deveria ser 0 em caso de erro"
  end
  
  test "total_price deve retornar o preço sem desconto quando não há cookies" do
    course = courses(:curso_rails_ativo)
    
    price = course.total_price({})
    
    assert_equal 497.0, price, "Preço deveria ser 497.0"
  end
  
  test "last_installment deve retornar valor correto para 1 parcela" do
    course = courses(:curso_simulado) # 1 parcela
    
    last_installment = course.last_installment
    
    assert_equal 97.0, last_installment
  end
  
  test "last_installment deve retornar string vazia quando não há parcelas" do
    course = Course.new(installments: "0")
    
    assert_equal "", course.last_installment
  end
  
  test "last_installment deve calcular com juros para múltiplas parcelas" do
    course = courses(:curso_rails_ativo) # 12 parcelas, 497,00
    
    last_installment = course.last_installment
    
    # (497 / 12) + (497 * 1.67 / 100)
    expected = (497.0 / 12) + (497.0 * 1.67 / 100)
    
    assert_in_delta expected, last_installment, 0.01
  end
  
  test "all_installments deve retornar array de parcelas" do
    course = courses(:curso_rails_ativo)
    
    installments = course.all_installments
    
    assert_instance_of Array, installments
    assert_equal 12, installments.length
    assert installments.first[:key] == 1
    assert installments.first[:value].present?
  end
  
  test "total_amount_with_installment deve retornar valor total com parcelas" do
    course = courses(:curso_rails_ativo)
    
    total = course.total_amount_with_installment("12")
    
    assert total.positive?
    assert total.is_a?(Float)
  end
  
  test "total_amount_with_installment deve retornar valor cash quando não há parcela" do
    course = courses(:curso_rails_ativo)
    
    total = course.total_amount_with_installment("")
    
    assert_equal 497.0, total
  end
  
  test "curso deve ter valores padrão corretos" do
    course = Course.new
    
    assert_equal false, course.signature, "Signature deveria ser false por padrão"
    assert_equal false, course.recurrent, "Recurrent deveria ser false por padrão"
    assert_equal false, course.use_chat, "Use_chat deveria ser false por padrão"
    assert_equal false, course.modal_discount, "Modal_discount deveria ser false por padrão"
    assert_equal false, course.lifetime, "Lifetime deveria ser false por padrão"
    assert_equal 0, course.count_message_chat_gpt, "Count_message_chat_gpt deveria ser 0 por padrão"
    assert_equal "usual", course.kind, "Kind deveria ser 'usual' por padrão"
    assert_equal "no", course.essay_mentoring, "Essay_mentoring deveria ser 'no' por padrão"
  end
  
  test "curso pago deve ter valores preenchidos" do
    course = courses(:curso_rails_ativo)
    
    assert_equal "paid", course.nature
    assert course.value_cash.present?, "Value_cash deveria estar presente"
    assert course.installments.present?, "Installments deveria estar presente"
  end
  
  test "curso gratuito pode ter valores vazios" do
    course = courses(:curso_gratuito)
    
    assert_equal "free", course.nature
    # Valores podem estar vazios
  end
  
  test "curso com chat deve ter count_message_chat_gpt maior que zero" do
    course = courses(:curso_rails_ativo)
    
    assert course.use_chat
    assert course.count_message_chat_gpt > 0
  end
  
  test "curso simulado deve ter kind simulated" do
    course = courses(:curso_simulado)
    
    assert_equal "simulated", course.kind
  end
  
  test "deve ter constante INTEREST definida" do
    assert_equal 1.67, Course::INTEREST
  end
  
  test "callback verify_slug deve ser executado após save" do
    course = Course.new(
      company: companies(:rani_passos),
      title: "Curso Sem Slug Inicial",
      nature: "free",
      status_disclosure: "active",
      status_access: "active",
      duration: "1 mês",
      period_access: 1
    )
    
    assert_nil course.slug, "Slug deveria ser nil antes de salvar"
    
    course.save!
    
    assert_not_nil course.slug, "Slug deveria ser gerado após salvar"
    assert course.slug.include?("curso-sem-slug-inicial")
    assert course.slug.include?(course.id.to_s)
  end
  
  test "callback não deve sobrescrever slug existente" do
    course = courses(:curso_rails_ativo)
    original_slug = course.slug
    
    course.title = "Novo Título Diferente"
    course.save!
    
    assert_equal original_slug, course.slug, "Slug não deveria ser alterado"
  end
  
  test "curso deve aceitar anexos de imagem" do
    course = courses(:curso_rails_ativo)
    
    assert_respond_to course, :image
    assert_respond_to course, :banner
    assert_respond_to course, :image_mobile
  end
  
  test "curso deve aceitar nested attributes" do
    course = Course.new(
      company: companies(:rani_passos),
      title: "Curso com Categorias",
      nature: "paid",
      course_categories_attributes: [
        { category_id: categories(:web_development).id }
      ]
    )
    
    assert course.valid?
  end
  
  test "percentage_discount_applied deve retornar 0 quando não há desconto" do
    course = courses(:curso_rails_ativo)
    
    discount = course.percentage_discount_applied({})
    
    assert_equal 0, discount
  end
  
  test "deve combinar scopes corretamente" do
    # Buscar cursos pagos, ativos e em destaque
    results = Course.paids.disclosure_actives.featureds
    
    assert_includes results, courses(:curso_rails_ativo)
    assert_includes results, courses(:curso_premium_lifetime)
    assert_not_includes results, courses(:curso_gratuito)
    assert_not_includes results, courses(:curso_inativo)
  end
  
  test "curso recorrente e assinatura devem ser compatíveis" do
    course = courses(:curso_recorrente)
    
    assert course.recurrent, "Curso recorrente deveria ter recurrent true"
    assert course.signature, "Curso recorrente geralmente é assinatura"
  end
  
  test "curso lifetime e premium devem ter características específicas" do
    course = courses(:curso_premium_lifetime)
    
    assert course.lifetime
    assert course.signature
    assert_equal "yes", course.featured
    assert course.use_chat
    assert course.count_message_chat_gpt > 100
  end
  
  test "curso deve ter mensagens de expiração quando aplicável" do
    course = courses(:curso_rails_ativo)
    
    assert course.thirty_days_finish_access.present?
    assert course.ten_days_finish_access.present?
    assert course.one_day_finish_access.present?
  end
  
  test "curso deve ter tags formatadas corretamente" do
    course = courses(:curso_rails_ativo)
    
    assert course.tags.present?
    assert course.tags.include?("ruby")
    assert course.tags.include?("rails")
  end
end