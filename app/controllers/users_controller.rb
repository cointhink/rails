class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @balances = COIND.map do |name, coind|
      info = coind.balance(@user.username)
      {"name" => name, "balance" => info["balance"]}
    end
  end
end
