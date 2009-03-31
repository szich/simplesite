class CreateDisciplines < ActiveRecord::Migration
  def self.up
    create_table :disciplines do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    add_column :users, :discipline_id, :integer
    
    Discipline.new(:name => 'Additional').save
    Discipline.new(:name => 'Associate').save
    Discipline.new(:name => 'Attorney').save
    Discipline.new(:name => 'CFP').save
    Discipline.new(:name => 'CPA').save
    Discipline.new(:name => 'Emeritus').save
    Discipline.new(:name => 'Insurance').save
    Discipline.new(:name => 'Trust').save
    Discipline.new(:name => 'Unknown').save    
    
  end

  def self.down
    drop_table :disciplines
    remove_column :users, :discipline_id
  end
end
