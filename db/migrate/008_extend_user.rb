class ExtendUser < ActiveRecord::Migration
  def self.up
    add_column :users, :website, :string
    add_column :users, :im, :string
    add_column :users, :im_secondary, :string
    add_column :users, :business_fax, :string
    add_column :users, :personal_fax, :string
    add_column :users, :send_emails, :boolean
    add_column :users, :is_admin, :boolean
    add_column :users, :member_since, :datetime
  end

  def self.down
    remove_column :users, :website
    remove_column :users, :im
    remove_column :users, :im_secondary
    remove_column :users, :business_fax
    remove_column :users, :personal_fax
    remove_column :users, :send_emails
    remove_column :users, :is_admin
    remove_column :users, :member_since
  end
end