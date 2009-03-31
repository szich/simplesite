# Include hook code here
ActionController::Base.send(:include, DataGrid)
ActionView::Base.send :include, DataGrid

# copy supporting files over to the rails app.
def copy_files_without_overwriting(source, dest)
  files = Dir.glob(source+'*.*')
  files.each {|f| FileUtils.cp(f, dest) unless File.exists?(dest + File.basename(f)) }  
end

directories = ['/public/stylesheets/', '/public/images/']
directories.each {|dir| copy_files_without_overwriting(File.join(directory, dir), RAILS_ROOT + dir) }

# fix the csv rendering bug.
source = RAILS_ROOT  + '/config/environment.rb'
mime_csv = "Mime::SET << Mime::CSV unless Mime::SET.include?(Mime::CSV)"
File.open(source, 'a') { |f| f << "\n#{mime_csv}\n" } unless File.read(source).include?(mime_csv)