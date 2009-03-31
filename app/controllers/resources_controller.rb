class ResourcesController < ApplicationController
  before_filter :login_required
  before_filter :can_manage_content_required, :except => [:index, :show]
  
  data_grid_scaffold :resource, :act_restful => true, :default_sort_col => :view_count #, :include => [:event] #country, :division, :citation]

  # # GET /resources
  # # GET /resources.xml
  # def index
  #   @resources = Resource.find(:all)
  # 
  #   respond_to do |format|
  #     format.html # index.rhtml
  #     format.xml  { render :xml => @resources.to_xml }
  #   end
  # end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @resource.to_xml }
    end
  end

  # GET /resources/new
  def new
    @resource = Resource.new
    @resource.event_id = params[:event_id]
    store_previous_location( resources_url )
    
    render :layout => false if params[:nolayout]    
  end
  
  def nolayout
    @resource = Resource.new
    @resource.event_id = params[:event_id]
    render :layout => false #'blank'
  end
  

  # GET /resources/1;edit
  def edit
    @resource = Resource.find(params[:id])
    store_previous_location( resource_url(@resource) )
  end

  # POST /resources
  # POST /resources.xml
  def create
    @resource = Resource.new(params[:resource])

    respond_to do |format|
      logger.debug "\nformat is #{format.html}\n"
      if @resource.save
        flash[:notice] = 'Resource was successfully created.'
        format.html { redirect_back_or_default( resource_url(@resource) ) }
        format.xml  { head :created, :location => resource_url(@resource) }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors.to_xml }
        format.js  { render :action => "nolayout" }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource was successfully updated.'
        format.html { redirect_back_or_default( resource_url(@resource) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors.to_xml }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.xml  { head :ok }
    end
  end
end
