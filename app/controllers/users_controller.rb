class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    if logged_in? && current_user == @user
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
            @transactions << ["transactions"]
          end
        rescue Errno::ECONNREFUSED, Jimson::Client::Error::ServerError => e
          logger.info e
        end
      end
      @transactions.flatten!
    end
  end
end
