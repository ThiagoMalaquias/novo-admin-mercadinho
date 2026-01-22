class FiliaisController < ApplicationController
  before_action :set_filial, only: %i[show edit update destroy]

  def index
    @filiais = Filial.all.order(created_at: :asc)
  end

  def show; end

  def new
    @filial = Filial.new
  end

  def edit; end

  def create
    @filial = Filial.new(filial_params)

    respond_to do |format|
      if @filial.save
        format.html { redirect_to filiais_url, notice: 'Filial criada com sucesso' }
        format.json { render :show, status: :created, location: @filial }
      else
        format.html { render :new }
        format.json { render json: @filial.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @filial.update(filial_params)
        format.html { redirect_to filiais_url, notice: 'Filial atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @filial }
      else
        format.html { render :edit }
        format.json { render json: @filial.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @filial.destroy
    respond_to do |format|
      format.html { redirect_to filiais_url, notice: 'Filial excluida com sucesso.' }
      format.json { head :no_content }
    end
  end

  private

  def set_filial
    @filial = Filial.find(params[:id])
  end

  def filial_params
    params.require(:filial).permit(:nome_fantasia, :email, :telefone)
  end
end
