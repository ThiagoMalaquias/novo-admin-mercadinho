class TlsTokensController < ApplicationController
  before_action :set_tls_token, only: %i[show edit update destroy]

  def index
    @tls_tokens = TlsToken.order(created_at: :desc)
  end

  def show; end

  def new
    @tls_token = TlsToken.new(quantidade_acessos: 0)
  end

  def edit; end

  def create
    @tls_token = TlsToken.new(tls_token_params)

    respond_to do |format|
      if @tls_token.save
        format.html { redirect_to tls_tokens_path, notice: "Token TLS criado com sucesso." }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @tls_token.update(tls_token_params)
        format.html { redirect_to tls_tokens_path, notice: "Token TLS atualizado com sucesso." }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @tls_token.destroy
    respond_to do |format|
      format.html { redirect_to tls_tokens_path, notice: "Token TLS excluído com sucesso." }
    end
  end

  private

  def set_tls_token
    @tls_token = TlsToken.find(params[:id])
  end

  def tls_token_params
    params.require(:tls_token).permit(:codigo, :quantidade_acessos)
  end
end
