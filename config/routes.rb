Btcmarketwatch::Application.routes.draw do
  resources :exchanges
  root :to => 'dash#chart'
end
