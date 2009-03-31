require 'vpim/icalendar'

class Event < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :resources
  
  validates_presence_of :name, :location, :held_on, :description
  
  def full_address
    "#{address} #{city}, #{state} #{zip}"
  end
    
  def users_not_attending
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
