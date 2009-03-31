class AddDefaultPages < ActiveRecord::Migration
  @page_names = ['Contact Us', 'Terms Of Use', 'Privacy Policy']
  
  def self.up
    @page_names.each do |name|
      Page.new(:name => name, :body => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.').save
    end
  end

  def self.down
    @page_names.each do |name|
      p = Page.find_by_name(name)
      p.destroy if p
    end
  end
end
