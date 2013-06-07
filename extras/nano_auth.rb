module NanoAuth
  private
  def current_user
    @current_user
  end

  def log_in(user)
    @current_user = user
    session[:logged_in_user_id] = user.id
  end

  def log_out
    @current_user = nil
    session[:logged_in_user_id] = nil
  end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to root_path
    end
  end

  def logged_in?
    !!@current_user
  end

  def auth
    id = session[:logged_in_user_id]
    if id
      begin
        log_in(User.find(id))
        logger.info("Login: #{current_user.username.inspect} #{current_user.email.inspect} User##{current_user.id}")
      rescue ActiveRecord::RecordNotFound
        logger.info("session user id of #{id} is bogus. removing")
        session[:logged_in_user_id] = nil
        return false
      end
    end
  end
end
