class AdministradoresController < ApplicationController
  before_action :set_administrador, only: %i[show edit update destroy]

  def index
    @administradores = Administrador.order("nome asc")
    
    options = { page: params[:page] || 1, per_page: 10 }
    @administradores = @administradores.paginate(options)
  end

  def show; end

  def new
    @administrador = Administrador.new
  end

  def edit; end

  def create
    @administrador = Administrador.new(administrador_params)

    respond_to do |format|
      if @administrador.save
        format.html { redirect_to @administrador, notice: 'Administrador foi criado com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @administrador.update(administrador_params)
        format.html { redirect_to @administrador, notice: 'Administrador foi atualizado com sucesso.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @administrador.destroy
    respond_to do |format|
      format.html { redirect_to administradores_url, notice: 'Administrador foi apagado com sucesso.' }
    end
  end

  private

  def set_administrador
    @administrador = Administrador.find(params[:id])
  end

  def administrador_params
    params.require(:administrador).permit(:nome, :email, :senha)
  end
end
