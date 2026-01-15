class Api::V1::ApplicationController < ActionController::Base
  before_action :validate_filial

  def validate_filial
    filial_id = request.headers['X-Filial-Id'] || request.headers['HTTP_X_FILIAL_ID'] rescue ""
    @filial = Filial.find_by(id: filial_id)
    return render json: { erro: "Filial não encontrada" }, status: :unauthorized if @filial.blank?
  end
end
