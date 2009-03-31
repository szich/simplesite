class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :name, :string
      t.column :body, :text
      t.column :created_by, :int
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :pages
  end
end
