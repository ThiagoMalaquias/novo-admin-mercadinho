namespace :relatorios do
  desc "Processa relatórios pendentes (gera XLSX, envia para AWS e grava o link)"
  task processar: :environment do
    pendentes = Relatorio.pendentes.to_a

    if pendentes.empty?
      puts "[relatorios:processar] Nenhum relatório pendente."
    else
      puts "[relatorios:processar] #{pendentes.size} relatório(s) pendente(s)."

      pendentes.each do |relatorio|
        puts "[relatorios:processar] Processando ##{relatorio.id} (#{relatorio.tipo})..."
        begin
          relatorio.processar!
          puts "[relatorios:processar] ##{relatorio.id} concluído → #{relatorio.arquivo_url}"
        rescue StandardError => e
          puts "[relatorios:processar] ##{relatorio.id} erro: #{e.message}"
        end
      end

      puts "[relatorios:processar] Finalizado."
    end
  end
end
