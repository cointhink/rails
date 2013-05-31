class ScriptsController < ApplicationController
	before_filter :require_login

	def list
    @scripts = current_user.scripts
	end

	def create
    script = Script.safe_create(params)
    unless script.valid?
      flash[:error] = "Script creation failed"
    end
    redirect_to :list
	end
end
