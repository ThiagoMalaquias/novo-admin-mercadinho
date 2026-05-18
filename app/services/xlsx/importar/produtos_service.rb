class Xlsx::Importar::ProdutosService
  attr_reader :arquivo

  def initialize(arquivo)
    @arquivo = arquivo
  end

  def call!
    validar_arquivo!

    workbook = SimpleXlsxReader.open(caminho_arquivo)
    worksheets = workbook.sheets
    raise "Não foi encontrado registro no arquivo enviado" if worksheets.count < 1

    worksheets.each do |worksheet|
      worksheet.rows.each do |line|
        importar_linha(line)
      end
    end
  end

  private

  def validar_arquivo!
    raise "Arquivo não encontrado: #{caminho_arquivo}" unless File.exist?(caminho_arquivo)
    raise "Formato de arquivo não suportado, por favor selecione arquivos com a extensão xlsx" unless nome_arquivo.downcase.end_with?(".xlsx")
  end

  def caminho_arquivo
    @caminho_arquivo ||= if arquivo.respond_to?(:tempfile)
                           arquivo.tempfile.path
                         else
                           arquivo.to_s
                         end
  end

  def nome_arquivo
    if arquivo.respond_to?(:original_filename)
      arquivo.original_filename
    else
      File.basename(caminho_arquivo)
    end
  end

  def importar_linha(linha)
    descricao_cupom = 0
    grupo_produto = 1
    codigo_barras = 2
    codigo_ncm = 3
    codigo_cast = 4
    preco = 5
    quantidade_alerta = 6
    quantidade_minima = 7
    status = 8

    return if linha[descricao_cupom].nil?
    return if linha[descricao_cupom].to_s.upcase == "DESCRIÇÃO DO CUPOM"

    produto = Produto.find_or_create_by(descricao_cupom: linha[descricao_cupom])
    produto.grupo_produto_id = GrupoProduto.find_or_create_by(nome: linha[grupo_produto]).id
    produto.codigo_venda = linha[codigo_barras]
    produto.codigo_ncm = linha[codigo_ncm]
    produto.codigo_cast = linha[codigo_cast]
    produto.preco = parse_preco(linha[preco])
    produto.quantidade_alerta = linha[quantidade_alerta].present? ? linha[quantidade_alerta].to_i : 20
    produto.quantidade_minima = linha[quantidade_minima].present? ? linha[quantidade_minima].to_i : 10
    produto.status = linha[status].present? ? linha[status].to_s.upcase : "ATIVO"
    produto.save!
  rescue StandardError => e
    Rails.logger.error("[ImportarProdutos] Linha #{linha.inspect}: #{e.message}")
    raise e
  end

  def parse_preco(valor)
    return 0 if valor.blank?

    reais = if valor.is_a?(Numeric)
              valor.to_f
            elsif valor.to_s.include?(",")
              Conversao.convert_comma_to_float(valor.to_s.gsub("R$", "").strip)
            else
              valor.to_s.gsub("R$", "").strip.to_f
            end

    (reais * 100).round
  end
end
