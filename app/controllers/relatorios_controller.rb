class RelatoriosController < ApplicationController
  def index
    @relatorios = Relatorio.recentes.paginate(page: params[:page] || 1, per_page: 20)
  end

  def create
    @relatorio = Relatorio.new(relatorio_params)
    @relatorio.administrador = administrador
    @relatorio.status = Relatorio::STATUSES[:pendente]
    @relatorio.nome ||= Relatorio.nome_para(@relatorio.tipo)

    if @relatorio.save
      redirect_to relatorios_path, notice: "Relatório solicitado com sucesso. Quando estiver pronto, ficará mostrado aqui."
    else
      redirect_back fallback_location: root_path,
                    alert: @relatorio.errors.full_messages.to_sentence
    end
  end

  def destroy
    @relatorio = Relatorio.find(params[:id])
    remover_arquivo_anexado!(@relatorio)
    @relatorio.destroy!
    redirect_to relatorios_path, notice: "Relatório excluído com sucesso."
  end

  private

  def remover_arquivo_anexado!(relatorio)
    return unless relatorio.arquivo.attached?

    attachment = relatorio.arquivo.attachment
    blob = attachment&.blob
    attachment&.delete

    return unless blob
    return if ActiveStorage::Attachment.exists?(blob_id: blob.id)

    blob.service.delete(blob.key) if blob.service.exist?(blob.key)
    blob.delete
  rescue StandardError => e
    Rails.logger.warn("[RelatoriosController] Falha ao remover arquivo do relatório ##{relatorio.id}: #{e.message}")
  end

  def relatorio_params
    params.require(:relatorio).permit(:tipo, :nome, filtros: [:data_inicio, :data_fim, :filial_id])
  end
end
