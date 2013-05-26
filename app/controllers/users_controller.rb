class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @balances = COIND.map do |name, coind|
      begin
        coind.user(@user.username).merge({"name"=>name})
      rescue Errno::ECONNREFUSED
        {"error" => "not available"}
      end
    end
  end
end
