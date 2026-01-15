class CreateFiliais < ActiveRecord::Migration[6.1]
  def change
    create_table :filiais do |t|
      t.string :nome_fantasia
      t.string :razao_social
      t.string :cpf_cnpj
      t.string :contato
      t.string :responsavel
      t.string :email
      t.string :codigo_regime_tributario
      t.string :inscricao_estadual
      t.string :inscricao_municipal
      t.string :tipo_negocio
      t.string :detalhes
      t.string :telefone
      t.string :celular
      t.string :cep
      t.string :endereco
      t.string :numero
      t.string :bairro
      t.string :estado
      t.string :cidade
      t.string :codigo_ibge
      t.string :observacoes

      t.timestamps
    end
  end
end
