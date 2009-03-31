class MyAccountController < ApplicationController
  
  def index
    @user = current_user
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:alert_good] = 'Your account was successfully updated.'
        format.html { redirect_to '/my_account' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end
  
  def edit_password
     @user = current_user
  end
  
  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:alert_good] = 'Your login information was successfully updated.'
      redirect_to '/my_account'
    else
      render :action => "edit_password"
    end
  end
  
end
