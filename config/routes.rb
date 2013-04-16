Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#chart'
  resources :exchanges
  resources :strategies
  resources :users
  match '/markets/:pair' => 'dash#slider'
  match '/pairs' => 'dash#pairs'
  post '/session/create' => 'session#create'
  match '/session/lookup' => 'session#lookup'
  match '/session/login' => 'session#login'
  match '/session/logout' => 'session#logout'
  match '/session/signup' => 'session#signup'
  match '*nowhere' => 'dash#fourohfour'
end
