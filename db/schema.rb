# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_08_30_122347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "acessos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "administrador_grupo_acessos", force: :cascade do |t|
    t.bigint "administrador_id", null: false
    t.bigint "grupo_acesso_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["administrador_id"], name: "index_administrador_grupo_acessos_on_administrador_id"
    t.index ["grupo_acesso_id"], name: "index_administrador_grupo_acessos_on_grupo_acesso_id"
  end

  create_table "administradores", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "senha"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ajuste_programados", force: :cascade do |t|
    t.string "nome"
    t.bigint "filial_id", null: false
    t.string "percentual_reajuste"
    t.string "arredondamento"
    t.string "status"
    t.bigint "administrador_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["administrador_id"], name: "index_ajuste_programados_on_administrador_id"
    t.index ["filial_id"], name: "index_ajuste_programados_on_filial_id"
  end

  create_table "estoques", force: :cascade do |t|
    t.bigint "filial_id", null: false
    t.bigint "produto_id", null: false
    t.string "acao"
    t.date "lancamento"
    t.integer "quantidade"
    t.string "valor_unitario"
    t.string "valor_total"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "validade"
    t.index ["filial_id"], name: "index_estoques_on_filial_id"
    t.index ["produto_id"], name: "index_estoques_on_produto_id"
  end

  create_table "filiais", force: :cascade do |t|
    t.string "nome_fantasia"
    t.string "razao_social"
    t.string "cpf_cnpj"
    t.string "contato"
    t.string "responsavel"
    t.string "email"
    t.string "codigo_regime_tributario"
    t.string "inscricao_estadual"
    t.string "inscricao_municipal"
    t.string "tipo_negocio"
    t.string "detalhes"
    t.string "telefone"
    t.string "celular"
    t.string "cep"
    t.string "endereco"
    t.string "numero"
    t.string "bairro"
    t.string "estado"
    t.string "cidade"
    t.string "codigo_ibge"
    t.string "observacoes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "filial_produtos", force: :cascade do |t|
    t.bigint "filial_id", null: false
    t.bigint "produto_id", null: false
    t.string "valor"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantidade_alerta"
    t.integer "quantidade_minima"
    t.string "status", default: "ATIVO"
    t.index ["filial_id"], name: "index_filial_produtos_on_filial_id"
    t.index ["produto_id"], name: "index_filial_produtos_on_produto_id"
  end

  create_table "financeiros", force: :cascade do |t|
    t.string "local"
    t.date "data"
    t.string "valor"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "forma_pagamentos", force: :cascade do |t|
    t.string "nome"
    t.string "classificacao"
    t.string "permite_troco"
    t.string "conta_assinada"
    t.string "abre_gaveta"
    t.string "dias_acerto_caixa"
    t.string "ativo"
    t.string "auto_atendimento"
    t.string "meio_pagamento_integrado"
    t.string "categoria_receita"
    t.string "conta_bancaria_receita"
    t.string "categoria_desapesa"
    t.string "conta_bancaria_despesa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "grupo_acessos", force: :cascade do |t|
    t.string "nome"
    t.string "acessos"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "grupo_produtos", force: :cascade do |t|
    t.string "nome"
    t.string "status"
    t.string "grupo_consumacao"
    t.string "fracionado"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "produtos", force: :cascade do |t|
    t.string "descricao_cupom"
    t.bigint "grupo_produto_id", null: false
    t.string "codigo_venda"
    t.string "codigo_ncm"
    t.string "codigo_cast"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
    t.string "preco"
    t.integer "quantidade_alerta"
    t.integer "quantidade_minima"
    t.text "imagem"
    t.index ["grupo_produto_id"], name: "index_produtos_on_grupo_produto_id"
  end

  create_table "venda_produtos", force: :cascade do |t|
    t.bigint "venda_id", null: false
    t.bigint "produto_id", null: false
    t.integer "quantidade"
    t.string "valor_unitario"
    t.string "valor_total"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "total_estoque"
    t.index ["produto_id"], name: "index_venda_produtos_on_produto_id"
    t.index ["venda_id"], name: "index_venda_produtos_on_venda_id"
  end

  create_table "vendas", force: :cascade do |t|
    t.bigint "filial_id", null: false
    t.string "nome"
    t.string "metodo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "valor"
    t.index ["filial_id"], name: "index_vendas_on_filial_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "administrador_grupo_acessos", "administradores"
  add_foreign_key "administrador_grupo_acessos", "grupo_acessos"
  add_foreign_key "ajuste_programados", "administradores"
  add_foreign_key "ajuste_programados", "filiais"
  add_foreign_key "estoques", "filiais"
  add_foreign_key "estoques", "produtos"
  add_foreign_key "filial_produtos", "filiais"
  add_foreign_key "filial_produtos", "produtos"
  add_foreign_key "produtos", "grupo_produtos"
  add_foreign_key "venda_produtos", "produtos"
  add_foreign_key "venda_produtos", "vendas"
  add_foreign_key "vendas", "filiais"
end
