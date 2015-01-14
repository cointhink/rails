class BlogController < ApplicationController
  def index
    @posts = Blogpost.all
  end

  def show
    @blogpost = Blogpost.where(slug:params[:slug]).first
    unless @blogpost
      flash[:error] = "Sorry, that blog post does not exist"
      redirect_to :root
    end
  end
end
