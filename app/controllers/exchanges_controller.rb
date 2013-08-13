class ExchangesController < ApplicationController
  def index
    @snapshot = Snapshot.last || Snapshot.new
    @exchanges = []
    if @snapshot
      latest_exchanges = @snapshot.exchange_runs.map{|er| er.exchange}
      @exchanges = Exchange.with_markets('btc','usd').map do |m|
        e = {:exchange => m[:exchange], :cost => 0} #descriptive data
        if latest_exchanges.include?(m[:exchange])
          exchange_runs = @snapshot.exchange_runs.select{|er| er.exchange == m[:exchange]}.first
          e[:depth_runs] = exchange_runs.depth_runs.reduce({}){|m,dr| m[dr.market.bidask('usd')]=dr.cost;m}
          e[:cost] = e[:depth_runs].values.sum{|cost| cost.amount.to_f}
        end
        e
      end
      @exchanges.sort_by!{|e| e[:cost]}.reverse!
    end
  end
  def show
    @exchange = Exchange.find(params[:id])
  end
end
