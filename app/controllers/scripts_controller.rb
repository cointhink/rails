class ScriptsController < ApplicationController
	before_filter :require_login

	def list
    @scripts = current_user.scripts.valid
	end

	def create
    script = Script.safe_create(params)
    script.user = current_user
    script.save
    unless script.valid?
      flash[:error] = script.errors.full_messages.join('. ')
    end
    redirect_to :action => :list
	end

  def lastrun
    @script = Script.find(params[:scriptname])
    if @script
      @run = @script.runs.latest.last
    end
  end

  def edit
    @script = Script.find(params[:scriptname])
  end

  def delete
    @script = Script.find(params[:scriptname])
    if @script
      @script.destroy
      flash[:success]="Script #{@script.name} deleted."
    end
    redirect_to :controller => :scripts, :action => :list
  end
end
