class CreateUsersEvents < ActiveRecord::Migration
  def self.up
    create_table :events_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :event_id, :integer
    end
  end

  def self.down
    drop_table :users_events
  end
end
