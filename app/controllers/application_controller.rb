class ApplicationController < ActionController::Base
  protect_from_forgery

  helper NanoAuth # available in views
  include NanoAuth # available in controllers

  before_filter :auth
end
