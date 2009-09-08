# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def display_snippet(name)
    page = Page.find_by_name(name)
    
    return unless page
    
    <<-"end_module_eval"
    <div id="#{page.name}_snippet" class="snippet">
      #{page.body}<br />
      #{link_to('edit', edit_page_path(page)) if can_manage_content? }
    </div>
    
    end_module_eval
  end
  
  def url_to_previous_page(default = "/")
    session[:return_to] ? session[:return_to] : default
  end
  
  def current_user_attending?(event)
    Attendee.find_by_event_id_and_user_id(event.id, current_user.id)
  end
  
  def display_attending_status(event)
    attendance = current_user_attending?(event)
    
    if attendance == nil
      "You have yet to decied if you are going to attend this event."
    elsif attendance.attending? == true
      "You are attending this event."
    elsif attendance.attending? == false
      "You are not attending this event."
    end    
  end
  
end
