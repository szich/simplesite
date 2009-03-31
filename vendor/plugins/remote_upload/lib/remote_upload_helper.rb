module RemoteUploadHelper
  # Returns a form tag that will submit through a hidden iFrame in the
  # background instead of the regular reloading POST arrangement. Even
  # though it's using JavaScript to serialize the form elements, the form
  # submission will work just like a regular submission as viewed by the
  # receiving side (all elements available in @params). The options for
  # specifying the target with :url and defining callbacks is the same as
  # link_to_remote.
  #
  # A "fall-through" target for browsers that doesn't do JavaScript can be
  # specified with the :action/:method options on :html.
  #
  # Example:
  #   form_remote_upload_tag :html => { :action =>
  #     url_for(:controller => "some", :action => "place") }
  #
  # The Hash passed to the :html key is equivalent to the options (2nd)
  # argument in the FormTagHelper.form_tag method.
  #
  # By default the fall-through action is the same as the one specified in
  # the :url (and the default method is :post).
  #
  def form_remote_upload_tag(options = {})
    options[:html] ||= {}
    options[:html][:id] = options[:html][:id] || 'remote_upload_form' #this needs to generate a unique ID
    options[:html][:action] = options[:html][:action] || url_for(options[:url])

    tag('form', options[:html], true) + 
    remote_upload_function(options[:html][:id], options) + 
    hidden_field_tag("remote_upload", "yes")
  end

private
  def remote_upload_function(form_id, options)
    javascript_options = options_for_remote_upload(options)

    update = ''
    if options[:update] and options[:update].is_a?(Hash)
      update  = []
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ? 
      "new RemoteUpload.Request(" :
      "new RemoteUpload.Updater(#{update}, "
    function << "'#{form_id}', #{javascript_options})"

    javascript_tag(function)
  end

  def options_for_remote_upload(options)
    js_options = build_callbacks(options)
    
    js_options[:insertion]    = "Insertion.#{options[:position].to_s.camelize}" if options[:position]
    js_options[:evalScripts]  = options[:script].nil? || options[:script]

    options_for_javascript(js_options)
  end
  
end
