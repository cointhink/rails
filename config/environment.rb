# Load the rails application
require File.expand_path('../application', __FILE__)

Slim::Engine.set_default_options(pretty: true)

# Initialize the rails application
Btcmarketwatch::Application.initialize!
