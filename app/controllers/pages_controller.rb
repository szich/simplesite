class PagesController < ApplicationController
  before_filter :can_manage_content_required, :except => [:index, :show, :seminar_files]
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.find(:all)
    @events = Event.find(:all, :order => 'held_on', :limit => 5)
    @news_items = NewsItem.find(:all, :order => 'updated_at desc', :limit => 5)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @pages.to_xml }
    end
  end
  
  def seminar_files
    session[:can_see_seminar_files] = true if request.post? && params[:login] && (params[:login][:password].downcase == 'changeme!')    
    @allowed = session[:can_see_seminar_files]
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @page.to_xml }
    end
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1;edit
  def edit
    @page = Page.find(params[:id])
    store_previous_location( page_url(@page) )
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        flash[:alert_good] = 'Page was successfully created.'
        format.html { redirect_to page_url(@page) }
        format.xml  { head :created, :location => page_url(@page) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_back_or_default( page_url(@page) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.xml  { head :ok }
    end
  end
end
