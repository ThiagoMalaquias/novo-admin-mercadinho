json.extract! filial, :id, :nome_fantasia, :razao_social, :cpf_cnpj, :contato, :responsavel, :email, :codigo_regime_tributario, :inscricao_estadual, :inscricao_municipal, :tipo_negocio, :detalhes, :telefone, :celular, :cep, :endereco, :numero, 
              :bairro, :estado, :cidade, :codigo_ibge, :observacoes, :created_at, :updated_at
json.url filial_url(filial, format: :json)
