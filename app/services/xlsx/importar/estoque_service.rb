class Xlsx::Importar::EstoqueService
  attr_accessor :arquivo

  def initialize(arquivo)
    @arquivo = arquivo
  end

  def call!
    raise "Formato de arquivo não suportado, por favor seleciona arquivos com a extenção xlsx" unless File.basename(arquivo.tempfile).include?(".xlsx")

    workbook = SimpleXlsxReader.open(arquivo.tempfile)
    worksheets = workbook.sheets
    raise "Não foi encontrado registro no arquivo enviado" if worksheets.count < 1

    ActiveRecord::Base.transaction do
      worksheets.each do |worksheet|
        worksheet.rows.each do |line|
          importar_linha(line)
        end
      end
    end
  end

  private

  def importar_linha(linha)
    cod_filial = 0
    cod_produto = 1
    acao = 2 
    lancamento = 3
    quantidade = 4
    valor_unitario = 5

    return if linha[cod_filial] == "Código Filial" || linha[cod_filial].nil? rescue return

    estoque = Estoque.new
    estoque.filial_id = linha[cod_filial].to_i.to_s
    estoque.produto_id = linha[cod_produto].to_i.to_s
    estoque.acao = linha[acao].to_s
    estoque.lancamento = linha[lancamento]
    estoque.quantidade = linha[quantidade].to_i
    estoque.valor_unitario = Conversao.convert_comma_to_float(linha[valor_unitario]) * 100.0
    estoque.valor_total = valor_total(linha[quantidade], linha[valor_unitario])
    estoque.save!
  end

  def valor_total(quantidade, valor_unitario)
    total = Conversao.convert_comma_to_float(valor_unitario) * quantidade
    total * 100.0
  end
end
