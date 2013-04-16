Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#chart'
  resources :exchanges
  resources :strategies
  match '/markets/:pair' => 'dash#slider'
  match '/pairs' => 'dash#pairs'
  match '/session/lookup' => 'session#lookup'
  match '/session/login' => 'session#login'
  match '/session/signup' => 'session#signup'
  match '*nowhere' => 'dash#fourohfour'
end
