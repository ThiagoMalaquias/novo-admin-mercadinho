class Relatorio < ApplicationRecord
  belongs_to :administrador, optional: true
  has_one_attached :arquivo

  TIPOS = {
    produtos_mais_vendidos: "produtos_mais_vendidos"
  }.freeze

  NOMES = {
    produtos_mais_vendidos: "Produtos mais vendidos"
  }.freeze

  STATUSES = {
    pendente: "pendente",
    processando: "processando",
    concluido: "concluido",
    erro: "erro"
  }.freeze

  validates :tipo, presence: true, inclusion: { in: TIPOS.values }
  validates :status, presence: true, inclusion: { in: STATUSES.values }

  before_validation :definir_nome, on: :create

  scope :pendentes, -> { where(status: STATUSES[:pendente]).order(:created_at) }
  scope :recentes, -> { order(created_at: :desc) }

  def pendente?
    status == STATUSES[:pendente]
  end

  def concluido?
    status == STATUSES[:concluido]
  end

  def link_download
    if arquivo.attached?
      return Rails.application.routes.url_helpers.rails_blob_path(
        arquivo,
        disposition: "attachment",
        only_path: true
      )
    end

    arquivo_url.presence
  end

  def processar!
    update!(status: STATUSES[:processando], erro_mensagem: nil)
    service_class.new(self).call!
  rescue StandardError => e
    update!(status: STATUSES[:erro], erro_mensagem: e.message, processado_em: Time.current)
    raise
  end

  def self.nome_para(tipo)
    NOMES[tipo.to_sym] || tipo.to_s.humanize
  end

  private

  def definir_nome
    self.nome = self.class.nome_para(tipo) if nome.blank?
  end

  def service_class
    case tipo
    when TIPOS[:produtos_mais_vendidos]
      Relatorios::Gerar::ProdutosMaisVendidosService
    else
      raise "Tipo de relatório não suportado: #{tipo}"
    end
  end
end
