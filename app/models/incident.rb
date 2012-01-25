class Incident < ActiveRecord::Base
  belongs_to :group
  has_many :incident_events

  attr_accessor :events_added_count, :events_rejected_count

  validates_presence_of :incident_name

  def events_added_count
    @events_added_count.blank? ? 0 : @events_added_count
  end

  def events_rejected_count
    @events_rejected_count.blank? ? 0 : @events_rejected_count
  end

  def status_class
    return 'ok'   if self.status.downcase == 'resolved'
    return 'warn' if self.status.downcase == 'suspicious'
    'error'
  end
end
