class LoginController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'login'

  def index; end

  def logar
    value, time = Login.new(params["login"]).call
    cookies[:pdv_legal] = { value: value.to_json, expires: time, httponly: true }

    redirect_to "/"
  rescue => e
    flash[:erro] = e.message
    redirect_to login_path
  end

  def deslogar
    cookies[:pdv_legal] = nil
    redirect_to login_path
  end
end
