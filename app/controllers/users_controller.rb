class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    if logged_in? && current_user == @user
      @balances = {}
      COIND.each do |coinname, coind|
        begin
          @balances[coinname] = coind.user(@user.username)
        rescue Errno::ECONNREFUSED
          {"error" => "not available"}
        end
      end
    end
  end
end
