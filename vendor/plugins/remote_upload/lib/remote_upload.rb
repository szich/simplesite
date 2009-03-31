module RemoteUpload #:nodoc:
  def self.append_features(base) #:nodoc:
   super
   base.extend ClassMethods
  end
  
  # == Remote Upload
  #
  # The remote upload plugin allows "ajax" style remote file uploads. The concept was
  # take from a Drupal module. 
  #
  # You will need to copy the <tt>remote_upload.js</tt> from the plugin's javascript
  # directory to <tt>public/javascripts</tt>. The plugin will add <tt>remote_upload</tt> to 
  # the default scripts loaded by <tt>javascript_include_tag :defaults</tt>.
  #
  module ClassMethods

    # Creates an +after_filter+ which will call +finish_remote_upload+.
    #
    def remote_upload_for(*actions)
      before_filter :start_remote_upload
      if actions.flatten.first == :all
        after_filter :finish_remote_upload
      else
        after_filter :finish_remote_upload, :only => actions
      end
    end
  end

  # Pretend to be a Prototype AJAX request.
  def start_remote_upload
    self.request.env['HTTP_X_REQUESTED_WITH'] = "XMLHttpRequest"  unless params[:remote_upload].blank?
  end

  # Wraps the output in a div container. Then calls back to the handler in the parent window
  # sending along a status code and the output.
  #
  def finish_remote_upload
    unless params[:remote_upload].blank?
      status = response.headers['Status'][0..2]
      content_type, response.headers['Content-Type'] = response.headers['Content-Type'], 'text/plain'

      template = "#{status}<remote_upload:split>#{content_type}<remote_upload:split>#{response.body}"

      erase_results
      render :inline => template, :status => status, :layout => false
    end
  end
end
