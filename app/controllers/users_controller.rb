class UsersController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :generate_vcard]
  before_filter :can_manage_users_required, :except => [:index, :show, :generate_vcard]
  
  # generated code from the data_grid plugin
  def index     
     # set the default value for the clear button           
     params[:clear] = "" unless params[:clear]
     params[:sort] = "last_name_asc" unless params[:sort]
     #params[:filter] = {} unless params[:filter]
     
     # save the model names for use by the views (filter & sort)
     @plural_model_name = 'users'
     @model_name = 'user'
     @act_restful = true
         
     # sanatize the display param.
     params[:display] = sanitize_display(params[:display])

     # sanatize the sort params
     @sort_col, @sort_dir, model_name, @orig_col_name = sanitize_sort(params[:sort], '', @plural_model_name)
     
     # sanatize the filter params
     params[:filter] = nil if params[:clear].downcase == "clear" # if the user clicked on the 'clear' toss the filter params to the bit bucket.
     conditions = HashWithIndifferentAccess.new
     conditions.merge!(logged_in? ? {:is_active => 1} : {:show_personal_info => 1, :is_active => 1}) # the built in filter.
     conditions = params[:filter].merge!(conditions) if params[:filter]
          
     @filter = sanitize_filter(conditions)
     
     # create the params for the find method
     find_params = {:per_page => params[:display].to_i}
     
     # we need to remove the single quotes so the order works with included tables.
     # because rails alises all of the columns to generated names i.e. t0_r0, t0_r1
     find_params.merge!({:order => ActiveRecord::Base.send(:sanitize_sql, [" #{model_name}.? #{@sort_dir}", @sort_col]).delete("'")}) if @sort_col
     find_params.merge!({:conditions => @filter}) if @filter
     find_params.merge!({:include => :discipline })

     # do the search
     @user_pages, @user_data = paginate :users, find_params
     
     # take care of rendeing if the user wants us to.
     respond_to do |format|
       format.html  # index.rhtml
       format.xml   { render :xml => @user_data.to_xml }
       format.text  { render :text => data_text(false) }
       format.csv   { render :text => data_text }
     end                 
   end

   def list_text    
     headers['Content-Type'] = "text/plain"
     render :text => data_text(false)
   end

   def list_csv
     headers['Content-Type'] = "application/vnd.ms-excel" 
     headers['Content-Disposition'] = 'attachment; filename="data_listing.csv"'
     headers['Cache-Control'] = nil
     render :text => data_text
   end
  
  # render new.rhtml
  def new
    @user = User.new
    @user.business_city = "Portland"
    @user.business_state = "OR"
    #@disciplines = Discipline.find(:all)
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    #self.current_user = @user
    #redirect_back_or_default('/')
    #flash[:alert_good] = "Thanks for signing up!"
    flash[:alert_good] = 'User was successfully created.'
    redirect_to users_url #user_url(@user)
    
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = User.find(params[:id])
    #@disciplines = Discipline.find(:all)
  end  
  
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end    
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end  
  
  def generate_vcard
    u = User.find(params[:id])
    vcard = u.generate_vcard
    send_data vcard.to_s, :type => 'text/x-vcard', :filename => "#{u.full_name}.vcf"
  end

end