class SessionController < ApplicationController
  def lookup
    user = User.where(username:params[:username]).first
    if user
      redirect_to({:action => :login, :username => params[:username]})
    else
      redirect_to({:action => :signup, :username => params[:username]})
    end
  end

  def create
    user = User.where(username:params[:username]).first
    if user
      if user.authentic?(params[:password])
        logger.info("before #{session.inspect}")
        log_in(user.id)
        logger.info("after #{session.inspect}")
        flash[:success] = "Welcome back, #{user.username}"
        redirect_to root_url
      else
        flash[:error] = "Bad password"
        redirect_to({:action => :login, :username => params[:username]})
      end
    else
      matching_routes = Rails.application.routes.routes.simulator.simulate("/#{params[:username]}")
      if matching_routes.memos && matching_routes.memos.size == 1 # exactly one route
        user = User.safe_create(params)
        if user.valid?
          log_in(user.id)
          redirect_to :root, :notice => "Welcome, #{user.username}"
        else
          flash[:error] = user.errors.full_messages.join('. ')
          redirect_to({:action => :signup, :username => params[:username],
                                           :email => params[:email]})
        end
      else
          flash[:error] = "That username is not allowed. Please pick another."
          redirect_to({:action => :signup, :username => params[:username],
                                           :email => params[:email]})        
      end
    end
  end

  def logout
    log_out()
    flash[:success] = "Logged out."
    redirect_to :root
  end
end
