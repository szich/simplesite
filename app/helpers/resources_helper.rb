module ResourcesHelper
  
  def format_name_col(resource)
    uri = resource.local_uri ? resource.local_uri.url : resource.remote_uri
    link_to(resource.name, uri)
  end
  
  def format_event_col(resource)
    resource.event ? link_to(resource.event.name, event_path(resource.event)) : 'none'
  end
end
