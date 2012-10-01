class ExchangesController < ApplicationController

  def show
    @exchange = Exchange.find_by_name(params[:id])
    redirect_to root_path unless @exchange
  end
end
