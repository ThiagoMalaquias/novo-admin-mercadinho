class Relatorios::Gerar::BaseService
  attr_reader :relatorio

  def initialize(relatorio)
    @relatorio = relatorio
  end

  def call!
    raise NotImplementedError
  end

  private

  def filtros
    relatorio.filtros || {}
  end

  def anexar_e_finalizar!(tempfile, filename)
    relatorio.arquivo.attach(
      io: File.open(tempfile.path),
      filename: filename,
      content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    relatorio.update!(
      status: Relatorio::STATUSES[:concluido],
      arquivo_nome: filename,
      arquivo_url: blob_url,
      processado_em: Time.current,
      erro_mensagem: nil
    )
  end

  def blob_url
    host = Rails.application.routes.default_url_options[:host].presence ||
           ENV.fetch("APP_HOST", "localhost:3001")

    Rails.application.routes.url_helpers.rails_blob_url(
      relatorio.arquivo,
      host: host,
      protocol: host.include?("localhost") ? "http" : "https"
    )
  end

  def with_tempfile(prefix)
    tempfile = Tempfile.new([prefix, ".xlsx"])
    tempfile.binmode
    yield tempfile
  ensure
    tempfile&.close
    tempfile&.unlink
  end
end
