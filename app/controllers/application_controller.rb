class ApplicationController < ActionController::Base
  protect_from_forgery

  helper NanoAuth # available in views
  include NanoAuth # available in controllers
  include Routy

  before_filter :auth
end
