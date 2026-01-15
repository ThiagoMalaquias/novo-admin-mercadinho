class Estoque < ApplicationRecord
  belongs_to :filial
  belongs_to :produto

  scope :entradas, -> { where(acao: "entrada") }
  scope :saidas, -> { where(acao: "saida") }

  def self.calculo_valor_total(estoques)
    return 0 unless estoques.count.positive?

    entradas = estoques.entradas
    saidas = estoques.saidas

    valor_total_entrada = entradas.sum do |entrada|
      Conversao.convert_comma_to_float(entrada.valor_total)
    end

    valor_total_saida = saidas.sum do |saida|
      Conversao.convert_comma_to_float(saida.valor_total)
    end

    valor_total_entrada - valor_total_saida
  end
end
