class BlogController < ApplicationController
  layout "application_blank"

  def index
    @post = Post.where("published_date <= ?", Time.zone.now).order("published_date desc").first 
  end
end
