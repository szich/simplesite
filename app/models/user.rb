require 'digest/sha1'
require 'vpim/vcard'

class User < ActiveRecord::Base
  has_and_belongs_to_many :events
  belongs_to :discipline
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password
  
  def full_name
    "#{first_name} #{last_name}"
  end  
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) && u.is_active ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def self.find_all_active_users
    User.find(:all, :conditions => 'is_active = 1', :order => 'first_name, last_name')
  end
  
  def find_my_upcoming_events
    events.find(:all, :conditions => "held_on >= '#{Date.today}'", :order => 'held_on')
  end
  
  def find_my_past_events
    events.find(:all, :conditions => "held_on < '#{Date.today}'", :order => 'held_on')
  end
  
  def generate_vcard
    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.given = first_name if first_name && first_name != ''
        name.family = last_name if last_name && last_name != ''
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.location = 'work'
        addr.street = business_address if business_address && business_address != ''
        addr.extended = business_address2 if business_address2 && business_address2 != ''
        addr.locality = business_city if business_city && business_city != ''
        addr.region = business_state if business_state && business_state != ''
        addr.postalcode = business_zip if business_zip && business_zip != ''
      end

      maker.add_tel(phone) { |t| t.location = 'work'; t.preferred = true } if phone && phone != ''
      maker.add_tel(phone_secondary) { |t| t.location = 'secondary'; t.preferred = false } if phone_secondary && phone_secondary != ''

      maker.add_email(email) { |e| e.location = 'work'; e.preferred = true } if email != ''
      maker.add_email(email_secondary) { |e| e.location = 'secondary'; e.preferred = false } if email_secondary && email_secondary != ''

    end
    
    return card
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    
end
