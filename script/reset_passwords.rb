# To use this script
# 1) Place this file in the RAILS_ROOT/script directory.
# 2) Place the epcp_database.csv file in the same directory.
# 3) Open the terminal in the script directory (if you haven't already)
# 4) Run it using: ./runner -e production 'load "./reset_passwords.rb"'

require 'rubygems'
require 'faster_csv'

def make_password(length=7, key="abcedfghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ123456789")
  pass =  "*" * length 
  srand = Time.now.to_i 
  length.times {|i| pass[i] = key[rand(key.length)]}
  return pass
end

# Main entry point
User.transaction do
  FasterCSV.open("./user_list.csv", "w+") do |csv|
    csv << ["first_name","last_name","login","password"]  

    User.find(:all).each do |u|
      password = make_password
      u.password = password
      u.password_confirmation = password
      u.save
      csv << [u.first_name, u.last_name, u.login, password]
    end
    
  end #csv
end # transaction