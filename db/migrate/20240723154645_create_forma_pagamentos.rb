class CreateFormaPagamentos < ActiveRecord::Migration[6.1]
  def change
    create_table :forma_pagamentos do |t|
      t.string :nome
      t.string :classificacao
      t.string :permite_troco
      t.string :conta_assinada
      t.string :abre_gaveta
      t.string :dias_acerto_caixa
      t.string :ativo
      t.string :auto_atendimento
      t.string :meio_pagamento_integrado
      t.string :categoria_receita
      t.string :conta_bancaria_receita
      t.string :categoria_desapesa
      t.string :conta_bancaria_despesa

      t.timestamps
    end
  end
end
