class ScriptsController < ApplicationController
	before_filter :require_login

	def list
    @scripts = current_user.scripts		
	end

	def create
		
	end
end
