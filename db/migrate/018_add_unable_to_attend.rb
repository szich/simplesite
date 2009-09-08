class AddUnableToAttend < ActiveRecord::Migration
  def self.up
    add_column :events_users, :attending, :integer, :default => 1
    add_column :events_users, :id, :primary_key
    rename_table :events_users, :attendees
  end

  def self.down
    rename_table :attendees, :events_users
    remove_column :events_users, :attending
    remove_column :events_users, :id    
  end
end
