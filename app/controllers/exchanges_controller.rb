class ExchangesController < ApplicationController
  def index
    @snapshot = Snapshot.last || Snapshot.new
    @exchanges = Exchange.actives
    @latest_exchanges = @snapshot.exchange_runs.map{|er| er.exchange}
  end

  def show
    @exchange = Exchange.find(params[:id])
  end

  def orderbook
    time = Time.parse(params[:date])
    if time
      e = Exchange.find(params[:exchange])
      if e
        from, to = params[:market].split(':')
        m1 = e.markets.where(['from_currency = ? and to_currency = ?', from, to]).first
        if m1
          m2 = m1.pair
          run1 = m1.depth_runs.includes(:exchange_run).where('created_at <= ?', time).order('created_at desc').limit(1).first
          if run1
            erun = run1.exchange_run
            run2 = m2.depth_runs.where('exchange_run_id = ?', erun.id).first
            render :json => { :exchange => e.name, :market => "#{m1.from_currency}:#{m1.to_currency}",
                              :date => erun.created_at,
                              :ask => {:price => run1.best_offer.price,
                                       :currency => m1.from_currency,
                                       :quantity => run1.best_offer.quantity},
                              :bid => {:price => run2.best_offer.price,
                                       :quantity => run2.best_offer.quantity}}
         else
          render :json => { :err => "Time unavailable"}
         end
       else
        render :json => { :err => "Bad market"}
       end
     else
      render :json => { :err => "Bad exchange"}
     end
   else
    render :json => { :err => "Bad time"}
   end
  end
end
