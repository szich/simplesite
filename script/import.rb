# To use this script
# 1) Place this file in the RAILS_ROOT/script directory.
# 2) Place the epcp_database.csv file in the same directory.
# 3) Open the terminal in the script directory (if you haven't already)
# 4) Run it using: ./runner -e production 'load "./import.rb"'

require 'rubygems'
require 'faster_csv'
require 'digest/sha1'

# mock for testing
# class User
#   attr_accessor :is_donor, :is_business, :login, :password, :business_name, :notes, :contact_person, :address, :city, :state, :zip, :phone_primary, :fax_primary, :relationship_to_school, :website, :contact_person, :contact_person_title, :email_primary, :fax
#   def User.transaction() yield end
#   def save() true end  
# end

unknown_disciplne = Discipline.find_by_name('Unknown')

def make_login(strings)
  new_login = []
  strings.each do |s| 
    next unless s;
    new_login << s.gsub('.', '').gsub(' ', '')
  end
  new_login.join('.').downcase  
end

def make_password(length=7, key="abcedfghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ123456789")
  pass =  "*" * length 
  srand = Time.now.to_i 
  length.times {|i| pass[i] = key[rand(key.length)]}
  return pass
end

# Main entry point
User.transaction do
  count = 1
  FasterCSV.foreach('epcp_database.csv', {:headers => true, :header_converters => :symbol } ) do |row|
    count = count + 1
    
    user = User.new
    user.first_name = row[:firstname]
    user.last_name = row[:lastname]
    user.job_title = row[:jobtitle]
    user.business_name = row[:company]
    user.business_address = row[:address1].to_s
    user.business_address2 = row[:address2].to_s
    user.business_city = row[:city]
    user.business_state = row[:state]
    user.business_zip = row[:zip]
    user.phone = row[:phone]
    user.business_fax = row[:fax]
    user.email = row[:email]
    user.member_since = row[:membershipyear]
    
    user.login = make_login([user.first_name, user.last_name]) #  user.first_name.downcase + '.' + user.last_name.downcase
    user.password = make_password
    user.password_confirmation = user.password
    
    d = Discipline.find_by_name(row[:category])
    user.discipline = d ? d : unknown_disciplne
    
    user.is_active = 1
    user.can_manage_content = 0
    user.can_manage_users = 0
    user.show_personal_info = 0    
    
    if user.save
      puts "#{count},#{user.id},#{user.first_name},#{user.last_name},#{user.email},#{user.login},#{user.password}"
    else
      raise(ScriptError, "Could not save '#{user.first_name} #{user.last_name}' row #{count}, errors #{user.errors.each do |err| puts err end} rolling back ENTIRE import.")
    end
  end
end # transaction


# raw csv col names:
#LastName,FirstName,Category,JobTitle,Company,Address1,Address2,City,State,ZIP,Phone,Fax,EMail,OSB,WSB,CFP,MembershipYear