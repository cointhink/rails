Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#menu'

  resources :exchanges
  resources :strategies

  match '/arbitrage/:pair' => 'dash#chart'
  match '/arbitrage' => 'dash#chart'
  match '/markets/:pair' => 'dash#slider'
  match '/pairs' => 'dash#pairs'

  post '/session/create' => 'session#create'
  match '/session/lookup' => 'session#lookup'
  match '/session/login' => 'session#login'
  match '/session/logout' => 'session#logout'
  match '/session/signup' => 'session#signup'

  post '/scripts' => 'scripts#create'
  match '/scripts' => 'scripts#list'

  match '/:id' => 'users#show'
  match '/:username/:scriptname' => 'scripts#lastrun'
  match '/:username/:id/edit' => 'scripts#edit'

  match '*nowhere' => 'dash#fourohfour'
end
