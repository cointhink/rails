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
    redirect_to :action => :list
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
    @script = Script.find(params[:scriptname])
  end

  def update
    @script = Script.find(params[:scriptname])
    @script.safe_update(params[:script])
    redirect_to :action => :lastrun, :scriptname => @script.slug
  end

  def delete
    @script = Script.find(params[:scriptname])
    if @script
      @script.destroy
      flash[:success]="Script #{@script.name} deleted."
    end
    redirect_to :controller => :scripts, :action => :list
  end

  def start
    @script = Script.find(params[:scriptname])
    if @script
      if owner_check(@script)
        @script.start!
      else
        flash[:error] = "No permission to start this script."
      end
    end
    redirect_to :action => :lastrun
  end

  def stop
    @script = Script.find(params[:scriptname])
    if @script
      @script.stop!
    end
    redirect_to :action => :lastrun
  end

  def reset
    @script = Script.find(params[:scriptname])
    if @script
      if owner_check(@script)
        @script.reset!
      else
        flash[:error] = "No permission to reset this script."
      end
    end
    redirect_to :action => :lastrun
  end

  private
  def owner_check(script)
    script.user == current_user
  end
end
