class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @balances = COIND.map do |name, coind|
      coin_record = {"name" => name}
      begin
      info = coind.balance(@user.username)
      coin_record["balance"] = info["balance"]
      rescue Errno::ECONNREFUSED
        coin_record["error"] = "not available"
      end
      coin_record
    end
  end
end
