class SetDefaultActiveState < ActiveRecord::Migration
  def self.up
    remove_column :users, :is_active
    add_column :users, :is_active, :boolean, :default => 1
  end

  def self.down
  end
end
