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
  match '/scripts' => 'scripts#manage'
  match '/scripts/leaderboard' => 'scripts#leaderboard'

  get '/:id' => 'users#show'
  get '/:username/:scriptname' => 'scripts#lastrun'
  delete '/:username/:scriptname' => 'scripts#delete'
  put '/:username/:scriptname' => 'scripts#update'
  get '/:username/:scriptname/edit' => 'scripts#edit'
  post '/:username/:scriptname/start' => 'scripts#start'
  post '/:username/:scriptname/stop' => 'scripts#stop'
  post '/:username/:scriptname/reset' => 'scripts#reset'

  match '*nowhere' => 'dash#fourohfour'
end
