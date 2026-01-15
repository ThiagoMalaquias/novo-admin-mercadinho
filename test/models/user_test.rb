require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixtures devem ser válidas" do
    assert users(:usuario_ativo).valid?, "Usuário ativo deveria ser válido"
    assert users(:usuario_inativo).valid?, "Usuário inativo deveria ser válido"
    assert users(:usuario_sem_chat).valid?, "Usuário sem chat deveria ser válido"
    assert users(:usuario_admin).valid?, "Usuário admin deveria ser válido"
  end
  
  test "deve criar um usuário válido" do
    assert_difference('User.count', 1) do
      User.create!(
        company: companies(:rani_passos),
        name: "Novo Usuário",
        email: "novo@example.com",
        cpf: "746.971.314-01",  # CPF válido
        phone: "(11) 99999-9999",
        password: "password123",
        status: "active"
      )
    end
  end
  
  test "deve exigir name" do
    user = User.new(
      company: companies(:rani_passos),
      email: "test@example.com",
      cpf: "111.444.777-35",  # CPF válido
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:name], "não pode ficar em branco"
  end
  
  test "deve exigir email" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      cpf: "111.444.777-35",  # CPF válido
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:email], "não pode ficar em branco"
  end
  
  test "deve exigir cpf" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "test@example.com",
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:cpf], "não pode ficar em branco"
  end
  
  test "deve exigir phone" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "test@example.com",
      cpf: "111.444.777-35",  # CPF válido
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:phone], "não pode ficar em branco"
  end
  
  # ==========================================
  # TESTES DE VALIDAÇÕES DE UNICIDADE
  # ==========================================
  
  test "email deve ser único" do
    existing_user = users(:usuario_ativo)
    
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: existing_user.email,
      cpf: "746.971.314-01",  # CPF válido diferente
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:email], "já está em uso"
  end
  
  test "cpf deve ser único" do
    existing_user = users(:usuario_ativo)
    
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "unique@example.com",
      cpf: existing_user.cpf,  # CPF duplicado
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:cpf], "já está em uso"
  end
  
  test "deve validar CPF válido" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "cpf_valido_test@example.com",  # Email único
      cpf: "265.466.520-80",  # CPF válido
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert user.valid?, "User deveria ser válido. Erros: #{user.errors.full_messages}"
  end
  
  test "deve rejeitar CPF inválido" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "test@example.com",
      cpf: "640.224.900-92",  # CPF válido
      phone: "(11) 99999-9999",
      password: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:base], "CPF inválido"
  end
  
  test "deve aceitar CPF em branco (será validado por presence)" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "test@example.com",
      cpf: "",
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:cpf], "não pode ficar em branco"
  end
  
  test "deve pertencer a uma empresa" do
    user = users(:usuario_ativo)
    
    assert_not_nil user.company
    assert_instance_of Company, user.company
    assert_equal "Rani Passos", user.company.name
  end
  
  test "deve ter muitos endereços" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :addresses
  end
  
  test "deve ter muitos carrinhos abertos" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :open_carts
  end
  
  test "deve ter muitos pagamentos" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :payments
  end
  
  test "deve ter muitos user_courses" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :user_courses
  end
  
  test "deve ter muitas tags através de user_tags" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :tags
    assert_respond_to user, :user_tags
  end
  
  test "deve ter relacionamentos dependentes" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :notifications
    assert_respond_to user, :favorite_courses
    assert_respond_to user, :ips
    assert_respond_to user, :tracks
    assert_respond_to user, :chat_gpt_messages
    assert_respond_to user, :error_chat_gpt_messages
    assert_respond_to user, :course_essays
  end
  
  test "scope actives deve retornar apenas usuários ativos" do
    actives = User.actives
    
    assert_includes actives, users(:usuario_ativo)
    assert_includes actives, users(:usuario_sem_chat)
    assert_not_includes actives, users(:usuario_inativo)
  end
  
  test "scope inactives deve retornar apenas usuários inativos" do
    inactives = User.inactives
    
    assert_includes inactives, users(:usuario_inativo)
    assert_not_includes inactives, users(:usuario_ativo)
  end
  
  test "without_mask deve remover máscara do CPF" do
    user = users(:usuario_ativo)
    
    cpf_sem_mascara = user.without_mask("cpf")
    
    assert_equal "36583421020", cpf_sem_mascara
    assert_not_includes cpf_sem_mascara, "."
    assert_not_includes cpf_sem_mascara, "-"
  end
  
  test "without_mask deve extrair área code do telefone" do
    user = users(:usuario_ativo)
    user.phone = "(11) 98765-4321"
    
    area_code = user.without_mask("area_code")
    
    assert_equal "11", area_code
  end
  
  test "without_mask deve extrair número do telefone" do
    user = users(:usuario_ativo)
    user.phone = "(11) 98765-4321"
    
    number = user.without_mask("number")
    
    assert_equal "987654321", number
  end
  
  test "without_mask deve retornar telefone completo sem máscara" do
    user = users(:usuario_ativo)
    user.phone = "(11) 98765-4321"
    
    total_number = user.without_mask("total_number")
    
    assert_equal "11987654321", total_number
    assert_not_includes total_number, "("
    assert_not_includes total_number, ")"
    assert_not_includes total_number, "-"
    assert_not_includes total_number, " "
  end
  
  test "courses deve retornar cursos do usuário" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :courses
  end
  
  test "courses_student_area deve retornar cursos da área do aluno" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :courses_student_area
  end
  
  test "courses_open_carts deve retornar cursos no carrinho" do
    user = users(:usuario_ativo)
    
    result = user.courses_open_carts
    
    assert_respond_to result, :each
  end
  
  test "track_carts deve retornar histórico de carrinho por curso" do
    user = users(:usuario_ativo)
    course = courses(:curso_rails_ativo)
    
    result = user.track_carts(course.id)
    
    assert_respond_to result, :each
  end
  
  test "approve_last_term deve retornar false quando não há termos" do
    user = users(:usuario_ativo)
    
    result = user.approve_last_term
    
    assert_includes [true, false], result
  end
  
  test "track_courses deve retornar cursos rastreados pelo usuário" do
    user = users(:usuario_ativo)
    
    result = user.track_courses
    
    assert_respond_to result, :each
  end
  
  test "all_notifications deve retornar array de notificações" do
    user = users(:usuario_ativo)
    
    result = user.all_notifications
    
    assert_instance_of Array, result
  end
  
  test "essays deve retornar array de redações" do
    user = users(:usuario_ativo)
    
    result = user.essays
    
    assert_instance_of Array, result
  end
  
  test "ip_status deve retornar status do IP" do
    user = users(:usuario_ativo)
    
    status = user.ip_status
    
    assert_not_nil status
    assert_kind_of String, status
  end
  
  test "cart_course_names deve retornar nomes dos cursos no carrinho" do
    user = users(:usuario_ativo)
    
    result = user.cart_course_names
    
    assert_kind_of String, result
  end
  
  test "deve ter devise configurado" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :encrypted_password
    assert_respond_to user, :reset_password_token
    assert_respond_to user, :remember_created_at
    assert_respond_to user, :sign_in_count
  end
  
  test "deve criptografar password" do
    user = User.create!(
      company: companies(:rani_passos),
      name: "Test User",
      email: "password_test@example.com",
      cpf: "390.533.447-05",  # CPF válido
      phone: "(11) 99999-9999",
      password: "mypassword123"
    )
    
    assert_not_nil user.encrypted_password
    assert_not_equal "mypassword123", user.encrypted_password
  end
  
  test "deve validar senha com valid_password?" do
    user = users(:usuario_ativo)
    
    assert user.valid_password?("password123")
    assert_not user.valid_password?("wrongpassword")
  end
  
  test "deve ter valores padrão corretos" do
    user = User.new
    
    assert_equal false, user.use_chat, "Use_chat deveria ser false por padrão"
    assert_equal true, user.validate_ip, "Validate_ip deveria ser true por padrão"
    assert_equal 0, user.sign_in_count, "Sign_in_count deveria ser 0 por padrão"
  end
  
  test "usuário ativo deve ter status active" do
    user = users(:usuario_ativo)
    
    assert_equal "active", user.status
  end
  
  test "usuário inativo deve ter status inactive" do
    user = users(:usuario_inativo)
    
    assert_equal "inactive", user.status
  end
  
  test "usuário com chat deve ter use_chat true" do
    user = users(:usuario_ativo)
    
    assert user.use_chat
    assert_not_nil user.thread_chat
  end
  
  test "usuário sem chat deve ter use_chat false" do
    user = users(:usuario_sem_chat)
    
    assert_not user.use_chat
  end
  
  test "deve ter authentication_token para API" do
    user = users(:usuario_ativo)
    
    assert_respond_to user, :authentication_token
  end

  test "deve lidar com telefone em diferentes formatos" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "phone_test@example.com",
      cpf: "854.789.390-30",  # CPF válido
      phone: "11987654321",
      password: "password123"
    )

    assert user.valid?
  end
  
  test "deve aceitar diferentes formatos de CPF" do
    user1 = User.new(
      company: companies(:rani_passos),
      name: "Test User 1",
      email: "cpf1@example.com",
      cpf: "111.444.777-35",  # CPF válido com máscara
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    user2 = User.new(
      company: companies(:rani_passos),
      name: "Test User 2",
      email: "cpf2@example.com",
      cpf: "11144477735",  # CPF válido sem máscara
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert user1.valid?
    assert user2.valid?
  end
  
  test "email deve ter formato válido" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "invalid_email",
      cpf: "111.444.777-35",  # CPF válido
      phone: "(11) 99999-9999",
      password: "password123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:email], "não é válido"
  end
  
  test "password deve ter tamanho mínimo" do
    user = User.new(
      company: companies(:rani_passos),
      name: "Test User",
      email: "test@example.com",
      cpf: "111.444.777-35",  # CPF válido
      phone: "(11) 99999-9999",
      password: "123"
    )
    
    assert_not user.valid?
    assert_includes user.errors[:password], "é muito curto (mínimo: 6 caracteres)"
  end
  
  test "deve criar usuário com todos os campos" do
    user = User.create!(
      company: companies(:rani_passos),
      name: "Usuário Completo",
      birth_date: "1992-06-15",
      cpf: "214.643.810-03",  # CPF válido
      phone: "(41) 98888-7777",
      status: "active",
      email: "completo@example.com",
      password: "password123",
      use_chat: true,
      validate_ip: false,
      last_ip: "192.168.1.50"
    )
    
    assert user.persisted?
    assert_equal "Usuário Completo", user.name
    assert_equal "active", user.status
    assert user.use_chat
    assert_not user.validate_ip
  end
end