class NewsItemsController < ApplicationController
  before_filter :login_required
  before_filter :can_manage_content_required, :except => [:index, :show]
  
  # GET /news_items
  # GET /news_items.xml
  def index
    @news_items = NewsItem.find(:all, :order => 'updated_at desc')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @news_items.to_xml }
    end
  end

  # GET /news_items/1
  # GET /news_items/1.xml
  def show
    @news_item = NewsItem.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @news_item.to_xml }
    end
  end

  # GET /news_items/new
  def new
    @news_item = NewsItem.new
  end

  # GET /news_items/1;edit
  def edit
    @news_item = NewsItem.find(params[:id])
  end

  # POST /news_items
  # POST /news_items.xml
  def create
    @news_item = NewsItem.new(params[:news_item])
    @news_item.created_by = current_user

    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'NewsItem was successfully created.'
        format.html { redirect_to news_item_url(@news_item) }
        format.xml  { head :created, :location => news_item_url(@news_item) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors.to_xml }
      end
    end
  end

  # PUT /news_items/1
  # PUT /news_items/1.xml
  def update
    @news_item = NewsItem.find(params[:id])
    @news_item.created_by = current_user

    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = 'NewsItem was successfully updated.'
        format.html { redirect_to news_item_url(@news_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors.to_xml }
      end
    end
  end

  # DELETE /news_items/1
  # DELETE /news_items/1.xml
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy

    respond_to do |format|
      format.html { redirect_to news_items_url }
      format.xml  { head :ok }
    end
  end
end
