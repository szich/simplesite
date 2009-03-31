class Resource < ActiveRecord::Base
  belongs_to :event
  upload_column :local_uri  
  validates_presence_of :name
  
  # returns the uri of the resource (be it local or remote )
  def uri
    local_uri ? local_uri.url : remote_uri
  end
  
  def validate
    self.errors.add "Please enter a link or select a file.", "" unless uri and uri != ''
  end
   
end
