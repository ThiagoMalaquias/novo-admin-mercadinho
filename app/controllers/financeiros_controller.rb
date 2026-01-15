class FinanceirosController < ApplicationController
  before_action :set_financeiro, only: %i[ show edit update destroy ]

  def index
    @financeiros = Financeiro.all
  end

  def show
  end

  def new
    @financeiro = Financeiro.new
  end

  def edit
  end

  def create
    @financeiro = Financeiro.new(financeiro_params)

    respond_to do |format|
      if @financeiro.save
        format.html { redirect_to financeiro_url(@financeiro), notice: "Financeiro criado com sucesso." }
        format.json { render :show, status: :created, location: @financeiro }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @financeiro.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @financeiro.update(financeiro_params)
        format.html { redirect_to financeiro_url(@financeiro), notice: "Financeiro alterado com sucesso." }
        format.json { render :show, status: :ok, location: @financeiro }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @financeiro.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @financeiro.destroy

    respond_to do |format|
      format.html { redirect_to financeiros_url, notice: "Financeiro excluído com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    def set_financeiro
      @financeiro = Financeiro.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def financeiro_params
      params.require(:financeiro).permit(:local, :data, :valor)
    end
end
