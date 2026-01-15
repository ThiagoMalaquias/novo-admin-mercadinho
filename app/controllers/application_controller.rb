class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def authenticate_user!
    if cookies[:pdv_legal].blank?
      redirect_to login_path
      return
    end
          
    if administrador.present?
      return if instance_of?(::HomeController)

      if administrador.acessos.blank?
         flash[:error] = "Usuário sem acesso a página"
         redirect_to "/"
         return false
      else
        unless administrador.acessos_include?("#{self.class}::#{params[:action]}")
          flash[:error] = "Usuário sem acesso a página"
          redirect_to "/"
          return false
        end
      end
    end

    return true
  end

  def administrador
    if cookies[:pdv_legal].present?
      return @adm if @adm.present?
      @adm = Administrador.find(JSON.parse(cookies[:pdv_legal])["id"])
      return @adm
    end
  end
end
