class AjusteProgramadosController < ApplicationController
  before_action :set_ajuste_programado, only: %i[show edit update destroy]

  def index
    @ajuste_programados = AjusteProgramado.all
  end

  def show; end

  def new
    @ajuste_programado = AjusteProgramado.new
  end

  def edit; end

  def create
    @ajuste_programado = AjusteProgramado.new(ajuste_programado_params)
    @ajuste_programado.administrador = @adm
    @ajuste_programado.status = "Em digitação"

    respond_to do |format|
      if @ajuste_programado.save
        format.html { redirect_to ajuste_programados_url, notice: 'Ajuste Programado criado com sucesso.' }
        format.json { render :show, status: :created, location: @ajuste_programado }
      else
        format.html { render :new }
        format.json { render json: @ajuste_programado.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ajuste_programado.update(ajuste_programado_params)
        format.html { redirect_to ajuste_programados_url, notice: 'Ajuste programado atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @ajuste_programado }
      else
        format.html { render :edit }
        format.json { render json: @ajuste_programado.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ajuste_programado.destroy
    respond_to do |format|
      format.html { redirect_to ajuste_programados_url, notice: 'Ajuste programado excluído com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def set_ajuste_programado
    @ajuste_programado = AjusteProgramado.find(params[:id])
  end

  def ajuste_programado_params
    params.require(:ajuste_programado).permit(:nome, :filial_id, :percentual_reajuste, :arredondamento, :status, :administrador_id)
  end
end
