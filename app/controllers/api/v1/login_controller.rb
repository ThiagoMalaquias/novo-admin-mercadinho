class Api::V1::LoginController < Api::V1::ApplicationController
  skip_before_action :validate_filial
  skip_before_action :verify_authenticity_token, only: %i[sign_in]

  def sign_in
    usuario = FilialUsuario.find_by(email: login_params[:email], telefone: login_params[:telefone])
    if usuario.present?
      render json: {
        usuario_id: usuario.id,
        filial_id: usuario.filial_id,
        nome: usuario.nome,
        email: usuario.email
      }, status: :ok
    else
      render json: { message: "Usuário ou senha inválidos" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:login).permit(:email, :telefone)
  end
end
