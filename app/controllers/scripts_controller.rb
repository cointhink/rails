class ScriptsController < ApplicationController
  before_filter :require_login, :except => [:lastrun, :leaderboard, :docs]

  def manage
    @scripts = current_user.scripts.valid
  end

  def create
    script = Script.safe_create(params)
    script.user = current_user
    script.save
    if script.valid?
      RIEMANN << {service:'cointhink script', tags:['create'],
                  description:"script: #{script.script_name}"}
      script.rethink_insert
    else
      flash[:error] = script.errors.full_messages.join('. ')
    end
    redirect_to :action => :manage
  end

  def leaderboard
    @scripts = Script.valid.enableds.where(docker_status:"running").all
    @rates = {}
    mtgox_price = REDIS.hgetall('mtgox-ticker-BTCUSD')
    @rates["BTCUSD"] = mtgox_price["value"].to_f
    @script_values = @scripts.map{|s| {script:s,
                                       value:s.inventory_value_in("btc", @rates)}
                     }.sort_by! {|s| s[:value]}.reverse
  end

  def lastrun
    @script = Script.find(params[:scriptname])
    if @script
      @run = @script.runs.latest.last
      @signals = @script.last_signals
      @trades = @script.last_trades(5)
    end
  end

  def edit
    @script = current_user.scripts.find(params[:scriptname])
  end

  def update
    @script = current_user.scripts.find(params[:scriptname])
    @script.safe_update(params[:script])
    RIEMANN << {service:'cointhink script', tags:['update'],
                description:"script: #{@script.script_name}"}
    redirect_to :action => :lastrun, :scriptname => @script.slug
  end

  def delete
    @script = current_user.scripts.find(params[:scriptname])
    @script.destroy
    flash[:success]="Script #{@script.name} deleted."
    redirect_to :controller => :scripts, :action => :manage
  end

  def start
    @script = current_user.scripts.find(params[:scriptname])
    if @script.enabled?
      @script.start!
      RIEMANN << {service:'cointhink script', tags:['start'],
                  description:"script: #{@script.script_name}"}
      flash[:success] = "Script "+@script.script_name+" started"
      redirect_to :action => :lastrun
    else
      redirect_to :action => :showenable
    end
  end

  def stop
    @script = current_user.scripts.find(params[:scriptname])
    @script.stop!
    redirect_to :action => :lastrun
  end

  def reset
    @script = current_user.scripts.find(params[:scriptname])
    @script.reset!
    redirect_to :action => :lastrun
  end

  def showenable
    @script = current_user.scripts.find(params[:scriptname])
  end

  def enable
    @script = current_user.scripts.find(params[:scriptname])
    if params[:button] == 'cancel'
      flash[:notice] = "Action cancelled."
      redirect_to :action => :lastrun
    end

    if params[:button] == 'enable'
      price = @script.price
      if current_user.balance('btc') > price
        purchase = current_user.purchases.create({amount: price,
                                                  purchasable: @script})
        @script.add_time(1.week)
        flash[:notice] = "Script enabled until #{@script.enabled_until}. Press start to begin."
      else
        flash[:error] = 'A balance of 0.01 credits is necessary before starting this script'
      end
      redirect_to :action => :lastrun
    end
  end
end
