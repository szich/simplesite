class Attendee < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  
  def self.attend_event(event, user)
    attendance = Attendee.find_or_create_by_user_id_and_event_id(user.id, event.id)
    attendance.update_attribute :attending, true
  end
  
  def self.cant_attend_event(event, user)
    attendance = Attendee.find_or_create_by_user_id_and_event_id(user.id, event.id)
    attendance.update_attribute :attending, false
  end  
end