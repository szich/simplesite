class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.column :user_id, :int
      t.column :event_id, :int
      t.column :name, :string
      t.column :local_uri, :string
      t.column :remote_uri, :text
      t.column :description, :text
      t.column :view_count, :int
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :resources
  end
end
