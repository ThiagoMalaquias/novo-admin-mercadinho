class Relatorios::Gerar::FormasRecebimentoService < Relatorios::Gerar::BaseService
  CORES_METODO = {
    "CREDITO" => "5B98B6",
    "DEBITO" => "FF6600",
    "PIX" => "5A736F",
    "VA SODEXO" => "FDD752"
  }.freeze

  COR_PRIMARIA = "1E3A8A".freeze
  COR_SECUNDARIA = "2563EB".freeze
  COR_CLARA = "DBEAFE".freeze
  COR_ZEBRA = "F3F4F6".freeze
  COR_BORDA = "D1D5DB".freeze

  def call!
    vendas = buscar_vendas

    with_tempfile("formas_recebimento") do |tempfile|
      package = Axlsx::Package.new
      package.use_shared_strings = true

      package.workbook.add_worksheet(name: "Formas de Recebimento") do |sheet|
        estilos = criar_estilos(package.workbook.styles)

        adicionar_cabecalho(sheet, estilos)
        adicionar_resumo(sheet, estilos, vendas)
        adicionar_lista_vendas(sheet, estilos, vendas)

        sheet.column_widths 20, 14, 32, 16, 18, 14
        sheet.sheet_view.show_grid_lines = false
        sheet.page_setup.set(orientation: :landscape, fit_to_width: 1, fit_to_height: 0)
      end

      package.serialize(tempfile.path)
      anexar_e_finalizar!(tempfile, nome_arquivo)
    end

    relatorio
  end

  private

  def buscar_vendas
    scope = Venda.periodo_data(filtros["data_inicio"], filtros["data_fim"])
    scope = scope.where(filial_id: filtros["filial_id"]) if filtros["filial_id"].present?
    scope
  end

  def adicionar_cabecalho(sheet, estilos)
    sheet.add_row ["Relatório de Formas de Recebimento", nil, nil, nil, nil, nil], style: estilos[:titulo], height: 36
    sheet.merge_cells "A1:F1"

    sheet.add_row ["Período", periodo_formatado, nil, nil, nil, nil], style: [estilos[:rotulo], estilos[:info], estilos[:info], estilos[:info], estilos[:info], estilos[:info]], height: 20
    sheet.merge_cells "B2:F2"

    sheet.add_row ["Filial", nome_filial, nil, nil, nil, nil], style: [estilos[:rotulo], estilos[:info], estilos[:info], estilos[:info], estilos[:info], estilos[:info]], height: 20
    sheet.merge_cells "B3:F3"

    sheet.add_row ["Gerado em", Time.current.strftime("%d/%m/%Y %H:%M"), nil, nil, nil, nil], style: [estilos[:rotulo], estilos[:info], estilos[:info], estilos[:info], estilos[:info], estilos[:info]], height: 20
    sheet.merge_cells "B4:F4"

    sheet.add_row []
  end

  def adicionar_resumo(sheet, estilos, vendas)
    linha_secao = sheet.rows.size + 1
    sheet.add_row ["Resumo por Método", nil, nil, nil, nil, nil], style: estilos[:secao], height: 26
    sheet.merge_cells "A#{linha_secao}:F#{linha_secao}"

    sheet.add_row ["Método", "Qtd. Vendas", "Valor", "Percentual"],
                  style: [estilos[:header], estilos[:header_centro], estilos[:header_direita], estilos[:header_direita]],
                  height: 22

    total_valor = vendas.sum(:valor).to_f
    total_qtd = vendas.count
    quantidades = vendas.group(:metodo).count
    valores = vendas.group(:metodo).sum(:valor)

    valores.sort_by { |_, valor| -valor }.each do |metodo, valor|
      percentual = total_valor.positive? ? valor / total_valor : 0
      estilo_metodo = estilos[:metodos][metodo] || estilos[:texto]

      sheet.add_row [metodo, quantidades[metodo].to_i, valor / 100.0, percentual],
                    style: [estilo_metodo, estilos[:inteiro], estilos[:moeda], estilos[:percentual]],
                    height: 20
    end

    sheet.add_row ["TOTAL", total_qtd, total_valor / 100.0, total_valor.positive? ? 1 : 0],
                  style: [estilos[:total_rotulo], estilos[:total_inteiro], estilos[:total_moeda], estilos[:total_percentual]],
                  height: 22

    sheet.add_row []
    sheet.add_row []
  end

  def adicionar_lista_vendas(sheet, estilos, vendas)
    linha_secao = sheet.rows.size + 1
    sheet.add_row ["Lista de Vendas", nil, nil, nil, nil, nil], style: estilos[:secao], height: 26
    sheet.merge_cells "A#{linha_secao}:F#{linha_secao}"

    sheet.add_row ["Data", "Nº Venda", "Filial", "Método", "Valor", "Nº Produtos"],
                  style: [estilos[:header], estilos[:header_centro], estilos[:header], estilos[:header_centro], estilos[:header_direita], estilos[:header_centro]],
                  height: 22

    linha_inicial = sheet.rows.size + 1
    total_valor = 0

    vendas.includes(:filial, :produtos).order(created_at: :desc).each_with_index do |venda, indice|
      zebra = indice.odd?
      total_valor += venda.valor.to_i

      sheet.add_row [
        venda.created_at.strftime("%d/%m/%Y %H:%M"),
        venda.id,
        venda.filial&.nome_fantasia,
        venda.metodo,
        venda.valor / 100.0,
        venda.produtos.size
      ], style: [
        estilos[zebra ? :texto_zebra : :texto],
        estilos[zebra ? :centro_zebra : :centro],
        estilos[zebra ? :texto_zebra : :texto],
        estilos[zebra ? :centro_zebra : :centro],
        estilos[zebra ? :moeda_zebra : :moeda],
        estilos[zebra ? :centro_zebra : :centro]
      ], height: 18
    end

    if sheet.rows.size >= linha_inicial
      linha_final = sheet.rows.size
      sheet.auto_filter = "A#{linha_inicial - 1}:F#{linha_final}"
      sheet.add_row ["TOTAL", nil, nil, nil, total_valor / 100.0, nil],
                    style: [estilos[:total_rotulo], estilos[:total_rotulo], estilos[:total_rotulo], estilos[:total_rotulo], estilos[:total_moeda], estilos[:total_rotulo]],
                    height: 22
    else
      linha_vazia = sheet.rows.size + 1
      sheet.add_row ["Nenhuma venda encontrada para o período selecionado.", nil, nil, nil, nil, nil], style: estilos[:vazio], height: 24
      sheet.merge_cells "A#{linha_vazia}:F#{linha_vazia}"
    end
  end

  def criar_estilos(styles)
    borda = { style: :thin, color: COR_BORDA }
    base = { font_name: "Calibri", sz: 11, border: borda, alignment: { vertical: :center } }
    moeda = "[$R$-416] #,##0.00"

    estilos = {
      titulo: styles.add_style(font_name: "Calibri", sz: 18, b: true, fg_color: "FFFFFF", bg_color: COR_PRIMARIA,
                               alignment: { horizontal: :center, vertical: :center }),
      rotulo: styles.add_style(font_name: "Calibri", sz: 11, b: true, fg_color: COR_PRIMARIA, bg_color: COR_CLARA,
                               border: borda, alignment: { vertical: :center, indent: 1 }),
      info: styles.add_style(font_name: "Calibri", sz: 11, fg_color: "111827", border: borda,
                             alignment: { vertical: :center, indent: 1 }),
      secao: styles.add_style(font_name: "Calibri", sz: 13, b: true, fg_color: "FFFFFF", bg_color: COR_SECUNDARIA,
                              alignment: { vertical: :center, indent: 1 }),
      header: styles.add_style(base.merge(b: true, fg_color: COR_PRIMARIA, bg_color: COR_CLARA)),
      header_centro: styles.add_style(base.merge(b: true, fg_color: COR_PRIMARIA, bg_color: COR_CLARA,
                                                 alignment: { horizontal: :center, vertical: :center })),
      header_direita: styles.add_style(base.merge(b: true, fg_color: COR_PRIMARIA, bg_color: COR_CLARA,
                                                  alignment: { horizontal: :right, vertical: :center })),
      texto: styles.add_style(base),
      texto_zebra: styles.add_style(base.merge(bg_color: COR_ZEBRA)),
      centro: styles.add_style(base.merge(alignment: { horizontal: :center, vertical: :center })),
      centro_zebra: styles.add_style(base.merge(bg_color: COR_ZEBRA, alignment: { horizontal: :center, vertical: :center })),
      inteiro: styles.add_style(base.merge(num_fmt: 3, alignment: { horizontal: :center, vertical: :center })),
      moeda: styles.add_style(base.merge(format_code: moeda)),
      moeda_zebra: styles.add_style(base.merge(format_code: moeda, bg_color: COR_ZEBRA)),
      percentual: styles.add_style(base.merge(format_code: "0.0%")),
      total_rotulo: styles.add_style(base.merge(b: true, fg_color: "FFFFFF", bg_color: COR_PRIMARIA)),
      total_inteiro: styles.add_style(base.merge(b: true, fg_color: "FFFFFF", bg_color: COR_PRIMARIA, num_fmt: 3,
                                                 alignment: { horizontal: :center, vertical: :center })),
      total_moeda: styles.add_style(base.merge(b: true, fg_color: "FFFFFF", bg_color: COR_PRIMARIA, format_code: moeda)),
      total_percentual: styles.add_style(base.merge(b: true, fg_color: "FFFFFF", bg_color: COR_PRIMARIA, format_code: "0.0%")),
      vazio: styles.add_style(font_name: "Calibri", sz: 11, i: true, fg_color: "6B7280",
                              alignment: { horizontal: :center, vertical: :center })
    }

    estilos[:metodos] = CORES_METODO.transform_values do |cor|
      texto_escuro = cor == "FDD752"
      styles.add_style(base.merge(b: true, bg_color: cor, fg_color: texto_escuro ? "111827" : "FFFFFF"))
    end

    estilos
  end

  def periodo_formatado
    inicio = formatar_data(filtros["data_inicio"])
    fim = formatar_data(filtros["data_fim"])
    [inicio, fim].compact.join(" a ").presence || "Todo o período"
  end

  def formatar_data(data)
    return if data.blank?

    Date.parse(data.to_s).strftime("%d/%m/%Y")
  rescue ArgumentError
    data.to_s
  end

  def nome_filial
    return "Todas as Filiais" if filtros["filial_id"].blank?

    Filial.find_by(id: filtros["filial_id"])&.nome_fantasia || "Filial ##{filtros['filial_id']}"
  end

  def nome_arquivo
    periodo = [filtros["data_inicio"], filtros["data_fim"]].compact.join("_a_")
    "formas_recebimento_#{periodo}_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
  end
end
