Btcmarketwatch::Application.routes.draw do
  root :to => 'dash#menu'

  resources :exchanges
  resources :strategies

  get '/blog/' => 'blog#index'
  get '/blog/post' => 'blog#create'
  get '/blog/:slug' => 'blog#show'
  post '/blog' => 'blog#create'
  match '/arbitrage/:pair' => 'dash#chart'
  match '/arbitrage' => 'dash#chart'
  match '/markets/:pair' => 'dash#slider'
  get '/site/tos' => 'dash#tos'
  get '/site/fees' => 'dash#fees'

  post '/session/create' => 'session#create'
  match '/session/lookup' => 'session#lookup'
  match '/session/login' => 'session#login'
  match '/session/logout' => 'session#logout'
  match '/session/signup' => 'session#signup'

  post '/scripts' => 'scripts#create'
  match '/scripts' => 'scripts#manage'
  match '/scripts/leaderboard' => 'scripts#leaderboard'
  match '/scripts/docs(/*path)' => 'scripts#docs'

  get '/:id' => 'users#show'
  post '/:id' => 'users#update'
  get '/:username/:scriptname' => 'scripts#lastrun'
  delete '/:username/:scriptname' => 'scripts#delete'
  put '/:username/:scriptname' => 'scripts#update'
  get '/:username/:scriptname/edit' => 'scripts#edit'
  get '/:username/:scriptname/enable' => 'scripts#showenable'
  post '/:username/:scriptname/start' => 'scripts#start'
  post '/:username/:scriptname/stop' => 'scripts#stop'
  post '/:username/:scriptname/reset' => 'scripts#reset'
  post '/:username/:scriptname/enable' => 'scripts#enable'

  match '*nowhere' => 'dash#fourohfour'
end
