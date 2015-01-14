class BlogController < ApplicationController
  def index
    @posts = Blogpost.all
  end

  def show
    @post = Blogpost.where(slug:params[:slug])
  end
end
