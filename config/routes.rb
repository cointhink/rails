Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#chart'
  resources :exchanges
  resources :strategies
  match '/markets/:pair' => 'dash#slider'
  match '/pairs' => 'dash#pairs'
  match '*nowhere' => 'dash#fourohfour'
end
