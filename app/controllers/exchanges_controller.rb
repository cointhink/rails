class ExchangesController < ApplicationController
  def index
    @snapshot = Snapshot.last || Snapshot.new
    @exchanges = Exchange.actives
    @latest_exchanges = @snapshot.exchange_runs.map{|er| er.exchange}
  end

  def show
    @exchange = Exchange.find(params[:id])
  end
end
