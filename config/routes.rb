ActionController::Routing::Routes.draw do |map|
  map.resources :resources, :new => {:nolayout => :get}
  map.resources :events, :member => {:signup => :post, :regrets => :post, :generate_ical => :get}
  map.resources :my_account, :collection => {:edit_password => :get, :update_password => :post}
  map.resources :users, :pages, :member => {:generate_vcard => :get}
  map.resources :security, :news_items

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  map.connect 'seminar_files', :controller => 'pages', :action => 'seminar_files'
  map.connect 'seminar_files_2011', :controller => 'pages', :action => 'seminar_files_2011'

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "pages" #, :action => "new"

  # This is a wild card path.  In our case it performs a search
  # for a page with the name passed in the url.
  map.connect '*path', :controller => 'redirect', :action => 'index'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  # map.connect ':controller/:action/:id.:format'
  # map.connect ':controller/:action/:id'
end
