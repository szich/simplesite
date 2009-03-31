class ExtendingPermissions < ActiveRecord::Migration
  def self.up
    rename_column :users, :is_admin, :can_manage_content
    add_column :users, :can_manage_users, :boolean, :default => 0
  end

  def self.down
    rename_column :users, :can_manage_content, :is_admin
    remove_column :users, :can_manage_users
  end
end
