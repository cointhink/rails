class BlogController < ApplicationController
  def index
    if logged_in? && current_user.acl_flags.where({name:"blog"}).any?
      @posts = Blogpost.all
    else
      @posts = Blogpost.where(published:true).all
    end
  end

  def show
    @blogpost = Blogpost.where(slug:params[:slug]).first
    unless @blogpost
      flash[:error] = "Sorry, that blog post does not exist"
      redirect_to :root
    end
  end

  def edit
    if logged_in? && current_user.acl_flags.where({name:"blog"}).any?
      @post = Blogpost.find_by_slug(params[:slug]) || Blogpost.new
    else
      redirect_to :root
    end
  end

  def create
    if logged_in? && current_user.acl_flags.where({name:"blog"}).any?
      if params[:slug]
        post = Blogpost.find_by_slug(params[:slug])
        post.title = params[:title]
        post.body = params[:body]
        post.save
        flash[:alert] = "updated #{post.title}"
        redirect_to "/blog/#{post.slug}"
      else
        post = Blogpost.create({title:params[:title], body:params[:body]})
        redirect_to "/blog/#{post.slug}"
      end
    else
      redirect_to :root
    end
  end
end
