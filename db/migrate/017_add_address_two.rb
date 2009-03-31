class AddAddressTwo < ActiveRecord::Migration
  def self.up
    add_column :users, :business_address2, :string
  end

  def self.down
    remove_column :users, :business_address2
  end
end
