class AddSpeakersToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :speakers, :text
  end

  def self.down
    remove_column :events, :speakers
  end
end
