class ExchangesController < ApplicationController

  def show
    @exchange = Exchange.where(:name => params[:id]).first
  end
end
