class RedirectController < ApplicationController
  def index
    page = Page.find_by_name(params[:path].first)
    page ? redirect_to(page_path(page)) : redirect_to('/')
  end  
end
