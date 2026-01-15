class Login
  attr_accessor :email, :senha, :lembrar

  def initialize(login_params)
    @email = login_params["email"]
    @senha = login_params["senha"]
    @lembrar = login_params["lembrar"]
  end

  def call
    user = Administrador.find_by(email: email, senha: senha)
    raise "Email ou Senha inválidos" if user.nil?

    time = lembrar == "1" ? 1.year.from_now : 30.minutes.from_now

    [{ id: user.id, nome: user.nome, email: user.email }, time]
  end
end
