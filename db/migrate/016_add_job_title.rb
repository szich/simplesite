class AddJobTitle < ActiveRecord::Migration
  def self.up
    add_column :users, :job_title, :string
  end

  def self.down
    remove_column :users, :job_title
  end
end
