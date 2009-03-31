# plugin init file for rails
# this file will be picked up by rails automatically and
# add the file_column extensions to rails

require 'remote_upload'
require 'remote_upload_helper'

ActionView::Base.send(:include, RemoteUploadHelper)
ActionView::Helpers::AssetTagHelper.send(:register_javascript_include_default, 'remote_upload')
ActionController::Base.send(:include, RemoteUpload)