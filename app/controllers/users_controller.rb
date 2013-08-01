class UsersController < ApplicationController
  before_filter :require_login, :except => [:show]

  def show
    @user = User.find(params[:id])
    if logged_in? &&
       current_user == @user
      @balances = {}
      COIND.each do |coinname, coind|
        begin
          begin
          @balances[coinname] = coind.user(current_user.username)
          rescue Jimson::Client::Error::ServerError => e
            logger.info e
            @balances[coinname] = {"error" => "unavailable"}
          end
        rescue Errno::ECONNREFUSED
          @balances[coinname] = {"error" => "not enabled"}
        end
      end

      @transactions = []
      COIND.each do |coinname, coind|
        begin
          tx_resp = coind.transactions(current_user.username)
          if tx_resp["transactions"]
            tx = tx_resp["transactions"].map{|t|
                       t.merge({:currency => SETTINGS["cryptocoins"][coinname]["currency"]})}
            @transactions << tx
          end
        rescue Errno::ECONNREFUSED, Jimson::Client::Error::ServerError => e
          logger.info e
        end
      end
      @transactions.flatten!
    end
  end

  def update
    unless params[:email].blank?
      current_user.email = params[:email]
      if current_user.save
        flash[:success] = "Email updated"
      else
        flash[:error] = current_user.errors.full_messages.join('. ')
      end
    end

    unless params[:old_password].blank?
      if current_user.change_password(params[:old_password], params[:new_password])
        flash[:success] = "Password updated"
      else
        flash[:error] = current_user.errors.full_messages.join('. ')
      end
    end

    redirect_to :action => :show
  end
end
