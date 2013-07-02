class ApplicationController < ActionController::Base
  protect_from_forgery

  helper NanoAuth # available in views
  include NanoAuth # available in controllers
  include Routy

  before_filter :auth

  # a valid route, with an invalid accepts header (image/*) causes this
  rescue_from  ActionView::MissingTemplate, :with => :missing_template

  def missing_template
    render :nothing => true, :status => 406
  end
end
