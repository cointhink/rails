class BlogController < ApplicationController
  def index
    @posts = Blogpost.where(published:true).all
  end

  def show
    @blogpost = Blogpost.where(slug:params[:slug]).first
    unless @blogpost
      flash[:error] = "Sorry, that blog post does not exist"
      redirect_to :root
    end
  end

  def create
    if logged_in?
    end
  end
end
