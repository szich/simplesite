class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :name, :string
      t.column :held_on, :datetime
      t.column :address, :string
      t.column :city, :string
      t.column :state, :string
      t.column :zip, :string
      t.column :location, :string
      t.column :description, :text
      t.column :type_id, :int
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :events
  end
end
