class SessionController < ApplicationController
  def lookup
    user = User.where(email:params[:email]).first
    if user
      redirect_to :login, {:email => params[:email]}
    else
      redirect_to :signup
    end
  end
end
