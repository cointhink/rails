Btcmarketwatch::Application.routes.draw do
  resources :exchanges
  match '/pairs' => 'dash#pairs'
  root :to => 'dash#chart'
end
