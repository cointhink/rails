class ScriptsController < ApplicationController
	before_filter :require_login

	def list
    @scripts = current_user.scripts
	end

	def create
    script = Script.safe_create(params)
    script.user = current_user
    script.save
    unless script.valid?
      flash[:error] = "Script creation failed"
    end
    redirect_to :action => :list
	end

  def edit
    @script = Script.find(params[:id])
  end
end
