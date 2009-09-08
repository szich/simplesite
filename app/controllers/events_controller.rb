class EventsController < ApplicationController
  before_filter :login_required
  before_filter :can_manage_content_required, :except => [:index, :show, :generate_ical, :signup, :regrets]
    
  data_grid_scaffold :event, :act_restful => true , :default_sort_col => 'held_on'

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @event.to_xml }
    end
  end

  # GET /events/new
  def new
    @event = Event.new
    @event.city = "Portland"
    @event.state = "OR"
  end

  # GET /events/1;edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.users << User.find(params['add_to_event']) if params['add_to_event']

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to event_url(@event) }
        format.xml  { head :created, :location => event_url(@event) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors.to_xml }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    @event.users.clear
    @event.users << User.find(params['add_to_event']) if params['add_to_event']
    
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to event_url(@event) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors.to_xml }
      end
    end
  end
  
  def signup
    event = Event.find(params[:id])
    Attendee.attend_event(event, current_user)
    
    flash[:alert_good] = "You sucessfully signed up to attend this event."
    redirect_to event_url(event)
  end

  def regrets
    event = Event.find(params[:id])
    Attendee.cant_attend_event(event, current_user)  
    
    flash[:alert_good] = "You are no longer signed up to attend this event."
    redirect_to event_url(event)
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.xml  { head :ok }
    end
  end
  
  def generate_ical
    e = Event.find(params[:id])
    ical = e.generate_ical
    send_data ical.to_s, :type => 'text/calendar', :filename => "#{e.name}.ics"
  end
  
end
