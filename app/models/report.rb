class Report < ActiveRecord::Base
  belongs_to :user
  has_many :pdfs, dependent: :destroy

  serialize :report_criteria, ActiveSupport::HashWithIndifferentAccess

  # virtual attributes ... these allow us to create/update the NotificationCriteria
  #                        object in the notify_criteria column:
  # attr_accessible :priority_ids, :minimum_matches, :attacker_ips, :target_ips
  attr_accessor :sig_priority, :sig_id, :source_address, :source_port, :destination_address, :destination_port, :sensor_id, :timestamp_gte, :timestamp_lte
  # validates :notify_criteria_as_string, uniqueness: {scope: :user_id, message: "you already have a Notification with the same criteria!"}

  validates :name, presence: true
end
