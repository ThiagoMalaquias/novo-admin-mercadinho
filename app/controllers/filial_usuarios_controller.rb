class FilialUsuariosController < ApplicationController
  before_action :set_filial
  before_action :set_filial_usuario, only: %i[show edit update destroy]

  def index
    @filial_usuarios = @filial.filial_usuarios.includes(:token).order(created_at: :desc)
    @filial_usuarios = @filial_usuarios.paginate(page: params[:page] || 1, per_page: 10)
  end

  def show; end

  def new
    @filial_usuario = @filial.filial_usuarios.new
  end

  def edit; end

  def create
    @filial_usuario = @filial.filial_usuarios.new(filial_usuario_params)

    respond_to do |format|
      if @filial_usuario.save
        format.html { redirect_to filial_filial_usuarios_path(@filial), notice: "Usuário criado com sucesso." }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @filial_usuario.update(filial_usuario_params)
        format.html { redirect_to filial_filial_usuarios_path(@filial), notice: "Usuário atualizado com sucesso." }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @filial_usuario.destroy
    respond_to do |format|
      format.html { redirect_to filial_filial_usuarios_path(@filial), notice: "Usuário excluído com sucesso." }
    end
  end

  private

  def set_filial
    @filial = Filial.find(params[:filial_id])
  end

  def set_filial_usuario
    @filial_usuario = @filial.filial_usuarios.find(params[:id])
  end

  def filial_usuario_params
    params.require(:filial_usuario).permit(:nome, :email, :telefone, :token_id)
  end
end
