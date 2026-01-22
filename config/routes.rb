Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :produtos
      resources :grupo_produtos
      resources :login do
        post "sign_in", on: :collection
      end
    end
  end

  resources :financeiros
  resources :vendas
  resources :estoques do
    post "importar", on: :collection
  end
  resources :ajuste_programados
  resources :forma_pagamentos
  resources :produtos do
    get "por_codigo_barras", on: :collection
  end
  resources :grupo_produtos
  resources :filiais do
    resources :filial_produtos do
      get "alterar_status", on: :member
    end
  end
  resources :administradores
  resources :grupo_acessos

  root to: 'home#index'

  get "/produtos_mais_vendidos", to: 'home#produtos_mais_vendidos'
  get "/formas_recebimento", to: 'home#formas_recebimento'
  get "/faturamento_filial", to: 'home#faturamento_filial'
  get "/consumo_produtos", to: 'home#consumo_produtos'

  get '/login', to: 'login#index'
  post '/logar', to: 'login#logar'
  get '/sair', to: 'login#deslogar'
end
