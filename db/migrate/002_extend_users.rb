class ExtendUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :business_name, :string
    add_column :users, :business_address, :string
    add_column :users, :business_city, :string
    add_column :users, :business_state, :string
    add_column :users, :business_zip, :string
    add_column :users, :personal_address, :string
    add_column :users, :personal_city, :string
    add_column :users, :personal_state, :string
    add_column :users, :personal_zip, :string
    add_column :users, :member_type_id, :integer
    add_column :users, :phone, :string
    add_column :users, :phone_secondary, :string
    add_column :users, :email_secondary, :string
    add_column :users, :role_id, :integer
    add_column :users, :is_active, :boolean
    add_column :users, :prefered_contact_method, :string
    add_column :users, :show_personal_info, :boolean
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :business_name    
    remove_column :users, :business_address
    remove_column :users, :business_city
    remove_column :users, :business_state
    remove_column :users, :business_zip
    remove_column :users, :personal_address
    remove_column :users, :personal_city
    remove_column :users, :personal_state
    remove_column :users, :personal_zip
    remove_column :users, :member_type_id
    remove_column :users, :phone
    remove_column :users, :phone_secondary
    remove_column :users, :email_secondary
    remove_column :users, :role_id
    remove_column :users, :is_active
    remove_column :users, :prefered_contact_method
    remove_column :users, :show_personal_info
  end
end
