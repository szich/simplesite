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
	  current_user.events.include?(event)
  end
end
