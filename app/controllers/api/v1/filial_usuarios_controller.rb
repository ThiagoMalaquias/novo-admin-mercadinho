class Api::V1::FilialUsuariosController < Api::V1::ApplicationController
  def show
    filial_usuario = @filial.filial_usuarios.find_by(id: params[:id])
    if filial_usuario.present?
      render json: { id: filial_usuario.id, token: filial_usuario.token&.codigo }, status: :ok
    else
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
  end
end
