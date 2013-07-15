class ScriptsController < ApplicationController
	before_filter :require_login, :except => [:lastrun, :leaderboard]

	def manage
    @scripts = current_user.scripts.valid
	end

	def create
    script = Script.safe_create(params)
    script.user = current_user
    script.save
    if script.valid?
      script.rethink_insert
    else
      flash[:error] = script.errors.full_messages.join('. ')
    end
    redirect_to :action => :manage
	end

  def leaderboard
    @scripts = Script.all
    @scripts.sort! {|a,b| b.inventory["btc"] <=> a.inventory["btc"]}
  end

  def lastrun
    @script = Script.find(params[:scriptname])
    if @script
      @run = @script.runs.latest.last
      @signals = r.db('cointhink').
        table('signals').
        get_all(@script.script_name, {index:'name'}).
        order_by(r.desc('time')).
        limit(8).
        run(R)
    end
  end

  def edit
    @script = current_user.scripts.find(params[:scriptname])
  end

  def update
    @script = current_user.scripts.find(params[:scriptname])
    @script.safe_update(params[:script])
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
    @script.start!
    redirect_to :action => :lastrun
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

end
