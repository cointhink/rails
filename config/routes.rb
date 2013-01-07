Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#chart'
  resources :exchanges
  match '/pairs' => 'dash#pairs'
  match '*nowhere' => 'dash#fourohfour'
end
