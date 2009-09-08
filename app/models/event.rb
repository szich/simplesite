require 'vpim/icalendar'

class Event < ActiveRecord::Base
  has_many :attendees
  has_many :users, :through => :attendees
  has_many :resources
  
  validates_presence_of :name, :location, :held_on, :description
  
  def full_address
    "#{address} #{city}, #{state} #{zip}"
  end
  
  def users_attending
    self.users.find(:all, :conditions => 'attending = 1')
  end
    
  def users_not_attending
    self.users.find(:all, :conditions => 'attending = 0')
  end
  
  def undecided_users
    User.find_all_active_users - self.users
  end
  
  def generate_ical
      cal = Vpim::Icalendar.create2

      cal.add_event do |e|
        e.dtstart(held_on)
        e.dtend held_on + 1.hour
        e.summary(name)
        e.description(description)
        e.url("http://www.epcportland.org/events/#{self.id}")
        e.sequence(0)

        now = Time.now
        e.created(now)
        e.lastmod(now)
      end

      cal.encode
  end
  
end
